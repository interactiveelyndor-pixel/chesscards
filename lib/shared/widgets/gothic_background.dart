import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

// ────────────────────────────────────────
// Animated Gothic Background
// ────────────────────────────────────────
class GothicBackground extends StatefulWidget {
  final Widget child;

  const GothicBackground({super.key, required this.child});

  @override
  State<GothicBackground> createState() => _GothicBackgroundState();
}

class _GothicBackgroundState extends State<GothicBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.abyssBlack,
      body: Stack(
        children: [
          // Background Animation
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              final t = _pulseController.value;
              return Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/main_menu_bg_final.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF14070D),
                      ),
                    ),
                  ),

                  // Atmospheric Vignette
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF0C0612).withOpacity(0.55),
                            const Color(0xFF0C0612).withOpacity(0.65),
                            const Color(0xFF07040B).withOpacity(0.85),
                            const Color(0xFF040208).withOpacity(0.98),
                          ],
                          stops: const [0.0, 0.45, 0.72, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Floating fiery embers
                  ..._buildParticles(context, t),
                ],
              );
            },
          ),
          
          // Foreground Content
          widget.child,
        ],
      ),
    );
  }

  List<Widget> _buildParticles(BuildContext context, double t) {
    final rand = Random(42);
    final size = MediaQuery.of(context).size;
    return List.generate(18, (i) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final s = 2.0 + rand.nextDouble() * 3;
      final phase = rand.nextDouble();
      final alpha = (0.2 + 0.5 * ((t + phase) % 1.0)).clamp(0.0, 0.8);
      return Positioned(
        left: x,
        top: y - t * 30,
        child: Container(
          width: s,
          height: s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.bloodWine.withOpacity(alpha * 0.6),
            boxShadow: [
              BoxShadow(
                color: AppColors.bloodWine.withOpacity(alpha * 0.4),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      );
    });
  }
}
