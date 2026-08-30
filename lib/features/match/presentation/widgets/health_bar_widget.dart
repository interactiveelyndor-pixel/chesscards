import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';

class HealthBarWidget extends StatelessWidget {
  final int health;
  final int maxHealth;
  final bool isReversed;

  const HealthBarWidget({
    super.key,
    required this.health,
    required this.maxHealth,
    this.isReversed = false,
  });

  @override
  Widget build(BuildContext context) {
    final double fillPct = (health / maxHealth).clamp(0.0, 1.0);
    final bool isCritical = fillPct <= 0.30;

    final Color healthColor = isCritical
        ? AppColors.bloodWine
        : Color.lerp(
            const Color(0xFFD48A42), // amber at mid
            const Color(0xFFFF9E00), // bright amber/gold at full
            ((fillPct - 0.3) / 0.7).clamp(0.0, 1.0),
          )!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isReversed
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        // Label row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isReversed) ...[
              const Icon(Icons.favorite, color: AppColors.bloodWine, size: 10.5),
              const SizedBox(width: 4),
            ],
            Text(
              '$health',
              style: GoogleFonts.cinzel(
                color: healthColor,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              ' / $maxHealth',
              style: GoogleFonts.cinzel(
                color: AppColors.fogGray,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isReversed) ...[
              const SizedBox(width: 4),
              const Icon(Icons.favorite, color: AppColors.bloodWine, size: 10.5),
            ],
          ],
        ),
        const SizedBox(height: 3),
        // Hand-drawn Bar track
        Container(
          height: 8,
          width: 96,
          decoration: BoxDecoration(
            color: const Color(0xFF140700),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: const Color(0xFF4A1A00),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                // Fill
                Align(
                  alignment: isReversed
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    width: 96 * fillPct,
                    height: 8,
                    decoration: BoxDecoration(
                      color: healthColor,
                      boxShadow: [
                        BoxShadow(
                          color: healthColor.withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isCritical)
          Container(
            width: 96,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.bloodWine.withValues(alpha: 0.6),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 500.ms)
              .then()
              .fadeOut(duration: 500.ms),
      ],
    );
  }
}
