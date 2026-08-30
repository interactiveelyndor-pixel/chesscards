import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';

/// Floating damage/heal number that animates upward then fades out.
class DamageNumberOverlay extends StatelessWidget {
  final int damage;
  final int heal;
  final Alignment alignment;
  final VoidCallback onComplete;

  const DamageNumberOverlay({
    super.key,
    required this.damage,
    required this.heal,
    required this.alignment,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (damage > 0) _FloatingNumber(
                text: '-$damage HP',
                color: AppColors.bloodWine,
                onComplete: heal <= 0 ? onComplete : null,
              ),
              if (heal > 0) ...[
                const SizedBox(height: 4),
                _FloatingNumber(
                  text: '+$heal HP',
                  color: AppColors.spectralGreen,
                  onComplete: onComplete,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingNumber extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback? onComplete;

  const _FloatingNumber({
    required this.text,
    required this.color,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.cinzel(
        color: color,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        shadows: [
          Shadow(color: color.withValues(alpha: 0.9), blurRadius: 14),
          const Shadow(color: Colors.black, blurRadius: 4),
        ],
      ),
    )
        .animate(onComplete: (_) => onComplete?.call())
        .moveY(begin: 0, end: -60, duration: 1000.ms, curve: Curves.easeOut)
        .fadeIn(duration: 200.ms)
        .then(delay: 500.ms)
        .fadeOut(duration: 300.ms);
  }
}
