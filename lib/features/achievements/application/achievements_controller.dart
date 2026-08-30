import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../store/application/store_controller.dart';

final achievementsControllerProvider = StateNotifierProvider<AchievementsController, List<String>>((ref) {
  return AchievementsController(ref);
});

class AchievementsController extends StateNotifier<List<String>> {
  static const _key = 'unlocked_achievements';
  final Ref _ref;
  
  AchievementsController(this._ref) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = prefs.getStringList(_key) ?? [];
    state = unlocked;
  }

  Future<bool> unlockAchievement(String id, {int rewardSouls = 50}) async {
    if (state.contains(id)) return false;
    
    final newState = [...state, id];
    state = newState;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, newState);

    if (rewardSouls > 0) {
      _ref.read(storeControllerProvider.notifier).addCurrency(souls: rewardSouls);
    }
    
    return true; 
  }

  Future<void> recordWin() async {
    final prefs = await SharedPreferences.getInstance();
    final winCount = (prefs.getInt('win_count') ?? 0) + 1;
    await prefs.setInt('win_count', winCount);
    
    if (winCount >= 10) {
      unlockAchievement('abyssal_master');
    }
  }
}
