import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/soul_doll.dart';
import '../../domain/doll_state.dart';
import 'doll_glow_overlay.dart';
import 'dart:math';

class SoulDollWidget extends StatefulWidget {
  final SoulDoll doll;
  final String? equippedDollId;
  final bool isCurrentTurn;
  final bool facingLeft;
  final double width;
  final double height;

  const SoulDollWidget({
    super.key,
    required this.doll,
    this.equippedDollId,
    this.isCurrentTurn = false,
    this.facingLeft = false,
    this.width = 140,
    this.height = 180,
  });

  @override
  State<SoulDollWidget> createState() => _SoulDollWidgetState();
}

class _SoulDollWidgetState extends State<SoulDollWidget> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    Color activeColor = AppColors.ghostBlue;
    if (widget.doll.isPlayerControlled) {
      if (widget.equippedDollId == 'doll_crimson_wraith') {
        activeColor = AppColors.bloodWine;
      } else if (widget.equippedDollId == 'doll_golden_effigy') {
        activeColor = AppColors.runeGold;
      } else {
        activeColor = AppColors.runeGold;
      }
    } else {
      activeColor = AppColors.ghostBlue;
    }

    final double intensity = widget.doll.corruptionProgress;
    
    // Shaking logic
    final bool isShaking = widget.doll.corruptionLevel >= 3;
    
    return RepaintBoundary(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background glow based on state
            DollGlowOverlay(
              color: widget.doll.state.glowColor,
              intensity: intensity > 0.2 ? intensity : 0.5,
            ),
            
            // Turn indicator glow
            if (widget.isCurrentTurn)
              const DollGlowOverlay(
                color: AppColors.candleIvory,
                intensity: 0.5,
              ),
              
            // The Doll Silhouette 
            _buildProceduralDoll(intensity, activeColor)
              .animate(
                target: isShaking ? 1 : 0, 
                onPlay: (controller) => controller.repeat(),
              )
              .shimmer(duration: 1200.ms, color: AppColors.cursePurple.withValues(alpha: 0.3))
              .shake(hz: 10 + (intensity * 10), offset: Offset(2 * intensity, 2 * intensity)),
              
            // Breathing animation (when calm)
            if (widget.doll.corruptionLevel < 2)
              Positioned.fill(
                child: Container(color: Colors.transparent)
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scaleY(begin: 1.0, end: 1.02, duration: 2.seconds),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProceduralDoll(double intensity, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: intensity),
      duration: const Duration(milliseconds: 800),
      builder: (context, val, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _DollPainter(corruption: val, state: widget.doll.state, baseColor: color),
        );
      },
    );
  }
}

class _DollPainter extends CustomPainter {
  final double corruption;
  final DollState state;
  final Color baseColor;

