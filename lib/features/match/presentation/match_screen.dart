import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_colors.dart';
import '../../dolls/domain/soul_doll_controller.dart';
import '../../dolls/domain/soul_doll.dart';
import '../../dolls/presentation/widgets/soul_doll_widget.dart';
import '../../dolls/presentation/widgets/doll_reaction_banner.dart';
import '../../spells/domain/spell.dart';
import '../../spells/domain/spell_target_type.dart';
import '../../spells/domain/spell_engine.dart';
import '../../spells/presentation/spell_scroll_bar.dart';
import '../../spells/presentation/mana_bar_widget.dart';
import '../../relics/presentation/relic_bag_modal.dart';
import '../../board/presentation/widgets/isometric_board_widget.dart';
import '../../board/presentation/widgets/capture_particle_overlay.dart';
import '../../board/presentation/models/board_tile.dart';
import '../../board/domain/board_position.dart';
import '../../../shared/enums/piece_color.dart';
import '../../../shared/enums/piece_type.dart';
import '../../../../core/audio/audio_service.dart';
import '../../../../core/audio/audio_enums.dart';
import '../../store/application/store_controller.dart';

import '../application/match_controller.dart';
import '../domain/turn_phase.dart';
import 'widgets/end_turn_button.dart';
import 'widgets/health_bar_widget.dart';
import 'widgets/turn_timer_widget.dart';
import 'widgets/action_history_panel.dart';
import 'widgets/check_overlay.dart';
import 'widgets/turn_pass_overlay.dart';
import 'widgets/promotion_overlay.dart';
import 'widgets/action_toast_overlay.dart';
import 'widgets/damage_number_overlay.dart';
import 'widgets/match_summary_overlay.dart';
import 'widgets/pause_menu_overlay.dart';
import '../../tutorial/presentation/ftue_tutorial_overlay.dart';
import '../../tutorial/application/tutorial_controller.dart';
import '../../../../shared/widgets/gothic_background.dart';
import '../../ads/presentation/widgets/unity_banner_ad_widget.dart';
import '../../../../core/services/ad_manager.dart';
import '../../menu/presentation/widgets/how_to_play_modal.dart';

class MatchScreen extends ConsumerStatefulWidget {
  const MatchScreen({super.key});

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  StreamSubscription? _playerSub;
  StreamSubscription? _opponentSub;
  bool _showCheck = false;
  bool _isPaused = false;

  Spell? _selectedSpell;
  BoardPosition? _primaryTarget;
  BoardPosition? _secondaryTarget;
  Set<BoardPosition> _validSpellTargets = {};

