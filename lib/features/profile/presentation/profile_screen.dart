import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../shared/widgets/gothic_background.dart';
import '../../store/application/store_controller.dart';
import '../application/profile_controller.dart';
import '../domain/player_profile_stats.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeState = ref.watch(storeControllerProvider);
    final stats = ref.watch(profileControllerProvider);

    final level = storeState.playerLevel;
    final xp = storeState.playerXp;
    final xpForNextLevel = level * 500;
    final xpProgress = (xp % 500) / 500.0;
    final rankTitle = PlayerProfileStats.getRankTitle(level);

    return Scaffold(
      body: GothicBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Top App Bar ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.candleIvory),
                      onPressed: () => context.pop(),
                    ),
                    Text(
                      'SOUL GRIMOIRE',
                      style: GoogleFonts.cinzelDecorative(
                        color: AppColors.runeGold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    // Currency Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF140224),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF9D4EDD), width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.blur_on, color: AppColors.ghostBlue, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${storeState.soulFragments}',
                            style: GoogleFonts.cinzel(
                              color: AppColors.candleIvory,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Profile Body ──────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // ── 1. Master Level Header Card ────────────────────────
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF2B0938), Color(0xFF110418)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.runeGold.withValues(alpha: 0.7), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.runeGold.withValues(alpha: 0.2),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Level Crest Emblem
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const RadialGradient(
                                      colors: [Color(0xFFFF9E00), Color(0xFF5A1A00)],
                                    ),
                                    border: Border.all(color: AppColors.runeGold, width: 2.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF9E00).withValues(alpha: 0.4),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$level',
                                      style: GoogleFonts.cinzel(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'LEVEL $level',
                                        style: GoogleFonts.cinzel(
                                          color: AppColors.runeGold,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        rankTitle,
                                        style: GoogleFonts.cinzelDecorative(
                                          color: AppColors.candleIvory,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'XP: $xp / $xpForNextLevel',
                                        style: GoogleFonts.cinzel(
                                          color: AppColors.fogGray,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // XP Progress Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: xpProgress.clamp(0.05, 1.0),
                                minHeight: 8,
                                backgroundColor: const Color(0xFF140700),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9E00)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── 2. Playstyle & Tactical Signature ──────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF140700),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: stats.playStyleColor.withValues(alpha: 0.8),
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: stats.playStyleColor.withValues(alpha: 0.15),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: stats.playStyleColor.withValues(alpha: 0.2),
                                border: Border.all(color: stats.playStyleColor, width: 1.5),
                              ),
                              child: Icon(stats.playStyleIcon, color: stats.playStyleColor, size: 26),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TACTICAL ARCHETYPE',
                                    style: GoogleFonts.cinzel(
                                      color: stats.playStyleColor,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  Text(
                                    stats.playStyleTitle,
                                    style: GoogleFonts.cinzelDecorative(
                                      color: AppColors.candleIvory,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    stats.playStyleDescription,
                                    style: GoogleFonts.raleway(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── 3. Performance & Stats Grid ───────────────────────
                      Row(
                        children: [
                          _StatCard(
                            title: 'MATCHES',
                            value: '${stats.totalMatchesPlayed}',
                            subtitle: '${stats.totalWins}W / ${stats.totalLosses}L',
                            icon: Icons.sports_esports_rounded,
                            accentColor: AppColors.runeGold,
                          ),
                          const SizedBox(width: 10),
                          _StatCard(
                            title: 'WIN RATE',
                            value: '${stats.winRate.toStringAsFixed(1)}%',
                            subtitle: 'Streak: ${stats.currentWinStreak} (Best: ${stats.highestWinStreak})',
                            icon: Icons.military_tech_rounded,
                            accentColor: const Color(0xFF55A630),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _StatCard(
                            title: 'CHECKMATES',
                            value: '${stats.totalCheckmates}',
                            subtitle: 'Lethal Strikes',
                            icon: Icons.gavel_rounded,
                            accentColor: AppColors.bloodWine,
                          ),
                          const SizedBox(width: 10),
                          _StatCard(
                            title: 'SPELLS CAST',
                            value: '${stats.totalSpellsCast}',
                            subtitle: 'Favorite: ${stats.mostUsedSpell}',
                            icon: Icons.auto_awesome,
                            accentColor: AppColors.cursePurple,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _StatCard(
                            title: 'RELICS EQUIPPED',
                            value: '${stats.totalRelicsEquipped}',
                            subtitle: 'Loot Artifacts',
                            icon: Icons.shield_rounded,
                            accentColor: AppColors.ghostBlue,
                          ),
                          const SizedBox(width: 10),
                          _StatCard(
                            title: 'NIGHTMARES',
                            value: '${stats.totalPuzzlesSolved}',
                            subtitle: 'Puzzles Solved',
                            icon: Icons.psychology_rounded,
                            accentColor: const Color(0xFFFF9E00),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── 4. Rank Hierarchy Roadmap ─────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10071C),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF381A54), width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GOTHIC RANKS ROADMAP',
                              style: GoogleFonts.cinzel(
                                color: AppColors.runeGold,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _RankRow(title: 'Novice Necromancer', minLevel: 1, currentLevel: level),
                            _RankRow(title: 'Crypt Apprentice', minLevel: 3, currentLevel: level),
                            _RankRow(title: 'Graveyard Warden', minLevel: 5, currentLevel: level),
                            _RankRow(title: 'Shadow Sorcerer', minLevel: 8, currentLevel: level),
                            _RankRow(title: 'Soul Monarch', minLevel: 12, currentLevel: level),
                            _RankRow(title: 'Lich Grandmaster', minLevel: 16, currentLevel: level),
                            _RankRow(title: 'Abyssal Overlord', minLevel: 20, currentLevel: level),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF140700),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cinzel(
                    color: AppColors.fogGray,
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                Icon(icon, color: accentColor, size: 16),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.cinzel(
                color: AppColors.candleIvory,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.raleway(
                color: Colors.white60,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final String title;
  final int minLevel;
  final int currentLevel;

  const _RankRow({
    required this.title,
    required this.minLevel,
    required this.currentLevel,
  });

  @override
  Widget build(BuildContext context) {
    final isReached = currentLevel >= minLevel;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isReached ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isReached ? const Color(0xFF55A630) : AppColors.fogGray.withValues(alpha: 0.5),
            size: 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.cinzel(
                color: isReached ? AppColors.candleIvory : AppColors.fogGray,
                fontSize: 11,
                fontWeight: isReached ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            'Lv. $minLevel',
            style: GoogleFonts.cinzel(
              color: isReached ? AppColors.runeGold : AppColors.fogGray,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
