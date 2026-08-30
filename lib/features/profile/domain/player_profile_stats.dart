import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

enum PlayStyleArchetype {
  aggressiveSpellweaver,
  fortressTactician,
  reanimationMaster,
  swiftExecutioner,
  balancedNecromancer,
}

class PlayerProfileStats {
  final int totalMatchesPlayed;
  final int totalWins;
  final int totalLosses;
  final int totalCheckmates;
  final int highestWinStreak;
  final int currentWinStreak;
  final int totalSpellsCast;
  final int totalRelicsEquipped;
  final int totalPuzzlesSolved;
  final String mostUsedSpell;
  final Map<String, int> spellUsageCounts;

  const PlayerProfileStats({
    this.totalMatchesPlayed = 0,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.totalCheckmates = 0,
    this.highestWinStreak = 0,
    this.currentWinStreak = 0,
    this.totalSpellsCast = 0,
    this.totalRelicsEquipped = 0,
    this.totalPuzzlesSolved = 0,
    this.mostUsedSpell = 'Fireball',
    this.spellUsageCounts = const {},
  });

  double get winRate =>
      totalMatchesPlayed > 0 ? (totalWins / totalMatchesPlayed) * 100 : 0.0;

  PlayStyleArchetype get playStyle {
    if (totalSpellsCast > totalMatchesPlayed * 3) {
      return PlayStyleArchetype.aggressiveSpellweaver;
    } else if (totalRelicsEquipped > totalMatchesPlayed * 2) {
      return PlayStyleArchetype.fortressTactician;
    } else if ((spellUsageCounts['spell_necromancy'] ?? 0) >= 3) {
      return PlayStyleArchetype.reanimationMaster;
    } else if (winRate >= 70 && totalMatchesPlayed >= 3) {
      return PlayStyleArchetype.swiftExecutioner;
    }
    return PlayStyleArchetype.balancedNecromancer;
  }

  String get playStyleTitle {
    switch (playStyle) {
      case PlayStyleArchetype.aggressiveSpellweaver:
        return 'Aggressive Spellweaver';
      case PlayStyleArchetype.fortressTactician:
        return 'Fortress Tactician';
      case PlayStyleArchetype.reanimationMaster:
        return 'Reanimation Specialist';
      case PlayStyleArchetype.swiftExecutioner:
        return 'Swift Executioner';
      case PlayStyleArchetype.balancedNecromancer:
        return 'Gothic Grandmaster';
    }
  }

  String get playStyleDescription {
    switch (playStyle) {
      case PlayStyleArchetype.aggressiveSpellweaver:
        return 'Devastates enemy formations with relentless elemental spell bombardments.';
      case PlayStyleArchetype.fortressTactician:
        return 'Fortifies defensive positions with relic equipment and impenetrable stone walls.';
      case PlayStyleArchetype.reanimationMaster:
        return 'Masters the dark arts to raise fallen pieces from the graveyard.';
      case PlayStyleArchetype.swiftExecutioner:
        return 'Delivers lethal tactical checkmates with terrifying speed and precision.';
      case PlayStyleArchetype.balancedNecromancer:
        return 'Maintains a harmonious balance between classical chess mastery and dark sorcery.';
    }
  }

  IconData get playStyleIcon {
    switch (playStyle) {
      case PlayStyleArchetype.aggressiveSpellweaver:
        return Icons.auto_awesome;
      case PlayStyleArchetype.fortressTactician:
        return Icons.shield_rounded;
      case PlayStyleArchetype.reanimationMaster:
        return Icons.all_inclusive_rounded;
      case PlayStyleArchetype.swiftExecutioner:
        return Icons.bolt_rounded;
      case PlayStyleArchetype.balancedNecromancer:
        return Icons.military_tech_rounded;
    }
  }

  Color get playStyleColor {
    switch (playStyle) {
      case PlayStyleArchetype.aggressiveSpellweaver:
        return AppColors.soulFlame;
      case PlayStyleArchetype.fortressTactician:
        return AppColors.ghostBlue;
      case PlayStyleArchetype.reanimationMaster:
        return AppColors.spectralGreen;
      case PlayStyleArchetype.swiftExecutioner:
        return AppColors.runeGold;
      case PlayStyleArchetype.balancedNecromancer:
        return AppColors.cursePurple;
    }
  }

  static String getRankTitle(int level) {
    if (level < 3) return 'Novice Necromancer';
    if (level < 5) return 'Crypt Apprentice';
    if (level < 8) return 'Graveyard Warden';
    if (level < 12) return 'Shadow Sorcerer';
    if (level < 16) return 'Soul Monarch';
    if (level < 20) return 'Lich Grandmaster';
    return 'Abyssal Overlord';
  }

  PlayerProfileStats copyWith({
    int? totalMatchesPlayed,
    int? totalWins,
    int? totalLosses,
    int? totalCheckmates,
    int? highestWinStreak,
    int? currentWinStreak,
    int? totalSpellsCast,
    int? totalRelicsEquipped,
    int? totalPuzzlesSolved,
    String? mostUsedSpell,
    Map<String, int>? spellUsageCounts,
  }) {
    return PlayerProfileStats(
      totalMatchesPlayed: totalMatchesPlayed ?? this.totalMatchesPlayed,
      totalWins: totalWins ?? this.totalWins,
      totalLosses: totalLosses ?? this.totalLosses,
      totalCheckmates: totalCheckmates ?? this.totalCheckmates,
      highestWinStreak: highestWinStreak ?? this.highestWinStreak,
      currentWinStreak: currentWinStreak ?? this.currentWinStreak,
      totalSpellsCast: totalSpellsCast ?? this.totalSpellsCast,
      totalRelicsEquipped: totalRelicsEquipped ?? this.totalRelicsEquipped,
      totalPuzzlesSolved: totalPuzzlesSolved ?? this.totalPuzzlesSolved,
      mostUsedSpell: mostUsedSpell ?? this.mostUsedSpell,
      spellUsageCounts: spellUsageCounts ?? this.spellUsageCounts,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalMatchesPlayed': totalMatchesPlayed,
        'totalWins': totalWins,
        'totalLosses': totalLosses,
        'totalCheckmates': totalCheckmates,
        'highestWinStreak': highestWinStreak,
        'currentWinStreak': currentWinStreak,
        'totalSpellsCast': totalSpellsCast,
        'totalRelicsEquipped': totalRelicsEquipped,
        'totalPuzzlesSolved': totalPuzzlesSolved,
        'mostUsedSpell': mostUsedSpell,
        'spellUsageCounts': spellUsageCounts,
      };

  factory PlayerProfileStats.fromJson(Map<String, dynamic> json) =>
      PlayerProfileStats(
        totalMatchesPlayed: json['totalMatchesPlayed'] as int? ?? 0,
        totalWins: json['totalWins'] as int? ?? 0,
        totalLosses: json['totalLosses'] as int? ?? 0,
        totalCheckmates: json['totalCheckmates'] as int? ?? 0,
        highestWinStreak: json['highestWinStreak'] as int? ?? 0,
        currentWinStreak: json['currentWinStreak'] as int? ?? 0,
        totalSpellsCast: json['totalSpellsCast'] as int? ?? 0,
        totalRelicsEquipped: json['totalRelicsEquipped'] as int? ?? 0,
        totalPuzzlesSolved: json['totalPuzzlesSolved'] as int? ?? 0,
        mostUsedSpell: json['mostUsedSpell'] as String? ?? 'Fireball',
        spellUsageCounts: (json['spellUsageCounts'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v as int)) ??
            const {},
      );
}
