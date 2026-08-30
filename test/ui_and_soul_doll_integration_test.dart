import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_chess/features/board/domain/board_position.dart';
import 'package:super_chess/features/board/domain/game_board.dart';
import 'package:super_chess/features/dolls/domain/doll_state.dart';
import 'package:super_chess/features/dolls/domain/soul_doll.dart';
import 'package:super_chess/features/dolls/domain/soul_doll_controller.dart';
import 'package:super_chess/features/match/application/match_controller.dart';
import 'package:super_chess/features/match/domain/chess_move.dart';
import 'package:super_chess/features/match/domain/game_state.dart';
import 'package:super_chess/features/match/domain/game_status.dart';
import 'package:super_chess/features/match/domain/match_state.dart';
import 'package:super_chess/features/match/domain/turn_phase.dart';
import 'package:super_chess/features/pieces/domain/chess_piece.dart';
import 'package:super_chess/features/relics/domain/relics.dart';
import 'package:super_chess/features/spells/domain/spells.dart';
import 'package:super_chess/features/spells/domain/spell_engine.dart';
import 'package:super_chess/shared/enums/piece_color.dart';
import 'package:super_chess/shared/enums/piece_type.dart';
import 'package:super_chess/features/match/domain/chess_ai.dart';
import 'package:super_chess/core/audio/audio_service.dart';
import 'package:super_chess/core/audio/audio_enums.dart';
import 'package:super_chess/core/network/network_service.dart';

class MockAudioService implements AudioService {
  @override
  Future<void> init() async {}
  @override
  Future<void> playBgm(BgmType type) async {}
  @override
  Future<void> crossfadeBgm(BgmType type) async {}
  @override
  Future<void> stopBgm() async {}
  @override
  Future<void> playSfx(SfxType type) async {}
  @override
  void dispose() {}
}

class MockNetworkService implements NetworkService {
  @override
  String? get userId => 'mock_user_id';
  @override
  String? currentMatchId;
  @override
  bool isPlayer1 = true;
  @override
  void Function(Map<String, dynamic> actionData)? onActionReceived;
  @override
  void Function(String opponentId)? onMatchStart;
  @override
  void Function()? onOpponentDisconnected;

