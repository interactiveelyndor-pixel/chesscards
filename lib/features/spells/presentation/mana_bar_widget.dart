import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';

class ManaBarWidget extends StatelessWidget {
  final int currentMana;
  final int maxMana;

  const ManaBarWidget({
    super.key,
    required this.currentMana,
    this.maxMana = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF100A18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.ghostBlue.withValues(alpha: 0.6),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ghostBlue.withValues(alpha: 0.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.diamond,
            color: AppColors.ghostBlue,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            '$currentMana/$maxMana',
            style: GoogleFonts.cinzel(
              color: AppColors.ghostBlue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(maxMana, (index) {
              final isFilled = index < currentMana;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 6,
                height: 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: isFilled ? AppColors.ghostBlue : const Color(0xFF1D1B28),
                  border: Border.all(
                    color: isFilled ? Colors.white70 : Colors.white12,
                    width: 0.8,
                  ),
                  boxShadow: isFilled
                      ? [
                          BoxShadow(
                            color: AppColors.ghostBlue.withValues(alpha: 0.75),
                            blurRadius: 5,
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
