import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/board_position.dart';
import '../../domain/board_geometry.dart';


class CaptureParticleOverlay extends StatefulWidget {
  final BoardPosition position;
  final double tileWidth;
  final double tileHeight;
  final VoidCallback onComplete;

  const CaptureParticleOverlay({
    super.key,
    required this.position,
    required this.tileWidth,
    required this.tileHeight,
    required this.onComplete,
  });

  @override
  State<CaptureParticleOverlay> createState() => _CaptureParticleOverlayState();
}

class _CaptureParticleOverlayState extends State<CaptureParticleOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Generate 20 particles
    for (int i = 0; i < 20; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = _random.nextDouble() * 100 + 50; // pixels per second
      final size = _random.nextDouble() * 6 + 2;
      _particles.add(_Particle(
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 50, // Slight upward bias
        size: size,
        color: _random.nextBool() ? AppColors.bloodWine : AppColors.ghostBlue,
      ));
    }

    _controller.addListener(() {
      setState(() {});
    });
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Find the absolute center of the board on the screen
        final boardCenterX = constraints.maxWidth / 2;
        final boardCenterY = constraints.maxHeight / 2;

        // Find the offset of the target tile relative to the board's 0,0
        final tileOffset = BoardGeometry.boardToScreen(
          widget.position.row, 
          widget.position.col, 
          widget.tileWidth, 
          widget.tileHeight,
        );

        // Calculate absolute position on the screen
        final x = boardCenterX - (4 * widget.tileWidth) + tileOffset.dx;
        final y = boardCenterY - (4 * widget.tileHeight) + tileOffset.dy;

        final t = _controller.value;
        final opacity = 1.0 - (t * t); // Fade out quadratically

        return Stack(
          children: _particles.map((p) {
            final dx = x + p.vx * t;
            final dy = y + p.vy * t + (100 * t * t); // Gravity
            return Positioned(
              left: dx - (p.size / 2),
              top: dy - (p.size / 2),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: p.size,
                  height: p.size,
                  decoration: BoxDecoration(
                    color: p.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: p.color.withValues(alpha: 0.8),
                        blurRadius: p.size * 2,
                      )
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _Particle {
  final double vx;
  final double vy;
  final double size;
  final Color color;

  _Particle({
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
  });
}
