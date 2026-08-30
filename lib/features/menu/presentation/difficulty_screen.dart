import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../theme/app_colors.dart';
import '../../match/application/match_controller.dart';
import '../../match/domain/chess_ai.dart';
import '../../../../shared/widgets/gothic_background.dart';
import '../../../../shared/widgets/gothic_button.dart';
import '../../../../shared/widgets/flying_bats.dart';
import '../../tutorial/application/tutorial_controller.dart';

class DifficultyScreen extends ConsumerWidget {
  const DifficultyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutorialStep = ref.watch(tutorialControllerProvider);
    final isTutorial = tutorialStep == TutorialStep.difficultySelect;

    return Scaffold(
      backgroundColor: AppColors.abyssBlack,
      body: GothicBackground(
        child: Stack(
          children: [
            // ── Main Screen Content ──────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // --- Top App Bar ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFCC7722)),
                          onPressed: () => context.go('/mode-select'),
                        ),
                        Expanded(
                          child: Text(
                            'SELECT DIFFICULTY',
                            style: GoogleFonts.cinzelDecorative(
                              color: const Color(0xFFFFB703),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4.0,
                              shadows: const [Shadow(color: Colors.black, blurRadius: 12)],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2),

                  const SizedBox(height: 10),

                  Text(
                    'THE CURSE GROWS STRONGER',
                    style: GoogleFonts.cinzel(
                      color: const Color(0xFFD48A42),
                      fontSize: 11,
                      letterSpacing: 6.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 800.ms),

                  const SizedBox(height: 40),
                  const FlyingBats(height: 80),
                  const Spacer(),

                  // --- Difficulty Buttons ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // NOVICE — always tappable
                        GothicButton(
                          label: 'NOVICE',
                          icon: Icons.shield_rounded,
                          glowColor: const Color(0xFFFFBA08),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFF48C06), Color(0xFF1A0A00)],
                          ),
                          onTap: () {
                            if (isTutorial) {
                              ref.read(tutorialControllerProvider.notifier).completeStep(TutorialStep.difficultySelect);
                            }
                            ref.read(matchControllerProvider.notifier).startAiMatch(difficulty: AiDifficulty.novice);
                            context.go('/match');
                          },
                          delay: 0,
                        ),
                        const SizedBox(height: 16),
                        // HAUNTED — disabled during tutorial
                        Opacity(
                          opacity: isTutorial ? 0.25 : 1.0,
                          child: IgnorePointer(
                            ignoring: isTutorial,
                            child: GothicButton(
                              label: 'HAUNTED',
                              icon: Icons.auto_awesome_rounded,
                              glowColor: const Color(0xFFFF7200),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFDC2F02), Color(0xFF1A0500)],
                              ),
                              onTap: () {
                                ref.read(matchControllerProvider.notifier).startAiMatch(difficulty: AiDifficulty.haunted);
                                context.go('/match');
                              },
                              delay: 150,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // NIGHTMARE — disabled during tutorial
                        Opacity(
                          opacity: isTutorial ? 0.25 : 1.0,
                          child: IgnorePointer(
                            ignoring: isTutorial,
                            child: GothicButton(
                              label: 'NIGHTMARE',
                              icon: Icons.whatshot_rounded,
                              glowColor: const Color(0xFFD00000),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF9D0208), Color(0xFF0D0000)],
                              ),
                              onTap: () {
                                ref.read(matchControllerProvider.notifier).startAiMatch(difficulty: AiDifficulty.nightmare);
                                context.go('/match');
                              },
                              delay: 300,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: TextButton.icon(
                      onPressed: isTutorial ? null : () => context.pop(),
                      icon: Icon(Icons.arrow_back_ios_new_rounded, size: 16,
                          color: isTutorial ? Colors.grey.withValues(alpha: 0.3) : const Color(0xFF8B4500)),
                      label: Text(
                        'BACK TO MODE SELECT',
                        style: GoogleFonts.cinzel(
                          color: isTutorial ? Colors.grey.withValues(alpha: 0.3) : const Color(0xFFCC7722),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ).animate().fadeIn(delay: 500.ms),
                  ),
                ],
              ),
            ),

            // ── Tutorial Overlay: Elyndor + Dialogue (only during tutorial) ──
            if (isTutorial)
              Positioned.fill(
                child: Stack(
                  children: [
                    // Semi-transparent dim — does NOT block touches on buttons below
                    IgnorePointer(
                      child: Container(color: Colors.black.withValues(alpha: 0.55)),
                    ),

                    // Elyndor character bottom-right
                    Positioned(
                      bottom: 0,
                      right: -10,
                      child: Image.asset(
                        'assets/images/elyndor.png',
                        height: 300,
                        errorBuilder: (_, __, ___) => const SizedBox(
                          height: 300,
                          width: 200,
                          child: Icon(Icons.person, size: 180, color: Color(0xFF8B4500)),
                        ),
                      ).animate().slideY(begin: 1.0, curve: Curves.easeOutBack, duration: 600.ms),
                    ),

                    // Dialogue box bottom-left
                    Positioned(
                      bottom: 80,
                      left: 16,
                      right: 180,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF140700).withValues(alpha: 0.96),
                          border: Border.all(color: const Color(0xFFFF9E00), width: 2),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF9E00).withValues(alpha: 0.3),
                              blurRadius: 18,
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ELYNDOR',
                              style: GoogleFonts.cinzelDecorative(
                                color: const Color(0xFFFFD166),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Let's start simple — tap NOVICE for your first duel!",
                              style: GoogleFonts.cinzel(
                                color: const Color(0xFFE5E5E5),
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ).animate().fadeIn(duration: 500.ms),
                          ],
                        ),
                      ).animate(delay: 400.ms).scaleXY(begin: 0.85, curve: Curves.easeOutBack, duration: 400.ms).fadeIn(),
                    ),

                    // Arrow pointing up to NOVICE button
                    Positioned(
                      bottom: 75,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Center(
                          child: Icon(
                            Icons.arrow_upward_rounded,
                            color: const Color(0xFFFFD166),
                            size: 32,
                          ).animate(onPlay: (c) => c.repeat())
                            .moveY(begin: 0, end: -10, duration: 600.ms, curve: Curves.easeInOut)
                            .then()
                            .moveY(begin: -10, end: 0, duration: 600.ms, curve: Curves.easeInOut),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