  _DollPainter({required this.corruption, required this.state, required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final Paint inkPaint = Paint()
      ..color = const Color(0xFF140F1E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint stitchPaint = Paint()
      ..color = const Color(0xFF1A1526)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final Paint burlapFill = Paint()
      ..color = Color.lerp(const Color(0xFF2C243B), baseColor.withValues(alpha: 0.8), corruption * 0.7)!
      ..style = PaintingStyle.fill;

    // --- 1. Handcrafted Ragdoll Body ---
    final Path body = Path()
      ..moveTo(size.width * 0.25, size.height * 0.92)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.55, size.width * 0.42, size.height * 0.45)
      ..lineTo(size.width * 0.58, size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.65, size.height * 0.55, size.width * 0.75, size.height * 0.92)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.96, size.width * 0.25, size.height * 0.92)
      ..close();

    canvas.drawPath(body, burlapFill);
    canvas.drawPath(body, inkPaint);

    // Body Patchwork Stitch
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.48), Offset(size.width * 0.5, size.height * 0.88), stitchPaint);
    for (int i = 0; i < 5; i++) {
      final y = size.height * (0.52 + i * 0.08);
      canvas.drawLine(Offset(size.width * 0.46, y - 2), Offset(size.width * 0.54, y + 2), stitchPaint);
    }

    // --- 2. Hand-Drawn Head ---
    final headCenter = Offset(center.dx, size.height * 0.28);
    final double headRadius = size.width * 0.28;

    final Path head = Path()
      ..moveTo(headCenter.dx - headRadius * 0.9, headCenter.dy)
      ..quadraticBezierTo(headCenter.dx - headRadius * 0.95, headCenter.dy - headRadius * 0.9, headCenter.dx, headCenter.dy - headRadius)
      ..quadraticBezierTo(headCenter.dx + headRadius * 0.95, headCenter.dy - headRadius * 0.9, headCenter.dx + headRadius * 0.9, headCenter.dy)
      ..quadraticBezierTo(headCenter.dx + headRadius * 0.85, headCenter.dy + headRadius * 0.95, headCenter.dx, headCenter.dy + headRadius * 0.9)
      ..quadraticBezierTo(headCenter.dx - headRadius * 0.85, headCenter.dy + headRadius * 0.95, headCenter.dx - headRadius * 0.9, headCenter.dy)
      ..close();

    canvas.drawPath(head, burlapFill);
    canvas.drawPath(head, inkPaint);

    // Head Seam
    final Path headSeam = Path()
      ..moveTo(headCenter.dx - headRadius * 0.1, headCenter.dy - headRadius * 0.95)
      ..quadraticBezierTo(headCenter.dx + headRadius * 0.15, headCenter.dy, headCenter.dx - headRadius * 0.05, headCenter.dy + headRadius * 0.88);
    canvas.drawPath(headSeam, stitchPaint);

    // Seam Cross-Stitches
    for (int i = 0; i < 6; i++) {
      final y = headCenter.dy - headRadius * 0.8 + (i * headRadius * 0.3);
      canvas.drawLine(Offset(headCenter.dx - headRadius * 0.18, y - 3), Offset(headCenter.dx + headRadius * 0.22, y + 3), stitchPaint);
    }

    // --- 3. Mismatched Button Eyes ---
    final Offset leftEye = Offset(headCenter.dx - headRadius * 0.42, headCenter.dy - headRadius * 0.12);
    final Offset rightEye = Offset(headCenter.dx + headRadius * 0.42, headCenter.dy - headRadius * 0.15);
    final double leftBtnR = size.width * 0.085;
    final double rightBtnR = size.width * 0.07;

    final Color glowColor = state.glowColor == Colors.transparent ? Colors.cyanAccent : state.glowColor;

    // Left Button (Outer ring + X stitch)
    final Paint buttonFill = Paint()
      ..color = const Color(0xFF1E182A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(leftEye, leftBtnR, buttonFill);
    canvas.drawCircle(leftEye, leftBtnR, inkPaint);
    canvas.drawCircle(leftEye, leftBtnR * 0.65, stitchPaint);

    // X Stitch on Left Button
    final Paint threadPaint = Paint()
      ..color = (corruption > 0.3) ? glowColor : AppColors.runeGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    if (corruption > 0.4) {
      threadPaint.maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);
    }

    final double xOff = leftBtnR * 0.35;
    canvas.drawLine(Offset(leftEye.dx - xOff, leftEye.dy - xOff), Offset(leftEye.dx + xOff, leftEye.dy + xOff), threadPaint);
    canvas.drawLine(Offset(leftEye.dx - xOff, leftEye.dy + xOff), Offset(leftEye.dx + xOff, leftEye.dy - xOff), threadPaint);

    // Right Button (Spiral / + stitch)
    canvas.drawCircle(rightEye, rightBtnR, buttonFill);
    canvas.drawCircle(rightEye, rightBtnR, inkPaint);
    final double plusOff = rightBtnR * 0.4;
    canvas.drawLine(Offset(rightEye.dx - plusOff, rightEye.dy), Offset(rightEye.dx + plusOff, rightEye.dy), threadPaint);
    canvas.drawLine(Offset(rightEye.dx, rightEye.dy - plusOff), Offset(rightEye.dx, rightEye.dy + plusOff), threadPaint);

    // --- 4. Dynamic Cartoon Mouth ---
    final Offset mouthCenter = Offset(headCenter.dx, headCenter.dy + headRadius * 0.45);

    if (state == DollState.screaming || state == DollState.cursed || corruption > 0.6) {
      // Gaping Cartoon Void Mouth with Stitched Teeth
      final double mouthW = headRadius * (0.7 + corruption * 0.3);
      final double mouthH = headRadius * (0.6 + corruption * 0.5);
      final Rect mouthRect = Rect.fromCenter(center: mouthCenter, width: mouthW, height: mouthH);

      final Path voidMouth = Path()..addOval(mouthRect);
      canvas.drawPath(voidMouth, Paint()..color = const Color(0xFF0D0914));
      canvas.drawPath(voidMouth, inkPaint);

      // Jagged stitched teeth around rim
      const int numTeeth = 8;
      for (int i = 0; i < numTeeth; i++) {
        final double angle = (i / numTeeth) * 2 * pi;
        final double tx1 = mouthCenter.dx + cos(angle) * mouthW * 0.48;
        final double ty1 = mouthCenter.dy + sin(angle) * mouthH * 0.48;
        final double tx2 = mouthCenter.dx + cos(angle) * mouthW * 0.28;
        final double ty2 = mouthCenter.dy + sin(angle) * mouthH * 0.28;
        canvas.drawLine(Offset(tx1, ty1), Offset(tx2, ty2), stitchPaint);
      }
    } else if (state == DollState.cracked || state == DollState.uneasy) {
      // Uneven stitched wavy frown
      final Path frown = Path()
        ..moveTo(mouthCenter.dx - headRadius * 0.35, mouthCenter.dy + 4)
        ..quadraticBezierTo(mouthCenter.dx, mouthCenter.dy - 6, mouthCenter.dx + headRadius * 0.35, mouthCenter.dy + 4);
      canvas.drawPath(frown, inkPaint);
    } else {
      // Stitched Ragdoll Mouth
      final double mW = headRadius * 0.4;
      canvas.drawLine(Offset(mouthCenter.dx - mW, mouthCenter.dy), Offset(mouthCenter.dx + mW, mouthCenter.dy), inkPaint);
      for (int i = 0; i < 5; i++) {
        final x = mouthCenter.dx - mW + (i * mW * 0.5);
        canvas.drawLine(Offset(x, mouthCenter.dy - 4), Offset(x, mouthCenter.dy + 4), stitchPaint);
      }
    }

    // --- 5. Dangling Loose Thread ---
    final Path looseThread = Path()
      ..moveTo(headCenter.dx + headRadius * 0.8, headCenter.dy + headRadius * 0.5)
      ..quadraticBezierTo(headCenter.dx + headRadius * 1.1, headCenter.dy + headRadius * 0.9, headCenter.dx + headRadius * 0.85, headCenter.dy + headRadius * 1.3);
    canvas.drawPath(looseThread, stitchPaint);
  }

  @override
  bool shouldRepaint(covariant _DollPainter oldDelegate) {
    return oldDelegate.corruption != corruption || oldDelegate.state != state;
  }
}