  BoardPosition? _captureParticlePosition;
  int _lastCaptureDamage = 0;
  int _lastCaptureHeal = 0;
  bool _showDamageNumber = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).playBgm(BgmType.inGame);
      _playerSub = ref.read(playerDollProvider.notifier).events.listen((event) {
        if (mounted) DollReactionBanner.showDollReaction(context, event);
      });
      _opponentSub =
          ref.read(opponentDollProvider.notifier).events.listen((event) {
        if (mounted) DollReactionBanner.showDollReaction(context, event);
      });
      ref.read(audioServiceProvider).playBgm(BgmType.inGame);
    });
  }

  @override
  void dispose() {
    _playerSub?.cancel();
    _opponentSub?.cancel();
    ref.read(audioServiceProvider).stopBgm();
    super.dispose();
  }


  void _onSpellTap(Spell spell) {
    final matchState = ref.read(matchControllerProvider);
    final isLocalMultiplayer = matchState.isLocalMode && !matchState.isAiMode && !matchState.isOnlineMode;
    if (!isLocalMultiplayer && !ref.read(matchControllerProvider.notifier).isMyTurn) {
      return;
    }

    if (_selectedSpell?.id == spell.id) {
      setState(() {
        _selectedSpell = null;
        _primaryTarget = null;
        _secondaryTarget = null;
        _validSpellTargets = const {};
      });
      return;
    }

    final PieceColor bottomPanelColor;
    if (isLocalMultiplayer) {
      bottomPanelColor = ref.read(matchControllerProvider.notifier).activePlayer;
    } else if (matchState.isOnlineMode) {
      bottomPanelColor = matchState.onlineColor ?? PieceColor.white;
    } else {
      bottomPanelColor = PieceColor.white;
    }

    setState(() {
      _selectedSpell = spell;
      _primaryTarget = null;
      _secondaryTarget = null;
      _validSpellTargets =
          SpellEngine.getValidTargets(spell, matchState.gameState.board, bottomPanelColor);
    });

    if (spell.targetType == SpellTargetType.none) {
      _playSelectedSpell();
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.hauntedCharcoal,
          content: Text(
            'Selected ${spell.name}. Select target tile on the board.',
            style: GoogleFonts.raleway(color: AppColors.candleIvory),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _onTileTap(BoardTile tile) {
    final pos = BoardPosition(tile.row, tile.col);

    if (_selectedSpell != null) {
      // ── Invalid target tap: cancel selection ──────────────────────────
      if (!_validSpellTargets.contains(pos)) {
        setState(() {
          _selectedSpell = null;
          _primaryTarget = null;
          _secondaryTarget = null;
          _validSpellTargets = const {};
        });
        return;
      }

      // ── Target tap: set target and fire immediately ───────────────────
      setState(() => _primaryTarget = pos);
      _playSelectedSpell();
    } else {
      ref.read(matchControllerProvider.notifier).selectTile(pos);
    }
  }

  void _playSelectedSpell() {
    if (_selectedSpell == null) return;
    ref.read(matchControllerProvider.notifier).playSpell(
          spell: _selectedSpell!,
          primary: _primaryTarget,
          secondary: _secondaryTarget,
        );
    setState(() {
      _selectedSpell = null;
      _primaryTarget = null;
      _secondaryTarget = null;
      _validSpellTargets = const {};
    });
  }

  void _openRelicBag() {
    final matchState = ref.read(matchControllerProvider);
    final isLocalMultiplayer = matchState.isLocalMode && !matchState.isAiMode && !matchState.isOnlineMode;
    final PieceColor bottomColor;
    if (isLocalMultiplayer) {
      bottomColor = ref.read(matchControllerProvider.notifier).activePlayer;
    } else if (matchState.isOnlineMode) {
      bottomColor = matchState.onlineColor ?? PieceColor.white;
    } else {
      bottomColor = PieceColor.white;
    }
    final inventory = bottomColor == PieceColor.white ? matchState.whiteRelics : matchState.blackRelics;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RelicBagModal(
        inventory: inventory,
        gameState: matchState.gameState,
        selectedTile: matchState.selectedTile,
        onEquipRelic: (relic, pos) {
          ref.read(matchControllerProvider.notifier).equipRelicToSelectedPiece(relic, pos);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(matchControllerProvider);
    final matchController = ref.read(matchControllerProvider.notifier);
    final storeState = ref.watch(storeControllerProvider);

    ref.listen(matchControllerProvider, (prev, next) {
      if (prev != null &&
          next.isOnlineMode &&
          next.result != null &&
          next.result!.reason == 'Opponent Disconnected' &&
          prev.result?.reason != 'Opponent Disconnected') {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.voidPanel,
            title: Text(
              'OPPONENT DISCONNECTED',
              style: GoogleFonts.cinzel(color: AppColors.runeGold),
            ),
            content: Text(
              'The opponent fled into the abyss. You have been awarded the victory and extra souls.',
              style: GoogleFonts.raleway(color: AppColors.fogGray),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK', style: TextStyle(color: AppColors.ghostBlue)),
              ),
            ],
          ),
        );
      }

      if (prev != null &&
          next.actionLog.isNotEmpty &&
          prev.actionLog.isNotEmpty &&
          next.actionLog.first != prev.actionLog.first) {
        if (next.actionLog.first.text.contains('CHECK!')) {
          setState(() => _showCheck = true);
        }
      } else if (prev != null &&
          next.actionLog.isNotEmpty &&
          prev.actionLog.isEmpty) {
        if (next.actionLog.first.text.contains('CHECK!')) {
          setState(() => _showCheck = true);
        }
      }

      if (prev != null &&
          next.lastMove != null &&
          next.lastMove != prev.lastMove) {
        if (next.lastMove!.isCapture) {

          setState(() {
            _captureParticlePosition = next.lastMove!.to;
            int dmg = 0;
            if (next.lastMove!.capturedPiece != null) {
              switch (next.lastMove!.capturedPiece!.type) {
                case PieceType.pawn: dmg = 10; break;
                case PieceType.knight: dmg = 30; break;
                case PieceType.bishop: dmg = 30; break;
                case PieceType.rook: dmg = 50; break;
                case PieceType.queen: dmg = 90; break;
                case PieceType.king: dmg = 150; break;
              }
            }
            _lastCaptureDamage = dmg;
            _lastCaptureHeal = (dmg * 0.5).round();
            _showDamageNumber = true;
          });
        }
      }

      // ── Show AppLovin MAX Interstitial Ad on Game Over State ──
      if (next.result != null && (prev == null || prev.result == null)) {
        ref.read(adManagerProvider).showGameOverInterstitial();
      }
    });

    final playerDoll = ref.watch(playerDollProvider);
    final opponentDoll = ref.watch(opponentDollProvider);

    final isLocalMultiplayer = matchState.isLocalMode && !matchState.isAiMode && !matchState.isOnlineMode;
    final activeColor = matchController.activePlayer;
    final isWhiteTurn = activeColor == PieceColor.white;
    final isMyTurn = matchController.isMyTurn;

    final PieceColor bottomPanelColor;
    if (isLocalMultiplayer) {
      bottomPanelColor = activeColor;
    } else if (matchState.isOnlineMode) {
      bottomPanelColor = matchState.onlineColor ?? PieceColor.white;
    } else {
      bottomPanelColor = PieceColor.white;
    }

    final isBottomPanelWhite = bottomPanelColor == PieceColor.white;
    final spellbook = isBottomPanelWhite ? matchState.whiteSpellbook : matchState.blackSpellbook;
    final relics = isBottomPanelWhite ? matchState.whiteRelics : matchState.blackRelics;

    final bool isBottomActive = isLocalMultiplayer ? true : isMyTurn;
    final bool isTopActive = isLocalMultiplayer ? false : !isMyTurn;

    final Color playerAccent = isBottomActive ? AppColors.runeGold : AppColors.fogGray.withValues(alpha: 0.5);
    final Color opponentAccent = isTopActive ? AppColors.runeGold : AppColors.ghostBlue.withValues(alpha: 0.5);

    final String playerName = isLocalMultiplayer ? (isWhiteTurn ? 'White Player' : 'Black Player') : 'You';
    final String opponentName = isLocalMultiplayer
        ? (isWhiteTurn ? 'Black Player' : 'White Player')
        : (matchState.isAiMode ? 'The Spirit' : 'Opponent');

    final tutorialStep = ref.watch(tutorialControllerProvider);
    
    // Automatically progress tutorial step if they made a move
    if (tutorialStep == TutorialStep.firstMove && matchState.turnNumber >= 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(tutorialControllerProvider.notifier).completeStep(TutorialStep.firstMove);
      });
    }

    final bool playerCritical = playerDoll.health / playerDoll.maxHealth <= 0.30;
    final bool opponentCritical = opponentDoll.health / opponentDoll.maxHealth <= 0.30;

    return Scaffold(
      backgroundColor: AppColors.abyssBlack,
      body: GothicBackground(
        child: Stack(
          children: [
            // ── Main Layout ──────────────────────────────────────────────────
            SafeArea(
            child: Column(
              children: [
                // ── TOP HUD — Opponent ────────────────────────────────────
                _CommanderPanel(
                  isActive: isTopActive,
                  accentColor: opponentAccent,
                  isOpponent: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _DollWithHealth(
                          doll: isLocalMultiplayer && !isWhiteTurn ? playerDoll : opponentDoll,
                          isCurrentTurn: isTopActive,
                          accentColor: opponentAccent,
                          isReversed: false,
                          name: opponentName,
                        ),
                        const Spacer(),
                        if (isTopActive)
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: TurnTimerWidget(seconds: matchState.secondsRemaining),
                          ),
                        const SizedBox(width: 8),
                        _TurnGlyph(isActive: isTopActive, color: opponentAccent),
                        const SizedBox(width: 8),
                        _IconGlyphButton(
                          icon: Icons.menu_book_rounded,
                          onTap: () {
                            ref.read(audioServiceProvider).playSfx(SfxType.buttonClick);
                            HowToPlayModal.show(context);
                          },
                          color: AppColors.runeGold,
                        ),
                        const SizedBox(width: 8),
                        _IconGlyphButton(
                          icon: Icons.pause_rounded,
                          onTap: () {
                            ref.read(audioServiceProvider).playSfx(SfxType.buttonClick);
                            setState(() => _isPaused = true);
                          },
                          color: AppColors.soulFlame,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── BOARD ─────────────────────────────────────────────────
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: RepaintBoundary(
                        child: IsometricBoardWidget(
                          gameState: matchState.gameState,
                          equippedBoardId: storeState.equippedBoardId,
                          selectedTile: matchState.selectedTile != null
                              ? BoardTile(matchState.selectedTile!.row,
                                  matchState.selectedTile!.col)
                              : null,
                          highlightedMoves: matchState.highlightedMoves,
                          validSpellTargets: _validSpellTargets,
                          lastMove: matchState.lastMove,
                          lastPlayedSpell: matchState.lastPlayedSpell,
                          lastSpellTarget: matchState.lastSpellTarget,
                          onTileTap: _onTileTap,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── BOTTOM HUD — Spells & Player ──────────────────────────
                _CommanderPanel(
                  isActive: isBottomActive,
                  accentColor: playerAccent,
                  isOpponent: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top row: Doll | Timer | Mana bar | Relic Bag | End Turn
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _DollWithHealth(
                                doll: isLocalMultiplayer && !isWhiteTurn ? opponentDoll : playerDoll,
                                equippedDollId: storeState.equippedDollId,
                                isCurrentTurn: isBottomActive,
                                accentColor: playerAccent,
                                isReversed: false,
                                name: playerName,
                              ),
                              
                              const SizedBox(width: 8),

                              if (isBottomActive) ...[
                                SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: TurnTimerWidget(seconds: matchState.secondsRemaining),
                                ),
                                const SizedBox(width: 8),
                              ],

                              // Mana Crystals
                              ManaBarWidget(
                                currentMana: spellbook.mana,
                                maxMana: spellbook.maxMana,
                              ),
                              
                              const SizedBox(width: 8),

                              // Relic Bag Button with badge
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E1428),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.runeGold.withValues(alpha: 0.8),
                                        width: 1.4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.runeGold.withValues(alpha: 0.2),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      tooltip: 'Open Relic Bag',
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.inventory_2_outlined, color: AppColors.runeGold, size: 20),
                                      onPressed: _openRelicBag,
                                    ),
                                  ),
                                if (relics.relics.isNotEmpty)
                                  Positioned(
                                    right: -4,
                                    top: -4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFC1121F),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.white, width: 1.2),
                                      ),
                                      child: Text(
                                        '${relics.relics.length}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(width: 8),

                            // End turn + undo
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                EndTurnButton(
                                  phase: isBottomActive ? matchState.phase : TurnPhase.waiting,
                                  onPressed: matchController.endTurn,
                                ),
                                if (matchState.canUndo) ...[
                                  const SizedBox(width: 6),
                                  _IconGlyphButton(
                                    icon: Icons.history,
                                    onTap: matchController.undo,
                                    color: AppColors.fogGray,
                                  ),
                                ] else if (matchState.undoSnapshot != null && !matchState.isOnlineMode) ...[
                                  const SizedBox(width: 6),
                                  _IconGlyphButton(
                                    icon: Icons.replay_rounded,
                                    onTap: matchController.claimRewardedUndo,
                                    color: AppColors.ghostBlue,
                                  ),
                                ],
                                if (!matchState.isOnlineMode) ...[
                                  const SizedBox(width: 6),
                                  _IconGlyphButton(
                                    icon: Icons.lightbulb_outline_rounded,
                                    onTap: matchController.claimRewardedHint,
                                    color: AppColors.runeGold,
                                  ),
                                ],
                              ],
                            ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Spell Scrollbar
                        SpellScrollBar(
                          spells: spellbook.spells,
                          currentMana: spellbook.mana,
                          selectedSpell: _selectedSpell,
                          onSpellTap: isBottomActive ? _onSpellTap : (_) {},
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Unity Ads Banner Ad (Clean mobile bottom dock) ──
                const UnityBannerAdWidget(
                  placementId: 'Banner_Android',
                  topPadding: 4.0,
                  bottomPadding: 2.0,
                ),
              ],
            ),
          ),

          // ── Overlays ─────────────────────────────────────────────────────
          ActionHistoryPanel(logs: matchState.actionLog),

          if (matchState.actionLog.isNotEmpty)
            ActionToastOverlay(latestAction: matchState.actionLog.first),

          if (_showCheck)
            Positioned.fill(
              child: CheckOverlay(
                onComplete: () {
                  if (mounted) setState(() => _showCheck = false);
                },
              ),
            ),

          if (_captureParticlePosition != null)
            Positioned.fill(
              child: IgnorePointer(
                child: CaptureParticleOverlay(
                  position: _captureParticlePosition!,
                  tileWidth: 42.0,
                  tileHeight: 32.0,
                  onComplete: () {
                    if (mounted) {
                      setState(() => _captureParticlePosition = null);
                    }
                  },
                ),
              ),
            ),

          if (matchState.showTurnPass)
            Positioned.fill(
              child: TurnPassOverlay(onTap: matchController.dismissTurnPass),
            ),

          if (matchState.pendingPromotion != null)
            Positioned.fill(
              child: PromotionOverlay(
                onPieceSelected: (pieceType) {
                  matchController.resolvePromotion(pieceType);
                },
              ),
            ),

          if (_isPaused)
            Positioned.fill(
              child: PauseMenuOverlay(
                onResume: () => setState(() => _isPaused = false),
                onRestart: () {
                  matchController.restart();
                  setState(() => _isPaused = false);
                },
              ),
            ),

          if (playerCritical || opponentCritical)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 1.0,
                      colors: [
                        Colors.transparent,
                        AppColors.bloodWine.withValues(alpha: playerCritical ? 0.22 : 0.12),
                      ],
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(duration: 700.ms)
                    .then()
                    .fadeOut(duration: 700.ms),
              ),
            ),

          if (_showDamageNumber)
            Positioned.fill(
              child: DamageNumberOverlay(
                damage: _lastCaptureDamage,
                heal: _lastCaptureHeal,
                alignment: matchController.activePlayer == PieceColor.white
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                onComplete: () {
                  if (mounted) setState(() => _showDamageNumber = false);
                },
              ),
            ),

          if (matchState.result != null)
            Positioned.fill(
              child: MatchSummaryOverlay(
                result: matchState.result!,
                playerCaptures: matchState.playerCaptures,
                opponentCaptures: 0,
                playerHealTotal: matchState.playerHealTotal,
                totalTurns: matchState.turnNumber,
                earnedSouls: matchState.result!.earnedSouls,
                onRematch: matchController.restartMatch,
                onExit: () => context.go('/menu'),
              ),
            ),

          if (_isPaused)
            Positioned.fill(
              child: PauseMenuOverlay(
                onResume: () => setState(() => _isPaused = false),
                onRestart: () {
                  matchController.restartMatch();
                  setState(() => _isPaused = false);
                },
              ),
            ),

          if (tutorialStep == TutorialStep.matchIntro)
            Positioned.fill(
              child: FtueTutorialOverlay(
                title: 'Spook·A·Chess Overview',
                message: 'Welcome Commander! Standard chess rules apply, but your King and army are backed by powerful Spells, magical Relics, and a Soul Doll Commander!',
                stepText: 'STEP 1 OF 5',
                isLeftAligned: false,
                onDismiss: () {
                  ref.read(tutorialControllerProvider.notifier).completeStep(TutorialStep.matchIntro);
                },
                onSkip: () {
                  ref.read(tutorialControllerProvider.notifier).skipTutorial();
                },
              ),
            ),

          if (tutorialStep == TutorialStep.combatRules)
            Positioned.fill(
              child: FtueTutorialOverlay(
                title: 'Two Paths to Victory',
                message: '1. CHECKMATE: Corner the enemy King.\n2. COMMANDER HP: Deplete enemy Doll HP to 0 by capturing enemy pieces and blasting them with Spells!',
                stepText: 'STEP 2 OF 5',
                isLeftAligned: true,
                onDismiss: () {
                  ref.read(tutorialControllerProvider.notifier).completeStep(TutorialStep.combatRules);
                },
                onSkip: () {
                  ref.read(tutorialControllerProvider.notifier).skipTutorial();
                },
              ),
            ),
          
          if (tutorialStep == TutorialStep.firstMove)
            Positioned.fill(
              child: FtueTutorialOverlay(
                title: 'Move Phase',
                message: 'Every turn starts with the Move Phase. Tap any of your pieces to preview valid moves and advance across the haunted board.',
                stepText: 'STEP 3 OF 5',
                isLeftAligned: true,
                showBarrier: false,
                onDismiss: () {
                  ref.read(tutorialControllerProvider.notifier).completeStep(TutorialStep.firstMove);
                },
                onSkip: () {
                  ref.read(tutorialControllerProvider.notifier).skipTutorial();
                },
              ),
            ),
          
          if (tutorialStep == TutorialStep.spellIntro)
            Positioned.fill(
              child: FtueTutorialOverlay(
                title: 'Spell Phase & Mana',
                message: 'You generate Mana each turn! Tap any Spell in your scroll bar below to destroy enemies, freeze ranks, or heal your Commander.',
                stepText: 'STEP 4 OF 5',
                isLeftAligned: false,
                showBarrier: false,
                onDismiss: () {
                  ref.read(tutorialControllerProvider.notifier).completeStep(TutorialStep.spellIntro);
                },
                onSkip: () {
                  ref.read(tutorialControllerProvider.notifier).skipTutorial();
                },
              ),
            ),

          if (tutorialStep == TutorialStep.relicIntro)
            Positioned.fill(
              child: FtueTutorialOverlay(
                title: 'Relics & Turn End',
                message: 'Tap the Relic Bag button (top-right of your tray) to equip artifacts onto pieces. When ready, press "END TURN" to pass the initiative!',
                stepText: 'STEP 5 OF 5',
                isLeftAligned: false,
                showBarrier: false,
                onDismiss: () {
                  ref.read(tutorialControllerProvider.notifier).completeStep(TutorialStep.relicIntro);
                },
                onSkip: () {
                  ref.read(tutorialControllerProvider.notifier).skipTutorial();
                },
              ),
            ),
        ],
        ),
      ),
    );
  }
}

