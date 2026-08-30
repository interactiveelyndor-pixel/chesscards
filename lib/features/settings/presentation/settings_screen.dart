import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/audio/audio_service.dart';
import '../../../../core/audio/audio_enums.dart';
import '../../../../theme/app_colors.dart';
import '../../../../shared/widgets/gothic_background.dart';
import '../../tutorial/application/tutorial_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsService = ref.watch(settingsServiceProvider);
    
    return Scaffold(
      backgroundColor: AppColors.abyssBlack,
      body: GothicBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // --- Custom AppBar ---
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
                        'SETTINGS',
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

              // --- Settings Panel ---
              Expanded(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF140700).withOpacity(0.85), // Carved stone/wood backing
                          border: Border.all(color: const Color(0xFF6B2700), width: 2.0),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6D00).withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _SettingRow(
                              label: 'MUSIC',
                              icon: Icons.music_note_rounded,
                              value: settingsService.musicEnabled,
                              onChanged: (val) {
                                settingsService.setMusicEnabled(val);
                                if (!val) {
                                  ref.read(audioServiceProvider).stopBgm();
                                } else {
                                  ref.read(audioServiceProvider).playBgm(BgmType.mainMenu);
                                }
                                setState(() {});
                              },
                            ),
                            const Divider(color: Color(0xFF4A1A00), height: 32, thickness: 1.5),
                            _SettingRow(
                              label: 'SFX',
                              icon: Icons.volume_up_rounded,
                              value: settingsService.sfxEnabled,
                              onChanged: (val) {
                                settingsService.setSfxEnabled(val);
                                setState(() {});
                              },
                            ),
                            const Divider(color: Color(0xFF4A1A00), height: 32, thickness: 1.5),
                            _SettingRow(
                              label: 'VIBRATION',
                              icon: Icons.vibration_rounded,
                              value: settingsService.vibrationEnabled,
                              onChanged: (val) {
                                settingsService.setVibrationEnabled(val);
                                setState(() {});
                              },
                            ),
                            const Divider(color: Color(0xFF4A1A00), height: 32, thickness: 1.5),
                            const _StaticSettingRow(
                              label: 'DARK THEME',
                              icon: Icons.dark_mode_rounded,
                              valueText: 'ALWAYS ON',
                            ),
                            const Divider(color: Color(0xFF4A1A00), height: 32, thickness: 1.5),
                            const _StaticSettingRow(
                              label: 'LANGUAGE',
                              icon: Icons.language_rounded,
                              valueText: 'ENGLISH',
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                    ),
                  ),
                ),
              ),

              // --- Reset Tutorial Button ---
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 12),
                child: TextButton.icon(
                  onPressed: () {
                    ref.read(settingsServiceProvider).setTutorialProgress(0);
                    ref.read(tutorialControllerProvider.notifier).resetTutorial();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Tutorial reset! Go to Main Menu to restart.',
                          style: GoogleFonts.cinzel(color: Colors.white),
                        ),
                        backgroundColor: const Color(0xFF4A1A00),
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFFD48A42)),
                  label: Text(
                    'RESET TUTORIAL',
                    style: GoogleFonts.cinzel(
                      color: const Color(0xFFD48A42),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
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

class _SettingRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFFD48A42), size: 24),
            const SizedBox(width: 16),
            Text(
              label, 
              style: GoogleFonts.cinzel(
                color: const Color(0xFFFFF3E0), 
                letterSpacing: 2,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFFF9E00), // Glowing ember thumb
          activeTrackColor: const Color(0xFF9D0208).withOpacity(0.5), // Dark red track
          inactiveThumbColor: const Color(0xFF666666),
          inactiveTrackColor: const Color(0xFF1A0A00),
        ),
      ],
    );
  }
}

class _StaticSettingRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final String valueText;

  const _StaticSettingRow({
    required this.label,
    required this.icon,
    required this.valueText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFFD48A42), size: 24),
            const SizedBox(width: 16),
            Text(
              label, 
              style: GoogleFonts.cinzel(
                color: const Color(0xFFFFF3E0), 
                letterSpacing: 2,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          valueText,
          style: GoogleFonts.cinzel(
            color: const Color(0xFFDC2F02),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
