import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../theme/app_colors.dart';
import '../../match/application/match_controller.dart';
import '../../../../shared/widgets/gothic_background.dart';
import '../../../../shared/widgets/gothic_button.dart';
import '../../../../shared/widgets/flying_bats.dart';
import '../../tutorial/application/tutorial_controller.dart';

class ModeSelectionScreen extends ConsumerWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutorialStep = ref.watch(tutorialControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.abyssBlack,
      body: GothicBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 40),

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
                            'SELECT MODE',
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
                        const SizedBox(width: 48), // Balance
                      ],
                    ),
                  ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2),

                  const SizedBox(height: 10),

                  // --- Sub-header ---
                  Text(
                    'CHOOSE YOUR PATH',
                    style: GoogleFonts.cinzel(
                      color: const Color(0xFFD48A42),
                      fontSize: 12,
                      letterSpacing: 6.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 800.ms),

                  const SizedBox(height: 60),

                  // --- Center content: The two main cards ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ModeCard(
                            title: 'LOCAL MULTIPLAYER',
                            icon: Icons.people_alt_rounded,
                            glowColor: const Color(0xFFFF9E00),
                            delayMs: 100,
                            onTap: () {
                              ref.read(matchControllerProvider.notifier).startLocalMatch();
                              context.go('/match');
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _ModeCard(
                            title: 'VS AI',
                            icon: Icons.smart_toy_rounded,
                            glowColor: const Color(0xFFDC2F02),
                            delayMs: 250,
                            onTap: () {
                              if (tutorialStep == TutorialStep.modeSelect) {
                                ref.read(tutorialControllerProvider.notifier).completeStep(TutorialStep.modeSelect);
                              }
                              context.go('/difficulty');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  const SizedBox(height: 20),

                  // --- Back Button ---
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: TextButton.icon(
                      onPressed: () => context.go('/menu'),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF8B4500)),
                      label: Text(
                        'BACK TO MENU',
                        style: GoogleFonts.cinzel(
                          color: const Color(0xFFCC7722),
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
            
            // ── Tutorial Overlay for modeSelect step ──────────────────────
            if (tutorialStep == TutorialStep.modeSelect)
              Positioned.fill(
                child: Stack(
                  children: [
                    // Dim that doesn't block touches
                    IgnorePointer(
                      child: Container(color: Colors.black.withValues(alpha: 0.55)),
                    ),

                    // Elyndor character bottom-left
                    Positioned(
                      bottom: 0,
                      left: -10,
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

                    // Dialogue box bottom-right
                    Positioned(
                      bottom: 80,
                      left: 180,
                      right: 16,
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
                              "Choose 'VS AI' to practice your arcane arts against the machine!",
                              style: GoogleFonts.cinzel(
                                color: const Color(0xFFE5E5E5),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ).animate().fadeIn(duration: 500.ms),
                          ],
                        ),
                      ).animate(delay: 400.ms).scaleXY(begin: 0.85, curve: Curves.easeOutBack, duration: 400.ms).fadeIn(),
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

class _ModeCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color glowColor;
  final VoidCallback onTap;
  final int delayMs;

  const _ModeCard({
    required this.title,
    required this.icon,
    required this.glowColor,
    required this.onTap,
    this.delayMs = 0,
  });

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFF140700).withOpacity(0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? widget.glowColor : const Color(0xFF4A1A00),
              width: _isHovered ? 2.5 : 1.5,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.glowColor.withOpacity(0.3),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isHovered ? widget.glowColor.withOpacity(0.2) : const Color(0xFF0D0200),
                  shape: BoxShape.circle,
                  border: Border.all(color: _isHovered ? widget.glowColor : const Color(0xFF4A1A00)),
                ),
                child: Icon(
                  widget.icon,
                  color: _isHovered ? Colors.white : widget.glowColor,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.title.replaceAll(' ', '\n'), // Stack words vertically
                style: GoogleFonts.cinzel(
                  color: _isHovered ? const Color(0xFFFFF3E0) : const Color(0xFFD48A42),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: widget.delayMs)).slideY(begin: 0.2);
  }
}
