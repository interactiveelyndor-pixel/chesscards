import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

/// Paints atmospheric, gothic vector heraldic emblems for each spell.
class SpellEmblemPainter extends CustomPainter {
  final String spellId;
  final bool isCasting;
  final double animationProgress;

  SpellEmblemPainter({
    required this.spellId,
    this.isCasting = false,
    this.animationProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.44;

    switch (spellId) {
      case 'spell_fireball':
        _drawFireball(canvas, center, radius);
        break;
      case 'spell_freeze':
        _drawFrostBind(canvas, center, radius);
        break;
      case 'spell_blizzard':
        _drawBlizzard(canvas, center, radius);
        break;
      case 'spell_soul_leech':
        _drawSoulLeech(canvas, center, radius);
        break;
      case 'spell_wall_of_stone':
        _drawWallOfStone(canvas, center, radius);
        break;
      case 'spell_necromancy':
        _drawNecromancy(canvas, center, radius);
        break;
      case 'spell_lightning':
        _drawLightning(canvas, center, radius);
        break;
      default:
        _drawGenericSigil(canvas, center, radius);
    }
  }

  void _drawFireball(Canvas canvas, Offset center, double radius) {
    // Outer flame aura
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.soulFlame.withValues(alpha: 0.8),
          const Color(0xFFC1121F).withValues(alpha: 0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.2));
    canvas.drawCircle(center, radius * 1.2, auraPaint);

    // Dynamic fire vortex paths
    final flamePaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Color(0xFF7B0000), Color(0xFFFF5500), Color(0xFFFFD166)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final path = Path();
    path.moveTo(center.dx, center.dy - radius * 0.95); // Top tip
    path.cubicTo(
      center.dx + radius * 0.7, center.dy - radius * 0.4,
      center.dx + radius * 0.9, center.dy + radius * 0.6,
      center.dx, center.dy + radius * 0.9,
    );
    path.cubicTo(
      center.dx - radius * 0.9, center.dy + radius * 0.6,
      center.dx - radius * 0.7, center.dy - radius * 0.4,
      center.dx, center.dy - radius * 0.95,
    );
    canvas.drawPath(path, flamePaint);

    // Inner core spark
    final corePaint = Paint()..color = const Color(0xFFFFF3B0);
    canvas.drawCircle(center + Offset(0, radius * 0.15), radius * 0.32, corePaint);
  }

  void _drawFrostBind(Canvas canvas, Offset center, double radius) {
    final icePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF90E0EF);

    // 6-pointed ice rune crystal
    for (int i = 0; i < 6; i++) {
      final angle = (i * pi / 3);
      final p2 = center + Offset(cos(angle) * radius * 0.85, sin(angle) * radius * 0.85);
      canvas.drawLine(center, p2, icePaint);

      // Branching spikes
      final branchAngle1 = angle + pi / 4;
      final branchAngle2 = angle - pi / 4;
      final branchCenter = center + Offset(cos(angle) * radius * 0.5, sin(angle) * radius * 0.5);
      canvas.drawLine(
        branchCenter,
        branchCenter + Offset(cos(branchAngle1) * radius * 0.3, sin(branchAngle1) * radius * 0.3),
        icePaint..strokeWidth = 1.4,
      );
      canvas.drawLine(
        branchCenter,
        branchCenter + Offset(cos(branchAngle2) * radius * 0.3, sin(branchAngle2) * radius * 0.3),
        icePaint..strokeWidth = 1.4,
      );
    }

