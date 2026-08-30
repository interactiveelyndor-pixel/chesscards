import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

/// A swirling arcane dimensional portal shader effect rendered via custom canvas painter.
class TeleportPortalEffect extends StatefulWidget {
  final double size;
  final VoidCallback? onComplete;

  const TeleportPortalEffect({
    super.key,
    this.size = 120.0,
    this.onComplete,
  });

  @override
  State<TeleportPortalEffect> createState() => _TeleportPortalEffectState();
}

class _TeleportPortalEffectState extends State<TeleportPortalEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_PortalParticle> _particles = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // Spawn 28 swirling spiral particles sucked into the vortex
    for (int i = 0; i < 28; i++) {
      final initialAngle = _rng.nextDouble() * 2 * pi;
      final initialRadius = _rng.nextDouble() * (widget.size * 0.55) + 15;
      final speed = _rng.nextDouble() * 3.5 + 2.0;
      final color = i % 3 == 0
          ? AppColors.ghostBlue
          : (i % 3 == 1 ? AppColors.cursePurple : AppColors.runeGold);

      _particles.add(_PortalParticle(
        angle: initialAngle,
        radius: initialRadius,
        speed: speed,
        size: _rng.nextDouble() * 3.5 + 1.5,
        color: color,
      ));
    }

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _PortalShaderPainter(
            progress: progress,
            particles: _particles,
          ),
        );
      },
    );
  }
}

class _PortalShaderPainter extends CustomPainter {
  final double progress;
  final List<_PortalParticle> particles;

  _PortalShaderPainter({
    required this.progress,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.45;

    // Overall envelope: quick expand, sustained vortex, collapse
    final double scale;
    final double opacity;
    if (progress < 0.25) {
      final t = progress / 0.25;
      scale = Curves.easeOutBack.transform(t);
      opacity = t;
    } else if (progress < 0.75) {
      scale = 1.0 + sin((progress - 0.25) * 4 * pi) * 0.08;
      opacity = 1.0;
    } else {
      final t = (progress - 0.75) / 0.25;
      scale = 1.0 - Curves.easeInCirc.transform(t);
      opacity = 1.0 - t;
    }

    if (scale <= 0.01 || opacity <= 0.01) return;

    final currentRadius = maxRadius * scale;

    // ── 1. Outer Chromatic Distortion Halo ─────────────────────────────────
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          AppColors.cursePurple.withValues(alpha: 0.35 * opacity),
          AppColors.ghostBlue.withValues(alpha: 0.5 * opacity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 0.85, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: currentRadius * 1.35))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, currentRadius * 1.35, haloPaint);

    // ── 2. Rotating Arcane Vortex Swirls ──────────────────────────────────
    final int armCount = 4;
    final double rotationAngle = progress * 6 * pi; // Spin fast

    final armPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < armCount; i++) {
      final armBaseAngle = (i * (2 * pi / armCount)) + rotationAngle;
      final path = Path();

      for (double r = currentRadius * 0.2; r <= currentRadius; r += 2.0) {
        final spiralAngle = armBaseAngle + (r / currentRadius) * 2.2;
        final x = center.dx + cos(spiralAngle) * r;
        final y = center.dy + sin(spiralAngle) * (r * 0.75); // Isometric elliptical squash
        if (r == currentRadius * 0.2) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      armPaint
        ..strokeWidth = (2.5 * scale)
        ..shader = LinearGradient(
          colors: [
            AppColors.ghostBlue.withValues(alpha: 0.9 * opacity),
            AppColors.cursePurpleLight.withValues(alpha: 0.6 * opacity),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: currentRadius));

      canvas.drawPath(path, armPaint);
    }

    // ── 3. Pulsing Event Horizon Singularity (Void Core) ───────────────────
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF040008),
          const Color(0xFF1B042E),
          AppColors.cursePurple.withValues(alpha: 0.8 * opacity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 0.85, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: currentRadius * 0.75));
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: currentRadius * 1.5,
        height: currentRadius * 1.1, // Isometric projection
      ),
      corePaint,
    );

    // ── 4. Glowing Rune Ring Outer Boundary ────────────────────────────────
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * scale
      ..color = AppColors.runeGold.withValues(alpha: 0.75 * opacity);
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: currentRadius * 1.8,
        height: currentRadius * 1.35,
      ),
      ringPaint,
    );

    // ── 5. Inward Suction Particles ────────────────────────────────────────
    for (final p in particles) {
      // Particles swirl inwards toward center
      final currentPProgress = (progress * p.speed) % 1.0;
      final pRadius = p.radius * (1.0 - currentPProgress) * scale;
      final pAngle = p.angle + (progress * 8 * pi);

      final px = center.dx + cos(pAngle) * pRadius;
      final py = center.dy + sin(pAngle) * (pRadius * 0.75);

      final pPaint = Paint()
        ..color = p.color.withValues(alpha: (1.0 - currentPProgress) * opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(px, py), p.size * (1.0 - currentPProgress * 0.5), pPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PortalShaderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _PortalParticle {
  final double angle;
  final double radius;
  final double speed;
  final double size;
  final Color color;

  _PortalParticle({
    required this.angle,
    required this.radius,
    required this.speed,
    required this.size,
    required this.color,
  });
}
