import '../../../shared/enums/piece_color.dart';

class MatchAction {
  final String type;
  final PieceColor player;
  final DateTime timestamp;
  final Map<String, dynamic> payload;

  const MatchAction({
    required this.type,
    required this.player,
    required this.timestamp,
    this.payload = const {},
  });
}
