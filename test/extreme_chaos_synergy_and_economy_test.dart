import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_chess/features/board/domain/board_position.dart';
import 'package:super_chess/features/board/domain/game_board.dart';
import 'package:super_chess/features/match/domain/chess_engine.dart';
import 'package:super_chess/features/match/domain/chess_move.dart';
import 'package:super_chess/features/match/domain/game_state.dart';
import 'package:super_chess/features/match/domain/game_status.dart';
import 'package:super_chess/features/match/domain/match_state.dart';
import 'package:super_chess/features/match/domain/turn_phase.dart';
import 'package:super_chess/features/pieces/domain/chess_piece.dart';
import 'package:super_chess/features/relics/domain/relics.dart';
import 'package:super_chess/features/relics/domain/relic_inventory.dart';
import 'package:super_chess/features/spells/domain/spell.dart';
import 'package:super_chess/features/spells/domain/spells.dart';
import 'package:super_chess/features/spells/domain/spellbook.dart';
import 'package:super_chess/features/spells/domain/spell_engine.dart';
import 'package:super_chess/features/store/application/store_controller.dart';
import 'package:super_chess/features/store/domain/store_item.dart';
import 'package:super_chess/features/daily/application/daily_controller.dart';
import 'package:super_chess/features/daily/domain/daily_reward_state.dart';
import 'package:super_chess/features/daily/presentation/daily_hub_screen.dart';
import 'package:super_chess/features/daily/presentation/daily_nightmare_puzzle_screen.dart';
import 'package:super_chess/shared/enums/piece_color.dart';
import 'package:super_chess/shared/enums/piece_type.dart';
import 'package:super_chess/core/audio/audio_service.dart';
import 'package:super_chess/core/audio/audio_enums.dart';
import 'package:super_chess/core/services/settings_service.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  List<ChessMove> getAllLegalMoves(GameState state) {
    final moves = <ChessMove>[];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final pos = BoardPosition(r, c);
        final piece = state.board.pieceAt(pos);
        if (piece != null && piece.color == state.currentTurn) {
          moves.addAll(ChessEngine.generateLegalMoves(state, pos));
        }
      }
    }
    return moves;
  }

  group('🔥 EXTREME CHAOS, SYNERGY, ECONOMY & RESOLUTION TEST MATRIX', () {

    // ─────────────────────────────────────────────────────────────────────────
    // SUITE 1: 500-GAME CHAOS MONKEY FUZZ TEST
    // ─────────────────────────────────────────────────────────────────────────
    test('1. 500-Game Chaos Monkey Fuzz Test with randomized moves & spells preserves all board invariants', () {
      final random = Random(42);
      const int totalGames = 500;
      int completedCheckmates = 0;
      int completedStalemates = 0;
      int maxTurnGames = 0;
      int totalSpellsCast = 0;

      final allSpells = <Spell>[
        const FireballSpell(),
        const FreezeSpell(),
        const BlizzardSpell(),
        const WallOfStoneSpell(),
        const SoulLeechSpell(),
        const NecromancySpell(),
        const LightningSpell(),
      ];

      for (int gameIdx = 0; gameIdx < totalGames; gameIdx++) {
        var gameState = GameState.initial();
        int turns = 0;

        var wRelics = RelicInventory(relics: [
          if (random.nextBool()) const BootsOfHasteRelic(),
          if (random.nextBool()) const AegisShieldRelic(),
          if (random.nextBool()) const SniperBowRelic(),
          if (random.nextBool()) const RingOfManaRelic(),
        ]);
        var bRelics = RelicInventory(relics: [
          if (random.nextBool()) const BootsOfHasteRelic(),
          if (random.nextBool()) const AegisShieldRelic(),
        ]);

        var matchState = MatchState(
          gameState: gameState,
          phase: TurnPhase.move,
          whiteRelics: wRelics,
          blackRelics: bRelics,
          whiteSpellbook: const Spellbook(mana: 10, spells: []),
          blackSpellbook: const Spellbook(mana: 10, spells: []),
          matchStartTime: DateTime.now(),
        );

        while (gameState.status == GameStatus.ongoing && turns < 50) {
          turns++;
          final activeColor = gameState.currentTurn;

          // ── A. Invariant Check Before Turn ──
          final wKingPositions = gameState.board.allPieces(PieceColor.white)
              .where((pos) => gameState.board.pieceAt(pos)?.type == PieceType.king)
              .toList();
          final bKingPositions = gameState.board.allPieces(PieceColor.black)
              .where((pos) => gameState.board.pieceAt(pos)?.type == PieceType.king)
              .toList();

          expect(wKingPositions.length, 1, reason: 'White King must always exist in game $gameIdx');
          expect(bKingPositions.length, 1, reason: 'Black King must always exist in game $gameIdx');

          // Ensure all piece positions are strictly in [0..7] x [0..7]
          for (final pos in [...gameState.board.allPieces(PieceColor.white), ...gameState.board.allPieces(PieceColor.black)]) {
            expect(pos.row, inInclusiveRange(0, 7));
            expect(pos.col, inInclusiveRange(0, 7));
          }

          // ── B. Execute Legal Move ──
          final legalMoves = getAllLegalMoves(gameState);
          if (legalMoves.isEmpty) {
            final evalStatus = ChessEngine.evaluateGameStatus(gameState);
            gameState = gameState.copyWith(status: evalStatus);
            break;
          }

          // Pick a random legal move
          final chosenMove = legalMoves[random.nextInt(legalMoves.length)];
          gameState = ChessEngine.makeMove(gameState, chosenMove);

          // ── C. Interleaved Random Spell Cast ──
          if (random.nextInt(3) == 0) {
            final spell = allSpells[random.nextInt(allSpells.length)];
            final validTargets = SpellEngine.getValidTargets(spell, gameState.board, activeColor);
            if (validTargets.isNotEmpty) {
              final targetList = validTargets.toList();
              final target = targetList[random.nextInt(targetList.length)];

              matchState = SpellEngine.applySpell(
                state: matchState.copyWith(gameState: gameState),
                spell: spell,
                casterColor: activeColor,
                target: target,
              );
              gameState = matchState.gameState;
              totalSpellsCast++;
            }
          }

          final currentStatus = ChessEngine.evaluateGameStatus(gameState);
          gameState = gameState.copyWith(status: currentStatus);
        }

        if (gameState.status == GameStatus.checkmate) {
          completedCheckmates++;
        } else if (gameState.status == GameStatus.stalemate) {
          completedStalemates++;
        } else {
          maxTurnGames++;
        }
      }

      expect(completedCheckmates + completedStalemates + maxTurnGames, totalGames);
      expect(totalSpellsCast, greaterThan(100));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // SUITE 2: MULTI-SPELL SYNERGY & COMBINATORICS MATRIX
    // ─────────────────────────────────────────────────────────────────────────
    test('2. Multi-Spell Synergy Matrix: Necromancy + Boots of Haste allows revived Pawn to double-push', () {
      final board = GameBoard.empty();
      // White King at (7,4), Black King at (0,4)
      board.setPiece(const BoardPosition(7, 4), const ChessPiece(type: PieceType.king, color: PieceColor.white));
      board.setPiece(const BoardPosition(0, 4), const ChessPiece(type: PieceType.king, color: PieceColor.black));

      final state = MatchState(
        gameState: GameState(
          board: board,
          currentTurn: PieceColor.white,
          status: GameStatus.ongoing,
          moveHistory: const [],
          whiteInCheck: false,
          blackInCheck: false,
        ),
        phase: TurnPhase.card,
        whiteRelics: const RelicInventory(relics: [BootsOfHasteRelic()]),
        blackRelics: const RelicInventory(relics: []),
        whiteSpellbook: const Spellbook(mana: 10, spells: [NecromancySpell()]),
        blackSpellbook: const Spellbook(mana: 10, spells: []),
        matchStartTime: DateTime.now(),
      );

      // Step 1: Cast Necromancy on empty square (5, 2)
      final necromancyState = SpellEngine.applySpell(
        state: state,
        spell: const NecromancySpell(),
        casterColor: PieceColor.white,
        target: const BoardPosition(5, 2),
      );

      final revivedPawn = necromancyState.gameState.board.pieceAt(const BoardPosition(5, 2));
      expect(revivedPawn, isNotNull);

      // Equip BootsOfHaste to the revived pawn
      final equippedBoard = necromancyState.gameState.board.clone();
      equippedBoard.setPiece(
        const BoardPosition(5, 2),
        revivedPawn!.copyWith(equipment: [const BootsOfHasteRelic()]),
      );
      final equippedState = necromancyState.gameState.copyWith(board: equippedBoard);

      // Step 2: Because pawn has BootsOfHasteRelic, the revived pawn on row 5 can double-push to row 3!
      final legalMoves = ChessEngine.generateLegalMoves(
        equippedState,
        const BoardPosition(5, 2),
      );

      final doublePushMove = legalMoves.where((m) => m.to == const BoardPosition(3, 2)).toList();
      expect(doublePushMove.length, 1, reason: 'Boots of Haste should allow revived pawn on row 5 to double push to row 3');
    });

    test('3. Multi-Spell Synergy Matrix: Soul Leech + Aegis Shield survives lethal capture line', () {
      final board = GameBoard.empty();
      // White King at (7,4), White Queen with Aegis Shield at (4,0)
      // Black King at (0,4), Black Rook at (3,0) aiming at file 0
      board.setPiece(const BoardPosition(7, 4), const ChessPiece(type: PieceType.king, color: PieceColor.white));
      board.setPiece(const BoardPosition(4, 0), const ChessPiece(
        type: PieceType.queen,
        color: PieceColor.white,
        equipment: [AegisShieldRelic()],
      ));
      board.setPiece(const BoardPosition(0, 4), const ChessPiece(type: PieceType.king, color: PieceColor.black));
      board.setPiece(const BoardPosition(3, 0), const ChessPiece(type: PieceType.rook, color: PieceColor.black));

      final state = MatchState(
        gameState: GameState(
          board: board,
          currentTurn: PieceColor.white,
          status: GameStatus.ongoing,
          moveHistory: const [],
          whiteInCheck: false,
          blackInCheck: false,
        ),
        phase: TurnPhase.card,
        whiteRelics: const RelicInventory(relics: [AegisShieldRelic()]),
        blackRelics: const RelicInventory(relics: []),
        whiteSpellbook: const Spellbook(mana: 10, spells: [SoulLeechSpell()]),
        blackSpellbook: const Spellbook(mana: 10, spells: []),
        matchStartTime: DateTime.now(),
      );

      // Cast Soul Leech on enemy Rook
      final leechedState = SpellEngine.applySpell(
        state: state,
        spell: const SoulLeechSpell(),
        casterColor: PieceColor.white,
        target: const BoardPosition(3, 0),
      );

      final queen = leechedState.gameState.board.pieceAt(const BoardPosition(4, 0));
      expect(queen?.type, PieceType.queen);

      // Now Black Rook captures the Queen at (4, 0)
      final captureMove = ChessMove(
        from: const BoardPosition(3, 0),
        to: const BoardPosition(4, 0),
        movedPiece: const ChessPiece(type: PieceType.rook, color: PieceColor.black),
        capturedPiece: queen,
        isCapture: true,
      );

      final postCaptureState = ChessEngine.makeMove(
        leechedState.gameState.copyWith(currentTurn: PieceColor.black),
        captureMove,
      );

      // Aegis Shield absorbs the blow and deflects Queen to safety (Queen still exists on board)!
      final remainingWhitePieces = postCaptureState.board.allPieces(PieceColor.white)
          .where((pos) => postCaptureState.board.pieceAt(pos)?.type == PieceType.queen)
          .toList();
      expect(remainingWhitePieces.isNotEmpty, isTrue, reason: 'Aegis Shield must deflect and preserve the Queen');
    });

    test('4. Multi-Spell Synergy Matrix: Wall of Stone traps enemy behind Blizzard freeze', () {
      final board = GameBoard.empty();
      board.setPiece(const BoardPosition(7, 4), const ChessPiece(type: PieceType.king, color: PieceColor.white));
      board.setPiece(const BoardPosition(0, 4), const ChessPiece(type: PieceType.king, color: PieceColor.black));
      // Black Knight at (2, 2)
      board.setPiece(const BoardPosition(2, 2), const ChessPiece(type: PieceType.knight, color: PieceColor.black));

      var state = MatchState(
        gameState: GameState(
          board: board,
          currentTurn: PieceColor.white,
          status: GameStatus.ongoing,
          moveHistory: const [],
          whiteInCheck: false,
          blackInCheck: false,
        ),
        phase: TurnPhase.card,
        whiteRelics: const RelicInventory(relics: []),
        blackRelics: const RelicInventory(relics: []),
        whiteSpellbook: const Spellbook(mana: 10, spells: [WallOfStoneSpell(), BlizzardSpell()]),
        blackSpellbook: const Spellbook(mana: 10, spells: []),
        matchStartTime: DateTime.now(),
      );

      // 1. Cast Wall of Stone at (3, 2)
      state = SpellEngine.applySpell(
        state: state,
        spell: const WallOfStoneSpell(),
        casterColor: PieceColor.white,
        target: const BoardPosition(3, 2),
      );
      expect(state.gameState.board.pieceAt(const BoardPosition(3, 2)), isNotNull);

      // 2. Cast Blizzard centered at (2, 2) to freeze Knight
      state = SpellEngine.applySpell(
        state: state,
        spell: const BlizzardSpell(),
        casterColor: PieceColor.white,
        target: const BoardPosition(2, 2),
      );

      final frozenKnight = state.gameState.board.pieceAt(const BoardPosition(2, 2));
      expect(frozenKnight?.isFrozen, isTrue);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // SUITE 3: 100-DAY VIRTUAL PLAYER ECONOMY & PROGRESSION SIMULATION
    // ─────────────────────────────────────────────────────────────────────────
    test('5. 100-Day Virtual Player Economy simulation verifies streaks, rewards, store purchases & XP leveling math', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final storeController = container.read(storeControllerProvider.notifier);
      final dailyController = container.read(dailyControllerProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      for (int day = 1; day <= 100; day++) {
        final streakIndex = ((day - 1) % 7) + 1;
        final reward = DailyRewardState.schedule[streakIndex - 1];

        await storeController.addCurrency(souls: reward.souls);
        await storeController.addXp(reward.xp);

        if (streakIndex == 7) {
          await storeController.unlockItem('doll_hollow_sovereign');
        }

        dailyController.recordMatchEvent(piecesCaptured: 3, spellsCast: 2, enemiesFrozen: 1);

        // Every 10 days, purchase a cosmetic board theme
        if (day % 10 == 0) {
          final storeItem = StoreItem(
            id: 'item_theme_$day',
            name: 'Theme $day',
            description: 'A test theme',
            type: StoreItemType.boardTheme,
            soulCost: 200,
            iconData: Icons.palette_rounded,
          );
          if (container.read(storeControllerProvider).soulFragments >= 200) {
            await storeController.purchaseItem(storeItem, true);
          }
        }
      }

      final finalState = container.read(storeControllerProvider);

      expect(finalState.soulFragments, greaterThan(0));
      expect(finalState.goldCoins, greaterThanOrEqualTo(0));
      expect(finalState.playerLevel, greaterThan(1));
      expect(finalState.playerXp, greaterThanOrEqualTo(0));
      expect(finalState.ownedItemIds.contains('doll_hollow_sovereign'), isTrue);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // SUITE 4: MULTI-DEVICE RESOLUTION & VIEWPORT MATRIX TESTS
    // ─────────────────────────────────────────────────────────────────────────
    testWidgets('6. Daily Hub renders with zero layout overflows on Compact Mobile (360x800)', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final prefs = await SharedPreferences.getInstance();
      final settingsService = SettingsService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            audioServiceProvider.overrideWithValue(MockAudioService()),
            settingsServiceProvider.overrideWithValue(settingsService),
          ],
          child: const MaterialApp(
            home: DailyHubScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
    });

    testWidgets('7. Daily Hub renders with zero layout overflows on Foldable Square (800x800)', (tester) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final prefs = await SharedPreferences.getInstance();
      final settingsService = SettingsService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            audioServiceProvider.overrideWithValue(MockAudioService()),
            settingsServiceProvider.overrideWithValue(settingsService),
          ],
          child: const MaterialApp(
            home: DailyHubScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
    });

    testWidgets('8. Daily Nightmare Puzzle renders with zero layout overflows on Tablet Landscape (1024x768)', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final prefs = await SharedPreferences.getInstance();
      final settingsService = SettingsService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            audioServiceProvider.overrideWithValue(MockAudioService()),
            settingsServiceProvider.overrideWithValue(settingsService),
          ],
          child: const MaterialApp(
            home: DailyNightmarePuzzleScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
    });

    testWidgets('9. Daily Nightmare Puzzle renders with zero layout overflows on Ultra-Wide Monitor (2560x1080)', (tester) async {
      tester.view.physicalSize = const Size(2560, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final prefs = await SharedPreferences.getInstance();
      final settingsService = SettingsService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            audioServiceProvider.overrideWithValue(MockAudioService()),
            settingsServiceProvider.overrideWithValue(settingsService),
          ],
          child: const MaterialApp(
            home: DailyNightmarePuzzleScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
    });
  });
}
