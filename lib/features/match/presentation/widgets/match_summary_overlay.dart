import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';
import '../../../../shared/enums/piece_color.dart';
import '../../domain/match_result.dart';
import '../../../../core/services/ad_manager.dart';
import '../../../../core/audio/audio_service.dart';
import '../../../../core/audio/audio_enums.dart';
import '../../../store/application/store_controller.dart';

class MatchSummaryOverlay extends ConsumerStatefulWidget {
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
  ConsumerState<MatchSummaryOverlay> createState() => _MatchSummaryOverlayState();
}

class _MatchSummaryOverlayState extends ConsumerState<MatchSummaryOverlay> {
  bool _hasDoubledSouls = false;
  bool _isLoadingAd = false;

  void _onDoubleSoulsTapped() async {
    if (_hasDoubledSouls || _isLoadingAd || widget.earnedSouls <= 0) return;

    setState(() => _isLoadingAd = true);
    await AdManager.instance.showRewardedAd(
      onRewarded: () {
        ref.read(storeControllerProvider.notifier).addCurrency(souls: widget.earnedSouls);
        ref.read(audioServiceProvider).playSfx(SfxType.cardPlay);
        if (mounted) {
          setState(() {
            _hasDoubledSouls = true;
            _isLoadingAd = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.voidPanel,
              content: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.runeGold),
                  const SizedBox(width: 8),
                  Text(
                    '+${widget.earnedSouls} Extra Souls claimed!',
                    style: GoogleFonts.cinzel(color: AppColors.runeGold, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
    if (mounted) setState(() => _isLoadingAd = false);
  }

  @override
  Widget build(BuildContext context) {
    final isWinner = widget.result.winner == PieceColor.white;
    final titleText = isWinner ? 'VICTORY' : 'DEFEATED';
    final titleColor = isWinner ? AppColors.runeGold : AppColors.bloodWine;
    final subtitle = isWinner ? 'The spirits bow before you.' : 'The darkness claims you.';

    final duration = widget.result.matchDuration;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final timeStr = '${minutes}m ${seconds}s';

    final displayedSouls = _hasDoubledSouls ? widget.earnedSouls * 2 : widget.earnedSouls;

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

              const SizedBox(height: 32),

              // ── Stats Card ────────────────────────────────────────────
              Container(
                width: 340,
                padding: const EdgeInsets.all(22),
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
                      value: '${widget.playerCaptures}',
                      color: AppColors.runeGold,
                    ),
                    const Divider(color: Colors.white12, height: 18),
                    _StatRow(
                      icon: Icons.favorite,
                      label: 'Total Healed',
                      value: '+${widget.playerHealTotal} HP',
                      color: AppColors.spectralGreen,
                    ),
                    const Divider(color: Colors.white12, height: 18),
                    _StatRow(
                      icon: Icons.swap_horiz,
                      label: 'Total Turns',
                      value: '${widget.totalTurns}',
                      color: AppColors.ghostBlue,
                    ),
                    const Divider(color: Colors.white12, height: 18),
                    _StatRow(
                      icon: Icons.timer_outlined,
                      label: 'Match Duration',
                      value: timeStr,
                      color: AppColors.fogGray,
                    ),
                    const Divider(color: Colors.white12, height: 18),
                    _StatRow(
                      icon: Icons.diamond_outlined,
                      label: 'Souls Earned',
                      value: _hasDoubledSouls ? '+$displayedSouls (DOUBLED!)' : '+$displayedSouls',
                      color: _hasDoubledSouls ? AppColors.runeGold : AppColors.soulFlame,
                    ),
                    const Divider(color: Colors.white12, height: 18),
                    _StatRow(
                      icon: Icons.star_border,
                      label: 'XP Earned',
                      value: '+${widget.result.earnedXp} XP',
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 24),

              // ── Optional Double Souls Rewarded Button ────────────────────
              if (isWinner && widget.earnedSouls > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: InkWell(
                    onTap: _hasDoubledSouls ? null : _onDoubleSoulsTapped,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _hasDoubledSouls
                              ? [const Color(0xFF2A2A2A), const Color(0xFF1A1A1A)]
                              : [const Color(0xFFFFB703), const Color(0xFFE85D04), const Color(0xFF7A0C16)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _hasDoubledSouls ? Colors.white24 : AppColors.runeGold,
                          width: 1.5,
                        ),
                        boxShadow: _hasDoubledSouls
                            ? []
                            : [
                                BoxShadow(
                                  color: AppColors.runeGold.withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _hasDoubledSouls ? Icons.check_circle : Icons.video_collection_rounded,
                            color: _hasDoubledSouls ? AppColors.spectralGreen : Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _hasDoubledSouls
                                ? 'SOULS DOUBLED (+$displayedSouls)'
                                : 'DOUBLE SOULS (+${widget.earnedSouls * 2})',
                            style: GoogleFonts.cinzel(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 750.ms, duration: 600.ms).scaleXY(begin: 0.9, end: 1.0),

              // ── Rematch & Main Menu Action Buttons ───────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SummaryButton(
                    label: 'REMATCH',
                    icon: Icons.replay,
                    color: titleColor,
                    onTap: widget.onRematch,
                  ),
                  const SizedBox(width: 16),
                  _SummaryButton(
                    label: 'MAIN MENU',
                    icon: Icons.home_outlined,
                    color: AppColors.fogGray,
                    onTap: widget.onExit,
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