    // Glowing diamond core
    final corePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final diamondPath = Path()
      ..moveTo(center.dx, center.dy - radius * 0.3)
      ..lineTo(center.dx + radius * 0.22, center.dy)
      ..lineTo(center.dx, center.dy + radius * 0.3)
      ..lineTo(center.dx - radius * 0.22, center.dy)
      ..close();
    canvas.drawPath(diamondPath, corePaint);
  }

  void _drawBlizzard(Canvas canvas, Offset center, double radius) {
    // Swirling tempest rings
    final swirlPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..shader = const SweepGradient(
        colors: [Color(0xFF0077B6), Color(0xFF00B4D8), Color(0xFFADE8F4), Color(0xFF0077B6)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius * 0.85), 0, 4.5, false, swirlPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius * 0.55), 2.0, 4.5, false, swirlPaint..strokeWidth = 1.6);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius * 0.3), 4.0, 4.5, false, swirlPaint..strokeWidth = 1.2);

    // Snow crystal dots
    final dotPaint = Paint()..color = Colors.white;
    for (int i = 0; i < 8; i++) {
      final a = (i * pi / 4) + 0.3;
      final r = radius * (0.4 + (i % 3) * 0.2);
      canvas.drawCircle(center + Offset(cos(a) * r, sin(a) * r), 1.8, dotPaint);
    }
  }

  void _drawSoulLeech(Canvas canvas, Offset center, double radius) {
    // Necrotic purple void aura
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF9D4EDD).withValues(alpha: 0.9),
          const Color(0xFF5A0089).withValues(alpha: 0.5),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.1));
    canvas.drawCircle(center, radius * 1.1, auraPaint);

    // Gothic Skull/Soul Sigil
    final skullPaint = Paint()
      ..color = const Color(0xFFE0AAFF)
      ..style = PaintingStyle.fill;

    // Top cranium
    canvas.drawOval(
      Rect.fromCenter(center: center - Offset(0, radius * 0.15), width: radius * 1.1, height: radius * 0.95),
      skullPaint,
    );
    // Jaw
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center + Offset(0, radius * 0.35), width: radius * 0.65, height: radius * 0.5),
        const Radius.circular(3),
      ),
      skullPaint,
    );

    // Dark eye sockets
    final eyePaint = Paint()..color = const Color(0xFF160029);
    canvas.drawCircle(center + Offset(-radius * 0.25, -radius * 0.1), radius * 0.16, eyePaint);
    canvas.drawCircle(center + Offset(radius * 0.25, -radius * 0.1), radius * 0.16, eyePaint);
  }

  void _drawWallOfStone(Canvas canvas, Offset center, double radius) {
    // Stone fortification crest
    final stonePaint = Paint()
      ..color = const Color(0xFF6C757D)
      ..style = PaintingStyle.fill;
    final stoneBorder = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    // Shield/Tower shape
    final path = Path()
      ..moveTo(center.dx - radius * 0.7, center.dy - radius * 0.6)
      ..lineTo(center.dx - radius * 0.7, center.dy - radius * 0.8) // Battlement left
      ..lineTo(center.dx - radius * 0.35, center.dy - radius * 0.8)
      ..lineTo(center.dx - radius * 0.35, center.dy - radius * 0.65)
      ..lineTo(center.dx + radius * 0.35, center.dy - radius * 0.65)
      ..lineTo(center.dx + radius * 0.35, center.dy - radius * 0.8)
      ..lineTo(center.dx + radius * 0.7, center.dy - radius * 0.8) // Battlement right
      ..lineTo(center.dx + radius * 0.7, center.dy + radius * 0.3)
      ..lineTo(center.dx, center.dy + radius * 0.85) // Bottom shield point
      ..lineTo(center.dx - radius * 0.7, center.dy + radius * 0.3)
      ..close();

    canvas.drawPath(path, stonePaint);
    canvas.drawPath(path, stoneBorder);

    // Runic brick mortar lines
    final linePaint = Paint()
      ..color = const Color(0xFF343A40)
      ..strokeWidth = 1.4;
    canvas.drawLine(
      Offset(center.dx - radius * 0.5, center.dy - radius * 0.1),
      Offset(center.dx + radius * 0.5, center.dy - radius * 0.1),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx - radius * 0.45, center.dy + radius * 0.25),
      Offset(center.dx + radius * 0.45, center.dy + radius * 0.25),
      linePaint,
    );
  }

  void _drawNecromancy(Canvas canvas, Offset center, double radius) {
    // Spectral Green Resurrection Ghost Flame
    final flamePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF2DC653).withValues(alpha: 0.85),
          const Color(0xFF007F5F).withValues(alpha: 0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.1));
    canvas.drawCircle(center, radius * 1.1, flamePaint);

    // Double Helix Resurrection Arc
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF99E2B4);

    final path1 = Path();
    path1.moveTo(center.dx - radius * 0.6, center.dy + radius * 0.7);
    path1.cubicTo(
      center.dx - radius * 0.8, center.dy,
      center.dx + radius * 0.8, center.dy,
      center.dx + radius * 0.6, center.dy - radius * 0.7,
    );
    canvas.drawPath(path1, arcPaint);

    final path2 = Path();
    path2.moveTo(center.dx + radius * 0.6, center.dy + radius * 0.7);
    path2.cubicTo(
      center.dx + radius * 0.8, center.dy,
      center.dx - radius * 0.8, center.dy,
      center.dx - radius * 0.6, center.dy - radius * 0.7,
    );
    canvas.drawPath(path2, arcPaint..color = const Color(0xFFD4AF37));
  }

  void _drawLightning(Canvas canvas, Offset center, double radius) {
    final boltPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        colors: [Color(0xFFE0AAFF), Color(0xFF7B2CBF), Color(0xFFFFD166)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final path = Path()
      ..moveTo(center.dx + radius * 0.2, center.dy - radius * 0.9)
      ..lineTo(center.dx - radius * 0.4, center.dy)
      ..lineTo(center.dx + radius * 0.05, center.dy)
      ..lineTo(center.dx - radius * 0.3, center.dy + radius * 0.9)
      ..lineTo(center.dx + radius * 0.45, center.dy - radius * 0.1)
      ..lineTo(center.dx - radius * 0.05, center.dy - radius * 0.1)
      ..close();

    canvas.drawPath(path, boltPaint);
  }

  void _drawGenericSigil(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = AppColors.runeGold;
    canvas.drawCircle(center, radius * 0.7, paint);
    canvas.drawRect(Rect.fromCenter(center: center, width: radius * 0.8, height: radius * 0.8), paint);
  }

  @override
  bool shouldRepaint(covariant SpellEmblemPainter oldDelegate) {
    return oldDelegate.spellId != spellId ||
        oldDelegate.isCasting != isCasting ||
        oldDelegate.animationProgress != animationProgress;
  }
}
