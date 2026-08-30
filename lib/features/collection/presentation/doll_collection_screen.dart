import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../theme/app_colors.dart';
import '../../../../shared/widgets/gothic_background.dart';

class DollCollectionScreen extends StatelessWidget {
  const DollCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                        'DOLL COLLECTION',
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

              // --- Dolls Carousel ---
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _DollCard(title: 'THE WATCHER', equipped: true).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                      const SizedBox(width: 32),
                      const _DollCard(title: 'THE CHILD', equipped: false).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                      const SizedBox(width: 32),
                      const _DollCard(title: 'THE MARIONETTE', equipped: false).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                    ],
                  ),
                ),
              ),

              // --- Bottom Info Bar ---
              Container(
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0400).withOpacity(0.85),
                  border: const Border(top: BorderSide(color: Color(0xFF4A1A00), width: 2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _BottomTab(label: 'EQUIP', icon: Icons.check_circle_outline, active: true),
                    _BottomTab(label: 'STATS', icon: Icons.analytics_outlined, active: false),
                    _BottomTab(label: 'LORE', icon: Icons.auto_stories, active: false),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5),
            ],
          ),
        ),
      ),
    );
  }
}

class _DollCard extends StatelessWidget {
  final String title;
  final bool equipped;

  const _DollCard({required this.title, required this.equipped});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF140700).withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: equipped ? const Color(0xFFFF9E00) : const Color(0xFF4A1A00),
          width: equipped ? 3 : 1.5,
        ),
        boxShadow: equipped
            ? [
                BoxShadow(
                  color: const Color(0xFFFF6D00).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Doll Image Area
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D0200),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                border: Border(bottom: BorderSide(color: equipped ? const Color(0xFFFF9E00) : const Color(0xFF4A1A00))),
              ),
              child: Center(
                child: Icon(
                  Icons.smart_toy_rounded,
                  size: 100,
                  color: equipped ? const Color(0xFFFFBA08) : const Color(0xFF8B4500),
                ),
              ),
            ),
          ),
          
          // Details Area
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title, 
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(
                      color: equipped ? const Color(0xFFFFF3E0) : const Color(0xFFD48A42),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (equipped)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9D0208).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFDC2F02)),
                      ),
                      child: Text(
                        'EQUIPPED',
                        style: GoogleFonts.cinzel(
                          color: const Color(0xFFFFBA08),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _BottomTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;

  const _BottomTab({required this.label, required this.icon, required this.active});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: active ? const Color(0xFFFFBA08) : const Color(0xFF8B4500),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.cinzel(
            color: active ? const Color(0xFFFFF3E0) : const Color(0xFF8B4500),
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            letterSpacing: 2.0,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
