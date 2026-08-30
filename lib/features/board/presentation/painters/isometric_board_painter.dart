import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/board_geometry.dart';
import '../models/board_tile.dart';
import '../../../match/domain/game_state.dart';
import '../../domain/board_position.dart';
import '../../../match/domain/chess_move.dart';
import 'handdrawn_piece_painter.dart';

class IsometricBoardPainter extends CustomPainter {
  final GameState? gameState;
  final BoardTile? selectedTile;
  final BoardTile? hoveredTile;
  final Set<BoardPosition> highlightedMoves;
  final Set<BoardPosition> validCardTargets;
  final Set<BoardPosition> validSpellTargets;
  final ChessMove? animatingMove;
  final double moveAnimationProgress;
  final double tileWidth;
  final double tileHeight;
  final double glowAnimationValue;
  final String? equippedBoardId;

  IsometricBoardPainter({
    this.gameState,
    this.selectedTile,
    this.hoveredTile,
    this.highlightedMoves = const {},
    this.validCardTargets = const {},
    this.validSpellTargets = const {},
    this.animatingMove,
    this.moveAnimationProgress = 0.0,
    required this.tileWidth,
    required this.tileHeight,
    this.glowAnimationValue = 1.0,
    this.equippedBoardId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Center the 8x8 grid on the canvas
    canvas.translate((size.width - 8 * tileWidth) / 2, (size.height - 8 * tileHeight) / 2);

    _drawBoardShadow(canvas);

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        _drawTile(canvas, row, col);
      }
    }

