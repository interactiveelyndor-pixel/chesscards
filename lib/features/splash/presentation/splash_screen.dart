import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../shared/widgets/gothic_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) context.go('/menu');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.abyssBlack,
      body: GothicBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // Logo Image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.transparent,
                    BlendMode.multiply,
                  ),
                  child: Image.asset(
                    'assets/images/game_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return Text(
                        'SPOOK-A-CHESS',
                        style: GoogleFonts.cinzelDecorative(
                          color: const Color(0xFFFFB703),
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 1500.ms)
              .scale(
                begin: const Offset(0.9, 0.9), 
                end: const Offset(1.0, 1.0), 
                duration: 2000.ms, 
                curve: Curves.easeOutCubic
              ),

              const SizedBox(height: 20),

              // Studio Text
              Text(
                'ELYNDOR INTERACTIVE',
                style: GoogleFonts.cinzel(
                  color: const Color(0xFFD48A42),
                  fontSize: 14,
                  letterSpacing: 8,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(delay: 800.ms, duration: 1500.ms),

              const Spacer(flex: 3),

              // Loading indicator
              const CircularProgressIndicator(color: Color(0xFFE85D04))
                  .animate()
                  .fadeIn(delay: 1500.ms),
              
              const SizedBox(height: 16),
              
              Text(
                'AWAKENING...',
                style: GoogleFonts.cinzel(
                  color: const Color(0xFF8B4500),
                  fontSize: 12,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(delay: 1500.ms),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
