import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/audio/audio_service.dart';
import '../../../../core/audio/audio_enums.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/network/network_service.dart';
import '../../application/match_controller.dart';
import '../../../menu/presentation/widgets/how_to_play_modal.dart';

class PauseMenuOverlay extends ConsumerStatefulWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;

  const PauseMenuOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
  });

  @override
  ConsumerState<PauseMenuOverlay> createState() => _PauseMenuOverlayState();
}

class _PauseMenuOverlayState extends ConsumerState<PauseMenuOverlay> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsServiceProvider);
    final audio = ref.read(audioServiceProvider);

    return Material(
      color: Colors.black.withValues(alpha: 0.78),
      child: Center(
        child: Container(
          width: 360,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF140D1B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.runeGold, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.runeGold.withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: Colors.black,
                blurRadius: 16,
              ),
            ],
          ),
          child: _buildMainPauseMenu(settings, audio),
        ),
      ),
    );
  }

  Widget _buildMainPauseMenu(SettingsService settings, AudioService audio) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pause_circle_outline, color: AppColors.runeGold, size: 28),
            const SizedBox(width: 8),
            Text(
              'GAME PAUSED',
              style: GoogleFonts.cinzel(
                color: AppColors.runeGold,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        Container(
          height: 1,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.runeGold.withValues(alpha: 0.6),
                Colors.transparent,
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Sound Toggles
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.fogGray.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        settings.musicEnabled ? Icons.music_note : Icons.music_off,
                        color: AppColors.soulFlame,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Music',
                        style: GoogleFonts.cinzel(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: settings.musicEnabled,
                    activeColor: AppColors.runeGold,
                    activeTrackColor: AppColors.soulFlame.withValues(alpha: 0.4),
                    onChanged: (val) async {
                      await settings.setMusicEnabled(val);
                      if (val) {
                        audio.playBgm(BgmType.inGame);
                      } else {
                        audio.stopBgm();
                      }
                      setState(() {});
                    },
                  ),
                ],
              ),
              const Divider(color: Colors.white12, height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        settings.sfxEnabled ? Icons.volume_up : Icons.volume_off,
                        color: AppColors.soulFlame,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sound Effects',
                        style: GoogleFonts.cinzel(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: settings.sfxEnabled,
                    activeColor: AppColors.runeGold,
                    activeTrackColor: AppColors.soulFlame.withValues(alpha: 0.4),
                    onChanged: (val) async {
                      await settings.setSfxEnabled(val);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Action Buttons
        _MenuButton(
          label: 'RESUME BATTLE',
          icon: Icons.play_arrow,
          color: AppColors.runeGold,
          textColor: Colors.black,
          onTap: widget.onResume,
        ),

        const SizedBox(height: 10),

        _MenuButton(
          label: 'HOW TO PLAY & RULES',
          icon: Icons.menu_book,
          color: const Color(0xFF2A1C38),
          textColor: AppColors.runeGold,
          onTap: () => HowToPlayModal.show(context),
        ),

        const SizedBox(height: 10),

        _MenuButton(
          label: 'RESTART MATCH',
          icon: Icons.refresh,
          color: const Color(0xFF2A1C38),
          textColor: AppColors.ghostBlue,
          onTap: () {
            widget.onRestart();
            widget.onResume();
          },
        ),

        const SizedBox(height: 10),

        _MenuButton(
          label: 'SURRENDER & EXIT',
          icon: Icons.exit_to_app,
          color: const Color(0xFF381418),
          textColor: const Color(0xFFFF6B6B),
          onTap: () {
            audio.stopBgm();
            if (ref.read(matchControllerProvider).isOnlineMode) {
              ref.read(networkServiceProvider).leaveMatch();
            }
            context.go('/menu');
          },
        ),
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: textColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cinzel(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
