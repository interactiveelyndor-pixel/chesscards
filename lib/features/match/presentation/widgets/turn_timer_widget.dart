import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';

class TurnTimerWidget extends StatelessWidget {
  final int seconds;
  final int maxSeconds;

  const TurnTimerWidget({
    super.key,
    required this.seconds,
    this.maxSeconds = 30,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (seconds / maxSeconds).clamp(0.0, 1.0);
    final bool isUrgent = seconds <= 5;
    final bool isWarning = seconds <= 10;

    final Color arcColor = isUrgent
        ? AppColors.bloodWine
        : isWarning
            ? const Color(0xFFFF7200)
            : const Color(0xFFFFB703);

    Widget timer = SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 3,
              color: AppColors.dimGray.withValues(alpha: 0.5),
            ),
          ),
          // Progress arc
          SizedBox.expand(
            child: CustomPaint(
              painter: _ArcPainter(
                progress: progress,
                color: arcColor,
                glowColor: arcColor.withValues(alpha: 0.5),
              ),
            ),
          ),
          // Center number
          Text(
            '$seconds',
            style: GoogleFonts.cinzel(
              color: arcColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              shadows: [
                Shadow(
                  color: arcColor.withValues(alpha: 0.8),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isUrgent) {
      timer = timer
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(begin: 1.0, end: 1.1, duration: 300.ms);
    }

    return timer;
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color glowColor;

  const _ArcPainter({
    required this.progress,
    required this.color,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 3;
    const startAngle = -pi / 2; // Start at top
    final sweepAngle = 2 * pi * progress;

    // Glow layer
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = glowColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // Crisp top layer
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}


