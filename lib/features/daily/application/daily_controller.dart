import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/daily_reward_state.dart';
import '../domain/daily_contract.dart';
import '../domain/daily_puzzle.dart';
import '../../store/application/store_controller.dart';
import '../../achievements/application/achievements_controller.dart';
import '../../profile/application/profile_controller.dart';

class DailyState {
  final DailyRewardState rewardState;
  final List<DailyContract> contracts;
  final DailyPuzzle puzzle;
  final bool masterChestClaimed;

  const DailyState({
    required this.rewardState,
    required this.contracts,
    required this.puzzle,
    this.masterChestClaimed = false,
  });

  bool get hasUnclaimedRewards {
    if (!rewardState.hasClaimedToday) return true;
    if (contracts.any((c) => c.isCompleted && !c.isClaimed)) return true;
    if (allContractsCompleted && !masterChestClaimed) return true;
    if (!puzzle.isCompleted) return true;
    return false;
  }

  bool get allContractsCompleted => contracts.every((c) => c.isCompleted);

  DailyState copyWith({
    DailyRewardState? rewardState,
    List<DailyContract>? contracts,
    DailyPuzzle? puzzle,
    bool? masterChestClaimed,
  }) {
    return DailyState(
      rewardState: rewardState ?? this.rewardState,
      contracts: contracts ?? this.contracts,
      puzzle: puzzle ?? this.puzzle,
      masterChestClaimed: masterChestClaimed ?? this.masterChestClaimed,
    );
  }
}

final dailyControllerProvider =
    StateNotifierProvider<DailyController, DailyState>((ref) {
  return DailyController(ref);
});

class DailyController extends StateNotifier<DailyState> {
  final Ref _ref;

  static const String _keyDailyReward = 'daily_reward_state';
  static const String _keyDailyContracts = 'daily_contracts_state';
  static const String _keyDailyPuzzle = 'daily_puzzle_state';
  static const String _keyMasterChest = 'daily_master_chest_claimed';

  DailyController(this._ref)
      : super(DailyState(
          rewardState: DailyRewardState.initial(),
          contracts: DailyContract.generateDefaultDailyContracts(),
          puzzle: DailyPuzzle.getTodayPuzzle(),
          masterChestClaimed: false,
        )) {
    _loadDailyState();
  }

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _getYesterdayString() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadDailyState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = _getTodayString();
      final yesterdayStr = _getYesterdayString();

      // 1. Load Daily Login Reward State
      final rewardJson = prefs.getString(_keyDailyReward);
      DailyRewardState rewardState;

      if (rewardJson != null) {
        final decoded = jsonDecode(rewardJson) as Map<String, dynamic>;
        final saved = DailyRewardState.fromJson(decoded);

        if (saved.lastClaimDate == todayStr) {
          rewardState = saved.copyWith(hasClaimedToday: true);
        } else if (saved.lastClaimDate == yesterdayStr) {
          final nextStreak = saved.currentStreak >= 7 ? 1 : saved.currentStreak + 1;
          rewardState = saved.copyWith(
            currentStreak: nextStreak,
            hasClaimedToday: false,
          );
        } else {
          rewardState = DailyRewardState(
            currentStreak: 1,
            lastClaimDate: saved.lastClaimDate,
            hasClaimedToday: false,
            totalConsecutiveDays: 0,
          );
        }
      } else {
        rewardState = DailyRewardState.initial();
      }

      // 2. Load Daily Contracts
      final contractsDate = prefs.getString('${_keyDailyContracts}_date');
      List<DailyContract> contracts;
      bool masterChest = false;

      if (contractsDate == todayStr) {
        final contractsJson = prefs.getString(_keyDailyContracts);
        if (contractsJson != null) {
          final list = jsonDecode(contractsJson) as List<dynamic>;
          contracts = list.map((e) => DailyContract.fromJson(e as Map<String, dynamic>)).toList();
        } else {
          contracts = DailyContract.generateDefaultDailyContracts();
        }
        masterChest = prefs.getBool('${_keyMasterChest}_$todayStr') ?? false;
      } else {
        contracts = DailyContract.generateDefaultDailyContracts();
        masterChest = false;
      }

      // 3. Load Daily Puzzle
      final puzzleDate = prefs.getString('${_keyDailyPuzzle}_date');
      DailyPuzzle puzzle;
      if (puzzleDate == todayStr) {
        final isCompleted = prefs.getBool('${_keyDailyPuzzle}_completed') ?? false;
        puzzle = DailyPuzzle.getTodayPuzzle().copyWith(isCompleted: isCompleted);
      } else {
        puzzle = DailyPuzzle.getTodayPuzzle();
      }

