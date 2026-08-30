import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';
import '../../../../shared/enums/piece_color.dart';
import '../../domain/match_result.dart';

class MatchSummaryOverlay extends StatelessWidget {
  final MatchResult result;
  final int playerCaptures;
  final int opponentCaptures;
  final int playerHealTotal;
  final int totalTurns;
  final int earnedSouls;
  final VoidCallback onRematch;
  final VoidCallback onExit;

  const MatchSummaryOverlay({
    super.key,
    required this.result,
    required this.playerCaptures,
    required this.opponentCaptures,
    required this.playerHealTotal,
    required this.totalTurns,
    required this.earnedSouls,
    required this.onRematch,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final isWinner = result.winner == PieceColor.white;
    final titleText = isWinner ? 'VICTORY' : 'DEFEATED';
    final titleColor = isWinner ? AppColors.runeGold : AppColors.bloodWine;
    final subtitle = isWinner ? 'The spirits bow before you.' : 'The darkness claims you.';

    final duration = result.matchDuration;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final timeStr = '${minutes}m ${seconds}s';

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              isWinner
                  ? const Color(0xFF1A1500).withValues(alpha: 0.97)
                  : const Color(0xFF150008).withValues(alpha: 0.97),
              AppColors.abyssBlack.withValues(alpha: 0.98),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Title ─────────────────────────────────────────────────
              Text(
                titleText,
                style: GoogleFonts.cinzel(
                  color: titleColor,
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 14,
                  shadows: [
                    Shadow(color: titleColor.withValues(alpha: 0.8), blurRadius: 40),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .scaleXY(begin: 0.6, end: 1.0, curve: Curves.easeOutBack),

              const SizedBox(height: 8),

              Text(
                subtitle,
                style: GoogleFonts.raleway(
                  color: AppColors.fogGray.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 800.ms),

              const SizedBox(height: 48),

              // ── Stats Card ────────────────────────────────────────────
              Container(
                width: 340,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.voidPanel.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: titleColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: titleColor.withValues(alpha: 0.08),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _StatRow(
                      icon: Icons.sports_kabaddi,
                      label: 'Pieces Captured',
                      value: '$playerCaptures',
                      color: AppColors.runeGold,
                    ),
                    const Divider(color: Colors.white12, height: 20),
                    _StatRow(
                      icon: Icons.favorite,
                      label: 'Total Healed',
                      value: '+$playerHealTotal HP',
                      color: AppColors.spectralGreen,
                    ),
                    const Divider(color: Colors.white12, height: 20),
                    _StatRow(
                      icon: Icons.swap_horiz,
                      label: 'Total Turns',
                      value: '$totalTurns',
                      color: AppColors.ghostBlue,
                    ),
                    const Divider(color: Colors.white12, height: 20),
                    _StatRow(
                      icon: Icons.timer_outlined,
                      label: 'Match Duration',
                      value: timeStr,
                      color: AppColors.fogGray,
                    ),
                    const Divider(color: Colors.white12, height: 20),
                    _StatRow(
                      icon: Icons.diamond_outlined,
                      label: 'Souls Earned',
                      value: '+$earnedSouls',
                      color: AppColors.soulFlame,
                    ),
                    const Divider(color: Colors.white12, height: 20),
                    _StatRow(
                      icon: Icons.star_border,
                      label: 'XP Earned',
                      value: '+${result.earnedXp} XP',
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 48),

              // ── Buttons ───────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SummaryButton(
                    label: 'REMATCH',
                    icon: Icons.replay,
                    color: titleColor,
                    onTap: onRematch,
                  ),
                  const SizedBox(width: 16),
                  _SummaryButton(
                    label: 'MAIN MENU',
                    icon: Icons.home_outlined,
                    color: AppColors.fogGray,
                    onTap: onExit,
                  ),
                ],
              ).animate().fadeIn(delay: 900.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.raleway(
            color: AppColors.fogGray,
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.cinzel(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SummaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SummaryButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
          color: color.withValues(alpha: 0.1),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cinzel(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
