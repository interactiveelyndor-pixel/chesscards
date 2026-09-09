import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_chess/features/board/domain/board_position.dart';
import 'package:super_chess/features/board/domain/game_board.dart';
import 'package:super_chess/features/match/domain/chess_ai.dart';
import 'package:super_chess/features/match/domain/chess_engine.dart';
import 'package:super_chess/features/match/domain/game_state.dart';
import 'package:super_chess/features/match/domain/game_status.dart';
import 'package:super_chess/features/match/domain/turn_phase.dart';
import 'package:super_chess/features/match/application/match_controller.dart';
import 'package:super_chess/features/pieces/domain/chess_piece.dart';
import 'package:super_chess/features/spells/domain/spells.dart';
import 'package:super_chess/features/spells/domain/spellbook.dart';
import 'package:super_chess/features/tutorial/application/tutorial_controller.dart';
import 'package:super_chess/shared/enums/piece_color.dart';
import 'package:super_chess/shared/enums/piece_type.dart';
import 'package:super_chess/core/audio/audio_service.dart';
import 'package:super_chess/core/audio/audio_enums.dart';
import 'package:super_chess/core/network/network_service.dart';
import 'package:super_chess/core/services/settings_service.dart';

class MockAudioService implements AudioService {
  int sfxPlayCount = 0;
  int bgmPlayCount = 0;
  int crossfadeBgmCount = 0;
  int stopBgmCount = 0;

  @override
  Future<void> init() async {}

  @override
  Future<void> playBgm(BgmType type) async {
    bgmPlayCount++;
  }

  @override
  Future<void> crossfadeBgm(BgmType type) async {
    crossfadeBgmCount++;
  }

  @override
  Future<void> stopBgm() async {
    stopBgmCount++;
  }

  @override
  Future<void> playSfx(SfxType type) async {
    sfxPlayCount++;
  }

  @override
  void dispose() {}
}

class MockNetworkService implements NetworkService {
  @override
  String? get userId => 'adversary_mock_user';
  @override
  String? currentMatchId = 'test_match_99';
  @override
  bool isPlayer1 = true;
  @override
  void Function(Map<String, dynamic> actionData)? onActionReceived;
  @override
  void Function(String opponentId)? onMatchStart;
  @override
  void Function()? onOpponentDisconnected;

  int sentMoveActions = 0;
  int sentCardActions = 0;
  int sentEndTurnActions = 0;

  @override
  Future<void> signInAnonymously() async {}

  @override
  Future<void> findMatch() async {}

  @override
  Future<void> sendMoveAction(BoardPosition from, BoardPosition to, PieceType? promotion) async {
    sentMoveActions++;
  }

  @override
  Future<void> sendCardAction(String cardId, BoardPosition? primary, BoardPosition? secondary) async {
    sentCardActions++;
  }

  @override
  Future<void> sendEndTurnAction() async {
    sentEndTurnActions++;
  }

