enum ContractType {
  capturePieces,
  castSpells,
  absorbDamageWithAegis,
  piercePawnsWithSniper,
  winMatchWithHighHp,
  freezeEnemies,
  castFireball,
  castNecromancy,
  equipRelics,
}

class DailyContract {
  final String id;
  final String title;
  final String description;
  final String icon;
  final ContractType type;
  final int targetValue;
  final int currentValue;
  final int soulReward;
  final int xpReward;
  final bool isClaimed;

  const DailyContract({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.soulReward,
    required this.xpReward,
    this.isClaimed = false,
  });

  bool get isCompleted => currentValue >= targetValue;
  double get progressRatio => (currentValue / targetValue).clamp(0.0, 1.0);

  DailyContract copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    ContractType? type,
    int? targetValue,
    int? currentValue,
    int? soulReward,
    int? xpReward,
    bool? isClaimed,
  }) {
    return DailyContract(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      soulReward: soulReward ?? this.soulReward,
      xpReward: xpReward ?? this.xpReward,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon,
        'type': type.name,
        'targetValue': targetValue,
        'currentValue': currentValue,
        'soulReward': soulReward,
        'xpReward': xpReward,
        'isClaimed': isClaimed,
      };

  factory DailyContract.fromJson(Map<String, dynamic> json) => DailyContract(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        icon: json['icon'] as String,
        type: ContractType.values.byName(json['type'] as String),
        targetValue: json['targetValue'] as int,
        currentValue: json['currentValue'] as int,
        soulReward: json['soulReward'] as int,
        xpReward: json['xpReward'] as int,
        isClaimed: json['isClaimed'] as bool? ?? false,
      );

  static List<DailyContract> generateDefaultDailyContracts([DateTime? date]) {
    final now = date ?? DateTime.now();
    final dayOffset = (now.year * 365 + now.month * 31 + now.day) % 7;

    return [
      DailyContract(
        id: 'contract_cast_spells',
        title: 'Weaver of Incantations',
        description: 'Cast ${3 + (dayOffset % 3)} Spells during matches.',
        icon: '🔮',
        type: ContractType.castSpells,
        targetValue: 3 + (dayOffset % 3),
        currentValue: 0,
        soulReward: 200 + (dayOffset * 20),
        xpReward: 100 + (dayOffset * 15),
      ),
      DailyContract(
        id: 'contract_capture_pieces',
        title: 'The Grim Reaping',
        description: 'Capture ${4 + (dayOffset % 3)} enemy chess pieces.',
        icon: '⚔️',
        type: ContractType.capturePieces,
        targetValue: 4 + (dayOffset % 3),
        currentValue: 0,
        soulReward: 250 + (dayOffset * 25),
        xpReward: 150 + (dayOffset * 20),
      ),
      DailyContract(
        id: 'contract_freeze_enemies',
        title: 'Frostbound Silence',
        description: 'Freeze ${2 + (dayOffset % 2)} enemy pieces with Ice spells.',
        icon: '❄️',
        type: ContractType.freezeEnemies,
        targetValue: 2 + (dayOffset % 2),
        currentValue: 0,
        soulReward: 300 + (dayOffset * 30),
        xpReward: 200 + (dayOffset * 25),
      ),
    ];
  }
}
