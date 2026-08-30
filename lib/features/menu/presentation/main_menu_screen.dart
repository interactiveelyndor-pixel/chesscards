import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../tutorial/application/tutorial_controller.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/audio/audio_service.dart';
import '../../../../core/audio/audio_enums.dart';
import '../../../../shared/widgets/gothic_button.dart';
import '../../../../shared/widgets/gothic_background.dart';
import '../../../../shared/widgets/flying_bats.dart';
import '../../ads/presentation/widgets/max_banner_ad_widget.dart';
class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).playBgm(BgmType.mainMenu);
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final mainContent = PopScope(
      canPop: false,
      child: GothicBackground(
        child: Stack(
          children: [

            // --- Main Content ---
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 16),

                          // --- Logo / Title Block ---
                          _TitleBlock(floatController: _floatController),

                          // --- Atmospheric Bats flying across dead space ---
                          const FlyingBats(),

                          // --- Menu Buttons ---
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                GothicButton(
                                  label: 'PLAY LOCAL',
                                  icon: Icons.play_arrow_rounded,
                                  isPrimary: true,
                                  glowColor: const Color(0xFFFF9E00),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0xFFFF7200), Color(0xFF220901)],
                                  ),
                                  onTap: () {
                                    // Always advance tutorial if on welcome step
                                    final step = ref.read(tutorialControllerProvider);
                                    if (step == TutorialStep.welcome) {
                                      ref.read(tutorialControllerProvider.notifier).completeStep(TutorialStep.welcome);
                                    }
                                    context.go('/mode-select');
                                  },
                                  delay: 0,
                                ),
                                const SizedBox(height: 12),
                                GothicButton(
                                  label: 'PLAY ONLINE',
                                  icon: Icons.wifi_rounded,
                                  glowColor: const Color(0xFFFFBA08),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0xFFF48C06), Color(0xFF1A0A00)],
                                  ),
                                  onTap: () => context.go('/lobby'),
                                  delay: 60,
                                ),
                                const SizedBox(height: 12),
                                GothicButton(
                                  label: 'DAILY RITUALS',
                                  icon: Icons.auto_awesome_rounded,
                                  glowColor: const Color(0xFF9D4EDD),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0xFF7B2CBF), Color(0xFF240046)],
                                  ),
                                  onTap: () => context.push('/daily'),
                                  delay: 120,
                                ),
                                const SizedBox(height: 12),
                                GothicButton(
                                  label: 'SETTINGS',
                                  icon: Icons.settings_rounded,
                                  glowColor: const Color(0xFFDC2F02),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0xFF9D0208), Color(0xFF0D0200)],
                                  ),
                                  onTap: () => context.go('/settings'),
                                  delay: 180,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // --- Bottom Nav ---
                          _BottomNav(size: size),
                        ],
                      ),

                      // --- Studio Credit fills the footer area ---
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '⚜',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFFAD5C00),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'MADE BY',
                              style: GoogleFonts.cinzel(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF8B4500),
                                letterSpacing: 4.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Elyndor Interactive',
                              style: GoogleFonts.cinzelDecorative(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFCC7722),
                                letterSpacing: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'SUPER CHESS v1.0.0',
                              style: GoogleFonts.cinzel(
                                color: const Color(0xFF8B4500),
                                fontSize: 9,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- AppLovin MAX Banner Ad ---
                      const MaxBannerAdWidget(
                        topPadding: 12,
                        bottomPadding: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.abyssBlack,
      body: Consumer(
        builder: (context, ref, child) {
          final tutorialStep = ref.watch(tutorialControllerProvider);
          
          return Stack(
            children: [
              mainContent,
              // ── Tutorial welcome overlay ──────────────────────────────
              if (tutorialStep == TutorialStep.welcome)
                Positioned.fill(
                  child: Stack(
                    children: [
                      // Dim — does NOT block taps on buttons below
                      IgnorePointer(
                        child: Container(color: Colors.black.withValues(alpha: 0.55)),
                      ),

                      // Elyndor portrait bottom-left
                      Positioned(
                        bottom: 0,
                        left: -10,
                        child: Image.asset(
                          'assets/images/elyndor.png',
                          height: 320,
                          errorBuilder: (_, __, ___) => const SizedBox(
                            height: 320,
                            width: 210,
                            child: Icon(Icons.person, size: 200, color: Color(0xFF8B4500)),
                          ),
                        ).animate().slideY(begin: 1.0, curve: Curves.easeOutBack, duration: 600.ms),
                      ),

                      // Dialogue box bottom-right
                      Positioned(
                        bottom: 80,
                        left: 190,
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
                                "Welcome to the Abyss... I am Elyndor. Tap 'PLAY LOCAL' to begin your first lesson!",
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
          );
        },
      ),
    );
  }
}

// ────────────────────────────────────────
// Title Block with floating animation
// ────────────────────────────────────────
class _TitleBlock extends StatelessWidget {
  final AnimationController floatController;
  const _TitleBlock({required this.floatController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatController,
      builder: (context, child) {
        final offset = sin(floatController.value * pi) * 6;
        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Premium Logo Image (transparent PNG) ---
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.transparent,
                BlendMode.multiply,
              ),
              child: Image.asset(
                'assets/images/game_logo.png',
                fit: BoxFit.fitWidth,
                errorBuilder: (_, __, ___) {
                  // Fallback to text if image fails to load
                  return _FallbackLogo();
                },
              ),
            )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(
                  begin: const Offset(0.92, 0.92),
                  curve: Curves.easeOutCubic,
                  duration: 1000.ms,
                ),
          ],
        ),
      ),
    );
  }
}

