import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

enum DollState {
  calm,
  uneasy,
  cracked,
  possessed,
  screaming,
  cursed;

  String get displayName {
    return name[0].toUpperCase() + name.substring(1);
  }

  String get description {
    switch (this) {
      case DollState.calm: return 'The doll stares blankly.';
      case DollState.uneasy: return 'It feels like it is watching you.';
      case DollState.cracked: return 'Hairline fractures appear on the porcelain.';
      case DollState.possessed: return 'A dark energy radiates from within.';
      case DollState.screaming: return 'It emits a silent, agonizing scream.';
      case DollState.cursed: return 'The soul is entirely consumed by the void.';
    }
  }

  Color get glowColor {
    switch (this) {
      case DollState.calm: return Colors.transparent;
      case DollState.uneasy: return AppColors.candleIvory.withValues(alpha: 0.2);
      case DollState.cracked: return AppColors.ghostBlue.withValues(alpha: 0.4);
      case DollState.possessed: return AppColors.cursePurple.withValues(alpha: 0.6);
      case DollState.screaming: return AppColors.bloodWine.withValues(alpha: 0.8);
      case DollState.cursed: return AppColors.abyssBlack;
    }
  }
}
