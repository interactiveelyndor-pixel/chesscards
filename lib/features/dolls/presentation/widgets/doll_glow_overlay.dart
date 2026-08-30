import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DollGlowOverlay extends StatelessWidget {
  final Color color;
  final double intensity;

  const DollGlowOverlay({
    super.key,
    required this.color,
    this.intensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    if (color == Colors.transparent || intensity == 0) {
      return const SizedBox.shrink();
    }
    
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: 0.6 * intensity,
          duration: const Duration(seconds: 2),
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [color.withValues(alpha: 0.5 * intensity), Colors.transparent],
                radius: 0.7,
                stops: const [0.2, 1.0],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2.seconds),
        ),
      ),
    );
  }
}
