import 'doll_state.dart';

class SoulDoll {
  final String id;
  final String ownerName;
  final int corruptionLevel; // 0 to 5
  final DollState state;
  final int captures;
  final int losses;
  final bool isPlayerControlled;
  final int health;
  final int maxHealth;

  const SoulDoll({
    required this.id,
    required this.ownerName,
    required this.corruptionLevel,
    required this.state,
    this.captures = 0,
    this.losses = 0,
    this.isPlayerControlled = false,
    this.health = 150,
    this.maxHealth = 150,
  });

  factory SoulDoll.initial({
    required String id, 
    required String ownerName,
    bool isPlayerControlled = false,
  }) {
    return SoulDoll(
      id: id,
      ownerName: ownerName,
      corruptionLevel: 0,
      state: DollState.calm,
      isPlayerControlled: isPlayerControlled,
      health: 150,
      maxHealth: 150,
    );
  }

  SoulDoll copyWith({
    String? id,
    String? ownerName,
    int? corruptionLevel,
    DollState? state,
    int? captures,
    int? losses,
    bool? isPlayerControlled,
    int? health,
    int? maxHealth,
  }) {
    return SoulDoll(
      id: id ?? this.id,
      ownerName: ownerName ?? this.ownerName,
      corruptionLevel: corruptionLevel ?? this.corruptionLevel,
      state: state ?? this.state,
      captures: captures ?? this.captures,
      losses: losses ?? this.losses,
      isPlayerControlled: isPlayerControlled ?? this.isPlayerControlled,
      health: health ?? this.health,
      maxHealth: maxHealth ?? this.maxHealth,
    );
  }

  bool get isFullyCursed => corruptionLevel >= 5;
  double get corruptionProgress => (corruptionLevel.clamp(0, 5)) / 5.0;
  bool get isDead => health <= 0;

  SoulDoll takeDamage(int amount) {
    final nextHealth = (health - amount).clamp(0, maxHealth);
    return copyWith(
      health: nextHealth,
      state: nextHealth == 0 ? DollState.cursed : (nextHealth <= (maxHealth * 0.3) ? DollState.screaming : state),
    );
  }

  SoulDoll heal(int amount) {
    final nextHealth = (health + amount).clamp(0, maxHealth);
    return copyWith(
      health: nextHealth,
      state: nextHealth > (maxHealth * 0.3) ? DollState.calm : state,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerName': ownerName,
      'corruptionLevel': corruptionLevel,
      'state': state.name,
      'captures': captures,
      'losses': losses,
      'isPlayerControlled': isPlayerControlled,
      'health': health,
      'maxHealth': maxHealth,
    };
  }

  factory SoulDoll.fromJson(Map<String, dynamic> json) {
    return SoulDoll(
      id: json['id'] as String,
      ownerName: json['ownerName'] as String,
      corruptionLevel: json['corruptionLevel'] as int,
      state: DollState.values.byName(json['state'] as String),
      captures: json['captures'] as int,
      losses: json['losses'] as int,
      isPlayerControlled: json['isPlayerControlled'] as bool,
      health: json['health'] as int? ?? 150,
      maxHealth: json['maxHealth'] as int? ?? 150,
    );
  }
}
