import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class HauntedBackground extends StatefulWidget {
  final Widget child;

  const HauntedBackground({super.key, required this.child});

  @override
  State<HauntedBackground> createState() => _HauntedBackgroundState();
}

class _HauntedBackgroundState extends State<HauntedBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Ember> _embers = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Initialize embers
    for (int i = 0; i < 40; i++) {
      _embers.add(_Ember(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: _random.nextDouble() * 0.05 + 0.02,
        size: _random.nextDouble() * 3 + 1,
        wobbleOffset: _random.nextDouble() * pi * 2,
        wobbleSpeed: _random.nextDouble() * 2 + 1,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [AppColors.hauntedCharcoal, AppColors.abyssBlack],
                center: Alignment(0, 0.3),
                radius: 1.2,
              ),
            ),
          ),
        ),
        
        // Animated embers
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _EmberPainter(
                  embers: _embers,
                  time: _controller.value,
                ),
              );
            },
          ),
        ),

        // Vignette
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
                radius: 1.0,
                stops: const [0.6, 1.0],
              ),
            ),
          ),
        ),

        // The actual content
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

class _Ember {
  double x;
  double y;
  final double speed;
  final double size;
  final double wobbleOffset;
  final double wobbleSpeed;

  _Ember({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.wobbleOffset,
    required this.wobbleSpeed,
  });
}

class _EmberPainter extends CustomPainter {
  final List<_Ember> embers;
  final double time;

  _EmberPainter({required this.embers, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    for (final ember in embers) {
      // Calculate continuous Y position
      double currentY = ember.y - (time * ember.speed * 5);
      // Wrap around
      currentY = currentY - currentY.floor();

      // Wobble X based on time
      final currentX = ember.x + sin(time * pi * 2 * ember.wobbleSpeed + ember.wobbleOffset) * 0.05;
      
      final dx = currentX * size.width;
      final dy = currentY * size.height;

      // Pulse opacity
      final opacity = (sin(time * pi * 4 + ember.wobbleOffset) * 0.3 + 0.5).clamp(0.1, 0.8);

      paint.color = AppColors.bloodWine.withValues(alpha: opacity);
      canvas.drawCircle(Offset(dx, dy), ember.size, paint);
      
      // Inner hot core
      paint.color = Colors.orangeAccent.withValues(alpha: opacity * 0.8);
      canvas.drawCircle(Offset(dx, dy), ember.size * 0.4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EmberPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}