    _drawBoardBorder(canvas);
    _drawCoordinates(canvas);
    if (gameState != null) {
      _drawPieces(canvas);
    }
  }

  void _drawBoardShadow(Canvas canvas) {
    // Outer glow behind the whole board
    canvas.drawRect(
      Rect.fromLTWH(-12, -12, 8 * tileWidth + 24, 8 * tileHeight + 24),
      Paint()
        ..color = AppColors.cursePurple.withValues(alpha: 0.25 + glowAnimationValue * 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 8 * tileWidth, 8 * tileHeight),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
  }

  void _drawBoardBorder(Canvas canvas) {
    final boardRect = Rect.fromLTWH(-1, -1, 8 * tileWidth + 2, 8 * tileHeight + 2);
    // Glowing border
    canvas.drawRect(
      boardRect,
      Paint()
        ..color = AppColors.cursePurple.withValues(alpha: 0.5 + glowAnimationValue * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8),
    );
    // Crisp inner border
    canvas.drawRect(
      boardRect,
      Paint()
        ..color = AppColors.cursePurple.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawTile(Canvas canvas, int row, int col) {
    final bool isDark = (row + col) % 2 != 0;

    final Offset center = BoardGeometry.boardToScreen(row, col, tileWidth, tileHeight);
    final Rect tileRect = Rect.fromCenter(center: center, width: tileWidth, height: tileHeight);
    final Path path = Path()..addRect(tileRect);

    final bool isSelected = selectedTile?.row == row && selectedTile?.col == col;
    final bool isHovered = hoveredTile?.row == row && hoveredTile?.col == col;

    Color tileBase;
    Color tileDark;
    
    if (equippedBoardId == 'board_void_marble') {
      tileBase = isDark ? AppColors.abyssBlack : const Color(0xFFCBD5E1);
      tileDark = isDark ? const Color(0xFF0F0B18) : const Color(0xFF94A3B8);
    } else {
      // Iconic Gothic Crimson Red & Warm Ivory Chessboard
      tileBase = isDark ? const Color(0xFF9E2231) : const Color(0xFFF5EEE6);
      tileDark = isDark ? const Color(0xFF781420) : const Color(0xFFDDD2C4);
    }

    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [tileBase, tileDark],
      ).createShader(tileRect);

    canvas.drawPath(path, fillPaint);

    // Last move highlight — amber ghost squares
    if (animatingMove != null) {
      final isFrom = animatingMove!.from.row == row && animatingMove!.from.col == col;
      final isTo   = animatingMove!.to.row   == row && animatingMove!.to.col   == col;
      if (isFrom || isTo) {
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.amber.withValues(alpha: isTo ? 0.28 : 0.15)
            ..style = PaintingStyle.fill,
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.amber.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }

    // Hand-drawn sketchy ink tile grid line
    final Paint inkBorderPaint = Paint()
      ..color = isDark
          ? const Color(0xFF0F0B18)
          : AppColors.cursePurple.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawPath(path, inkBorderPaint);

    // Hand-drawn corner etching dots
    final Paint cornerEtch = Paint()
      ..color = isDark
          ? const Color(0xFF332747)
          : AppColors.runeGold.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final double cornerOff = tileWidth * 0.38;
    canvas.drawCircle(Offset(center.dx - cornerOff, center.dy - cornerOff), 1.2, cornerEtch);
    canvas.drawCircle(Offset(center.dx + cornerOff, center.dy - cornerOff), 1.2, cornerEtch);
    canvas.drawCircle(Offset(center.dx - cornerOff, center.dy + cornerOff), 1.2, cornerEtch);
    canvas.drawCircle(Offset(center.dx + cornerOff, center.dy + cornerOff), 1.2, cornerEtch);

    // Hover effect
    if (isHovered && !isSelected) {
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.candleIvory.withValues(alpha: 0.15)
          ..style = PaintingStyle.fill,
      );
    }

    // Highlight valid moves
    if (highlightedMoves.any((pos) => pos.row == row && pos.col == col)) {
      final isCapture = gameState?.board.pieceAt(BoardPosition(row, col)) != null;
      final highlightColor = isCapture ? AppColors.bloodWine : AppColors.ghostBlue;
      
      canvas.drawCircle(
        center,
        tileWidth * 0.25,
        Paint()
          ..color = highlightColor.withValues(alpha: 0.6 * glowAnimationValue)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      
      canvas.drawCircle(
        center,
        tileWidth * 0.1,
        Paint()
          ..color = highlightColor
          ..style = PaintingStyle.fill,
      );
    }

    // Highlight valid card targets
    if (validCardTargets.any((pos) => pos.row == row && pos.col == col) ||
        validSpellTargets.any((pos) => pos.row == row && pos.col == col)) {
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.cursePurple.withValues(alpha: 0.4 * glowAnimationValue)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8),
      );
      
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.cursePurple
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }





    // Selected effect
    if (isSelected) {
      // Outer glow
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.cursePurple.withValues(alpha: 0.6 * glowAnimationValue)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10),
      );
      
      // Inner fill glow
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.ghostBlue.withValues(alpha: 0.3 * glowAnimationValue)
          ..style = PaintingStyle.fill,
      );

      // Solid inner border
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.cursePurple
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }
  }

  void _drawCoordinates(Canvas canvas) {
    const textStyle = TextStyle(
      color: AppColors.fogGray,
      fontSize: 12,
      fontFamily: 'Inter',
    );
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // Draw A-H (columns) along row 7 (bottom)
    for (int col = 0; col < 8; col++) {
      final Offset pos = BoardGeometry.boardToScreen(7, col, tileWidth, tileHeight);
      textPainter.text = TextSpan(text: String.fromCharCode(65 + col), style: textStyle);
      textPainter.layout();
      textPainter.paint(
        canvas, 
        Offset(pos.dx - textPainter.width / 2, pos.dy + tileHeight / 2 + 5)
      );
    }

    // Draw 1-8 (rows) along col 0 (left)
    for (int row = 0; row < 8; row++) {
      final Offset pos = BoardGeometry.boardToScreen(row, 0, tileWidth, tileHeight);
      textPainter.text = TextSpan(text: '${8 - row}', style: textStyle);
      textPainter.layout();
      textPainter.paint(
        canvas, 
        Offset(pos.dx - tileWidth / 2 - textPainter.width - 5, pos.dy - textPainter.height / 2)
      );
    }
  }

  void _drawPieces(Canvas canvas) {
    if (gameState == null) return;
    
    final List<Map<String, dynamic>> piecesToDraw = [];
    
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = gameState!.board.pieceAt(BoardPosition(row, col));
        if (piece != null) {
          piecesToDraw.add({
            'row': row,
            'col': col,
            'piece': piece,
            'depth': row + col,
          });
        }
      }
    }
    
    // Sort by depth (back to front)
    piecesToDraw.sort((a, b) => (a['depth'] as int).compareTo(b['depth'] as int));

    for (final item in piecesToDraw) {
      final int row = item['row'];
      final int col = item['col'];
      final piece = item['piece'];

      // Animate piece movement
      Offset center;
      if (animatingMove != null && animatingMove!.to.row == row && animatingMove!.to.col == col) {
        final Offset startCenter = BoardGeometry.boardToScreen(animatingMove!.from.row, animatingMove!.from.col, tileWidth, tileHeight);
        final Offset targetCenter = BoardGeometry.boardToScreen(row, col, tileWidth, tileHeight);
        
        // Arc animation: move up in Y during slide
        final double curve = Curves.easeInOut.transform(moveAnimationProgress);
        final double arcHeight = sin(curve * pi) * tileHeight;
        
        center = Offset(
          startCenter.dx + (targetCenter.dx - startCenter.dx) * curve,
          startCenter.dy + (targetCenter.dy - startCenter.dy) * curve - arcHeight,
        );
      } else {
        center = BoardGeometry.boardToScreen(row, col, tileWidth, tileHeight);
      }
      
      // Draw Hand-Drawn 2D Stylized Cartoon Piece
      HanddrawnPiecePainter.drawPiece(
        canvas: canvas,
        center: center,
        size: tileWidth * 1.12,
        piece: piece,
        glowIntensity: glowAnimationValue,
      );

      // Render Relic equipment badge if piece has items equipped
      if (piece.equipment.isNotEmpty) {
        final relic = piece.equipment.last;
        final TextPainter relicPainter = TextPainter(
          text: TextSpan(
            text: relic.icon,
            style: TextStyle(
              fontSize: tileWidth * 0.32,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final Offset badgeCenter = Offset(
          center.dx + tileWidth * 0.28,
          center.dy - tileHeight * 0.38,
        );

        final Paint badgeBg = Paint()
          ..color = AppColors.voidPanel
          ..style = PaintingStyle.fill;
        final Paint badgeBorder = Paint()
          ..color = AppColors.cursePurple
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;

        canvas.drawCircle(badgeCenter, tileWidth * 0.22, badgeBg);
        canvas.drawCircle(badgeCenter, tileWidth * 0.22, badgeBorder);

        relicPainter.paint(
          canvas,
          Offset(badgeCenter.dx - relicPainter.width / 2, badgeCenter.dy - relicPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant IsometricBoardPainter oldDelegate) {
    return oldDelegate.gameState != gameState ||
           oldDelegate.selectedTile != selectedTile ||
           oldDelegate.hoveredTile != hoveredTile ||
           oldDelegate.glowAnimationValue != glowAnimationValue ||
           oldDelegate.highlightedMoves != highlightedMoves ||
           oldDelegate.validCardTargets != validCardTargets ||
           oldDelegate.animatingMove != animatingMove ||
           oldDelegate.moveAnimationProgress != moveAnimationProgress;
  }
}
