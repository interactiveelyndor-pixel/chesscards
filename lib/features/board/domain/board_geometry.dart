import 'dart:ui';
import '../presentation/models/board_tile.dart';

class BoardGeometry {
  /// Converts a board row/col to a screen offset relative to the board's origin (top-left).
  /// Returns the CENTER of the tile.
  static Offset boardToScreen(int row, int col, double tileWidth, double tileHeight, {bool isFlipped = false}) {
    final int effectiveCol = isFlipped ? 7 - col : col;
    final int effectiveRow = isFlipped ? 7 - row : row;
    final double screenX = effectiveCol * tileWidth + (tileWidth / 2);
    final double screenY = effectiveRow * tileHeight + (tileHeight / 2);
    return Offset(screenX, screenY);
  }

  /// Converts a screen offset (relative to board's origin) to a BoardTile.
  /// Returns null if the calculated tile is outside the 8x8 bounds.
  static BoardTile? screenToBoard(Offset point, double tileWidth, double tileHeight, {bool isFlipped = false}) {
    final int col = (point.dx / tileWidth).floor();
    final int row = (point.dy / tileHeight).floor();

    if (isValidTile(row, col)) {
      final int actualRow = isFlipped ? 7 - row : row;
      final int actualCol = isFlipped ? 7 - col : col;
      return BoardTile(actualRow, actualCol);
    }
    return null;
  }

  /// Checks if the row/col is within the 8x8 grid bounds.
  static bool isValidTile(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }
}
