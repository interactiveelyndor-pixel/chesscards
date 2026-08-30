import '../../../shared/enums/piece_color.dart';
import '../../../shared/enums/piece_type.dart';
import '../../relics/domain/relic.dart';

class ChessPiece {
  final PieceType type;
  final PieceColor color;
  final bool hasMoved;
  final bool isFrozen;
  final bool hasShield;
  final bool hasPhantomStep;
  final List<Relic> equipment;

  const ChessPiece({
    required this.type,
    required this.color,
    this.hasMoved = false,
    this.isFrozen = false,
    this.hasShield = false,
    this.hasPhantomStep = false,
    this.equipment = const [],
  });

  ChessPiece copyWith({
    PieceType? type,
    PieceColor? color,
    bool? hasMoved,
    bool? isFrozen,
    bool? hasShield,
    bool? hasPhantomStep,
    List<Relic>? equipment,
  }) {
    return ChessPiece(
      type: type ?? this.type,
      color: color ?? this.color,
      hasMoved: hasMoved ?? this.hasMoved,
      isFrozen: isFrozen ?? this.isFrozen,
      hasShield: hasShield ?? this.hasShield,
      hasPhantomStep: hasPhantomStep ?? this.hasPhantomStep,
      equipment: equipment ?? this.equipment,
    );
  }

  String get symbol {
    switch (type) {
      case PieceType.king:
        return color == PieceColor.white ? '♔' : '♚';
      case PieceType.queen:
        return color == PieceColor.white ? '♕' : '♛';
      case PieceType.rook:
        return color == PieceColor.white ? '♖' : '♜';
      case PieceType.bishop:
        return color == PieceColor.white ? '♗' : '♝';
      case PieceType.knight:
        return color == PieceColor.white ? '♘' : '♞';
      case PieceType.pawn:
        return color == PieceColor.white ? '♙' : '♟';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChessPiece &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          color == other.color &&
          hasMoved == other.hasMoved &&
          isFrozen == other.isFrozen &&
          hasShield == other.hasShield &&
          hasPhantomStep == other.hasPhantomStep;

  @override
  int get hashCode =>
      type.hashCode ^ color.hashCode ^ hasMoved.hashCode ^ isFrozen.hashCode ^ hasShield.hashCode ^ hasPhantomStep.hashCode;
      
  @override
  String toString() => '${color.name} ${type.name}';
}
