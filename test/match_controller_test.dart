import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_chess/features/match/application/match_controller.dart';
import 'package:super_chess/features/match/domain/turn_phase.dart';
import 'package:super_chess/features/board/domain/board_position.dart';
import 'package:super_chess/shared/enums/piece_color.dart';
import 'package:super_chess/core/audio/audio_service.dart';
import 'package:super_chess/core/audio/audio_enums.dart';

import 'package:super_chess/core/network/network_service.dart';
import 'package:super_chess/shared/enums/piece_type.dart';

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
  
  group('MatchController Tests', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer(
        overrides: [
          audioServiceProvider.overrideWithValue(MockAudioService()),
          networkServiceProvider.overrideWithValue(MockNetworkService()),
        ],
      );
    });


    tearDown(() {
      container.dispose();
    });

    test('Initial phase is move', () {
      final state = container.read(matchControllerProvider);
      expect(state.phase, TurnPhase.move);
      expect(state.gameState.currentTurn, PieceColor.white);
      expect(state.turnNumber, 1);
    });

    test('Legal move changes phase to card', () {
      final controller = container.read(matchControllerProvider.notifier);
      
      controller.selectTile(const BoardPosition(6, 0));
      controller.makeMove(const BoardPosition(6, 0), const BoardPosition(5, 0));
      
      final state = container.read(matchControllerProvider);
      expect(state.phase, TurnPhase.card);
      expect(controller.activePlayer, PieceColor.white);
      expect(state.canUndo, true);
    });

    test('End turn switches player and increases mana', () {
      final controller = container.read(matchControllerProvider.notifier);

      expect(container.read(matchControllerProvider).whiteSpellbook.mana, 3);

      controller.endTurn();

      final state = container.read(matchControllerProvider);
      expect(state.phase, TurnPhase.move);
      expect(controller.activePlayer, PieceColor.black);
      expect(state.blackSpellbook.mana, 4);
    });

    test('Undo restores previous board and disables undo', () {
      final controller = container.read(matchControllerProvider.notifier);
      
      controller.selectTile(const BoardPosition(6, 0));
      controller.makeMove(const BoardPosition(6, 0), const BoardPosition(5, 0));
      
      var state = container.read(matchControllerProvider);
      expect(state.phase, TurnPhase.card);
      expect(state.gameState.board.pieceAt(const BoardPosition(5, 0)), isNotNull);
      
      controller.undo();
      
      state = container.read(matchControllerProvider);
      expect(state.phase, TurnPhase.move);
      expect(state.gameState.board.pieceAt(const BoardPosition(6, 0)), isNotNull);
      expect(state.gameState.board.pieceAt(const BoardPosition(5, 0)), isNull);
      expect(state.canUndo, false);
    });

    test('Undo disabled after end turn', () {
      final controller = container.read(matchControllerProvider.notifier);
      
      controller.selectTile(const BoardPosition(6, 0));
      controller.makeMove(const BoardPosition(6, 0), const BoardPosition(5, 0));
      controller.endTurn();
      
      final state = container.read(matchControllerProvider);
      expect(state.canUndo, false);
    });
    
    test('Restart resets state', () {
      final controller = container.read(matchControllerProvider.notifier);
      
      controller.endTurn();
      expect(container.read(matchControllerProvider).turnNumber, 2);
      
      controller.restartMatch();
      
      expect(container.read(matchControllerProvider).turnNumber, 1);
      expect(container.read(matchControllerProvider).phase, TurnPhase.move);
    });
  });
}
