import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../application/achievements_controller.dart';
import '../../../../shared/widgets/gothic_background.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref.watch(achievementsControllerProvider);

    final achievements = [
      _Achievement(
        id: 'first_blood',
        title: 'FIRST BLOOD',
        description: 'Capture your first piece.',
        icon: Icons.sports_kabaddi,
        isUnlocked: unlocked.contains('first_blood'),
      ),
      _Achievement(
        id: 'necromancer',
        title: 'NECROMANCER',
        description: 'Play 5 Paranormal Cards in a single match.',
        icon: Icons.auto_awesome,
        isUnlocked: unlocked.contains('necromancer'),
      ),
      _Achievement(
        id: 'checkmate',
        title: 'CHECKMATE',
        description: 'Win a game against a haunted AI.',
        icon: Icons.emoji_events,
        isUnlocked: unlocked.contains('checkmate'),
      ),
      _Achievement(
        id: 'abyssal_master',
        title: 'ABYSSAL MASTER',
        description: 'Win 10 matches.',
        icon: Icons.public,
        isUnlocked: unlocked.contains('abyssal_master'),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.abyssBlack,
      body: GothicBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // --- Top App Bar Area ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFCC7722)),
                      onPressed: () => context.go('/menu'),
                    ),
                    Expanded(
                      child: Text(
                        'TROPHIES',
                        style: GoogleFonts.cinzelDecorative(
                          color: const Color(0xFFFFB703),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4.0,
                          shadows: const [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance for back button
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.2),

              const SizedBox(height: 40),

              // --- List ---
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      itemCount: achievements.length,
                      itemBuilder: (context, index) {
                        final ach = achievements[index];
                        return _AchievementTile(achievement: ach)
                            .animate()
                            .fadeIn(delay: Duration(milliseconds: 100 * index))
                            .slideY(begin: 0.2, delay: Duration(milliseconds: 100 * index));
                      },
                    ),
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

class _Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;

  _Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
  });
}

class _AchievementTile extends StatelessWidget {
  final _Achievement achievement;

  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final color = achievement.isUnlocked ? const Color(0xFFFFBA08) : const Color(0xFF4A1A00);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF140700).withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color,
          width: achievement.isUnlocked ? 2.5 : 1.5,
        ),
        boxShadow: achievement.isUnlocked
            ? [
                BoxShadow(
                  color: const Color(0xFFFF6D00).withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: achievement.isUnlocked ? const Color(0xFF9D0208).withOpacity(0.2) : const Color(0xFF0D0200),
              shape: BoxShape.circle,
              border: Border.all(color: color),
              boxShadow: achievement.isUnlocked ? [
                BoxShadow(
                  color: const Color(0xFF9D0208).withOpacity(0.4),
                  blurRadius: 10,
                )
              ] : [],
            ),
            child: Icon(
              achievement.icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(width: 24),
          
          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: GoogleFonts.cinzel(
                    color: achievement.isUnlocked ? const Color(0xFFFFF3E0) : const Color(0xFF8B4500),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  achievement.description,
                  style: GoogleFonts.raleway(
                    color: achievement.isUnlocked ? const Color(0xFFD48A42) : const Color(0xFF6B2700),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          if (achievement.isUnlocked)
            const Icon(
              Icons.stars_rounded,
              color: Color(0xFFFF9E00),
              size: 28,
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1.seconds),
        ],
      ),
    );
  }
}
