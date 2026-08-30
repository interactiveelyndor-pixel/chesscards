import '../../../shared/enums/piece_color.dart';

class ActionLogEntry {
  final String text;
  final DateTime timestamp;
  final PieceColor player;
  final bool isImportant;

  const ActionLogEntry({
    required this.text,
    required this.timestamp,
    required this.player,
    this.isImportant = false,
  });
}
