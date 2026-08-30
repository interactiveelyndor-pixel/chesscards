import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'audio_enums.dart';
import '../services/settings_service.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService(ref)..init();
});

class AudioService {
  final Ref _ref;
  final AudioPlayer _bgmPlayer = AudioPlayer();
  // Map to hold preloaded SFX players for zero-latency playback
  final Map<SfxType, AudioPlayer> _sfxPlayers = {};

  AudioService(this._ref);

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    _bgmPlayer.setLoopMode(LoopMode.one);

    // Pre-initialize SFX players
    for (final sfx in SfxType.values) {
      _sfxPlayers[sfx] = AudioPlayer();
    }
    
    _isInitialized = true;
  }

  // --- Background Music ---

  BgmType? _currentBgmType;

  Future<void> playBgm(BgmType type) async {
    if (_currentBgmType == type) return;
    final settings = _ref.read(settingsServiceProvider);
    if (!settings.musicEnabled) return;

    if (!_isInitialized) await init();

    _currentBgmType = type;
    final assetPath = _getBgmAssetPath(type);
    try {
      await rootBundle.load(assetPath);
      await _bgmPlayer.setAsset(assetPath);
      _bgmPlayer.setVolume(1.0);
      _bgmPlayer.play();
    } catch (e) {
      log('AudioService: BGM asset not found or error playing ($assetPath) - ignoring for now.');
    }
  }

  Future<void> crossfadeBgm(BgmType type) async {
    if (_currentBgmType == type) return;
    final settings = _ref.read(settingsServiceProvider);
    if (!settings.musicEnabled) return;

    if (!_isInitialized) await init();

    // Fade out
    for (double v = 1.0; v >= 0.0; v -= 0.1) {
      if (!_bgmPlayer.playing) break;
      await _bgmPlayer.setVolume(v);
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _currentBgmType = type;
    final assetPath = _getBgmAssetPath(type);
    try {
      await rootBundle.load(assetPath);
      await _bgmPlayer.setAsset(assetPath);
      _bgmPlayer.play();

      // Fade in
      for (double v = 0.0; v <= 1.0; v += 0.1) {
        await _bgmPlayer.setVolume(v);
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      log('AudioService: BGM asset not found or error playing ($assetPath) - ignoring for now.');
    }
  }

  Future<void> stopBgm() async {
    _currentBgmType = null;
    await _bgmPlayer.stop();
  }

  // --- Sound Effects ---

  Future<void> playSfx(SfxType type) async {
    final settings = _ref.read(settingsServiceProvider);
    if (!settings.sfxEnabled) return;

    if (!_isInitialized) await init();

    final assetPath = _getSfxAssetPath(type);
    final player = _sfxPlayers[type];

    if (player != null) {
      try {
        // We only attempt to load if the asset exists to prevent unhandled exceptions 
        // crashing the game when files are missing during development.
        await rootBundle.load(assetPath);
        
        // If it's already playing, restart it. 
        if (player.playing) {
          await player.stop();
        }
        await player.setAsset(assetPath);
        player.play();
      } catch (e) {
        log('AudioService: SFX asset not found or error playing ($assetPath) - ignoring for now.');
      }
    }
  }

  // --- Asset Path Mappings ---

  String _getBgmAssetPath(BgmType type) {
    switch (type) {
      case BgmType.mainMenu:
        return 'assets/audio/bgm/main_menu.mp3';
      case BgmType.inGame:
        return 'assets/audio/bgm/in_game.mp3';
      case BgmType.spookyAmbient:
        return 'assets/audio/bgm/spooky_ambient.mp3';
    }
  }

  String _getSfxAssetPath(SfxType type) {
    switch (type) {
      case SfxType.pieceMove:
        return 'assets/audio/sfx/piece_move.mp3';
      case SfxType.pieceCapture:
        return 'assets/audio/sfx/piece_capture.mp3';
      case SfxType.cardPlay:
        return 'assets/audio/sfx/card_play.mp3';
      case SfxType.cardDraw:
        return 'assets/audio/sfx/card_draw.mp3';
      case SfxType.buttonClick:
        return 'assets/audio/sfx/button_click.mp3';
      case SfxType.check:
        return 'assets/audio/sfx/check.mp3';
      case SfxType.checkmate:
        return 'assets/audio/sfx/checkmate.mp3';
      case SfxType.error:
        return 'assets/audio/sfx/error.mp3';
    }
  }

  void dispose() {
    _bgmPlayer.dispose();
    for (final player in _sfxPlayers.values) {
      player.dispose();
    }
  }
}
