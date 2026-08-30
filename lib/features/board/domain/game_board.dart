import 'board_position.dart';
import '../../pieces/domain/chess_piece.dart';
import '../../../shared/enums/piece_color.dart';
import '../../../shared/enums/piece_type.dart';

class GameBoard {
  final List<List<ChessPiece?>> squares;

  GameBoard(this.squares);

  factory GameBoard.initial() {
    final List<List<ChessPiece?>> initialSquares = List.generate(
      8,
      (_) => List.generate(8, (_) => null),
    );

    // Setup Black pieces (row 0 & 1)
    _setupRow(initialSquares, 0, PieceColor.black);
    _setupPawns(initialSquares, 1, PieceColor.black);

    // Setup White pieces (row 7 & 6)
    _setupRow(initialSquares, 7, PieceColor.white);
    _setupPawns(initialSquares, 6, PieceColor.white);

    return GameBoard(initialSquares);
  }

  factory GameBoard.empty() {
    return GameBoard(
      List.generate(8, (_) => List.generate(8, (_) => null)),
    );
  }

  static void _setupRow(List<List<ChessPiece?>> squares, int row, PieceColor color) {
    const types = [
      PieceType.rook,
      PieceType.knight,
      PieceType.bishop,
      PieceType.queen,
      PieceType.king,
      PieceType.bishop,
      PieceType.knight,
      PieceType.rook,
    ];
    for (int col = 0; col < 8; col++) {
      squares[row][col] = ChessPiece(type: types[col], color: color);
    }
  }

  static void _setupPawns(List<List<ChessPiece?>> squares, int row, PieceColor color) {
    for (int col = 0; col < 8; col++) {
      squares[row][col] = ChessPiece(type: PieceType.pawn, color: color);
    }
  }

  ChessPiece? pieceAt(BoardPosition pos) {
    if (!pos.isValid) return null;
    return squares[pos.row][pos.col];
  }

  void setPiece(BoardPosition pos, ChessPiece? piece) {
    if (!pos.isValid) return;
    squares[pos.row][pos.col] = piece;
  }

  void movePiece(BoardPosition from, BoardPosition to) {
    if (!from.isValid || !to.isValid) return;
    final piece = pieceAt(from);
    setPiece(to, piece);
    setPiece(from, null);
  }

  GameBoard clone() {
    final List<List<ChessPiece?>> newSquares = List.generate(
      8,
      (row) => List.generate(
        8,
        (col) => squares[row][col],
      ),
    );
    return GameBoard(newSquares);
  }

  List<BoardPosition> allPieces(PieceColor color) {
    final positions = <BoardPosition>[];
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = squares[row][col];
        if (piece != null && piece.color == color) {
          positions.add(BoardPosition(row, col));
        }
      }
    }
    return positions;
  }

  BoardPosition? kingPosition(PieceColor color) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = squares[row][col];
        if (piece != null && piece.color == color && piece.type == PieceType.king) {
          return BoardPosition(row, col);
        }
      }
    }
    return null;
  }
}
