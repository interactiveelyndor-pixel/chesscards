import '../../board/domain/board_position.dart';
import '../../pieces/domain/chess_piece.dart';
import '../../../shared/enums/piece_type.dart';

class ChessMove {
  final BoardPosition from;
  final BoardPosition to;
  final ChessPiece movedPiece;
  final ChessPiece? capturedPiece;
  final bool isCapture;
  final bool isPromotion;
  final bool isCastling;
  final PieceType? promotionType;
  final PieceType? promotionChoice;

  const ChessMove({
    required this.from,
    required this.to,
    required this.movedPiece,
    this.capturedPiece,
    this.isCapture = false,
    this.isPromotion = false,
    this.isCastling = false,
    this.promotionType,
    this.promotionChoice,
  });

  ChessMove copyWith({
    BoardPosition? from,
    BoardPosition? to,
    ChessPiece? movedPiece,
    ChessPiece? capturedPiece,
    bool? isCapture,
    bool? isPromotion,
    bool? isCastling,
    PieceType? promotionType,
    PieceType? promotionChoice,
  }) {
    return ChessMove(
      from: from ?? this.from,
      to: to ?? this.to,
      movedPiece: movedPiece ?? this.movedPiece,
      capturedPiece: capturedPiece ?? this.capturedPiece,
      isCapture: isCapture ?? this.isCapture,
      isPromotion: isPromotion ?? this.isPromotion,
      isCastling: isCastling ?? this.isCastling,
      promotionType: promotionType ?? this.promotionType,
      promotionChoice: promotionChoice ?? this.promotionChoice,
    );
  }

  String get algebraicDescription {
    if (isCastling) {
      return to.col > from.col ? 'O-O' : 'O-O-O';
    }
    String desc = '';
    if (movedPiece.type != PieceType.pawn) desc += movedPiece.type.shortName;
    if (isCapture) {
      if (movedPiece.type == PieceType.pawn) desc += String.fromCharCode(97 + from.col);
      desc += 'x';
    }
    desc += to.algebraic;
    final chosen = promotionChoice ?? promotionType;
    if (isPromotion && chosen != null) desc += '=${chosen.shortName}';
    return desc;
  }
}
