import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/player_profile_stats.dart';

final profileControllerProvider =
    StateNotifierProvider<ProfileController, PlayerProfileStats>((ref) {
  return ProfileController();
});

class ProfileController extends StateNotifier<PlayerProfileStats> {
  static const String _keyProfileStats = 'player_profile_stats_v1';

  ProfileController() : super(const PlayerProfileStats()) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_keyProfileStats);
      if (data != null) {
        final json = jsonDecode(data) as Map<String, dynamic>;
        state = PlayerProfileStats.fromJson(json);
      }
    } catch (_) {}
  }

  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(state.toJson());
      await prefs.setString(_keyProfileStats, data);
    } catch (_) {}
  }

  Future<void> recordMatchResult({required bool isWin, required bool isCheckmate}) async {
    final newMatches = state.totalMatchesPlayed + 1;
    final newWins = isWin ? state.totalWins + 1 : state.totalWins;
    final newLosses = !isWin ? state.totalLosses + 1 : state.totalLosses;
    final newCheckmates = isCheckmate && isWin ? state.totalCheckmates + 1 : state.totalCheckmates;
    
    final currentStreak = isWin ? state.currentWinStreak + 1 : 0;
    final highestStreak = currentStreak > state.highestWinStreak ? currentStreak : state.highestWinStreak;

    state = state.copyWith(
      totalMatchesPlayed: newMatches,
      totalWins: newWins,
      totalLosses: newLosses,
      totalCheckmates: newCheckmates,
      currentWinStreak: currentStreak,
      highestWinStreak: highestStreak,
    );
    await _saveStats();
  }

  Future<void> recordSpellCast(String spellId, String spellName) async {
    final counts = Map<String, int>.from(state.spellUsageCounts);
    counts[spellId] = (counts[spellId] ?? 0) + 1;

    String topSpell = state.mostUsedSpell;
    int maxCount = 0;
    counts.forEach((key, count) {
      if (count > maxCount) {
        maxCount = count;
        topSpell = spellName;
      }
    });

    state = state.copyWith(
      totalSpellsCast: state.totalSpellsCast + 1,
      spellUsageCounts: counts,
      mostUsedSpell: topSpell,
    );
    await _saveStats();
  }

  Future<void> recordRelicEquipped() async {
    state = state.copyWith(
      totalRelicsEquipped: state.totalRelicsEquipped + 1,
    );
    await _saveStats();
  }

  Future<void> recordPuzzleSolved() async {
    state = state.copyWith(
      totalPuzzlesSolved: state.totalPuzzlesSolved + 1,
    );
    await _saveStats();
  }
}
