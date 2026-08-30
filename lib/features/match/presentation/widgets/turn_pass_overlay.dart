import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../theme/app_colors.dart';

class TurnPassOverlay extends StatelessWidget {
  final VoidCallback onTap;

  const TurnPassOverlay({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: AppColors.abyssBlack.withValues(alpha: 0.95),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PASS THE DEVICE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.bloodWine,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ).animate().fadeIn(duration: 500.ms).scaleXY(begin: 0.9, end: 1.0),
            const SizedBox(height: 32),
            const Icon(Icons.person, size: 100, color: AppColors.fogGray).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 48),
            const Text(
              'Tap anywhere to continue',
              style: TextStyle(color: AppColors.fogGray, fontSize: 16, letterSpacing: 2),
            ).animate().fadeIn(delay: 800.ms).then().animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 800.ms),
          ],
        ),
      ),
    );
  }
}
