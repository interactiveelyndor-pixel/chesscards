import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/store_state.dart';
import '../domain/store_item.dart';

final storeControllerProvider = StateNotifierProvider<StoreController, StoreState>((ref) {
  return StoreController();
});

class StoreController extends StateNotifier<StoreState> {
  StoreController() : super(StoreState.initial()) {
    _loadData();
  }

  static const String _levelKey = 'store_level';
  static const String _xpKey = 'store_xp';
  static const String _soulsKey = 'store_souls';
  static const String _goldKey = 'store_gold';
  static const String _ownedKey = 'store_owned_items';
  static const String _equippedDollKey = 'store_equipped_doll';
  static const String _equippedBoardKey = 'store_equipped_board';
  static const String _dailyAdSoulsKey = 'store_daily_ad_souls_count';
  static const String _dailyAdGoldKey = 'store_daily_ad_gold_count';
  static const String _dailyAdDateKey = 'store_daily_ad_date';

  bool _isInitialized = false;

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    if (_isInitialized) return;
    
    final level = prefs.getInt(_levelKey) ?? state.playerLevel;
    final xp = prefs.getInt(_xpKey) ?? state.playerXp;
    final souls = prefs.getInt(_soulsKey) ?? state.soulFragments;
    final gold = prefs.getInt(_goldKey) ?? state.goldCoins;
    var owned = prefs.getStringList(_ownedKey) ?? state.ownedItemIds;
    if (!owned.contains('board_crimson_crypt')) {
      owned = ['board_crimson_crypt', ...owned];
    }
    final equippedDoll = prefs.getString(_equippedDollKey) ?? state.equippedDollId;
    final equippedBoard = prefs.getString(_equippedBoardKey) ?? state.equippedBoardId ?? 'board_crimson_crypt';

    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString(_dailyAdDateKey);
    final int dailyAdSoulClaims = (savedDate == todayStr) ? (prefs.getInt(_dailyAdSoulsKey) ?? 0) : 0;
    final int dailyAdGoldClaims = (savedDate == todayStr) ? (prefs.getInt(_dailyAdGoldKey) ?? 0) : 0;

    _isInitialized = true;
    if (!mounted) return;
    state = StoreState(
      playerLevel: level,
      playerXp: xp,
      soulFragments: souls,
      goldCoins: gold,
      ownedItemIds: owned,
      equippedDollId: equippedDoll,
      equippedBoardId: equippedBoard,
      dailyAdSoulsClaimed: dailyAdSoulClaims,
      dailyAdGoldClaimed: dailyAdGoldClaims,
      isLoading: false,
    );
  }

  Future<void> _saveData() async {
    final curState = state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_levelKey, curState.playerLevel);
    await prefs.setInt(_xpKey, curState.playerXp);
    await prefs.setInt(_soulsKey, curState.soulFragments);
    await prefs.setInt(_goldKey, curState.goldCoins);
    await prefs.setStringList(_ownedKey, curState.ownedItemIds);
    await prefs.setInt(_dailyAdSoulsKey, curState.dailyAdSoulsClaimed);
    await prefs.setInt(_dailyAdGoldKey, curState.dailyAdGoldClaimed);
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString(_dailyAdDateKey, todayStr);

    if (curState.equippedDollId != null) {
      await prefs.setString(_equippedDollKey, curState.equippedDollId!);
    }
    if (curState.equippedBoardId != null) {
      await prefs.setString(_equippedBoardKey, curState.equippedBoardId!);
    }
  }

  Future<bool> claimDailyAdSouls({int amount = 100}) async {
    if (state.dailyAdSoulsClaimed >= 3) return false;

    state = state.copyWith(
      soulFragments: state.soulFragments + amount,
      dailyAdSoulsClaimed: state.dailyAdSoulsClaimed + 1,
    );
    await _saveData();
    return true;
  }

  Future<bool> claimDailyAdGold({int amount = 300}) async {
    if (state.dailyAdGoldClaimed >= 3) return false;

    state = state.copyWith(
      goldCoins: state.goldCoins + amount,
      dailyAdGoldClaimed: state.dailyAdGoldClaimed + 1,
    );
    await _saveData();
    return true;
  }

  bool canAfford(StoreItem item, bool useSouls) {
    if (useSouls) {
      if (item.soulCost == null) return false;
      return state.soulFragments >= item.soulCost!;
    } else {
      if (item.goldCost == null) return false;
      return state.goldCoins >= item.goldCost!;
    }
  }

  bool isOwned(String itemId) {
    if (itemId == 'board_crimson_crypt') return true;
    return state.ownedItemIds.contains(itemId);
  }

  Future<bool> purchaseItem(StoreItem item, bool useSouls) async {
    if (isOwned(item.id) && item.type != StoreItemType.currency && item.type != StoreItemType.cardPack) {
      return false; // Can only buy dolls/boards once
    }

    if (!canAfford(item, useSouls)) {
      return false;
    }

    int newSouls = state.soulFragments;
    int newGold = state.goldCoins;

    if (useSouls) {
      newSouls -= item.soulCost!;
    } else {
      newGold -= item.goldCost!;
    }

    // Apply currency pack effects
    if (item.id == 'currency_gold_pouch') {
      newGold += 500;
    } else if (item.id == 'currency_gold_chest') {
      newGold += 1500;
    } else if (item.id == 'currency_soul_shard') {
      newSouls += 100;
    }

    final newOwned = List<String>.from(state.ownedItemIds);
    if ((item.type == StoreItemType.doll || item.type == StoreItemType.boardTheme) && !newOwned.contains(item.id)) {
      newOwned.add(item.id);
    }

    state = state.copyWith(
      soulFragments: newSouls,
      goldCoins: newGold,
      ownedItemIds: newOwned,
    );

    await _saveData();
    return true;
  }

  Future<void> addCurrency({int souls = 0, int gold = 0}) async {
    state = state.copyWith(
      soulFragments: state.soulFragments + souls,
      goldCoins: state.goldCoins + gold,
    );
    await _saveData();
  }

  Future<void> addXp(int amount) async {
    int newXp = state.playerXp + amount;
    int newLevel = state.playerLevel;
    
    // Simple leveling curve: 1000 XP per level
    while (newXp >= newLevel * 1000) {
      newXp -= newLevel * 1000;
      newLevel++;
    }

    state = state.copyWith(
      playerLevel: newLevel,
      playerXp: newXp,
    );
    await _saveData();
  }

  Future<void> unlockDoll(String itemId) async {
    await unlockItem(itemId);
  }

  Future<void> unlockItem(String itemId) async {
    if (isOwned(itemId)) return;
    final newOwned = [...state.ownedItemIds, itemId];
    state = state.copyWith(ownedItemIds: newOwned);
    await _saveData();
  }

  Future<void> equipItem(StoreItem item) async {
    if (!isOwned(item.id)) return;

    if (item.type == StoreItemType.doll) {
      state = state.copyWith(equippedDollId: item.id);
    } else if (item.type == StoreItemType.boardTheme) {
      state = state.copyWith(equippedBoardId: item.id);
    }
    await _saveData();
  }
  
  // For testing/debugging: resets the balance to default
  Future<void> resetBalances() async {
      state = state.copyWith(
        soulFragments: 5000, 
        goldCoins: 1000, 
        ownedItemIds: [],
        equippedDollId: null,
        equippedBoardId: null,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_equippedDollKey);
      await prefs.remove(_equippedBoardKey);
      await _saveData();
  }
}
