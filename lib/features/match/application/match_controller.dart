import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../board/domain/board_position.dart';
import '../../match/domain/chess_engine.dart';
import '../../match/domain/chess_move.dart';
import '../../match/domain/chess_ai.dart';
import '../../match/domain/game_status.dart';
import '../../../shared/enums/piece_color.dart';
import '../../../shared/enums/piece_type.dart';
import '../../dolls/domain/soul_doll_controller.dart';
import '../domain/match_state.dart';
import '../domain/match_snapshot.dart';
import '../domain/action_log_entry.dart';
import '../domain/turn_phase.dart';
import '../domain/match_result.dart';
import '../../../core/audio/audio_enums.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/network/network_service.dart';
import '../../spells/domain/spell.dart';
import '../../spells/domain/spell_engine.dart';
import '../../relics/domain/relic.dart';
import '../../relics/domain/relics.dart';
import '../../store/application/store_controller.dart';
import '../../achievements/application/achievements_controller.dart';
import '../../leaderboard/application/leaderboard_service.dart';
import '../../daily/application/daily_controller.dart';
import '../../profile/application/profile_controller.dart';
import '../../../core/services/ad_manager.dart';

final matchControllerProvider = StateNotifierProvider<MatchController, MatchState>((ref) {
  return MatchController(ref);
});

class MatchController extends StateNotifier<MatchState> {
  final Ref _ref;
  Timer? _timer;
  bool _aiThinking = false;

