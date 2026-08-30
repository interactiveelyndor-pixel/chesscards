enum PieceColor {
  white,
  black;

  PieceColor get opposite {
    return this == PieceColor.white ? PieceColor.black : PieceColor.white;
  }
}