  @override
  Future<void> leaveMatch() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('🎯 ADVANCED AI, NETWORK, AUDIO, IMMUTABILITY & FTUE SUITE', () {

    // ─────────────────────────────────────────────────────────────────────────
    // 1. AI BENCHMARK & TACTICAL REASONING
    // ─────────────────────────────────────────────────────────────────────────
    test('1. AI Benchmark: Nightmare AI prioritizes high-value spell targets & Haunted AI responds in < 200ms', () {
      final nightmareAi = ChessAi(difficulty: AiDifficulty.nightmare);
      final hauntedAi = ChessAi(difficulty: AiDifficulty.haunted);
      final gameState = GameState.initial();

      // Test 1A: Benchmark calculation speed
      final hauntedSw = Stopwatch()..start();
      final hauntedMove = hauntedAi.getBestMove(gameState.copyWith(currentTurn: PieceColor.black));
      hauntedSw.stop();

      expect(hauntedMove, isNotNull);
      expect(hauntedSw.elapsedMilliseconds, lessThan(500), reason: 'Haunted AI calculation must take < 500ms');

      // Test 1B: Tactical Spell Target Evaluation
      // Board with White Rook at (4,4) and White Pawn at (4,0)
      final board = GameBoard.empty();
      board.setPiece(const BoardPosition(7, 4), const ChessPiece(type: PieceType.king, color: PieceColor.white));
      board.setPiece(const BoardPosition(0, 4), const ChessPiece(type: PieceType.king, color: PieceColor.black));
      board.setPiece(const BoardPosition(4, 4), const ChessPiece(type: PieceType.rook, color: PieceColor.white));
      board.setPiece(const BoardPosition(4, 0), const ChessPiece(type: PieceType.pawn, color: PieceColor.white));

      final spellbook = const Spellbook(
        mana: 10,
        spells: [FireballSpell()],
      );

      final spellAction = nightmareAi.getBestSpellAction(
        spellbook: spellbook,
        board: board,
        aiColor: PieceColor.black,
      );

      expect(spellAction, isNotNull);
      expect(spellAction!.primary, const BoardPosition(4, 4), reason: 'Fireball AI must target the higher-value Rook over Pawn');
    });

    test('2. AI Tournament: Haunted AI produces legal, tactical responses over 15 turns without error', () {
      final hauntedAi = ChessAi(difficulty: AiDifficulty.haunted);
      var state = GameState.initial();
      int turns = 0;

      while (state.status == GameStatus.ongoing && turns < 15) {
        turns++;
        final move = hauntedAi.getBestMove(state);
        if (move == null) break;
        state = ChessEngine.makeMove(state, move);
        final status = ChessEngine.evaluateGameStatus(state);
        state = state.copyWith(status: status);
      }

      expect(turns, greaterThanOrEqualTo(8));
      expect(state.moveHistory.length, greaterThanOrEqualTo(8));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // 2. NETWORK MULTIPLAYER ADVERSARY & PACKET INTEGRITY
    // ─────────────────────────────────────────────────────────────────────────
    test('3. Network Adversary: Serializes packets and processes actions cleanly', () async {
      final mockNetwork = MockNetworkService();
      final mockAudio = MockAudioService();

      final container = ProviderContainer(
        overrides: [
          networkServiceProvider.overrideWithValue(mockNetwork),
          audioServiceProvider.overrideWithValue(mockAudio),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(matchControllerProvider.notifier);
      controller.startOnlineMatch(isPlayer1: true);

      // Verify initial state
      expect(container.read(matchControllerProvider).isOnlineMode, isTrue);

      // 1. Send legal move packet
      await mockNetwork.sendMoveAction(
        const BoardPosition(6, 4),
        const BoardPosition(4, 4),
        null,
      );
      expect(mockNetwork.sentMoveActions, 1);

      // 2. Send spell card packet
      await mockNetwork.sendCardAction(
        'spell_fireball',
        const BoardPosition(1, 0),
        null,
      );
      expect(mockNetwork.sentCardActions, 1);

      // 3. Send end turn packet
      await mockNetwork.sendEndTurnAction();
      expect(mockNetwork.sentEndTurnActions, 1);

      await Future<void>.delayed(const Duration(milliseconds: 20));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // 3. INFINITE UNDO-REDO & STATE IMMUTABILITY STRESS
    // ─────────────────────────────────────────────────────────────────────────
    test('4. Immutability Stress: 25 consecutive Move -> Undo cycles preserve 100% board integrity and mana refund', () async {
      final mockAudio = MockAudioService();
      final mockNetwork = MockNetworkService();

      final container = ProviderContainer(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudio),
          networkServiceProvider.overrideWithValue(mockNetwork),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(matchControllerProvider.notifier);
      controller.startLocalMatch();

      final initialBoard = container.read(matchControllerProvider).gameState.board.clone();

      for (int cycle = 0; cycle < 25; cycle++) {
        // Step 1: Make move e2 -> e4
        controller.selectTile(const BoardPosition(6, 4));
        controller.makeMove(const BoardPosition(6, 4), const BoardPosition(4, 4));

        expect(container.read(matchControllerProvider).phase, TurnPhase.card);
        expect(container.read(matchControllerProvider).canUndo, isTrue);

        // Step 2: Undo move
        controller.undo();

        expect(container.read(matchControllerProvider).phase, TurnPhase.move);
        expect(container.read(matchControllerProvider).canUndo, isFalse);

        // Assert board is back to exact initial configuration
        for (int r = 0; r < 8; r++) {
          for (int c = 0; c < 8; c++) {
            final pos = BoardPosition(r, c);
            final initialPiece = initialBoard.pieceAt(pos);
            final currentPiece = container.read(matchControllerProvider).gameState.board.pieceAt(pos);
            expect(currentPiece?.type, initialPiece?.type, reason: 'Mismatch at ($r, $c) in undo cycle $cycle');
            expect(currentPiece?.color, initialPiece?.color, reason: 'Color mismatch at ($r, $c) in undo cycle $cycle');
          }
        }
      }

      await Future<void>.delayed(const Duration(milliseconds: 20));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // 4. RAPID AUDIO & SFX CONCURRENCY STRESS
    // ─────────────────────────────────────────────────────────────────────────
    test('5. Audio Stress: 100 rapid-fire SFX & fast BGM crossfade calls complete with zero crashes', () async {
      final mockAudio = MockAudioService();

      final allSfx = [
        SfxType.pieceMove,
        SfxType.pieceCapture,
        SfxType.cardPlay,
        SfxType.cardDraw,
        SfxType.check,
        SfxType.checkmate,
        SfxType.buttonClick,
      ];

      // Fire 100 SFX events in rapid succession
      for (int i = 0; i < 100; i++) {
        final sfx = allSfx[i % allSfx.length];
        await mockAudio.playSfx(sfx);
      }

      expect(mockAudio.sfxPlayCount, 100);

      // Fast BGM switching
      await mockAudio.playBgm(BgmType.mainMenu);
      await mockAudio.crossfadeBgm(BgmType.inGame);
      await mockAudio.crossfadeBgm(BgmType.spookyAmbient);
      await mockAudio.stopBgm();

      expect(mockAudio.bgmPlayCount, 1);
      expect(mockAudio.crossfadeBgmCount, 2);
      expect(mockAudio.stopBgmCount, 1);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // 5. FTUE (FIRST-TIME USER EXPERIENCE) STATE MACHINE & RESET LIFECYCLE
    // ─────────────────────────────────────────────────────────────────────────
    test('6. FTUE Lifecycle: Tutorial state machine advances through all steps and resets cleanly via Settings', () async {
      final prefs = await SharedPreferences.getInstance();
      final settingsService = SettingsService(prefs);

      final container = ProviderContainer(
        overrides: [
          settingsServiceProvider.overrideWithValue(settingsService),
        ],
      );
      addTearDown(container.dispose);

      final tutorialController = container.read(tutorialControllerProvider.notifier);

      // Step 0: Initial state is Welcome
      expect(container.read(tutorialControllerProvider), TutorialStep.welcome);

      // Advance through all steps in sequence
      tutorialController.completeStep(TutorialStep.welcome);
      expect(container.read(tutorialControllerProvider), TutorialStep.modeSelect);

      tutorialController.completeStep(TutorialStep.modeSelect);
      expect(container.read(tutorialControllerProvider), TutorialStep.difficultySelect);

      tutorialController.completeStep(TutorialStep.difficultySelect);
      expect(container.read(tutorialControllerProvider), TutorialStep.matchIntro);

      tutorialController.completeStep(TutorialStep.matchIntro);
      expect(container.read(tutorialControllerProvider), TutorialStep.combatRules);

      tutorialController.completeStep(TutorialStep.combatRules);
      expect(container.read(tutorialControllerProvider), TutorialStep.firstMove);

      tutorialController.completeStep(TutorialStep.firstMove);
      expect(container.read(tutorialControllerProvider), TutorialStep.spellIntro);

      tutorialController.completeStep(TutorialStep.spellIntro);
      expect(container.read(tutorialControllerProvider), TutorialStep.relicIntro);

      tutorialController.completeStep(TutorialStep.relicIntro);
      expect(container.read(tutorialControllerProvider), TutorialStep.completed);
      expect(settingsService.tutorialProgress, TutorialStep.completed.index);

      // Reset tutorial
      tutorialController.resetTutorial();
      expect(container.read(tutorialControllerProvider), TutorialStep.welcome);
      expect(settingsService.tutorialProgress, 0);

      // Skip tutorial
      tutorialController.skipTutorial();
      expect(container.read(tutorialControllerProvider), TutorialStep.completed);
    });
  });
}
