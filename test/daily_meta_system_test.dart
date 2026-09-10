import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_chess/features/daily/application/daily_controller.dart';
import 'package:super_chess/features/daily/domain/daily_reward_state.dart';
import 'package:super_chess/features/daily/domain/daily_contract.dart';
import 'package:super_chess/features/store/application/store_controller.dart';
import 'package:super_chess/features/store/domain/store_inventory.dart';
import 'package:super_chess/features/board/domain/board_position.dart';
import 'package:super_chess/features/match/domain/chess_engine.dart';
import 'package:super_chess/features/match/domain/game_status.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('🔮 DAILY META RETENTION SYSTEM TESTS', () {

    // ─────────────────────────────────────────────────────────────────────────
    // 1. 7-DAY SÉANCE LOGIN RITUAL TESTS
    // ─────────────────────────────────────────────────────────────────────────
    test('1. Daily Reward State initializes with 7-day reward schedule and streak = 1', () {
      final state = DailyRewardState.initial();
      expect(state.currentStreak, 1);
      expect(state.hasClaimedToday, isFalse);
      expect(DailyRewardState.schedule.length, 7);

      // Verify Day 7 has mythic doll reward
      final day7 = DailyRewardState.schedule.last;
      expect(day7.day, 7);
      expect(day7.specialUnlockId, 'doll_hollow_sovereign');
      expect(day7.souls, 1500);
    });

    test('2. Claiming Daily Login Reward grants Souls and XP to StoreController', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final dailyController = container.read(dailyControllerProvider.notifier);
      final initialSouls = container.read(storeControllerProvider).soulFragments;

      await dailyController.claimDailyLoginReward();

      final updatedState = container.read(dailyControllerProvider);
      expect(updatedState.rewardState.hasClaimedToday, isTrue);

      final newSouls = container.read(storeControllerProvider).soulFragments;
      expect(newSouls, initialSouls + 150); // Day 1 awards 150 soulFragments
    });

    // ─────────────────────────────────────────────────────────────────────────
    // 2. WITCH'S LEDGER (DAILY CONTRACTS) TESTS
    // ─────────────────────────────────────────────────────────────────────────
    test('3. Match events correctly advance daily contract progress', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(dailyControllerProvider.notifier);

      // Simulate capturing 3 pieces and casting 2 spells
      controller.recordMatchEvent(piecesCaptured: 3, spellsCast: 2, enemiesFrozen: 1);

      final state = container.read(dailyControllerProvider);
      final captureContract = state.contracts.firstWhere((c) => c.type == ContractType.capturePieces);
      final spellContract = state.contracts.firstWhere((c) => c.type == ContractType.castSpells);
      final freezeContract = state.contracts.firstWhere((c) => c.type == ContractType.freezeEnemies);

      expect(captureContract.currentValue, 3);
      expect(spellContract.currentValue, 2);
      expect(freezeContract.currentValue, 1);
    });

    test('4. Claiming completed contracts and Master Cursed Chest awards bonus Souls', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(dailyControllerProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      // Advance all contracts to completion
      controller.recordMatchEvent(piecesCaptured: 10, spellsCast: 10, enemiesFrozen: 10);

      final state = container.read(dailyControllerProvider);
      expect(state.allContractsCompleted, isTrue);

      final initialSouls = container.read(storeControllerProvider).soulFragments;

      // Claim first contract
      final contract = state.contracts.first;
      await controller.claimContract(contract.id);

      final soulFragmentsAfterContract = container.read(storeControllerProvider).soulFragments;
      expect(soulFragmentsAfterContract, initialSouls + contract.soulReward);

      // Claim Master Cursed Chest
      await controller.claimMasterChest();
      final finalSouls = container.read(storeControllerProvider).soulFragments;
      expect(finalSouls, greaterThanOrEqualTo(soulFragmentsAfterContract + 500)); // Master chest grants 500+ souls (including achievement)
    });

    // ─────────────────────────────────────────────────────────────────────────
    // 3. THE DAILY NIGHTMARE TACTICAL PUZZLE TESTS
    // ─────────────────────────────────────────────────────────────────────────
    test('5. Daily Nightmare Puzzle solves correctly delivering checkmate', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(dailyControllerProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final puzzle = container.read(dailyControllerProvider).puzzle;
      expect(puzzle.isCompleted, isFalse);

      // Step 1: Frost Bind freezes defender at (1, 6)
      final frozenBoard = puzzle.initialGameState.board.clone();
      final bishop = frozenBoard.pieceAt(const BoardPosition(1, 6))!;
      frozenBoard.setPiece(const BoardPosition(1, 6), bishop.copyWith(isFrozen: true));
      final puzzleStateWithFrozenDefender = puzzle.initialGameState.copyWith(board: frozenBoard);

      // Step 2: White Queen checkmates at (1, 7) [h7]
      final winningMove = puzzle.winningMoves.first;
      final nextState = ChessEngine.makeMove(puzzleStateWithFrozenDefender, winningMove);

      final status = ChessEngine.evaluateGameStatus(nextState);
      expect(status == GameStatus.checkmate || nextState.status == GameStatus.checkmate, isTrue);

      // Complete puzzle
      final initialSouls = container.read(storeControllerProvider).soulFragments;
      await controller.completeDailyPuzzle();

      expect(container.read(dailyControllerProvider).puzzle.isCompleted, isTrue);
      expect(container.read(storeControllerProvider).soulFragments, initialSouls + puzzle.soulReward);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // 4. STORE & PLAYABLE COSMETIC CHESSBOARD SUITE
    // ─────────────────────────────────────────────────────────────────────────
    test('6. Store Inventory contains the 4 thematic Chess Board variants and default ownership', () {
      final boards = StoreInventory.boardItems;
      expect(boards.length, 4);

      final crimson = boards.firstWhere((b) => b.id == 'board_crimson_crypt');
      expect(crimson.goldCost, 0);
      expect(crimson.soulCost, 0);

      final voidMarble = boards.firstWhere((b) => b.id == 'board_void_marble');
      expect(voidMarble.goldCost, 1200);
      expect(voidMarble.soulCost, 300);

      final emerald = boards.firstWhere((b) => b.id == 'board_emerald_necropolis');
      expect(emerald.goldCost, 2000);
      expect(emerald.soulCost, 500);

      final magma = boards.firstWhere((b) => b.id == 'board_infernal_magma');
      expect(magma.goldCost, 3500);
      expect(magma.soulCost, 800);
    });

    test('7. Purchasing and equipping Board Themes updates equippedBoardId and deducts currency', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final storeController = container.read(storeControllerProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final voidMarble = StoreInventory.boardItems.firstWhere((b) => b.id == 'board_void_marble');
      
      // Initial state has 2000 gold and 1500 souls
      final initialGold = container.read(storeControllerProvider).goldCoins;
      final initialSouls = container.read(storeControllerProvider).soulFragments;

      // Purchase with Gold
      final purchased = await storeController.purchaseItem(voidMarble, false);
      expect(purchased, isTrue);
      expect(container.read(storeControllerProvider).goldCoins, initialGold - 1200);
      expect(container.read(storeControllerProvider).soulFragments, initialSouls);
      expect(storeController.isOwned('board_void_marble'), isTrue);

      // Equip Void Marble
      await storeController.equipItem(voidMarble);
      expect(container.read(storeControllerProvider).equippedBoardId, 'board_void_marble');
    });

    test('8. Daily Soul Well and Alchemist Gold rewarded ad claims cap at 3 daily claims', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final storeController = container.read(storeControllerProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final initialSouls = container.read(storeControllerProvider).soulFragments;
      final initialGold = container.read(storeControllerProvider).goldCoins;

      // Claim 3 Daily Soul Well offerings
      expect(await storeController.claimDailyAdSouls(amount: 100), isTrue);
      expect(await storeController.claimDailyAdSouls(amount: 100), isTrue);
      expect(await storeController.claimDailyAdSouls(amount: 100), isTrue);
      expect(await storeController.claimDailyAdSouls(amount: 100), isFalse, reason: 'Must cap at 3 daily claims');

      // Claim 3 Alchemist Gold offerings
      expect(await storeController.claimDailyAdGold(amount: 300), isTrue);
      expect(await storeController.claimDailyAdGold(amount: 300), isTrue);
      expect(await storeController.claimDailyAdGold(amount: 300), isTrue);
      expect(await storeController.claimDailyAdGold(amount: 300), isFalse, reason: 'Must cap at 3 daily claims');

      expect(container.read(storeControllerProvider).soulFragments, initialSouls + 300);
      expect(container.read(storeControllerProvider).goldCoins, initialGold + 900);
    });
  });
}
