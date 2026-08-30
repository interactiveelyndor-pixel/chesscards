import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/turn_phase.dart';

class EndTurnButton extends StatelessWidget {
  final TurnPhase phase;
  final VoidCallback onPressed;

  const EndTurnButton({
    super.key,
    required this.phase,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Disabled states: waiting, game over, or still in move phase (must move first)
    final isDisabled = phase == TurnPhase.waiting ||
        phase == TurnPhase.gameOver ||
        phase == TurnPhase.move;
    final isCardPhase = phase == TurnPhase.card;

    String text = 'Move First';
    if (isCardPhase) text = 'End Turn';
    if (phase == TurnPhase.waiting) text = 'Waiting...';

    final Color glowColor = isDisabled
        ? Colors.transparent
        : (isCardPhase ? const Color(0xFFDC2F02) : const Color(0xFFFF9E00));

    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(16),
        splashColor: glowColor.withValues(alpha: 0.3),
        child: Container(
          width: 108,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDisabled
                ? const Color(0xFF140700)
                : (isCardPhase ? const Color(0xFF9D0208) : const Color(0xFF6B2700)),
            boxShadow: isDisabled
                ? []
                : [
                    const BoxShadow(
                      color: Color(0xFF0D0200),
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: glowColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
            border: Border.all(
              color: isDisabled
                  ? const Color(0xFF331400)
                  : (isCardPhase ? const Color(0xFFDC2F02) : const Color(0xFFFF9E00)),
              width: 2.2,
            ),
          ),
          child: Text(
            text,
            style: GoogleFonts.cinzel(
              color: isDisabled
                  ? AppColors.fogGray
                  : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );

    if (isCardPhase) {
      button = button
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(begin: 1.0, end: 1.04, duration: 400.ms, curve: Curves.easeInOut)
          .boxShadow(
            begin: BoxShadow(color: AppColors.bloodWine.withValues(alpha: 0.4), blurRadius: 14),
            end: BoxShadow(color: AppColors.bloodWine.withValues(alpha: 0.9), blurRadius: 28),
            duration: 400.ms,
          );
    }

    return button;
  }
}