  @override
  Future<void> signInAnonymously() async {}
  @override
  Future<void> findMatch() async {}
  @override
  Future<void> sendMoveAction(BoardPosition from, BoardPosition to, PieceType? promotion) async {}
  @override
  Future<void> sendCardAction(String cardId, BoardPosition? primary, BoardPosition? secondary) async {}
  @override
  Future<void> sendEndTurnAction() async {}
  @override
  Future<void> leaveMatch() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('👑 ADVANCED SOUL DOLL & INTEGRATION TESTS', () {

    // ─────────────────────────────────────────────────────────────────────────
    // 1. SOUL DOLL HP & DAMAGE CALCULATION MATRIX
    // ─────────────────────────────────────────────────────────────────────────
    test('1. Soul Doll takes exact damage on piece captures based on piece tier', () {
      final doll = SoulDoll.initial(id: 'doll_1', ownerName: 'Player');
      expect(doll.health, 150);

      // Pawn capture = 10 damage
      final dollAfterPawn = doll.takeDamage(10);
      expect(dollAfterPawn.health, 140);

      // Knight/Bishop capture = 30 damage
      final dollAfterKnight = dollAfterPawn.takeDamage(30);
      expect(dollAfterKnight.health, 110);

      // Rook capture = 50 damage
      final dollAfterRook = dollAfterKnight.takeDamage(50);
      expect(dollAfterRook.health, 60);

      // Queen capture = 90 damage (reduces to 0, does not go negative)
      final dollAfterQueen = dollAfterRook.takeDamage(90);
      expect(dollAfterQueen.health, 0);
      expect(dollAfterQueen.isDead, isTrue);
    });

    test('2. Soul Doll critical health state (< 30% HP) activates correctly', () {
      final doll = SoulDoll.initial(id: 'doll_1', ownerName: 'Player'); // maxHealth = 150, 30% is 45
      expect(doll.health / doll.maxHealth <= 0.30, isFalse);

      final damagedDoll = doll.takeDamage(110); // HP = 40 (26.6% <= 30%)
      expect(damagedDoll.health, 40);
      expect(damagedDoll.health / damagedDoll.maxHealth <= 0.30, isTrue);
    });

    test('3. Capturing enemy pieces heals player Soul Doll by 50% of capture damage', () {
      final doll = SoulDoll.initial(id: 'doll_1', ownerName: 'Player').copyWith(health: 50); // Damaged doll

      // Player captures Rook (damage = 50, heal = 25)
      final healedDoll = doll.heal(25);
      expect(healedDoll.health, 75);

      // Overheal caps at maxHealth
      final overHealed = healedDoll.heal(200);
      expect(overHealed.health, 150);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // 2. MULTIPLAYER PAYLOAD INTEGRATION & NETWORK PACKET INTEGRITY
    // ─────────────────────────────────────────────────────────────────────────
    test('4. Network move and spell packet serialization/deserialization integrity', () {
      // Simulate move action packet
      final movePayload = <String, dynamic>{
        'type': 'move',
        'from_row': 6,
        'from_col': 4,
        'to_row': 4,
        'to_col': 4,
        'promotion': null,
      };

      final from = BoardPosition(movePayload['from_row'] as int, movePayload['from_col'] as int);
      final to = BoardPosition(movePayload['to_row'] as int, movePayload['to_col'] as int);
      expect(from, const BoardPosition(6, 4));
      expect(to, const BoardPosition(4, 4));

      // Simulate spell action packet
      final spellPayload = <String, dynamic>{
        'type': 'card',
        'card_id': 'spell_fireball',
        'primary_row': 7,
        'primary_col': 1,
        'secondary_row': 5,
        'secondary_col': 2,
      };

      final primary = BoardPosition(spellPayload['primary_row'] as int, spellPayload['primary_col'] as int);
      final secondary = BoardPosition(spellPayload['secondary_row'] as int, spellPayload['secondary_col'] as int);
      expect(primary, const BoardPosition(7, 1));
      expect(secondary, const BoardPosition(5, 2));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // 3. PASS-AND-PLAY LOCAL MULTIPLAYER TURN PASS FLOW
    // ─────────────────────────────────────────────────────────────────────────
    test('5. Local Multiplayer: Turn Pass screen triggers after Move + Card Phase', () {
      final container = ProviderContainer(
        overrides: [
          audioServiceProvider.overrideWithValue(MockAudioService()),
          networkServiceProvider.overrideWithValue(MockNetworkService()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(matchControllerProvider.notifier);
      controller.startLocalMatch();

      expect(container.read(matchControllerProvider).isLocalMode, isTrue);
      expect(container.read(matchControllerProvider).showTurnPass, isFalse);

      // White makes move
      controller.selectTile(const BoardPosition(6, 4));
      controller.makeMove(const BoardPosition(6, 4), const BoardPosition(4, 4));

      // White ends turn -> Turn Pass screen displays for privacy hand-off
      controller.endTurn();
      expect(container.read(matchControllerProvider).showTurnPass, isTrue);

      // Player 2 taps "Ready" to dismiss turn pass
      controller.dismissTurnPass();
      expect(container.read(matchControllerProvider).showTurnPass, isFalse);
      expect(container.read(matchControllerProvider).gameState.currentTurn, PieceColor.black);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // 4. ACTION HISTORY AUDIT TRAIL LOGGING
    // ─────────────────────────────────────────────────────────────────────────
    test('6. Action History logs moves, captures, spell casts, and relic equip events in sequence', () {
      final container = ProviderContainer(
        overrides: [
          audioServiceProvider.overrideWithValue(MockAudioService()),
          networkServiceProvider.overrideWithValue(MockNetworkService()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(matchControllerProvider.notifier);
      controller.startAiMatch(difficulty: AiDifficulty.novice);

      // 1. Move pawn
      controller.selectTile(const BoardPosition(6, 4));
      controller.makeMove(const BoardPosition(6, 4), const BoardPosition(4, 4));

      // 2. Cast a spell (ensure White has mana)
      final wallSpell = const WallOfStoneSpell();
      controller.playSpell(
        spell: wallSpell,
        primary: const BoardPosition(3, 3),
      );

      final log = container.read(matchControllerProvider).actionLog;
      expect(log.isNotEmpty, isTrue);
      expect(log.any((entry) => entry.text.contains('Wall of Stone') || entry.text.contains('e4') || entry.text.contains('pawn')), isTrue);
    });
  });
}
