import 'dart:math';
import '../domain/chess_engine.dart';
import '../domain/chess_move.dart';
import '../domain/game_state.dart';
import '../../spells/domain/spell.dart';
import '../../spells/domain/spellbook.dart';
import '../../spells/domain/spell_engine.dart';
import '../../board/domain/board_position.dart';
import '../../board/domain/game_board.dart';
import '../../../shared/enums/piece_color.dart';
import '../../../shared/enums/piece_type.dart';

enum AiDifficulty { novice, haunted, nightmare }

class AiSpellAction {
  final Spell spell;
  final BoardPosition? primary;
  final BoardPosition? secondary;

  const AiSpellAction({required this.spell, this.primary, this.secondary});
}

class ChessAi {
  final AiDifficulty difficulty;
  final Random _random = Random();

  ChessAi({required this.difficulty});

  int get _searchDepth {
    switch (difficulty) {
      case AiDifficulty.novice:    return 2;
      case AiDifficulty.haunted:   return 3;
      case AiDifficulty.nightmare: return 4;
    }
  }

  /// Evaluates spells available in the AI spellbook and returns the best tactical cast.
  AiSpellAction? getBestSpellAction({
    required Spellbook spellbook,
    required GameBoard board,
    PieceColor aiColor = PieceColor.black,
  }) {
    for (final spell in spellbook.spells) {
      if (spellbook.mana < spell.manaCost) continue;

      final validTargets = SpellEngine.getValidTargets(spell, board, aiColor);
      if (validTargets.isEmpty) continue;

      if (spell.id == 'spell_fireball' || spell.id == 'spell_lightning') {
        // Destroy the highest value white piece
        BoardPosition? bestTarget;
        int maxVal = -1;
        for (final pos in validTargets) {
          final p = board.pieceAt(pos);
          if (p != null) {
            final val = _pieceValue(p.type);
            if (val > maxVal) {
              maxVal = val;
              bestTarget = pos;
            }
          }
        }
        if (bestTarget != null) {
          return AiSpellAction(spell: spell, primary: bestTarget);
        }
      } else if (spell.id == 'spell_freeze' || spell.id == 'spell_soul_leech') {
        return AiSpellAction(spell: spell, primary: validTargets.first);
      }
    }
    return null;
  }

  /// Returns the best move for the AI player (always [PieceColor.black]).
  ChessMove? getBestMove(GameState state) {
    final color = state.currentTurn;
    final allMoves = _getAllMovesForColor(state, color);
    if (allMoves.isEmpty) return null;

    // Novice: 30% random move for human-like feel
    if (difficulty == AiDifficulty.novice && _random.nextDouble() < 0.30) {
      return allMoves[_random.nextInt(allMoves.length)];
    }

    ChessMove? bestMove;
    int bestScore = -999999;

    for (final move in allMoves) {
      try {
        final newState = ChessEngine.makeMove(state, move);
        final score = _minimax(newState, _searchDepth - 1, -999999, 999999, false, color);
        if (score > bestScore) {
          bestScore = score;
          bestMove = move;
        }
      } catch (_) {}
    }

    return bestMove;
  }

  int _minimax(GameState state, int depth, int alpha, int beta, bool isMaximizing, PieceColor aiColor) {
    if (depth == 0) return _evaluate(state, aiColor);

    final color = isMaximizing ? aiColor : aiColor.opposite;
    final moves = _getAllMovesForColor(state, color);

    if (moves.isEmpty) {
      if (ChessEngine.isKingInCheck(state.board, color)) {
        return isMaximizing ? -99999 : 99999;
      }
      return 0; // Stalemate
    }

    if (isMaximizing) {
      int maxEval = -999999;
      for (final move in moves) {
        try {
          final newState = ChessEngine.makeMove(state, move);
          final eval = _minimax(newState, depth - 1, alpha, beta, false, aiColor);
          maxEval = max(maxEval, eval);
          alpha = max(alpha, eval);
          if (beta <= alpha) break;
        } catch (_) {}
      }
      return maxEval;
    } else {
      int minEval = 999999;
      for (final move in moves) {
        try {
          final newState = ChessEngine.makeMove(state, move);
          final eval = _minimax(newState, depth - 1, alpha, beta, true, aiColor);
          minEval = min(minEval, eval);
          beta = min(beta, eval);
          if (beta <= alpha) break;
        } catch (_) {}
      }
      return minEval;
    }
  }

  List<ChessMove> _getAllMovesForColor(GameState state, PieceColor color) {
    final positions = state.board.allPieces(color);
    final moves = <ChessMove>[];
    for (final pos in positions) {
      moves.addAll(ChessEngine.generateLegalMoves(state, pos));
    }
    // Captures first for better pruning
    moves.sort((a, b) => (b.isCapture ? 1 : 0) - (a.isCapture ? 1 : 0));
    return moves;
  }

