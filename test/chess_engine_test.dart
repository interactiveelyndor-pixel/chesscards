import 'package:flutter_test/flutter_test.dart';
import 'package:super_chess/features/board/domain/board_position.dart';
import 'package:super_chess/features/match/domain/chess_engine.dart';
import 'package:super_chess/features/match/domain/game_state.dart';
import 'package:super_chess/shared/enums/piece_color.dart';

void main() {
  group('Chess Engine Tests', () {
    test('Initial setup has 32 pieces and correct kings', () {
      final state = GameState.initial();
      final whitePieces = state.board.allPieces(PieceColor.white);
      final blackPieces = state.board.allPieces(PieceColor.black);

      expect(whitePieces.length, 16);
      expect(blackPieces.length, 16);
      expect(state.board.kingPosition(PieceColor.white), const BoardPosition(7, 4));
      expect(state.board.kingPosition(PieceColor.black), const BoardPosition(0, 4));
    });

    test('Pawn single & double move at start', () {
      final state = GameState.initial();
      final moves = ChessEngine.generateLegalMoves(state, const BoardPosition(6, 4)); // e2 pawn

      expect(moves.length, 2);
      expect(moves.any((m) => m.to == const BoardPosition(5, 4)), isTrue);
      expect(moves.any((m) => m.to == const BoardPosition(4, 4)), isTrue);
    });

    test('Knight jumping over pawns', () {
      final state = GameState.initial();
      final moves = ChessEngine.generateLegalMoves(state, const BoardPosition(7, 1)); // b1 knight

      expect(moves.length, 2);
      expect(moves.any((m) => m.to == const BoardPosition(5, 0)), isTrue);
      expect(moves.any((m) => m.to == const BoardPosition(5, 2)), isTrue);
    });

    test('Frozen piece cannot move', () {
      final state = GameState.initial();
      final board = state.board.clone();
      final piece = board.pieceAt(const BoardPosition(6, 4))!;
      board.setPiece(const BoardPosition(6, 4), piece.copyWith(isFrozen: true));
      final frozenState = state.copyWith(board: board);

      final moves = ChessEngine.generateLegalMoves(frozenState, const BoardPosition(6, 4));
      expect(moves.isEmpty, isTrue);
    });
  });
}