  MatchController(this._ref) : super(MatchState.initial()) {
    _startTimer();
    _initNetworkListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initNetworkListeners() {
    final network = _ref.read(networkServiceProvider);
    network.onActionReceived = (data) {
      if (!state.isOnlineMode || state.phase == TurnPhase.gameOver) return;
      if (data['type'] == 'move') {
        final from = BoardPosition(data['from']['row'], data['from']['col']);
        final to = BoardPosition(data['to']['row'], data['to']['col']);
        PieceType? promo;
        if (data['promotion'] != null) {
          promo = PieceType.values.firstWhere((e) => e.name == data['promotion']);
        }
        _handleNetworkMove(from, to, promo);
      } else if (data['type'] == 'spell') {
        final spell = _getSpellById(data['spellId']);
        BoardPosition? primary;
        BoardPosition? secondary;
        if (data['primary'] != null) {
          primary = BoardPosition(data['primary']['row'], data['primary']['col']);
        }
        if (data['secondary'] != null) {
          secondary = BoardPosition(data['secondary']['row'], data['secondary']['col']);
        }
        if (spell != null) {
          _handleNetworkSpell(spell, primary, secondary);
        }
      } else if (data['type'] == 'endTurn') {
        _handleNetworkEndTurn();
      }
    };

    network.onOpponentDisconnected = () {
      if (!state.isOnlineMode || state.phase == TurnPhase.gameOver) return;

      final player = state.onlineColor ?? PieceColor.white;
      _logAction('Opponent disconnected!', player, important: true);

      int earnedSouls = 50 + (state.playerCaptures * 10) + 100;
      int earnedXp = 100 + (state.playerCaptures * 25) + 300; // 300 win bonus

      _ref.read(achievementsControllerProvider.notifier).unlockAchievement('checkmate');
      _ref.read(achievementsControllerProvider.notifier).recordWin();
      _ref.read(storeControllerProvider.notifier).addCurrency(souls: earnedSouls);
      _ref.read(storeControllerProvider.notifier).addXp(earnedXp);

      if (state.isOnlineMode) {
        _ref.read(leaderboardServiceProvider).recordMatchResult(true, earnedSouls);
      }

      state = state.copyWith(
        phase: TurnPhase.gameOver,
        result: MatchResult(
          winner: player,
          reason: 'Opponent Disconnected',
          totalTurns: state.turnNumber,
          matchDuration: DateTime.now().difference(state.matchStartTime),
          earnedSouls: earnedSouls,
        ),
      );
    };
  }

  Spell? _getSpellById(String id) {
    for (var s in SpellEngine.allSpells) {
      if (s.id == id) return s;
    }
    return null;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (state.phase == TurnPhase.gameOver) {
        timer.cancel();
        return;
      }
      if (state.isOnlineMode && !isMyTurn) return;

      if (state.secondsRemaining > 0) {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
        if (state.secondsRemaining == 0) endTurn();
      }
    });
  }

  void startAiMatch({AiDifficulty difficulty = AiDifficulty.haunted}) {
    _ref.read(networkServiceProvider).leaveMatch();
    _ref.read(playerDollProvider.notifier).reset();
    _ref.read(opponentDollProvider.notifier).reset();
    _aiThinking = false;
    state = MatchState.initial().copyWith(
      isAiMode: true,
      isLocalMode: false,
      isOnlineMode: false,
      aiDifficulty: difficulty,
    );
    _startTimer();
  }

  void startLocalMatch() {
    _ref.read(networkServiceProvider).leaveMatch();
    _ref.read(playerDollProvider.notifier).reset();
    _ref.read(opponentDollProvider.notifier).reset();
    _aiThinking = false;
    state = MatchState.initial().copyWith(
      isAiMode: false,
      isLocalMode: true,
      isOnlineMode: false,
    );
    _startTimer();
  }

  void startOnlineMatch({required bool isPlayer1}) {
    _aiThinking = false;
    _ref.read(playerDollProvider.notifier).reset();
    _ref.read(opponentDollProvider.notifier).reset();
    state = MatchState.initial().copyWith(
      isAiMode: false,
      isLocalMode: false,
      isOnlineMode: true,
      onlineColor: isPlayer1 ? PieceColor.white : PieceColor.black,
    );
    _startTimer();
  }

  /// The player who is currently acting (moving or using spells this turn).
  /// Note: [ChessEngine.makeMove] flips [currentTurn] upon move completion,
  /// so during [TurnPhase.card], the acting player is [currentTurn.opposite].
  PieceColor get activePlayer {
    if (state.phase == TurnPhase.move) return state.gameState.currentTurn;
    return state.gameState.currentTurn.opposite;
  }

  /// True when the AI (black) is the active player.
  bool get isAiTurn =>
      state.isAiMode && activePlayer == PieceColor.black;

  bool get isMyTurn {
    if (state.isLocalMode && !state.isAiMode && !state.isOnlineMode) return true;
    if (state.isOnlineMode) return activePlayer == state.onlineColor;
    return activePlayer == PieceColor.white;
  }

  void restartMatch() {
    _aiThinking = false;
    if (state.isOnlineMode) return;
    _ref.read(playerDollProvider.notifier).reset();
    _ref.read(opponentDollProvider.notifier).reset();

    state = state.isAiMode
        ? MatchState.initial().copyWith(
            isAiMode: true,
            isLocalMode: false,
            aiDifficulty: state.aiDifficulty,
          )
        : MatchState.initial();
    _startTimer();
  }

  void dismissTurnPass() {
    state = state.copyWith(showTurnPass: false);
    if (isAiTurn) _scheduleAiMove();
  }

  void _logAction(String text, PieceColor player, {bool important = false}) {
    final entry = ActionLogEntry(
      text: text,
      timestamp: DateTime.now(),
      player: player,
      isImportant: important,
    );
    state = state.copyWith(actionLog: [entry, ...state.actionLog]);
  }

  void selectTile(BoardPosition pos) {
    if (state.phase != TurnPhase.move) return;
    if (isAiTurn) return;
    if (!isMyTurn) return;

    final color = activePlayer;

    if (state.selectedTile != null && state.highlightedMoves.contains(pos)) {
      makeMove(state.selectedTile!, pos);
      return;
    }

    final piece = state.gameState.board.pieceAt(pos);
    if (piece != null && piece.color == color && !piece.isFrozen) {
      final legalMoves = ChessEngine.generateLegalMoves(state.gameState, pos);
      state = state.copyWith(
        selectedTile: pos,
        highlightedMoves: legalMoves.map((m) => m.to).toSet(),
      );
    } else {
      state = state.copyWith(
        clearSelectedTile: true,
        highlightedMoves: const {},
      );
    }
  }

  void makeMove(BoardPosition from, BoardPosition to) {
    if (state.phase != TurnPhase.move) return;
    if (!isMyTurn) return;

    final gameState = state.gameState;
    final legalMoves = ChessEngine.generateLegalMoves(gameState, from);
    final validMove = legalMoves.cast<ChessMove?>().firstWhere(
      (m) => m?.to == to,
      orElse: () => null,
    );
    if (validMove == null) return;

    if (validMove.isPromotion) {
      state = state.copyWith(
        pendingPromotion: validMove,
        clearSelectedTile: true,
        highlightedMoves: const {},
      );
      return;
    }

    _commitMove(validMove);
    if (state.isOnlineMode) {
      _ref.read(networkServiceProvider).sendMoveAction(from, to, null);
    }
  }

  void resolvePromotion(PieceType chosenType) {
    final move = state.pendingPromotion;
    if (move == null) return;

    final promotedMove = move.copyWith(promotionChoice: chosenType);
    state = state.copyWith(clearPendingPromotion: true);
    _commitMove(promotedMove);

    if (state.isOnlineMode) {
      _ref.read(networkServiceProvider).sendMoveAction(move.from, move.to, chosenType);
    }
  }

  void _handleNetworkMove(BoardPosition from, BoardPosition to, PieceType? promo) {
    final legalMoves = ChessEngine.generateLegalMoves(state.gameState, from);
    final validMove = legalMoves.cast<ChessMove?>().firstWhere(
      (m) => m?.to == to,
      orElse: () => null,
    );
    if (validMove == null) return;

    if (promo != null && validMove.isPromotion) {
      _commitMove(validMove.copyWith(promotionChoice: promo));
    } else {
      _commitMove(validMove);
    }
  }

  void equipRelicToSelectedPiece(Relic relic, BoardPosition pos) {
    final piece = state.gameState.board.pieceAt(pos);
    if (piece == null || piece.color != activePlayer) return;

    final newEquipment = [...piece.equipment, relic];
    final updatedPiece = piece.copyWith(equipment: newEquipment);

    final newBoard = state.gameState.board.clone();
    newBoard.setPiece(pos, updatedPiece);

    final isWhite = activePlayer == PieceColor.white;
    final curRelics = isWhite ? state.whiteRelics : state.blackRelics;
    final updatedRelics = curRelics.removeRelic(relic.id);

    _logAction('${activePlayer.name} equipped ${relic.name} onto ${piece.type.name}', activePlayer, important: true);

    if (activePlayer == PieceColor.white) {
      _ref.read(profileControllerProvider.notifier).recordRelicEquipped();
      _ref.read(dailyControllerProvider.notifier).recordMatchEvent(relicsEquipped: 1);
    }

    state = state.copyWith(
      gameState: state.gameState.copyWith(board: newBoard),
      whiteRelics: isWhite ? updatedRelics : state.whiteRelics,
      blackRelics: !isWhite ? updatedRelics : state.blackRelics,
    );
  }

  void _commitMove(ChessMove validMove) {
    final snapshot = MatchSnapshot(
      gameState: state.gameState,
      whiteSpellbook: state.whiteSpellbook,
      blackSpellbook: state.blackSpellbook,
      whiteRelics: state.whiteRelics,
      blackRelics: state.blackRelics,
      phase: state.phase,
    );

    final player = activePlayer;
    final newGameState = ChessEngine.makeMove(state.gameState, validMove);

    final pieceSymbol = validMove.movedPiece.symbol;
    final dest = validMove.to.algebraic;
    final captureStr = validMove.isCapture ? 'captured on $dest' : 'moved to $dest';
    _logAction('$player $pieceSymbol $captureStr', player);

    var finalGameState = newGameState;

    // Capture & Relic Loot Drop Logic
    var wRelics = state.whiteRelics;
    var bRelics = state.blackRelics;

    if (validMove.isCapture) {
      HapticFeedback.mediumImpact();
      _ref.read(audioServiceProvider).playSfx(SfxType.pieceCapture);

      int damage = 0;
      if (validMove.capturedPiece != null) {
        final captured = validMove.capturedPiece!;

        switch (captured.type) {
          case PieceType.pawn: damage = 10; break;
          case PieceType.knight: damage = 30; break;
          case PieceType.bishop: damage = 30; break;
          case PieceType.rook: damage = 50; break;
          case PieceType.queen: damage = 90; break;
          case PieceType.king: damage = 150; break;
        }

        // Drop a Relic reward
        final droppedRelic = RelicPool.getRandomRelic();
        if (player == PieceColor.white) {
          wRelics = wRelics.addRelic(droppedRelic);
        } else {
          bRelics = bRelics.addRelic(droppedRelic);
        }
        _logAction('[Loot Drop] ${player.name} obtained ${droppedRelic.name}!', player, important: true);
      }

      final healAmount = (damage * 0.5).round();

      if (player == PieceColor.white) {
        _ref.read(playerDollProvider.notifier).onPieceCaptured();
        _ref.read(playerDollProvider.notifier).heal(healAmount);
        _ref.read(opponentDollProvider.notifier).onPieceLost();
        _ref.read(opponentDollProvider.notifier).takeDamage(damage);
        _ref.read(dailyControllerProvider.notifier).recordMatchEvent(piecesCaptured: 1);

        _ref.read(achievementsControllerProvider.notifier).unlockAchievement('first_blood');

        if (_ref.read(opponentDollProvider.notifier).state.health <= 0) {
          finalGameState = finalGameState.copyWith(status: GameStatus.checkmate);
        }
        state = state.copyWith(
          playerCaptures: state.playerCaptures + 1,
          playerHealTotal: state.playerHealTotal + healAmount,
        );
      } else {
        _ref.read(opponentDollProvider.notifier).onPieceCaptured();
        _ref.read(opponentDollProvider.notifier).heal(healAmount);
        _ref.read(playerDollProvider.notifier).onPieceLost();
        _ref.read(playerDollProvider.notifier).takeDamage(damage);

        if (_ref.read(playerDollProvider.notifier).state.health <= 0) {
          finalGameState = finalGameState.copyWith(status: GameStatus.checkmate);
        }
      }
    } else {
      HapticFeedback.lightImpact();
      _ref.read(audioServiceProvider).playSfx(SfxType.pieceMove);
    }

    if (finalGameState.status == GameStatus.checkmate) {
      _logAction('CHECKMATE!', player, important: true);
      _ref.read(audioServiceProvider).playSfx(SfxType.checkmate);
      if (player == PieceColor.white) {
        _ref.read(opponentDollProvider.notifier).triggerCheckmateReaction();
      } else {
        _ref.read(playerDollProvider.notifier).triggerCheckmateReaction();
      }
    } else if (finalGameState.status == GameStatus.check) {
      _logAction('CHECK!', player, important: true);
      _ref.read(audioServiceProvider).playSfx(SfxType.check);
      if (player == PieceColor.white) {
        _ref.read(opponentDollProvider.notifier).triggerCheckReaction();
      } else {
        _ref.read(playerDollProvider.notifier).triggerCheckReaction();
      }
    }

    // ── Determine next phase ────────────────────────────────────────────
    final isOver = finalGameState.status == GameStatus.checkmate ||
        finalGameState.status == GameStatus.stalemate;

    state = state.copyWith(
      gameState: finalGameState,
      whiteRelics: wRelics,
      blackRelics: bRelics,
      undoSnapshot: snapshot,
      canUndo: state.isLocalMode && !state.isAiMode,
      phase: isOver ? TurnPhase.gameOver : TurnPhase.card,
      clearSelectedTile: true,
      highlightedMoves: const {},
      lastMove: validMove,
    );

    if (isOver) {
      // ── Game over: award souls / XP ──────────────────────────────────
      int earnedSouls = 50 + (state.playerCaptures * 10);
      int earnedXp    = 100 + (state.playerCaptures * 25);
      if (player == PieceColor.white) {
        earnedSouls += 100;
        earnedXp    += 300;
        _ref.read(achievementsControllerProvider.notifier).unlockAchievement('checkmate');
        _ref.read(achievementsControllerProvider.notifier).recordWin();
      }
      _ref.read(storeControllerProvider.notifier).addCurrency(souls: earnedSouls);
      _ref.read(storeControllerProvider.notifier).addXp(earnedXp);
      _ref.read(profileControllerProvider.notifier).recordMatchResult(
        isWin: player == PieceColor.white,
        isCheckmate: finalGameState.status == GameStatus.checkmate,
      );

      if (state.isOnlineMode) {
        _ref.read(leaderboardServiceProvider).recordMatchResult(
          player == state.onlineColor, earnedSouls);
      }

      state = state.copyWith(
        result: MatchResult(
          winner: player,
          reason: finalGameState.status == GameStatus.checkmate ? 'Checkmate' : 'Stalemate',
          totalTurns: state.turnNumber,
          matchDuration: DateTime.now().difference(state.matchStartTime),
          earnedSouls: earnedSouls,
        ),
      );
      return;
    }

    // ── If this was the human's move in AI mode, AI now handles its full turn
    // after the human explicitly presses End Turn (handled in _commitEndTurn).
    // Nothing extra needed here — the card phase is for the human to cast spells.
  }

  void playSpell({
    required Spell spell,
    BoardPosition? primary,
    BoardPosition? secondary,
  }) {
    if (state.phase == TurnPhase.gameOver) return;
    if (!isMyTurn) return;

    _commitSpell(spell, primary, secondary);

    if (state.isOnlineMode) {
      _ref.read(networkServiceProvider).sendCardAction(spell.id, primary, secondary);
    }
  }

  void _handleNetworkSpell(Spell spell, BoardPosition? primary, BoardPosition? secondary) {
    _commitSpell(spell, primary, secondary);
  }

  void _commitSpell(Spell spell, BoardPosition? primary, BoardPosition? secondary) {
    final player = activePlayer;

    final updatedState = SpellEngine.applySpell(
      state: state,
      spell: spell,
      casterColor: player,
      target: primary,
      secondaryTarget: secondary,
    );

    _logAction('$player cast ${spell.name}', player, important: true);
    HapticFeedback.heavyImpact();
    _ref.read(audioServiceProvider).playSfx(SfxType.cardPlay);

    if (player == PieceColor.white) {
      final isFreeze = spell.id == 'spell_freeze' || spell.id == 'spell_blizzard';
      _ref.read(dailyControllerProvider.notifier).recordMatchEvent(
        spellsCast: 1,
        enemiesFrozen: isFreeze ? (spell.id == 'spell_blizzard' ? 2 : 1) : 0,
      );
      _ref.read(profileControllerProvider.notifier).recordSpellCast(spell.id, spell.name);
    }

    state = updatedState.copyWith(
      clearUndo: true,
    );
  }

  void endTurn() {
    if (state.phase == TurnPhase.gameOver) return;
    if (!isMyTurn && state.isOnlineMode) return;

    _commitEndTurn();

    if (state.isOnlineMode && isMyTurn) {
      _ref.read(networkServiceProvider).sendEndTurnAction();
    }
  }

  void _handleNetworkEndTurn() {
    _commitEndTurn();
  }

  void _commitEndTurn() {
    if (state.phase == TurnPhase.gameOver) return;

    var newGameState = state.gameState;

    final endingPlayer = state.phase == TurnPhase.move
        ? newGameState.currentTurn
        : newGameState.currentTurn.opposite;
    final newBoard = newGameState.board.clone();
    for (final pos in newBoard.allPieces(endingPlayer)) {
      final p = newBoard.pieceAt(pos);
      if (p != null) {
        if (p.isFrozen || p.hasPhantomStep) {
          newBoard.setPiece(pos, p.copyWith(isFrozen: false, hasPhantomStep: false));
        }
      }
    }
    newGameState = newGameState.copyWith(board: newBoard);

    if (state.phase == TurnPhase.move) {
      newGameState = newGameState.copyWith(currentTurn: newGameState.currentTurn.opposite);
    }

    final nextPlayer = newGameState.currentTurn;

    // Calculate bonus mana from equipped Ring of Mana relics
    int ringBonus = 0;
    for (final pos in newBoard.allPieces(nextPlayer)) {
      final p = newBoard.pieceAt(pos);
      if (p != null && p.equipment.any((r) => r.id == 'relic_ring_of_mana')) {
        ringBonus++;
      }
    }

    final totalManaGain = 1 + ringBonus;
    var wSpellbook = state.whiteSpellbook;
    var bSpellbook = state.blackSpellbook;

    if (nextPlayer == PieceColor.white) {
      final newSpell = SpellEngine.getRandomSpell();
      wSpellbook = wSpellbook.gainMana(totalManaGain).addSpell(newSpell);
      _ref.read(audioServiceProvider).playSfx(SfxType.cardDraw);
    } else {
      final newSpell = SpellEngine.getRandomSpell();
      bSpellbook = bSpellbook.gainMana(totalManaGain).addSpell(newSpell);
      if (state.isLocalMode && !state.isAiMode) {
        _ref.read(audioServiceProvider).playSfx(SfxType.cardDraw);
      }
    }

    final newTurn = state.turnNumber + 1;
    if (newTurn % 3 == 0) {
      _logAction('A mystical mana surge sweeps the board...', nextPlayer, important: true);
    }

    final showPass = state.isLocalMode && !state.isAiMode && !state.isOnlineMode;

    state = state.copyWith(
      gameState: newGameState,
      phase: TurnPhase.move,
      turnNumber: newTurn,
      secondsRemaining: 30,
      whiteSpellbook: wSpellbook,
      blackSpellbook: bSpellbook,
      clearUndo: true,
      showTurnPass: showPass,
      clearSelectedTile: true,
      highlightedMoves: const {},
    );

    // ── After end turn, check if it's now AI's move ─────────────────────
    // isAiTurn checks phase==move AND currentTurn==black, so this is safe.
    if (state.isAiMode && isAiTurn && !showPass) {
      _runAiFullTurn();
    }
  }

  /// Complete AI turn pipeline: move → optional spell → end turn.
  /// All steps are sequential via Future.delayed to feel natural.
  void _runAiFullTurn() {
    if (_aiThinking) return;
    _aiThinking = true;
    _logAction('The spirit contemplates...', PieceColor.black);

    // Step 1: AI chooses and plays a move
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted || state.phase == TurnPhase.gameOver) {
        _aiThinking = false;
        return;
      }

      final ai = ChessAi(difficulty: state.aiDifficulty);
      final bestMove = ai.getBestMove(state.gameState);

      if (bestMove == null) {
        _aiThinking = false;
        return;
      }

      _aiThinking = false;
      // Commit the move (transitions to card phase)
      if (bestMove.isPromotion) {
        _commitMove(bestMove.copyWith(promotionChoice: PieceType.queen));
      } else {
        _commitMove(bestMove);
      }

      // Step 2: AI considers casting a spell (card phase)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted || state.phase == TurnPhase.gameOver) return;

        final aiSpell = ai.getBestSpellAction(
          spellbook: state.blackSpellbook,
          board: state.gameState.board,
          aiColor: PieceColor.black,
        );
        if (aiSpell != null) {
          _commitSpell(aiSpell.spell, aiSpell.primary, aiSpell.secondary);
        }

        // Step 3: AI ends its turn
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted && state.phase != TurnPhase.gameOver) endTurn();
        });
      });
    });
  }

  void _scheduleAiMove() {
    if (_aiThinking) return;
    _aiThinking = true;
    _logAction('The spirit contemplates...', PieceColor.black);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final ai = ChessAi(difficulty: state.aiDifficulty);
      final bestMove = ai.getBestMove(state.gameState);

      if (bestMove == null || !mounted) {
        _aiThinking = false;
        return;
      }

      _aiThinking = false;
      if (bestMove.isPromotion) {
        _commitMove(bestMove.copyWith(promotionChoice: PieceType.queen));
      } else {
        _commitMove(bestMove);
      }
    });
  }

  void restart() {
    _timer?.cancel();
    _aiThinking = false;
    state = MatchState.initial().copyWith(
      isAiMode: state.isAiMode,
      aiDifficulty: state.aiDifficulty,
      isLocalMode: state.isLocalMode,
      isOnlineMode: state.isOnlineMode,
      onlineColor: state.onlineColor,
    );
    _startTimer();
  }

  void undo() {
    if (!state.canUndo || state.undoSnapshot == null) return;
    if (state.isOnlineMode) return;
    _logAction('Undo last move', activePlayer);
    state = state.copyWith(
      gameState: state.undoSnapshot!.gameState,
      whiteSpellbook: state.undoSnapshot!.whiteSpellbook,
      blackSpellbook: state.undoSnapshot!.blackSpellbook,
      whiteRelics: state.undoSnapshot!.whiteRelics,
      blackRelics: state.undoSnapshot!.blackRelics,
      phase: state.undoSnapshot!.phase,
      clearUndo: true,
      clearSelectedTile: true,
      clearHint: true,
      highlightedMoves: const {},
    );
  }

  /// Triggers an AppLovin MAX Rewarded Video Ad for a Free Undo Move.
  Future<void> claimRewardedUndo() async {
    if (state.isOnlineMode) return;
    await AdManager.instance.showRewardedAd(
      onRewarded: () {
        grantRewardedUndo();
      },
    );
  }

  /// Rewards the player with 1 Free Undo move after watching a rewarded video ad.
  void grantRewardedUndo() {
    if (state.undoSnapshot == null) {
      _logAction('Rewarded Video watched: Free Undo active for next move', activePlayer);
      state = state.copyWith(canUndo: true);
      return;
    }

    _logAction('Rewarded Video watched: 1 Free Undo granted', activePlayer);
    state = state.copyWith(
      gameState: state.undoSnapshot!.gameState,
      whiteSpellbook: state.undoSnapshot!.whiteSpellbook,
      blackSpellbook: state.undoSnapshot!.blackSpellbook,
      whiteRelics: state.undoSnapshot!.whiteRelics,
      blackRelics: state.undoSnapshot!.blackRelics,
      phase: state.undoSnapshot!.phase,
      clearUndo: true,
      clearSelectedTile: true,
      clearHint: true,
      highlightedMoves: const {},
    );
  }

  /// Triggers an AppLovin MAX Rewarded Video Ad for a Tactical Hint.
  Future<void> claimRewardedHint() async {
    if (state.isOnlineMode) return;
    await AdManager.instance.showRewardedAd(
      onRewarded: () {
        grantRewardedHint();
      },
    );
  }

  /// Rewards the player with a high-level tactical Hint move calculated by AI.
  void grantRewardedHint() {
    final ai = ChessAi(difficulty: AiDifficulty.nightmare);
    final bestMove = ai.getBestMove(state.gameState);
    if (bestMove == null) {
      _logAction('Oracle reveals no available moves', activePlayer);
      return;
    }

    _logAction(
      'Oracle Hint: ${bestMove.movedPiece.type.name.toUpperCase()} from (${bestMove.from.row}, ${bestMove.from.col}) to (${bestMove.to.row}, ${bestMove.to.col})',
      activePlayer,
    );

    state = state.copyWith(
      hintMove: bestMove,
      selectedTile: bestMove.from,
      highlightedMoves: {bestMove.from, bestMove.to},
    );
  }
}