class _CommanderPanel extends StatelessWidget {
  final bool isActive;
  final Color accentColor;
  final bool isOpponent;
  final Widget child;

  const _CommanderPanel({
    required this.isActive,
    required this.accentColor,
    required this.isOpponent,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      clipBehavior: Clip.none,
      margin: EdgeInsets.fromLTRB(
        8,
        isOpponent ? 4 : 0,
        8,
        isOpponent ? 0 : 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF140700).withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? accentColor.withValues(alpha: 0.9)
              : const Color(0xFF4A1A00),
          width: isActive ? 2.5 : 1.5,
        ),
        boxShadow: [
          const BoxShadow(
            color: Color(0xFF0D0200),
            offset: Offset(0, 3),
            blurRadius: 2,
          ),
          if (isActive)
            BoxShadow(
              color: accentColor.withValues(alpha: 0.25),
              blurRadius: 16,
              spreadRadius: 2,
            ),
        ],
      ),
      child: child,
    );
  }
}

class _DollWithHealth extends StatelessWidget {
  final SoulDoll doll;
  final String? equippedDollId;
  final bool isCurrentTurn;
  final Color accentColor;
  final bool isReversed;
  final String name;

  const _DollWithHealth({
    required this.doll,
    this.equippedDollId,
    required this.isCurrentTurn,
    required this.accentColor,
    required this.isReversed,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    Widget dollWidget = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF211A2E),
        border: Border.all(
          color: isCurrentTurn
              ? accentColor
              : const Color(0xFF382E4D),
          width: isCurrentTurn ? 2.2 : 1.5,
        ),
        boxShadow: isCurrentTurn
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: 100,
              height: 120,
              child: SoulDollWidget(
                doll: doll,
                equippedDollId: equippedDollId,
                isCurrentTurn: isCurrentTurn,
              ),
            ),
          ),
        ),
      ),
    );

    Widget nameLabel = Text(
      name.toUpperCase(),
      style: GoogleFonts.cinzel(
        color: isCurrentTurn
            ? accentColor
            : AppColors.fogGray,
        fontSize: 9,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );

    Widget healthBar = HealthBarWidget(
      health: doll.health,
      maxHealth: doll.maxHealth,
      isReversed: isReversed,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isReversed) ...[
          healthBar,
          const SizedBox(width: 8),
        ],
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            dollWidget,
            const SizedBox(height: 2),
            nameLabel,
          ],
        ),
        if (!isReversed) ...[
          const SizedBox(width: 8),
          healthBar,
        ],
      ],
    );
  }
}

class _TurnGlyph extends StatelessWidget {
  final bool isActive;
  final Color color;
  const _TurnGlyph({required this.isActive, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: 300.ms,
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? color : Colors.transparent,
        border: Border.all(
          color: isActive ? color : AppColors.dimGray,
          width: 1.5,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
    );
  }
}

class _IconGlyphButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  const _IconGlyphButton(
      {required this.icon, required this.onTap, required this.color});

  @override
  State<_IconGlyphButton> createState() => _IconGlyphButtonState();
}

class _IconGlyphButtonState extends State<_IconGlyphButton> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: 200.ms,
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _hovered
                ? widget.color.withValues(alpha: 0.15)
                : Colors.transparent,
            border: Border.all(
              color: _hovered
                  ? widget.color.withValues(alpha: 0.6)
                  : widget.color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(widget.icon, color: widget.color, size: 18),
        ),
      ),
    );
  }
}
