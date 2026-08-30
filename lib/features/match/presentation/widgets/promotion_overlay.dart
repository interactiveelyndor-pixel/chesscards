import 'package:flutter/material.dart';
import '../../../../shared/enums/piece_color.dart';
import '../../../../shared/enums/piece_type.dart';
import '../../../../theme/app_colors.dart';
import '../../../board/presentation/painters/handdrawn_piece_painter.dart';
import '../../../pieces/domain/chess_piece.dart';

class PromotionOverlay extends StatelessWidget {
  final ValueChanged<PieceType> onPieceSelected;

  const PromotionOverlay({
    super.key,
    required this.onPieceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.voidPanel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.ghostBlue.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.ghostBlue.withValues(alpha: 0.2),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PAWN ASCENSION',
                style: TextStyle(
                  color: AppColors.candleIvory,
                  fontSize: 20,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose your ascended form',
                style: TextStyle(
                  color: AppColors.fogGray,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PromotionOption(
                    pieceType: PieceType.queen,
                    onTap: () => onPieceSelected(PieceType.queen),
                  ),
                  const SizedBox(width: 16),
                  _PromotionOption(
                    pieceType: PieceType.rook,
                    onTap: () => onPieceSelected(PieceType.rook),
                  ),
                  const SizedBox(width: 16),
                  _PromotionOption(
                    pieceType: PieceType.bishop,
                    onTap: () => onPieceSelected(PieceType.bishop),
                  ),
                  const SizedBox(width: 16),
                  _PromotionOption(
                    pieceType: PieceType.knight,
                    onTap: () => onPieceSelected(PieceType.knight),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromotionOption extends StatelessWidget {
  final PieceType pieceType;
  final VoidCallback onTap;

  const _PromotionOption({
    required this.pieceType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.abyssBlack,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.runeGold.withValues(alpha: 0.7), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.runeGold.withValues(alpha: 0.2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Center(
          child: CustomPaint(
            size: const Size(44, 44),
            painter: _PieceCustomPainter(
              ChessPiece(type: pieceType, color: PieceColor.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _PieceCustomPainter extends CustomPainter {
  final ChessPiece piece;

  _PieceCustomPainter(this.piece);

  @override
  void paint(Canvas canvas, Size size) {
    HanddrawnPiecePainter.drawPiece(
      canvas: canvas,
      center: Offset(size.width / 2, size.height / 2),
      size: size.width,
      piece: piece,
    );
  }

  @override
  bool shouldRepaint(covariant _PieceCustomPainter oldDelegate) =>
      oldDelegate.piece != piece;
}
