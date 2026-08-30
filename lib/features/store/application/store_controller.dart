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

  bool _isInitialized = false;

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    if (_isInitialized) return;
    
    final level = prefs.getInt(_levelKey) ?? state.playerLevel;
    final xp = prefs.getInt(_xpKey) ?? state.playerXp;
    final souls = prefs.getInt(_soulsKey) ?? state.soulFragments;
    final gold = prefs.getInt(_goldKey) ?? state.goldCoins;
    final owned = prefs.getStringList(_ownedKey) ?? state.ownedItemIds;
    final equippedDoll = prefs.getString(_equippedDollKey) ?? state.equippedDollId;
    final equippedBoard = prefs.getString(_equippedBoardKey) ?? state.equippedBoardId;

    _isInitialized = true;
    state = StoreState(
      playerLevel: level,
      playerXp: xp,
      soulFragments: souls,
      goldCoins: gold,
      ownedItemIds: owned,
      equippedDollId: equippedDoll,
      equippedBoardId: equippedBoard,
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
    if (curState.equippedDollId != null) {
      await prefs.setString(_equippedDollKey, curState.equippedDollId!);
    }
    if (curState.equippedBoardId != null) {
      await prefs.setString(_equippedBoardKey, curState.equippedBoardId!);
    }
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
    if (item.id == 'currency_gold_pack') {
      newGold += 500;
    } else if (item.id == 'currency_soul_shard') {
      newSouls += 100;
    }

    final newOwned = List<String>.from(state.ownedItemIds);
    if (item.type == StoreItemType.doll || item.type == StoreItemType.boardTheme) {
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
