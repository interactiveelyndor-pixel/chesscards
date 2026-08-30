class BoardPosition {
  final int row;
  final int col;

  const BoardPosition(this.row, this.col);

  bool get isValid => row >= 0 && row < 8 && col >= 0 && col < 8;

  BoardPosition offset(int dRow, int dCol) {
    return BoardPosition(row + dRow, col + dCol);
  }

  String get algebraic {
    if (!isValid) return 'Invalid';
    final colChar = String.fromCharCode(97 + col); // 97 is 'a'
    final rowChar = (8 - row).toString();
    return '$colChar$rowChar';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardPosition &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'BoardPosition($row, $col)';
}
