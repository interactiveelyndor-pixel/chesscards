import 'package:flutter_test/flutter_test.dart';
import 'package:super_chess/features/board/domain/board_position.dart';
import 'package:super_chess/features/board/domain/game_board.dart';
import 'package:super_chess/features/match/domain/chess_ai.dart';
import 'package:super_chess/features/match/domain/chess_engine.dart';
import 'package:super_chess/features/match/domain/chess_move.dart';
import 'package:super_chess/features/match/domain/game_state.dart';
import 'package:super_chess/features/match/domain/game_status.dart';
import 'package:super_chess/features/match/domain/match_state.dart';
import 'package:super_chess/features/pieces/domain/chess_piece.dart';
import 'package:super_chess/features/relics/domain/relics.dart';
import 'package:super_chess/features/spells/domain/spells.dart';
import 'package:super_chess/features/spells/domain/spell_engine.dart';
import 'package:super_chess/shared/enums/piece_color.dart';
import 'package:super_chess/shared/enums/piece_type.dart';

void main() {
  group('Comprehensive Game Logic & Rule Engine Tests', () {
    test('1. Kingside Castling (O-O) moves both King and Rook', () {
      final board = GameBoard.empty();
      // White King at e1 (7,4), White Rook at h1 (7,7)
      board.setPiece(const BoardPosition(7, 4), const ChessPiece(type: PieceType.king, color: PieceColor.white));
      board.setPiece(const BoardPosition(7, 7), const ChessPiece(type: PieceType.rook, color: PieceColor.white));
      // Black King at e8 (0,4)
      board.setPiece(const BoardPosition(0, 4), const ChessPiece(type: PieceType.king, color: PieceColor.black));

      final state = GameState(
        board: board,
        currentTurn: PieceColor.white,
        status: GameStatus.ongoing,
        moveHistory: const [],
        whiteInCheck: false,
        blackInCheck: false,
      );

      final legalMoves = ChessEngine.generateLegalMoves(state, const BoardPosition(7, 4));
      final castlingMove = legalMoves.firstWhere((m) => m.isCastling && m.to == const BoardPosition(7, 6));

      final nextState = ChessEngine.makeMove(state, castlingMove);
      expect(nextState.board.pieceAt(const BoardPosition(7, 6))?.type, PieceType.king);
      expect(nextState.board.pieceAt(const BoardPosition(7, 5))?.type, PieceType.rook);
      expect(nextState.board.pieceAt(const BoardPosition(7, 4)), isNull);
      expect(nextState.board.pieceAt(const BoardPosition(7, 7)), isNull);
    });

    test('2. Queenside Castling (O-O-O) moves both King and Rook', () {
      final board = GameBoard.empty();
      // White King at e1 (7,4), White Rook at a1 (7,0)
      board.setPiece(const BoardPosition(7, 4), const ChessPiece(type: PieceType.king, color: PieceColor.white));
      board.setPiece(const BoardPosition(7, 0), const ChessPiece(type: PieceType.rook, color: PieceColor.white));
      board.setPiece(const BoardPosition(0, 4), const ChessPiece(type: PieceType.king, color: PieceColor.black));

      final state = GameState(
        board: board,
        currentTurn: PieceColor.white,
        status: GameStatus.ongoing,
        moveHistory: const [],
        whiteInCheck: false,
        blackInCheck: false,
      );

      final legalMoves = ChessEngine.generateLegalMoves(state, const BoardPosition(7, 4));
      final castlingMove = legalMoves.firstWhere((m) => m.isCastling && m.to == const BoardPosition(7, 2));

      final nextState = ChessEngine.makeMove(state, castlingMove);
      expect(nextState.board.pieceAt(const BoardPosition(7, 2))?.type, PieceType.king);
      expect(nextState.board.pieceAt(const BoardPosition(7, 3))?.type, PieceType.rook);
      expect(nextState.board.pieceAt(const BoardPosition(7, 4)), isNull);
      expect(nextState.board.pieceAt(const BoardPosition(7, 0)), isNull);
    });

    test('3. Castling blocked if King is in check or passing square is attacked', () {
      final board = GameBoard.empty();
      board.setPiece(const BoardPosition(7, 4), const ChessPiece(type: PieceType.king, color: PieceColor.white));
      board.setPiece(const BoardPosition(7, 7), const ChessPiece(type: PieceType.rook, color: PieceColor.white));
      // Black Rook aiming at f1 (7,5) which King passes through
      board.setPiece(const BoardPosition(0, 5), const ChessPiece(type: PieceType.rook, color: PieceColor.black));
      board.setPiece(const BoardPosition(0, 4), const ChessPiece(type: PieceType.king, color: PieceColor.black));

      final state = GameState(
        board: board,
        currentTurn: PieceColor.white,
        status: GameStatus.ongoing,
        moveHistory: const [],
        whiteInCheck: false,
        blackInCheck: false,
      );

      final legalMoves = ChessEngine.generateLegalMoves(state, const BoardPosition(7, 4));
      expect(legalMoves.any((m) => m.isCastling), isFalse);
    });

    test('4. Aegis Shield absorbs standard capture blow and preserves piece', () {
      final board = GameBoard.empty();
      board.setPiece(const BoardPosition(7, 4), const ChessPiece(type: PieceType.king, color: PieceColor.white));
      board.setPiece(const BoardPosition(0, 4), const ChessPiece(type: PieceType.king, color: PieceColor.black));

      // White Rook attacks Black Knight with Aegis Shield
      const whiteRook = ChessPiece(type: PieceType.rook, color: PieceColor.white);
      const blackKnight = ChessPiece(
        type: PieceType.knight,
        color: PieceColor.black,
        equipment: [AegisShieldRelic()],
      );

      board.setPiece(const BoardPosition(4, 4), whiteRook);
      board.setPiece(const BoardPosition(2, 4), blackKnight);

      final state = GameState(
        board: board,
        currentTurn: PieceColor.white,
        status: GameStatus.ongoing,
        moveHistory: const [],
        whiteInCheck: false,
        blackInCheck: false,
      );

      const move = ChessMove(
        from: BoardPosition(4, 4),
        to: BoardPosition(2, 4),
        movedPiece: whiteRook,
        capturedPiece: blackKnight,
        isCapture: true,
      );

      final nextState = ChessEngine.makeMove(state, move);

      // White rook is at (2, 4)
      expect(nextState.board.pieceAt(const BoardPosition(2, 4))?.type, PieceType.rook);
      // Black knight survived and deflected to an adjacent square without shield!
      final blackPieces = nextState.board.allPieces(PieceColor.black);
      final knightPos = blackPieces.firstWhere((p) => nextState.board.pieceAt(p)?.type == PieceType.knight);
      final knight = nextState.board.pieceAt(knightPos)!;
      expect(knight.equipment.any((r) => r.id == 'relic_aegis_shield'), isFalse);
    });

    test('5. Aegis Shield absorbs lethal Fireball spell', () {
      final match = MatchState.initial();
      final board = match.gameState.board;

      const shieldedPiece = ChessPiece(
        type: PieceType.bishop,
        color: PieceColor.black,
        equipment: [AegisShieldRelic()],
      );
      board.setPiece(const BoardPosition(3, 3), shieldedPiece);

      final updatedMatch = SpellEngine.applySpell(
        state: match.copyWith(
          whiteSpellbook: match.whiteSpellbook.copyWith(mana: 10),
        ),
        spell: const FireballSpell(),
        casterColor: PieceColor.white,
        target: const BoardPosition(3, 3),
      );

      final targetPiece = updatedMatch.gameState.board.pieceAt(const BoardPosition(3, 3));
      expect(targetPiece, isNotNull);
      expect(targetPiece?.type, PieceType.bishop);
      expect(targetPiece?.equipment.any((r) => r.id == 'relic_aegis_shield'), isFalse);
    });

    test('6. Boots of Haste allows double-push from any rank', () {
      final board = GameBoard.empty();
      board.setPiece(const BoardPosition(7, 4), const ChessPiece(type: PieceType.king, color: PieceColor.white));
      board.setPiece(const BoardPosition(0, 4), const ChessPiece(type: PieceType.king, color: PieceColor.black));

      // White Pawn at rank 4 (normally can only single step) with Boots of Haste
      const hastyPawn = ChessPiece(
        type: PieceType.pawn,
        color: PieceColor.white,
        equipment: [BootsOfHasteRelic()],
      );
      board.setPiece(const BoardPosition(4, 2), hastyPawn);

      final moves = ChessEngine.generatePseudoLegalMoves(board, const BoardPosition(4, 2));
      // Double step to (2, 2)
      expect(moves.any((m) => m.to == const BoardPosition(2, 2)), isTrue);
    });

    test('7. Soul Leech siphons 2 Mana from opponent', () {
      final initialMatch = MatchState.initial().copyWith(
        whiteSpellbook: MatchState.initial().whiteSpellbook.copyWith(mana: 2),
        blackSpellbook: MatchState.initial().blackSpellbook.copyWith(mana: 5),
      );

      final updatedMatch = SpellEngine.applySpell(
        state: initialMatch,
        spell: const SoulLeechSpell(),
        casterColor: PieceColor.white,
        target: const BoardPosition(1, 0),
      );

      // White paid 1 mana, gained 2 mana -> net 3
      expect(updatedMatch.whiteSpellbook.mana, 3);
      // Black lost 2 mana -> 5 - 2 = 3
      expect(updatedMatch.blackSpellbook.mana, 3);
    });

    test('8. Frozen pieces cannot deliver check', () {
      final board = GameBoard.empty();
      board.setPiece(const BoardPosition(7, 4), const ChessPiece(type: PieceType.king, color: PieceColor.white));
      board.setPiece(const BoardPosition(0, 4), const ChessPiece(type: PieceType.king, color: PieceColor.black));

      // Black Rook at (7, 0) would give check to White King at (7, 4) if unfrozen
      const frozenRook = ChessPiece(
        type: PieceType.rook,
        color: PieceColor.black,
        isFrozen: true,
      );
      board.setPiece(const BoardPosition(7, 0), frozenRook);

      expect(ChessEngine.isKingInCheck(board, PieceColor.white), isFalse);
    });

    test('9. Blizzard freezes all enemy pieces in 3x3 radius', () {
      final match = MatchState.initial();
      final updated = SpellEngine.applySpell(
        state: match.copyWith(
          whiteSpellbook: match.whiteSpellbook.copyWith(mana: 10),
        ),
        spell: const BlizzardSpell(),
        casterColor: PieceColor.white,
        target: const BoardPosition(1, 4),
      );

      // Rank 1 pawns around (1, 4) should be frozen
      expect(updated.gameState.board.pieceAt(const BoardPosition(1, 3))?.isFrozen, isTrue);
      expect(updated.gameState.board.pieceAt(const BoardPosition(1, 4))?.isFrozen, isTrue);
      expect(updated.gameState.board.pieceAt(const BoardPosition(1, 5))?.isFrozen, isTrue);
    });

    test('10. AI evaluates best spell and targets enemy Rook with Fireball', () {
      final ai = ChessAi(difficulty: AiDifficulty.haunted);
      final match = MatchState.initial().copyWith(
        blackSpellbook: MatchState.initial().blackSpellbook.copyWith(
          mana: 10,
          spells: [const FireballSpell()],
        ),
      );

      final action = ai.getBestSpellAction(
        spellbook: match.blackSpellbook,
        board: match.gameState.board,
      );
      expect(action, isNotNull);
      expect(action?.spell.id, 'spell_fireball');
      // Fireball should target White Rook/Bishop/Knight (highest value)
      final targetPiece = match.gameState.board.pieceAt(action!.primary!);
      expect(targetPiece, isNotNull);
      expect(targetPiece?.color, PieceColor.white);
      expect(targetPiece?.type != PieceType.king && targetPiece?.type != PieceType.queen, isTrue);
    });

    test('11. Wall of Stone places an impassable barrier on an empty tile', () {
      final match = MatchState.initial();
      const target = BoardPosition(4, 4);
      expect(match.gameState.board.pieceAt(target), isNull);

      final updated = SpellEngine.applySpell(
        state: match.copyWith(
          whiteSpellbook: match.whiteSpellbook.copyWith(mana: 10),
        ),
        spell: const WallOfStoneSpell(),
        casterColor: PieceColor.white,
        target: target,
      );

      final barrier = updated.gameState.board.pieceAt(target);
      expect(barrier, isNotNull);
      expect(barrier?.color, PieceColor.white);
      expect(barrier?.isFrozen, isTrue);
    });

    test('12. Necromancy revives a captured piece from graveyard onto empty tile', () {
      final match = MatchState.initial();
      final capturedQueen = const ChessPiece(type: PieceType.queen, color: PieceColor.white);
      final meta = <String, dynamic>{
        'graveyard_white': [capturedQueen],
      };
      final stateWithGraveyard = match.copyWith(
        gameState: match.gameState.copyWith(cardMetadata: meta),
        whiteSpellbook: match.whiteSpellbook.copyWith(mana: 10),
      );

      const target = BoardPosition(4, 4);
      final updated = SpellEngine.applySpell(
        state: stateWithGraveyard,
        spell: const NecromancySpell(),
        casterColor: PieceColor.white,
        target: target,
      );

      final revived = updated.gameState.board.pieceAt(target);
      expect(revived, isNotNull);
      expect(revived?.type, PieceType.queen);
      expect(revived?.color, PieceColor.white);
      expect(revived?.isFrozen, isFalse);
    });

    test('13. Sniper\'s Bow pierces through blocking pawns to capture/move behind them', () {
      final board = GameBoard.empty();
      // White King at (7, 4)
      board.setPiece(const BoardPosition(7, 4), const ChessPiece(type: PieceType.king, color: PieceColor.white));
      // White Rook equipped with Sniper's Bow at (7, 0)
      final sniper = RelicPool.allRelics.firstWhere((r) => r.id == 'relic_sniper_bow');
      board.setPiece(const BoardPosition(7, 0), ChessPiece(
        type: PieceType.rook,
        color: PieceColor.white,
        equipment: [sniper],
      ));

      // White Pawn blocking at (6, 0)
      board.setPiece(const BoardPosition(6, 0), const ChessPiece(type: PieceType.pawn, color: PieceColor.white));
      // Black Pawn target behind at (5, 0)
      board.setPiece(const BoardPosition(5, 0), const ChessPiece(type: PieceType.pawn, color: PieceColor.black));
      // Black King at (0, 4)
      board.setPiece(const BoardPosition(0, 4), const ChessPiece(type: PieceType.king, color: PieceColor.black));

      final state = GameState(
        board: board,
        currentTurn: PieceColor.white,
        status: GameStatus.ongoing,
        moveHistory: const [],
        whiteInCheck: false,
        blackInCheck: false,
      );

      final moves = ChessEngine.generateLegalMoves(state, const BoardPosition(7, 0));
      // Should be able to pierce through (6, 0) and capture (5, 0) or move to (4, 0)!
      final canPierceToBlackPawn = moves.any((m) => m.to == const BoardPosition(5, 0) && m.isCapture);
      expect(canPierceToBlackPawn, isTrue, reason: 'Sniper Bow must pierce through blocking pawn');
    });
  });
}
