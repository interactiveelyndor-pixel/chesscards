import 'doll_reaction.dart';

class DollEvent {
  final DollReaction reaction;
  final DateTime timestamp;
  final String? message;
  final String? soundKey;

  const DollEvent({
    required this.reaction,
    required this.timestamp,
    this.message,
    this.soundKey,
  });

  DollEvent copyWith({
    DollReaction? reaction,
    DateTime? timestamp,
    String? message,
    String? soundKey,
  }) {
    return DollEvent(
      reaction: reaction ?? this.reaction,
      timestamp: timestamp ?? this.timestamp,
      message: message ?? this.message,
      soundKey: soundKey ?? this.soundKey,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reaction': reaction.name,
      'timestamp': timestamp.toIso8601String(),
      'message': message,
      'soundKey': soundKey,
    };
  }

  factory DollEvent.fromJson(Map<String, dynamic> json) {
    return DollEvent(
      reaction: DollReaction.values.byName(json['reaction'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      message: json['message'] as String?,
      soundKey: json['soundKey'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DollEvent &&
          runtimeType == other.runtimeType &&
          reaction == other.reaction &&
          timestamp == other.timestamp &&
          message == other.message &&
          soundKey == other.soundKey;

  @override
  int get hashCode =>
      reaction.hashCode ^ timestamp.hashCode ^ message.hashCode ^ soundKey.hashCode;
}
