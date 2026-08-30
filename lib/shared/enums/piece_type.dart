enum PieceType {
  king,
  queen,
  rook,
  bishop,
  knight,
  pawn;

  String get shortName {
    switch (this) {
      case PieceType.king:
        return 'K';
      case PieceType.queen:
        return 'Q';
      case PieceType.rook:
        return 'R';
      case PieceType.bishop:
        return 'B';
      case PieceType.knight:
        return 'N';
      case PieceType.pawn:
        return 'P';
    }
  }

  String get displayName {
    return name[0].toUpperCase() + name.substring(1);
  }
}
