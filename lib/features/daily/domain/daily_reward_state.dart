class DailyReward {
  final int day;
  final String title;
  final String description;
  final int souls;
  final int xp;
  final String icon;
  final String? specialUnlockId;

  const DailyReward({
    required this.day,
    required this.title,
    required this.description,
    required this.souls,
    required this.xp,
    required this.icon,
    this.specialUnlockId,
  });
}

class DailyRewardState {
  final int currentStreak; // 1 to 7
  final String? lastClaimDate; // YYYY-MM-DD
  final bool hasClaimedToday;
  final int totalConsecutiveDays;

  const DailyRewardState({
    required this.currentStreak,
    this.lastClaimDate,
    required this.hasClaimedToday,
    this.totalConsecutiveDays = 0,
  });

  static const List<DailyReward> schedule = [
    DailyReward(
      day: 1,
      title: 'Tithe of the Crypt',
      description: '150 Lost Souls',
      souls: 150,
      xp: 50,
      icon: '🕯️',
    ),
    DailyReward(
      day: 2,
      title: 'Aegis Blessing',
      description: '250 Souls + Aegis Shield Charm',
      souls: 250,
      xp: 100,
      icon: '🛡️',
      specialUnlockId: 'relic_aegis_shield',
    ),
    DailyReward(
      day: 3,
      title: 'Grim Harvest',
      description: '350 Lost Souls + 150 XP',
      souls: 350,
      xp: 150,
      icon: '🩸',
    ),
    DailyReward(
      day: 4,
      title: "Sniper's Vision",
      description: '450 Souls + Sniper Bow Relic',
      souls: 450,
      xp: 200,
      icon: '🏹',
      specialUnlockId: 'relic_sniper_bow',
    ),
    DailyReward(
      day: 5,
      title: 'Cursed Reliquary',
      description: '600 Lost Souls + Ring of Mana',
      souls: 600,
      xp: 250,
      icon: '💍',
      specialUnlockId: 'relic_ring_of_mana',
    ),
    DailyReward(
      day: 6,
      title: 'The Blood Moon Offering',
      description: '800 Lost Souls + 400 XP',
      souls: 800,
      xp: 400,
      icon: '🌕',
    ),
    DailyReward(
      day: 7,
      title: 'The Hollow Sovereign',
      description: '1,500 Souls + Mythic Doll Skin',
      souls: 1500,
      xp: 1000,
      icon: '👑',
      specialUnlockId: 'doll_hollow_sovereign',
    ),
  ];

  DailyReward get todayReward {
    final index = (currentStreak - 1).clamp(0, schedule.length - 1);
    return schedule[index];
  }

  DailyRewardState copyWith({
    int? currentStreak,
    String? lastClaimDate,
    bool? hasClaimedToday,
    int? totalConsecutiveDays,
  }) {
    return DailyRewardState(
      currentStreak: currentStreak ?? this.currentStreak,
      lastClaimDate: lastClaimDate ?? this.lastClaimDate,
      hasClaimedToday: hasClaimedToday ?? this.hasClaimedToday,
      totalConsecutiveDays: totalConsecutiveDays ?? this.totalConsecutiveDays,
    );
  }

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'lastClaimDate': lastClaimDate,
        'hasClaimedToday': hasClaimedToday,
        'totalConsecutiveDays': totalConsecutiveDays,
      };

  factory DailyRewardState.fromJson(Map<String, dynamic> json) =>
      DailyRewardState(
        currentStreak: json['currentStreak'] as int? ?? 1,
        lastClaimDate: json['lastClaimDate'] as String?,
        hasClaimedToday: json['hasClaimedToday'] as bool? ?? false,
        totalConsecutiveDays: json['totalConsecutiveDays'] as int? ?? 0,
      );

  factory DailyRewardState.initial() => const DailyRewardState(
        currentStreak: 1,
        lastClaimDate: null,
        hasClaimedToday: false,
        totalConsecutiveDays: 0,
      );
}
