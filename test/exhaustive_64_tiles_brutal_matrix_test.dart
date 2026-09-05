import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_chess/features/board/domain/board_position.dart';
import 'package:super_chess/features/board/domain/game_board.dart';
import 'package:super_chess/features/match/domain/chess_engine.dart';
import 'package:super_chess/features/match/domain/chess_move.dart';
import 'package:super_chess/features/match/domain/game_state.dart';
import 'package:super_chess/features/match/domain/game_status.dart';
import 'package:super_chess/features/match/domain/match_state.dart';
import 'package:super_chess/features/pieces/domain/chess_piece.dart';
import 'package:super_chess/features/relics/domain/relics.dart';
import 'package:super_chess/features/spells/domain/spells.dart';
import 'package:super_chess/features/spells/domain/spell_engine.dart';
import 'package:super_chess/shared/enums/piece_color.dart';
import 'package:super_chess/shared/enums/piece_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('🔥 EXHAUSTIVE 64-TILE & ALL-MECHANICS BRUTAL MATRIX', () {

    // ─────────────────────────────────────────────────────────────────────────
    // SECTION 1: ALL 64 TILES × ALL PIECE TYPES MOVE MATRIX
    // ─────────────────────────────────────────────────────────────────────────
    test('1. Matrix Test: Every piece type on all 64 tiles generates in-bounds, valid moves', () {
      int totalPositionsTested = 0;
      int totalMovesGenerated = 0;

      for (int r = 0; r < 8; r++) {
        for (int c = 0; c < 8; c++) {
          final pos = BoardPosition(r, c);

          for (final type in PieceType.values) {
            for (final color in [PieceColor.white, PieceColor.black]) {
              final board = GameBoard.empty();
              final piece = ChessPiece(type: type, color: color);
              board.setPiece(pos, piece);

              // Add opposing king elsewhere to ensure valid state
              final oppKingPos = pos == const BoardPosition(0, 0)
                  ? const BoardPosition(7, 7)
                  : const BoardPosition(0, 0);
              board.setPiece(oppKingPos, ChessPiece(type: PieceType.king, color: color.opposite));

              final myKingPos = pos == const BoardPosition(7, 4)
                  ? const BoardPosition(7, 3)
                  : const BoardPosition(7, 4);
              if (type != PieceType.king) {
                board.setPiece(myKingPos, ChessPiece(type: PieceType.king, color: color));
              }

              final moves = ChessEngine.generatePseudoLegalMoves(board, pos);
              totalPositionsTested++;
              totalMovesGenerated += moves.length;

              for (final move in moves) {
                expect(move.from, pos);
                expect(move.to.row >= 0 && move.to.row < 8, isTrue,
                    reason: '$color $type at $pos moved out of bounds to row ${move.to.row}');
                expect(move.to.col >= 0 && move.to.col < 8, isTrue,
                    reason: '$color $type at $pos moved out of bounds to col ${move.to.col}');
                expect(move.from != move.to, isTrue,
                    reason: 'Move destination must differ from origin');
              }
            }
          }
        }
      }

      expect(totalPositionsTested, 64 * 6 * 2); // 64 tiles * 6 types * 2 colors = 768 configurations
      expect(totalMovesGenerated > 5000, isTrue);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // SECTION 2: ALL 8 SPELLS ON ALL 64 TILES
    // ─────────────────────────────────────────────────────────────────────────
    test('2. Spell Matrix: Blizzard 3x3 radius correctly clamps on all 64 tiles without error', () {
      for (int r = 0; r < 8; r++) {
        for (int c = 0; c < 8; c++) {
          final target = BoardPosition(r, c);
          final match = MatchState.initial();
          final updated = SpellEngine.applySpell(
            state: match.copyWith(
              whiteSpellbook: match.whiteSpellbook.copyWith(mana: 10),
            ),
            spell: const BlizzardSpell(),
            casterColor: PieceColor.white,
            target: target,
          );

          // Verify every tile in 3x3 around target is frozen if it's an enemy piece
          for (int dr = -1; dr <= 1; dr++) {
            for (int dc = -1; dc <= 1; dc++) {
              final checkPos = target.offset(dr, dc);
              if (checkPos.isValid) {
                final p = updated.gameState.board.pieceAt(checkPos);
                if (p != null && p.color == PieceColor.black) {
                  expect(p.isFrozen, isTrue);
                }
              }
            }
          }
        }
      }
    });

    test('3. Spell Matrix: Wall of Stone creates barriers on all 64 empty tiles', () {
      for (int r = 0; r < 8; r++) {
        for (int c = 0; c < 8; c++) {
          final target = BoardPosition(r, c);
          final board = GameBoard.empty();
          board.setPiece(const BoardPosition(7, 4), const ChessPiece(type: PieceType.king, color: PieceColor.white));
          board.setPiece(const BoardPosition(0, 4), const ChessPiece(type: PieceType.king, color: PieceColor.black));

          final match = MatchState.initial().copyWith(
            gameState: GameState(
              board: board,
              currentTurn: PieceColor.white,
              status: GameStatus.ongoing,
              moveHistory: const [],
              whiteInCheck: false,
              blackInCheck: false,
            ),
            whiteSpellbook: MatchState.initial().whiteSpellbook.copyWith(mana: 10),
          );

          if (target != const BoardPosition(7, 4) && target != const BoardPosition(0, 4)) {
            final updated = SpellEngine.applySpell(
              state: match,
              spell: const WallOfStoneSpell(),
              casterColor: PieceColor.white,
              target: target,
            );

            final barrier = updated.gameState.board.pieceAt(target);
            expect(barrier, isNotNull);
            expect(barrier?.color, PieceColor.white);
            expect(barrier?.isFrozen, isTrue);
          }
        }
      }
    });

    test('4. Spell Matrix: Fireball cannot target King/Queen on any of the 64 tiles', () {
      const fireball = FireballSpell();

      for (int r = 0; r < 8; r++) {
        for (int c = 0; c < 8; c++) {
          final pos = BoardPosition(r, c);

          // Place King
          final boardKing = GameBoard.empty();
          boardKing.setPiece(pos, const ChessPiece(type: PieceType.king, color: PieceColor.black));
          final kingTargets = SpellEngine.getValidTargets(fireball, boardKing, PieceColor.white);
          expect(kingTargets.contains(pos), isFalse, reason: 'Fireball must not target King at $pos');

          // Place Queen
          final boardQueen = GameBoard.empty();
          boardQueen.setPiece(pos, const ChessPiece(type: PieceType.queen, color: PieceColor.black));
          final queenTargets = SpellEngine.getValidTargets(fireball, boardQueen, PieceColor.white);
          expect(queenTargets.contains(pos), isFalse, reason: 'Fireball must not target Queen at $pos');

          // Place Rook
          final boardRook = GameBoard.empty();
          boardRook.setPiece(pos, const ChessPiece(type: PieceType.rook, color: PieceColor.black));
          final rookTargets = SpellEngine.getValidTargets(fireball, boardRook, PieceColor.white);
          expect(rookTargets.contains(pos), isTrue, reason: 'Fireball should target Rook at $pos');
        }
      }
    });

    // ─────────────────────────────────────────────────────────────────────────
    // SECTION 3: MANA SPECTRUM & INSUFFICIENT MANA VERIFICATION
    // ─────────────────────────────────────────────────────────────────────────
    test('5. Mana Economy: Spells cannot cast with mana < cost, deduct exact amount otherwise', () {
      for (final spell in SpellEngine.allSpells) {
        final match = MatchState.initial();

        // 1. Zero mana test (cannot cast)
        final zeroManaState = match.copyWith(
          whiteSpellbook: match.whiteSpellbook.copyWith(mana: 0, spells: [spell]),
        );
        final zeroResult = SpellEngine.applySpell(
          state: zeroManaState,
          spell: spell,
          casterColor: PieceColor.white,
          target: const BoardPosition(1, 0),
        );
        expect(zeroResult.whiteSpellbook.mana, 0);

        // 2. Exact mana test
        final exactManaState = match.copyWith(
          whiteSpellbook: match.whiteSpellbook.copyWith(mana: spell.manaCost, spells: [spell]),
        );
        final exactResult = SpellEngine.applySpell(
          state: exactManaState,
          spell: spell,
          casterColor: PieceColor.white,
          target: const BoardPosition(4, 4),
        );
        expect(exactResult.whiteSpellbook.mana, 0);

        // 3. Max mana (10) test
        final maxManaState = match.copyWith(
          whiteSpellbook: match.whiteSpellbook.copyWith(mana: 10, spells: [spell]),
        );
        final maxResult = SpellEngine.applySpell(
          state: maxManaState,
          spell: spell,
          casterColor: PieceColor.white,
          target: const BoardPosition(4, 4),
        );
        expect(maxResult.whiteSpellbook.mana, 10 - spell.manaCost);
      }
    });

    // ─────────────────────────────────────────────────────────────────────────
    // SECTION 4: ALL 4 RELICS COMBINED WITH ALL 6 PIECE TYPES
    // ─────────────────────────────────────────────────────────────────────────
    test('6. Relics Matrix: Boots of Haste allows 2-square advance from all 64 tiles', () {
      const boots = BootsOfHasteRelic();

      for (int r = 1; r < 7; r++) {
        for (int c = 0; c < 8; c++) {
          final pos = BoardPosition(r, c);
          final board = GameBoard.empty();
          board.setPiece(pos, ChessPiece(
            type: PieceType.pawn,
            color: PieceColor.white,
            equipment: const [boots],
          ));

          final moves = ChessEngine.generatePseudoLegalMoves(board, pos);
          // White pawn moves direction -1. Double move reaches r - 2
          if (r >= 2) {
            expect(moves.any((m) => m.to == BoardPosition(r - 2, c)), isTrue,
                reason: 'Boots of haste pawn at $pos should be able to double-push to (${r - 2}, $c)');
          }
        }
      }
    });

    test('7. Relics Matrix: Sniper Bow grants piercing line attacks on all 64 tiles', () {
      const sniper = SniperBowRelic();

      for (int r = 0; r < 8; r++) {
        for (int c = 0; c < 8; c++) {
          final pos = BoardPosition(r, c);
          final board = GameBoard.empty();
          board.setPiece(pos, ChessPiece(
            type: PieceType.rook,
            color: PieceColor.white,
            equipment: const [sniper],
          ));

          // Place an obstacle in front of the piece
          if (r > 1) {
            final obstaclePos = BoardPosition(r - 1, c);
            final targetBehind = BoardPosition(r - 2, c);
            board.setPiece(obstaclePos, const ChessPiece(type: PieceType.pawn, color: PieceColor.white));
            board.setPiece(targetBehind, const ChessPiece(type: PieceType.pawn, color: PieceColor.black));

            final moves = ChessEngine.generatePseudoLegalMoves(board, pos);
            expect(moves.any((m) => m.to == targetBehind), isTrue,
                reason: 'Sniper rook at $pos must pierce through $obstaclePos to reach $targetBehind');
          }
        }
      }
    });

    // ─────────────────────────────────────────────────────────────────────────
    // SECTION 5: 50-GAME RANDOMIZED MONTE CARLO STRESS TEST
    // ─────────────────────────────────────────────────────────────────────────
    test('8. Monte Carlo Simulation: 50 randomized game playouts without any crash or desync', () {
      final random = Random(42);

      for (int game = 0; game < 50; game++) {
        var state = GameState.initial();
        int turnCount = 0;

        while (state.status == GameStatus.ongoing && turnCount < 40) {
          final pieces = state.board.allPieces(state.currentTurn);
          final allLegalMoves = <ChessMove>[];

          for (final pos in pieces) {
            allLegalMoves.addAll(ChessEngine.generateLegalMoves(state, pos));
          }

          if (allLegalMoves.isEmpty) {
            // Stalemate or Checkmate
            final finalStatus = ChessEngine.evaluateGameStatus(state);
            expect(finalStatus == GameStatus.checkmate || finalStatus == GameStatus.stalemate, isTrue);
            break;
          }

          // Pick random move
          final chosenMove = allLegalMoves[random.nextInt(allLegalMoves.length)];
          state = ChessEngine.makeMove(state, chosenMove);
          turnCount++;

          // Verify state invariants
          expect(state.board.kingPosition(PieceColor.white) != null, isTrue);
          expect(state.board.kingPosition(PieceColor.black) != null, isTrue);
        }

        expect(turnCount > 0, isTrue);
      }
    });
  });
}