      state = DailyState(
        rewardState: rewardState,
        contracts: contracts,
        puzzle: puzzle,
        masterChestClaimed: masterChest,
      );
    } catch (_) {}
  }

  Future<void> claimDailyLoginReward() async {
    if (state.rewardState.hasClaimedToday) return;

    final todayStr = _getTodayString();
    final currentReward = state.rewardState.todayReward;

    _ref.read(storeControllerProvider.notifier).addCurrency(souls: currentReward.souls);
    _ref.read(storeControllerProvider.notifier).addXp(currentReward.xp);

    if (currentReward.specialUnlockId != null) {
      if (currentReward.specialUnlockId!.startsWith('doll_')) {
        _ref.read(storeControllerProvider.notifier).unlockDoll(currentReward.specialUnlockId!);
      }
    }

    final updatedRewardState = state.rewardState.copyWith(
      hasClaimedToday: true,
      lastClaimDate: todayStr,
      totalConsecutiveDays: state.rewardState.totalConsecutiveDays + 1,
    );

    state = state.copyWith(rewardState: updatedRewardState);
    _saveRewardState();
  }

  Future<void> claimContract(String contractId) async {
    final index = state.contracts.indexWhere((c) => c.id == contractId);
    if (index == -1) return;

    final contract = state.contracts[index];
    if (!contract.isCompleted || contract.isClaimed) return;

    _ref.read(storeControllerProvider.notifier).addCurrency(souls: contract.soulReward);
    _ref.read(storeControllerProvider.notifier).addXp(contract.xpReward);

    final updatedContracts = [...state.contracts];
    updatedContracts[index] = contract.copyWith(isClaimed: true);

    state = state.copyWith(contracts: updatedContracts);
    _saveContractsState();
  }

  Future<void> claimMasterChest() async {
    if (!state.allContractsCompleted || state.masterChestClaimed) return;

    const int masterChestSouls = 500;
    const int masterChestXp = 300;

    _ref.read(storeControllerProvider.notifier).addCurrency(souls: masterChestSouls);
    _ref.read(storeControllerProvider.notifier).addXp(masterChestXp);
    _ref.read(achievementsControllerProvider.notifier).unlockAchievement('bounty_hunter');

    state = state.copyWith(masterChestClaimed: true);

    final prefs = await SharedPreferences.getInstance();
    final todayStr = _getTodayString();
    await prefs.setBool('${_keyMasterChest}_$todayStr', true);
  }

  void recordMatchEvent({
    int piecesCaptured = 0,
    int spellsCast = 0,
    int enemiesFrozen = 0,
    bool aegisAbsorbed = false,
    bool sniperPierced = false,
    bool matchWon = false,
    int endingHp = 0,
    int relicsEquipped = 0,
    int fireballsCast = 0,
    int necromancyCast = 0,
  }) {
    bool hasChanges = false;
    final updatedContracts = state.contracts.map((contract) {
      if (contract.isClaimed) return contract;

      int progressDelta = 0;
      switch (contract.type) {
        case ContractType.capturePieces:
          progressDelta = piecesCaptured;
          break;
        case ContractType.castSpells:
          progressDelta = spellsCast;
          break;
        case ContractType.freezeEnemies:
          progressDelta = enemiesFrozen;
          break;
        case ContractType.absorbDamageWithAegis:
          progressDelta = aegisAbsorbed ? 1 : 0;
          break;
        case ContractType.piercePawnsWithSniper:
          progressDelta = sniperPierced ? 1 : 0;
          break;
        case ContractType.winMatchWithHighHp:
          if (matchWon && endingHp >= 75) {
            progressDelta = 1;
          }
          break;
        case ContractType.castFireball:
          progressDelta = fireballsCast;
          break;
        case ContractType.castNecromancy:
          progressDelta = necromancyCast;
          break;
        case ContractType.equipRelics:
          progressDelta = relicsEquipped;
          break;
      }

      if (progressDelta > 0) {
        hasChanges = true;
        final newProgress = (contract.currentValue + progressDelta).clamp(0, contract.targetValue);
        return contract.copyWith(currentValue: newProgress);
      }
      return contract;
    }).toList();

    if (hasChanges) {
      state = state.copyWith(contracts: updatedContracts);
      _saveContractsState();
    }
  }

  Future<void> completeDailyPuzzle() async {
    if (state.puzzle.isCompleted) return;

    final puzzleReward = state.puzzle.soulReward;
    final xpReward = state.puzzle.xpReward;

    state = state.copyWith(puzzle: state.puzzle.copyWith(isCompleted: true));

    _ref.read(storeControllerProvider.notifier).addCurrency(souls: puzzleReward);
    _ref.read(storeControllerProvider.notifier).addXp(xpReward);
    _ref.read(profileControllerProvider.notifier).recordPuzzleSolved();

    final prefs = await SharedPreferences.getInstance();
    final todayStr = _getTodayString();
    await prefs.setString('${_keyDailyPuzzle}_date', todayStr);
    await prefs.setBool('${_keyDailyPuzzle}_completed', true);
  }

  Future<void> completeEndlessPuzzle(DailyPuzzle puzzle) async {
    _ref.read(storeControllerProvider.notifier).addCurrency(souls: puzzle.soulReward);
    _ref.read(storeControllerProvider.notifier).addXp(puzzle.xpReward);
    _ref.read(profileControllerProvider.notifier).recordPuzzleSolved();
  }

  Future<void> _saveRewardState() async {
    final curState = state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDailyReward, jsonEncode(curState.rewardState.toJson()));
  }

  Future<void> _saveContractsState() async {
    final curState = state;
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _getTodayString();
    await prefs.setString('${_keyDailyContracts}_date', todayStr);
    final encoded = jsonEncode(curState.contracts.map((c) => c.toJson()).toList());
    await prefs.setString(_keyDailyContracts, encoded);
  }
}
