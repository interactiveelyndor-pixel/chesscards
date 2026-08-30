import '../../../shared/enums/piece_color.dart';

class MatchResult {
  final PieceColor? winner;
  final String reason;
  final int totalTurns;
  final Duration matchDuration;
  final int earnedSouls;
  final int earnedXp;

  const MatchResult({
    this.winner,
    required this.reason,
    required this.totalTurns,
    required this.matchDuration,
    this.earnedSouls = 0,
    this.earnedXp = 0,
  });
}
