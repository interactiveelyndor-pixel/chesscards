import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class RelicIconWidget extends StatelessWidget {
  final String relicId;
  final double size;

  const RelicIconWidget({
    super.key,
    required this.relicId,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = switch (relicId) {
      'relic_boots_of_haste' => (Icons.bolt_rounded, AppColors.spectralGreen),
      'relic_aegis_shield' => (Icons.shield_rounded, AppColors.ghostBlue),
      'relic_sniper_bow' => (Icons.gps_fixed_rounded, AppColors.soulFlame),
      'relic_ring_of_mana' => (Icons.auto_awesome, AppColors.cursePurple),
      _ => (Icons.stars_rounded, AppColors.runeGold),
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.0),
      ),
      child: Center(
        child: Icon(
          icon,
          size: size * 0.65,
          color: color,
        ),
      ),
    );
  }
}
