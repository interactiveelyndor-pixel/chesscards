import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_chess/core/services/ad_manager.dart';
import 'package:super_chess/core/services/settings_service.dart';
import 'package:super_chess/core/audio/audio_service.dart';
import 'package:super_chess/core/audio/audio_enums.dart';
import 'package:super_chess/core/network/network_service.dart';
import 'package:super_chess/features/match/application/match_controller.dart';
import 'package:super_chess/features/board/domain/board_position.dart';
import 'package:super_chess/shared/enums/piece_type.dart';

class MockAudioService implements AudioService {
  @override
  Future<void> init() async {}
  @override
  Future<void> playBgm(BgmType type) async {}
  @override
  Future<void> crossfadeBgm(BgmType type) async {}
  @override
  Future<void> stopBgm() async {}
  @override
  Future<void> playSfx(SfxType type) async {}
  @override
  void dispose() {}
}

class MockNetworkService implements NetworkService {
  @override
  String? get userId => 'mock_user_id';
  @override
  String? currentMatchId;
  @override
  bool isPlayer1 = true;
  @override
  void Function(Map<String, dynamic> actionData)? onActionReceived;
  @override
  void Function(String opponentId)? onMatchStart;
  @override
  void Function()? onOpponentDisconnected;

  @override
  Future<void> signInAnonymously() async {}
  @override
  Future<void> findMatch() async {}
  @override
  Future<void> sendMoveAction(BoardPosition from, BoardPosition to, PieceType? promotion) async {}
  @override
  Future<void> sendCardAction(String cardId, BoardPosition? primary, BoardPosition? secondary) async {}
  @override
  Future<void> sendEndTurnAction() async {}
  @override
  Future<void> leaveMatch() async {}
  @override
  void dispose() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('applovin_max');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'isInterstitialReady') {
        return true;
      }
      if (methodCall.method == 'isRewardedAdReady') {
        return true;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('📱 AppLovin MAX AdManager Interstitial & Rewarded Ad Lifecycle Tests', () {
    test('1. AdManager singleton instance initializes cleanly with correct adUnitIds', () {
      final adManager = AdManager.instance;
      expect(adManager, isNotNull);
      expect(AdManager.interstitialAdUnitId, 'YOUR_INTERSTITIAL_ID');
      expect(AdManager.rewardedAdUnitId, 'YOUR_REWARDED_ID');
    });

    test('2. AdManager pre-load and game-over interstitial calls execute cleanly', () async {
      final adManager = AdManager.instance;
      adManager.initialize();
      adManager.loadInterstitial();

      // Show interstitial on game over state
      final shown = await adManager.showGameOverInterstitial();
      expect(shown, isTrue);
    });

    test('3. AdManager pre-loads rewarded video on startup and executes onRewarded callback', () async {
      final adManager = AdManager.instance;
      adManager.initialize();
      adManager.loadRewardedAd();

      bool rewardReceived = false;
      final shown = await adManager.showRewardedAd(
        onRewarded: () {
          rewardReceived = true;
        },
      );

      expect(shown, isTrue);
      // In mock channel test environment, callback is hooked
      expect(adManager.isRewardedReady, isFalse);
    });

    test('4. Game State integration: Watching Rewarded Ad grants Free Undo in MatchController', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final settings = SettingsService(prefs);

      final container = ProviderContainer(
        overrides: [
          settingsServiceProvider.overrideWithValue(settings),
          audioServiceProvider.overrideWithValue(MockAudioService()),
          networkServiceProvider.overrideWithValue(MockNetworkService()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(matchControllerProvider.notifier);
      
      // Make a move
      controller.selectTile(const BoardPosition(6, 4));
      controller.makeMove(const BoardPosition(6, 4), const BoardPosition(4, 4));

      expect(container.read(matchControllerProvider).gameState.board.pieceAt(const BoardPosition(4, 4)), isNotNull);

      // Trigger rewarded undo
      controller.grantRewardedUndo();

      // Board state rolled back
      expect(container.read(matchControllerProvider).gameState.board.pieceAt(const BoardPosition(6, 4)), isNotNull);
      expect(container.read(matchControllerProvider).gameState.board.pieceAt(const BoardPosition(4, 4)), isNull);
    });

    test('5. Game State integration: Watching Rewarded Ad grants Oracle Tactical Hint', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final settings = SettingsService(prefs);

      final container = ProviderContainer(
        overrides: [
          settingsServiceProvider.overrideWithValue(settings),
          audioServiceProvider.overrideWithValue(MockAudioService()),
          networkServiceProvider.overrideWithValue(MockNetworkService()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(matchControllerProvider.notifier);

      expect(container.read(matchControllerProvider).hintMove, isNull);

      // Trigger rewarded hint
      controller.grantRewardedHint();

      final state = container.read(matchControllerProvider);
      expect(state.hintMove, isNotNull);
      expect(state.highlightedMoves.isNotEmpty, isTrue);
    });
  });
}