// Fallback text logo if image fails
class _FallbackLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0814).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF8B1E2F).withValues(alpha: 0.6),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC1121F).withValues(alpha: 0.25),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFB703), Color(0xFFE85D04), Color(0xFF7A0C16)],
            ).createShader(rect),
            child: Text(
              'SPOOK·A·CHESS',
              style: GoogleFonts.cinzelDecorative(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'THE HAUNTED STRATEGY',
            style: GoogleFonts.cinzel(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFE0D6C3),
              letterSpacing: 4.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckeredShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Path shieldPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.05)
      ..lineTo(size.width * 0.95, size.height * 0.2)
      ..lineTo(size.width * 0.95, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.9, size.height * 0.85, size.width * 0.5, size.height * 0.98)
      ..quadraticBezierTo(size.width * 0.1, size.height * 0.85, size.width * 0.05, size.height * 0.55)
      ..lineTo(size.width * 0.05, size.height * 0.2)
      ..close();

    canvas.save();
    canvas.clipPath(shieldPath);

    final midX = size.width * 0.5;
    final midY = size.height * 0.5;

    final darkPaint = Paint()..color = const Color(0xFF18050C);
    final redPaint = Paint()..color = const Color(0xFFE5383B);

    // Quadrant 1 (Top-Left: Dark)
    canvas.drawRect(Rect.fromLTRB(0, 0, midX, midY), darkPaint);
    // Quadrant 2 (Top-Right: Red)
    canvas.drawRect(Rect.fromLTRB(midX, 0, size.width, midY), redPaint);
    // Quadrant 3 (Bottom-Left: Red)
    canvas.drawRect(Rect.fromLTRB(0, midY, midX, size.height), redPaint);
    // Quadrant 4 (Bottom-Right: Dark)
    canvas.drawRect(Rect.fromLTRB(midX, midY, size.width, size.height), darkPaint);

    canvas.restore();

    // Shield outline
    final borderPaint = Paint()
      ..color = const Color(0xFFFF8FA3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(shieldPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ────────────────────────────────────────
// Bottom Navigation Bar
// ────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final Size size;
  const _BottomNav({required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Mist / smoke rising from above nav bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 120,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFF140700).withValues(alpha: 0.95),
                    const Color(0xFF0D0400).withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
        ),
        // The actual nav bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF140700).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF6B2700), width: 2.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6D00).withValues(alpha: 0.15),
                blurRadius: 18,
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: Color(0xFF000000),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'LEADERBOARD',
                onTap: () => context.go('/leaderboard'),
              ),
              _NavItem(
                icon: Icons.emoji_events_rounded,
                label: 'TROPHIES',
                onTap: () => context.go('/achievements'),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'PROFILE',
                onTap: () => context.push('/profile'),
              ),
              _NavItem(
                icon: Icons.storefront_rounded,
                label: 'STORE',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'COMING SOON',
                        style: GoogleFonts.cinzel(color: const Color(0xFFFFBA08), fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: const Color(0xFF140700),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Color(0xFF9D0208)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 500.ms, duration: 600.ms)
        .slideY(begin: 0.4, curve: Curves.easeOutCubic);
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFFFFB703), size: 26), // Golden icon — larger
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.cinzel(
                  color: const Color(0xFFD48A42), // Warm rusty gold text
                  fontSize: 7.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