  int _evaluate(GameState state, PieceColor aiColor) {
    int score = 0;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = state.board.pieceAt(BoardPosition(row, col));
        if (piece == null) continue;
        final value = _pieceValue(piece.type) + _positionBonus(piece.type, row, col, piece.color);
        score += (piece.color == aiColor) ? value : -value;
      }
    }
    
    // King Safety: Heavily penalize if AI's king is in check
    if (ChessEngine.isKingInCheck(state.board, aiColor)) {
      score -= 50;
    }
    if (ChessEngine.isKingInCheck(state.board, aiColor.opposite)) {
      score += 50;
    }
    
    return score;
  }

  int _pieceValue(PieceType type) {
    switch (type) {
      case PieceType.pawn:   return 100;
      case PieceType.knight: return 320;
      case PieceType.bishop: return 330;
      case PieceType.rook:   return 500;
      case PieceType.queen:  return 900;
      case PieceType.king:   return 20000;
    }
  }

  int _positionBonus(PieceType type, int row, int col, PieceColor color) {
    final r = color == PieceColor.white ? 7 - row : row;
    switch (type) {
      case PieceType.pawn:   return _pawnTable[r][col];
      case PieceType.knight: return _knightTable[r][col];
      case PieceType.bishop: return _bishopTable[r][col];
      case PieceType.rook:   return _rookTable[r][col];
      case PieceType.queen:  return _queenTable[r][col];
      case PieceType.king:   return _kingTable[r][col];
    }
  }

  static const _pawnTable = [
    [ 0,  0,  0,  0,  0,  0,  0,  0],
    [50, 50, 50, 50, 50, 50, 50, 50],
    [10, 10, 20, 30, 30, 20, 10, 10],
    [ 5,  5, 10, 25, 25, 10,  5,  5],
    [ 0,  0,  0, 20, 20,  0,  0,  0],
    [ 5, -5,-10,  0,  0,-10, -5,  5],
    [ 5, 10, 10,-20,-20, 10, 10,  5],
    [ 0,  0,  0,  0,  0,  0,  0,  0],
  ];
  static const _knightTable = [
    [-50,-40,-30,-30,-30,-30,-40,-50],
    [-40,-20,  0,  0,  0,  0,-20,-40],
    [-30,  0, 10, 15, 15, 10,  0,-30],
    [-30,  5, 15, 20, 20, 15,  5,-30],
    [-30,  0, 15, 20, 20, 15,  0,-30],
    [-30,  5, 10, 15, 15, 10,  5,-30],
    [-40,-20,  0,  5,  5,  0,-20,-40],
    [-50,-40,-30,-30,-30,-30,-40,-50],
  ];
  static const _bishopTable = [
    [-20,-10,-10,-10,-10,-10,-10,-20],
    [-10,  0,  0,  0,  0,  0,  0,-10],
    [-10,  0,  5, 10, 10,  5,  0,-10],
    [-10,  5,  5, 10, 10,  5,  5,-10],
    [-10,  0, 10, 10, 10, 10,  0,-10],
    [-10, 10, 10, 10, 10, 10, 10,-10],
    [-10,  5,  0,  0,  0,  0,  5,-10],
    [-20,-10,-10,-10,-10,-10,-10,-20],
  ];
  static const _rookTable = [
    [ 0,  0,  0,  0,  0,  0,  0,  0],
    [ 5, 10, 10, 10, 10, 10, 10,  5],
    [-5,  0,  0,  0,  0,  0,  0, -5],
    [-5,  0,  0,  0,  0,  0,  0, -5],
    [-5,  0,  0,  0,  0,  0,  0, -5],
    [-5,  0,  0,  0,  0,  0,  0, -5],
    [-5,  0,  0,  0,  0,  0,  0, -5],
    [ 0,  0,  0,  5,  5,  0,  0,  0],
  ];
  static const _queenTable = [
    [-20,-10,-10, -5, -5,-10,-10,-20],
    [-10,  0,  0,  0,  0,  0,  0,-10],
    [-10,  0,  5,  5,  5,  5,  0,-10],
    [ -5,  0,  5,  5,  5,  5,  0, -5],
    [  0,  0,  5,  5,  5,  5,  0, -5],
    [-10,  5,  5,  5,  5,  5,  0,-10],
    [-10,  0,  5,  0,  0,  0,  0,-10],
    [-20,-10,-10, -5, -5,-10,-10,-20],
  ];
  static const _kingTable = [
    [-30,-40,-40,-50,-50,-40,-40,-30],
    [-30,-40,-40,-50,-50,-40,-40,-30],
    [-30,-40,-40,-50,-50,-40,-40,-30],
    [-30,-40,-40,-50,-50,-40,-40,-30],
    [-20,-30,-30,-40,-40,-30,-30,-20],
    [-10,-20,-20,-20,-20,-20,-20,-10],
    [ 20, 20,  0,  0,  0,  0, 20, 20],
    [ 20, 30, 10,  0,  0, 10, 30, 20],
  ];
}
