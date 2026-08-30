import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';

class CheckOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  const CheckOverlay({super.key, required this.onComplete});

  @override
  State<CheckOverlay> createState() => _CheckOverlayState();
}

class _CheckOverlayState extends State<CheckOverlay> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), widget.onComplete);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Edge flash — red border ring
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.bloodWine.withValues(alpha: 0.7),
                  width: 6,
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 200.ms)
                .then()
                .fadeOut(delay: 800.ms, duration: 700.ms),
          ),
        ),

        // Center "CHECK" glyph
        Center(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.abyssBlack.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.bloodWine.withValues(alpha: 0.9),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.bloodWine.withValues(alpha: 0.5),
                  blurRadius: 40,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.bloodWine,
                  size: 28,
                  shadows: [
                    Shadow(
                      color: AppColors.bloodWine.withValues(alpha: 0.8),
                      blurRadius: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'CHECK',
                  style: GoogleFonts.cinzel(
                    color: AppColors.candleIvory,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 10,
                    shadows: [
                      Shadow(
                        color: AppColors.bloodWine.withValues(alpha: 0.9),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
              .animate()
              .scaleXY(begin: 0.7, end: 1.0, duration: 300.ms, curve: Curves.easeOutBack)
              .fadeIn(duration: 300.ms)
              .then()
              .fadeOut(delay: 900.ms, duration: 500.ms),
        ),
      ],
    );
  }
}
