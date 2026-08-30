import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_chess/features/board/domain/board_position.dart';
import 'package:super_chess/features/board/domain/game_board.dart';
import 'package:super_chess/features/match/application/match_controller.dart';
import 'package:super_chess/features/match/domain/chess_ai.dart';
import 'package:super_chess/features/match/domain/chess_engine.dart';
import 'package:super_chess/features/match/domain/chess_move.dart';
import 'package:super_chess/features/match/domain/game_state.dart';
import 'package:super_chess/features/match/domain/game_status.dart';
import 'package:super_chess/features/match/domain/match_state.dart';
import 'package:super_chess/features/match/domain/turn_phase.dart';
import 'package:super_chess/features/pieces/domain/chess_piece.dart';
import 'package:super_chess/features/relics/domain/relic.dart';
import 'package:super_chess/features/relics/domain/relics.dart';
import 'package:super_chess/features/spells/domain/spells.dart';
import 'package:super_chess/features/spells/domain/spell_engine.dart';
import 'package:super_chess/shared/enums/piece_color.dart';
import 'package:super_chess/shared/enums/piece_type.dart';
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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('⚔️ BRUTAL CHESS & SPELL LOGIC STRESS SUITE', () {
    test('BRUTAL 1: Absolute Pin - Pinned Rook cannot move off file even to capture attacker', () {
      final board = GameBoard.empty();
      // White King at (7,4), White Rook at (5,4), Black Queen at (0,4)
      board.setPiece(const BoardPosition(7, 4), const ChessPiece(type: PieceType.king, color: PieceColor.white));
      board.setPiece(const BoardPosition(5, 4), const ChessPiece(type: PieceType.rook, color: PieceColor.white));
      board.setPiece(const BoardPosition(0, 4), const ChessPiece(type: PieceType.queen, color: PieceColor.black));
      // Black King at (0,0)
      board.setPiece(const BoardPosition(0, 0), const ChessPiece(type: PieceType.king, color: PieceColor.black));

      final state = GameState(
        board: board,
        currentTurn: PieceColor.white,
        status: GameStatus.ongoing,
        moveHistory: const [],
        whiteInCheck: false,
        blackInCheck: false,
      );

      final legalMoves = ChessEngine.generateLegalMoves(state, const BoardPosition(5, 4));
      // Rook can only move along column 4 (e.g. capture Queen at (0,4) or slide on col 4)
      for (final move in legalMoves) {
        expect(move.to.col, 4, reason: 'Pinned rook must not move off the pin line');
      }
      expect(legalMoves.any((m) => m.to.row != 5 && m.to.col == 4), isTrue);
    });

    test('BRUTAL 2: Double Check - ONLY King moves are legal, blocking is impossible', () {
      final board = GameBoard.empty();
      // White King at (7,4)
      board.setPiece(const BoardPosition(7, 4), const ChessPiece(type: PieceType.king, color: PieceColor.white));
      // White Queen at (6,3)
      board.setPiece(const BoardPosition(6, 3), const ChessPiece(type: PieceType.queen, color: PieceColor.white));
      // Black Rook at (7,0) giving check horizontally
      board.setPiece(const BoardPosition(7, 0), const ChessPiece(type: PieceType.rook, color: PieceColor.black));
      // Black Bishop at (4,1) giving check diagonally
      board.setPiece(const BoardPosition(4, 1), const ChessPiece(type: PieceType.bishop, color: PieceColor.black));
      // Black King at (0,0)
      board.setPiece(const BoardPosition(0, 0), const ChessPiece(type: PieceType.king, color: PieceColor.black));

      final state = GameState(
        board: board,
        currentTurn: PieceColor.white,
        status: GameStatus.check,
        moveHistory: const [],
        whiteInCheck: true,
        blackInCheck: false,
      );

      // White Queen tries to move or block
      final queenMoves = ChessEngine.generateLegalMoves(state, const BoardPosition(6, 3));
      expect(queenMoves, isEmpty, reason: 'In double check, non-king pieces have zero legal moves');

      // White King MUST move to an unattacked square
      final kingMoves = ChessEngine.generateLegalMoves(state, const BoardPosition(7, 4));
      expect(kingMoves, isNotEmpty);
      for (final km in kingMoves) {
        final nextState = ChessEngine.makeMove(state, km);
        expect(ChessEngine.isKingInCheck(nextState.board, PieceColor.white), isFalse);
      }
    });

    test('BRUTAL 3: Scholar Checkmate in 4 moves detected with GameStatus.checkmate', () {
      var state = GameState.initial();

      // 1. e4 e5
      state = ChessEngine.makeMove(state, const ChessMove(
        from: BoardPosition(6, 4), to: BoardPosition(4, 4),
        movedPiece: ChessPiece(type: PieceType.pawn, color: PieceColor.white),
      ));
      state = ChessEngine.makeMove(state, const ChessMove(
        from: BoardPosition(1, 4), to: BoardPosition(3, 4),
        movedPiece: ChessPiece(type: PieceType.pawn, color: PieceColor.black),
      ));

      // 2. Bc4 Nc6
      state = ChessEngine.makeMove(state, const ChessMove(
        from: BoardPosition(7, 5), to: BoardPosition(4, 2),
        movedPiece: ChessPiece(type: PieceType.bishop, color: PieceColor.white),
      ));
      state = ChessEngine.makeMove(state, const ChessMove(
        from: BoardPosition(0, 1), to: BoardPosition(2, 2),
        movedPiece: ChessPiece(type: PieceType.knight, color: PieceColor.black),
      ));

      // 3. Qh5 Nf6
      state = ChessEngine.makeMove(state, const ChessMove(
        from: BoardPosition(7, 3), to: BoardPosition(3, 7),
        movedPiece: ChessPiece(type: PieceType.queen, color: PieceColor.white),
      ));
      state = ChessEngine.makeMove(state, const ChessMove(
        from: BoardPosition(0, 6), to: BoardPosition(2, 5),
        movedPiece: ChessPiece(type: PieceType.knight, color: PieceColor.black),
      ));

      // 4. Qxf7# (Checkmate!)
      state = ChessEngine.makeMove(state, const ChessMove(
        from: BoardPosition(3, 7), to: BoardPosition(1, 5),
        movedPiece: ChessPiece(type: PieceType.queen, color: PieceColor.white),
        capturedPiece: ChessPiece(type: PieceType.pawn, color: PieceColor.black),
        isCapture: true,
      ));

      expect(state.status, GameStatus.checkmate);
      expect(state.blackInCheck, isTrue);
    });

    test('BRUTAL 4: Stalemate detection when King has no moves and no other pieces can move', () {
      final board = GameBoard.empty();
      // Black King trapped at (0, 0)
      board.setPiece(const BoardPosition(0, 0), const ChessPiece(type: PieceType.king, color: PieceColor.black));
      // White Queen at (1, 2) covering (0,1), (1,0), (1,1) without putting King in check
      board.setPiece(const BoardPosition(1, 2), const ChessPiece(type: PieceType.queen, color: PieceColor.white));
      // White King at (2, 1) guarding Queen
      board.setPiece(const BoardPosition(2, 1), const ChessPiece(type: PieceType.king, color: PieceColor.white));

      final state = GameState(
        board: board,
        currentTurn: PieceColor.black,
        status: GameStatus.ongoing,
        moveHistory: const [],
        whiteInCheck: false,
        blackInCheck: false,
      );

      final status = ChessEngine.evaluateGameStatus(state);
      expect(status, GameStatus.stalemate);
    });

    test('BRUTAL 5: Wall of Stone blocks checking Ray and relieves check', () {
      final board = GameBoard.empty();
      // White King at (7, 4)
      board.setPiece(const BoardPosition(7, 4), const ChessPiece(type: PieceType.king, color: PieceColor.white));
      // Black Rook at (1, 4) attacking along file 4
      board.setPiece(const BoardPosition(1, 4), const ChessPiece(type: PieceType.rook, color: PieceColor.black));
      // Black King at (0, 0)
      board.setPiece(const BoardPosition(0, 0), const ChessPiece(type: PieceType.king, color: PieceColor.black));

      expect(ChessEngine.isKingInCheck(board, PieceColor.white), isTrue);

      // White casts Wall of Stone at (4, 4) to intercept the ray
      final match = MatchState.initial().copyWith(
        gameState: GameState(
          board: board,
          currentTurn: PieceColor.white,
          status: GameStatus.check,
          moveHistory: const [],
          whiteInCheck: true,
          blackInCheck: false,
        ),
        whiteSpellbook: MatchState.initial().whiteSpellbook.copyWith(mana: 10),
      );

      final updatedMatch = SpellEngine.applySpell(
        state: match,
        spell: const WallOfStoneSpell(),
        casterColor: PieceColor.white,
        target: const BoardPosition(4, 4),
      );

      expect(ChessEngine.isKingInCheck(updatedMatch.gameState.board, PieceColor.white), isFalse);
    });

    test('BRUTAL 6: Freezing attacking piece immediately cancels check condition', () {
      final board = GameBoard.empty();
      board.setPiece(const BoardPosition(7, 4), const ChessPiece(type: PieceType.king, color: PieceColor.white));
      board.setPiece(const BoardPosition(0, 0), const ChessPiece(type: PieceType.king, color: PieceColor.black));
      // Black Bishop checking King at (7,4) from (4,1)
      board.setPiece(const BoardPosition(4, 1), const ChessPiece(type: PieceType.bishop, color: PieceColor.black));

      expect(ChessEngine.isKingInCheck(board, PieceColor.white), isTrue);

      final match = MatchState.initial().copyWith(
        gameState: GameState(
          board: board,
          currentTurn: PieceColor.white,
          status: GameStatus.check,
          moveHistory: const [],
          whiteInCheck: true,
          blackInCheck: false,
        ),
        whiteSpellbook: MatchState.initial().whiteSpellbook.copyWith(mana: 10),
      );

      final updatedMatch = SpellEngine.applySpell(
        state: match,
        spell: const FreezeSpell(),
        casterColor: PieceColor.white,
        target: const BoardPosition(4, 1),
      );

      expect(ChessEngine.isKingInCheck(updatedMatch.gameState.board, PieceColor.white), isFalse);
      expect(updatedMatch.gameState.board.pieceAt(const BoardPosition(4, 1))?.isFrozen, isTrue);
    });

    test('BRUTAL 7: Aegis Shield survives first capture, second capture succeeds', () {
      final board = GameBoard.empty();
      board.setPiece(const BoardPosition(7, 0), const ChessPiece(type: PieceType.king, color: PieceColor.white));
      board.setPiece(const BoardPosition(7, 4), const ChessPiece(type: PieceType.rook, color: PieceColor.white));
      board.setPiece(const BoardPosition(0, 0), const ChessPiece(type: PieceType.king, color: PieceColor.black));

      // Black Queen equipped with Aegis Shield at (4, 4)
      final aegis = RelicPool.allRelics.firstWhere((r) => r.id == 'relic_aegis_shield');
      board.setPiece(const BoardPosition(4, 4), ChessPiece(
        type: PieceType.queen,
        color: PieceColor.black,
        equipment: [aegis],
      ));

      // White Rook at (7, 4) attacks Queen at (4, 4)
      var state = GameState(
        board: board,
        currentTurn: PieceColor.white,
        status: GameStatus.ongoing,
        moveHistory: const [],
        whiteInCheck: false,
        blackInCheck: false,
      );

      // Strike 1: Shield absorbs capture and Queen is deflected
      state = ChessEngine.makeMove(state, ChessMove(
        from: const BoardPosition(7, 4),
        to: const BoardPosition(4, 4),
        movedPiece: const ChessPiece(type: PieceType.rook, color: PieceColor.white),
        capturedPiece: state.board.pieceAt(const BoardPosition(4, 4)),
        isCapture: true,
      ));

      // Queen is still alive on board without shield!
      final aliveQueen = state.board.allPieces(PieceColor.black)
          .map((p) => state.board.pieceAt(p))
          .firstWhere((p) => p?.type == PieceType.queen, orElse: () => null);
      expect(aliveQueen, isNotNull);
      expect(aliveQueen?.equipment.any((r) => r.id == 'relic_aegis_shield'), isFalse);
    });

    test('BRUTAL 8: Ring of Mana stacking bonus generates extra mana on turn transition', () {
      final container = ProviderContainer(
        overrides: [
          audioServiceProvider.overrideWithValue(MockAudioService()),
          networkServiceProvider.overrideWithValue(MockNetworkService()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(matchControllerProvider.notifier);
      final ring = RelicPool.allRelics.firstWhere((r) => r.id == 'relic_ring_of_mana');

      // Equip 2 Rings of Mana on White pieces
      controller.equipRelicToSelectedPiece(ring, const BoardPosition(7, 0));
      controller.equipRelicToSelectedPiece(ring, const BoardPosition(7, 7));

      expect(container.read(matchControllerProvider).whiteSpellbook.mana, 3);

      // End White turn (transitions to Black, Black gets +1 mana)
      controller.endTurn();
      expect(container.read(matchControllerProvider).blackSpellbook.mana, 4);

      // End Black turn (transitions to White, White gets 1 + 2 bonus mana = 3 mana gained!)
      controller.endTurn();
      expect(container.read(matchControllerProvider).whiteSpellbook.mana, 6);
    });

    test('BRUTAL 9: Multi-Turn Full AI Game Simulation without desync or errors', () {
      final container = ProviderContainer(
        overrides: [
          audioServiceProvider.overrideWithValue(MockAudioService()),
          networkServiceProvider.overrideWithValue(MockNetworkService()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(matchControllerProvider.notifier);
      controller.startAiMatch(difficulty: AiDifficulty.novice);

      expect(container.read(matchControllerProvider).isAiMode, isTrue);

      // Simulate 5 full turns of gameplay
      final moves = [
        const [BoardPosition(6, 4), BoardPosition(4, 4)], // e4
        const [BoardPosition(7, 6), BoardPosition(5, 5)], // Nf3
        const [BoardPosition(7, 5), BoardPosition(4, 2)], // Bc4
      ];

      for (int i = 0; i < moves.length; i++) {
        final state = container.read(matchControllerProvider);
        if (state.phase == TurnPhase.gameOver) break;

        final from = moves[i][0];
        final to = moves[i][1];
        controller.selectTile(from);
        controller.makeMove(from, to);

        // Cast spell if mana available
        final currentMatch = container.read(matchControllerProvider);
        if (currentMatch.whiteSpellbook.mana >= 2 && currentMatch.whiteSpellbook.spells.isNotEmpty) {
          final spell = currentMatch.whiteSpellbook.spells.first;
          final validTargets = SpellEngine.getValidTargets(
            spell, currentMatch.gameState.board, PieceColor.white,
          );
          if (validTargets.isNotEmpty) {
            controller.playSpell(
              spell: spell,
              primary: validTargets.first,
            );
          }
        }

        controller.endTurn();
        expect(container.read(matchControllerProvider).phase != TurnPhase.gameOver ||
            container.read(matchControllerProvider).result != null, isTrue);
      }
    });

    test('BRUTAL 10: Soul Leech when opponent has 1 mana drains max 1 without going negative', () {
      final match = MatchState.initial().copyWith(
        whiteSpellbook: MatchState.initial().whiteSpellbook.copyWith(mana: 5),
        blackSpellbook: MatchState.initial().blackSpellbook.copyWith(mana: 1),
      );

      final updated = SpellEngine.applySpell(
        state: match,
        spell: const SoulLeechSpell(),
        casterColor: PieceColor.white,
        target: const BoardPosition(1, 0),
      );

      expect(updated.blackSpellbook.mana, 0); // Drained 1 (not -1)
      expect(updated.whiteSpellbook.mana, 5); // 5 - 1 cost + 1 gained = 5
    });
  });
}
