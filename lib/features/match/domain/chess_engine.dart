import '../../board/domain/board_position.dart';
import '../../board/domain/game_board.dart';
import '../../../shared/enums/piece_color.dart';
import '../../../shared/enums/piece_type.dart';
import '../../pieces/domain/chess_piece.dart';
import 'chess_move.dart';
import 'game_state.dart';
import 'game_status.dart';

class ChessEngine {
  static List<ChessMove> generatePseudoLegalMoves(GameBoard board, BoardPosition from, {bool includeCastling = true}) {
    final piece = board.pieceAt(from);
    if (piece == null || piece.isFrozen) return [];

    if (piece.hasPhantomStep) {
      return _generateSlidingMoves(board, from, piece.color, const [
          [-1, 0], [1, 0], [0, -1], [0, 1]
      ]);
    }

    final hasSniper = piece.equipment.any((r) => r.id == 'relic_sniper_bow');

    switch (piece.type) {
      case PieceType.pawn:
        return _generatePawnMoves(board, from, piece.color);
      case PieceType.knight:
        return _generateKnightMoves(board, from, piece.color);
      case PieceType.bishop:
        return _generateSlidingMoves(board, from, piece.color, const [
          [-1, -1], [-1, 1], [1, -1], [1, 1]
        ], canPierce: hasSniper);
      case PieceType.rook:
        return _generateSlidingMoves(board, from, piece.color, const [
          [-1, 0], [1, 0], [0, -1], [0, 1]
        ], canPierce: hasSniper);
      case PieceType.queen:
        return _generateSlidingMoves(board, from, piece.color, const [
          [-1, -1], [-1, 1], [1, -1], [1, 1],
          [-1, 0], [1, 0], [0, -1], [0, 1]
        ], canPierce: hasSniper);
      case PieceType.king:
        return _generateKingMoves(board, from, piece.color, includeCastling: includeCastling);
    }
  }

  static List<ChessMove> _generatePawnMoves(GameBoard board, BoardPosition from, PieceColor color) {
    final moves = <ChessMove>[];
    final int dir = color == PieceColor.white ? -1 : 1;
    final int startRow = color == PieceColor.white ? 6 : 1;
    final int promotionRow = color == PieceColor.white ? 0 : 7;
    final piece = board.pieceAt(from)!;
    final hasSniper = piece.equipment.any((r) => r.id == 'relic_sniper_bow');

    // Single push
    var to = from.offset(dir, 0);
    if (to.isValid && board.pieceAt(to) == null) {
      bool isPromotion = to.row == promotionRow;
      moves.add(ChessMove(from: from, to: to, movedPiece: piece, isPromotion: isPromotion));
      
      // Double push
      final hasBoots = piece.equipment.any((r) => r.id == 'relic_boots_of_haste');
      if (from.row == startRow || hasBoots) {
        var doubleTo = from.offset(dir * 2, 0);
        if (doubleTo.isValid && board.pieceAt(doubleTo) == null) {
          moves.add(ChessMove(from: from, to: doubleTo, movedPiece: piece));
        }
      }
    }

    // Captures
    for (int dCol in [-1, 1]) {
      to = from.offset(dir, dCol);
      if (to.isValid) {
        final target = board.pieceAt(to);
        if (target != null && target.color != color) {
          bool isPromotion = to.row == promotionRow;
          moves.add(ChessMove(
            from: from, 
            to: to, 
            movedPiece: piece, 
            capturedPiece: target, 
            isCapture: true, 
            isPromotion: isPromotion
          ));
        }
      }
    }

    // Sniper's Bow grants ranged piercing attacks through pawns and obstacles
    if (hasSniper) {
      moves.addAll(_generateSlidingMoves(
        board,
        from,
        color,
        const [
          [-1, 0], [1, 0], [0, -1], [0, 1],
          [-1, -1], [-1, 1], [1, -1], [1, 1]
        ],
        canPierce: true,
      ));
    }

    return moves;
  }

  static List<ChessMove> _generateKnightMoves(GameBoard board, BoardPosition from, PieceColor color) {
    final moves = <ChessMove>[];
    final piece = board.pieceAt(from)!;
    final hasSniper = piece.equipment.any((r) => r.id == 'relic_sniper_bow');
    const offsets = [
      [-2, -1], [-2, 1], [-1, -2], [-1, 2],
      [1, -2], [1, 2], [2, -1], [2, 1]
    ];

    for (var offset in offsets) {
      final to = from.offset(offset[0], offset[1]);
      if (to.isValid) {
        final target = board.pieceAt(to);
        if (target == null || target.color != color) {
          moves.add(ChessMove(
            from: from,
            to: to,
            movedPiece: piece,
            capturedPiece: target,
            isCapture: target != null,
          ));
        }
      }
    }

    if (hasSniper) {
      moves.addAll(_generateSlidingMoves(
        board,
        from,
        color,
        const [
          [-1, 0], [1, 0], [0, -1], [0, 1],
          [-1, -1], [-1, 1], [1, -1], [1, 1]
        ],
        canPierce: true,
      ));
    }

    return moves;
  }

  static List<ChessMove> _generateSlidingMoves(
    GameBoard board,
    BoardPosition from,
    PieceColor color,
    List<List<int>> directions, {
    bool canPierce = false,
  }) {
    final moves = <ChessMove>[];
    final piece = board.pieceAt(from)!;

    for (var dir in directions) {
      var current = from.offset(dir[0], dir[1]);
      int piercedCount = 0;

      while (current.isValid) {
        final target = board.pieceAt(current);
        if (target == null) {
          moves.add(ChessMove(from: from, to: current, movedPiece: piece));
        } else {
          if (target.color != color) {
            moves.add(ChessMove(
              from: from,
              to: current,
              movedPiece: piece,
              capturedPiece: target,
              isCapture: true,
            ));
          }
          if (canPierce && piercedCount < 2) {
            piercedCount++;
            // Pierces through obstacle and continues!
          } else {
            break; // Stop sliding if no pierce
          }
        }
        current = current.offset(dir[0], dir[1]);
      }
    }
    return moves;
  }

  static List<ChessMove> _generateKingMoves(GameBoard board, BoardPosition from, PieceColor color, {bool includeCastling = true}) {
    final moves = <ChessMove>[];
    final piece = board.pieceAt(from)!;
    final hasSniper = piece.equipment.any((r) => r.id == 'relic_sniper_bow');
    const offsets = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1],           [0, 1],
      [1, -1],  [1, 0],  [1, 1]
    ];

    for (var offset in offsets) {
      final to = from.offset(offset[0], offset[1]);
      if (to.isValid) {
        final target = board.pieceAt(to);
        if (target == null || target.color != color) {
          moves.add(ChessMove(
            from: from,
            to: to,
            movedPiece: piece,
            capturedPiece: target,
            isCapture: target != null,
          ));
        }
      }
    }

    if (hasSniper) {
      moves.addAll(_generateSlidingMoves(
        board,
        from,
        color,
        const [
          [-1, 0], [1, 0], [0, -1], [0, 1],
          [-1, -1], [-1, 1], [1, -1], [1, 1]
        ],
        canPierce: true,
      ));
    }

    // Castling
    if (includeCastling && !piece.hasMoved && !isKingInCheck(board, color)) {
      final int row = from.row;
      final oppositeColor = color.opposite;

      // Kingside castling (O-O)
      final rookKingside = board.pieceAt(BoardPosition(row, 7));
      if (rookKingside != null &&
          rookKingside.type == PieceType.rook &&
          rookKingside.color == color &&
          !rookKingside.hasMoved) {
        final f1 = BoardPosition(row, 5);
        final g1 = BoardPosition(row, 6);
        if (board.pieceAt(f1) == null && board.pieceAt(g1) == null) {
          if (!isSquareAttacked(board, f1, oppositeColor) &&
              !isSquareAttacked(board, g1, oppositeColor)) {
            moves.add(ChessMove(
              from: from,
              to: g1,
              movedPiece: piece,
              isCastling: true,
            ));
          }
        }
      }

      // Queenside castling (O-O-O)
      final rookQueenside = board.pieceAt(BoardPosition(row, 0));
      if (rookQueenside != null &&
          rookQueenside.type == PieceType.rook &&
          rookQueenside.color == color &&
          !rookQueenside.hasMoved) {
        final b1 = BoardPosition(row, 1);
        final c1 = BoardPosition(row, 2);
        final d1 = BoardPosition(row, 3);
        if (board.pieceAt(b1) == null &&
            board.pieceAt(c1) == null &&
            board.pieceAt(d1) == null) {
          if (!isSquareAttacked(board, d1, oppositeColor) &&
              !isSquareAttacked(board, c1, oppositeColor)) {
            moves.add(ChessMove(
              from: from,
              to: c1,
              movedPiece: piece,
              isCastling: true,
            ));
          }
        }
      }
    }

    return moves;
  }

  static bool isSquareAttacked(GameBoard board, BoardPosition pos, PieceColor byColor) {
    final enemyPositions = board.allPieces(byColor);
    for (final enemyPos in enemyPositions) {
      final enemyPiece = board.pieceAt(enemyPos);
      if (enemyPiece != null && !enemyPiece.isFrozen) {
        final moves = generatePseudoLegalMoves(board, enemyPos, includeCastling: false);
        if (moves.any((m) => m.to == pos)) {
          return true;
        }
      }
    }
    return false;
  }

  static bool isKingInCheck(GameBoard board, PieceColor color) {
    final kingPos = board.kingPosition(color);
    if (kingPos == null) return false;
    return isSquareAttacked(board, kingPos, color.opposite);
  }

  static BoardPosition resolvePortalDestination(GameState state, BoardPosition destination) {
    return destination;
  }

  static List<ChessMove> generateLegalMoves(GameState state, BoardPosition from) {
    final pseudoMoves = generatePseudoLegalMoves(state.board, from);
    final color = state.board.pieceAt(from)?.color;
    if (color == null || color != state.currentTurn) return [];

    return pseudoMoves.where((move) {
      final clonedBoard = state.board.clone();

      if (move.isCastling) {
        final row = move.from.row;
        clonedBoard.movePiece(move.from, move.to);
        if (move.to.col == 6) {
          // Kingside rook (row, 7) -> (row, 5)
          clonedBoard.movePiece(BoardPosition(row, 7), BoardPosition(row, 5));
        } else if (move.to.col == 2) {
          // Queenside rook (row, 0) -> (row, 3)
          clonedBoard.movePiece(BoardPosition(row, 0), BoardPosition(row, 3));
        }
      } else {
        clonedBoard.movePiece(move.from, move.to);
      }

      return (move.capturedPiece?.type != PieceType.king) && !isKingInCheck(clonedBoard, color);
    }).toList();
  }

  static bool hasAnyLegalMove(GameState state, PieceColor color) {
    final positions = state.board.allPieces(color);
    for (final pos in positions) {
      final legalMoves = generateLegalMoves(state, pos);
      if (legalMoves.isNotEmpty) return true;
    }
    return false;
  }

  static GameStatus evaluateGameStatus(GameState state) {
    final inCheck = isKingInCheck(state.board, state.currentTurn);
    final hasMoves = hasAnyLegalMove(state, state.currentTurn);

    if (inCheck && !hasMoves) {
      return GameStatus.checkmate;
    } else if (!inCheck && !hasMoves) {
      return GameStatus.stalemate;
    } else if (inCheck) {
      return GameStatus.check;
    }
    return GameStatus.ongoing;
  }

  static GameState makeMove(GameState state, ChessMove move) {
    // Validate
    final legalMoves = generateLegalMoves(state, move.from);
    if (!legalMoves.any((m) => m.to == move.to)) {
      throw Exception('Illegal move from ${move.from} to ${move.to}');
    }

    final newBoard = state.board.clone();
    final newMeta = Map<String, dynamic>.from(state.cardMetadata);

    if (move.isCastling) {
      final int row = move.from.row;
      newBoard.setPiece(move.to, move.movedPiece.copyWith(hasMoved: true));
      newBoard.setPiece(move.from, null);

      if (move.to.col == 6) {
        // Kingside: Move rook from (row, 7) to (row, 5)
        final rook = newBoard.pieceAt(BoardPosition(row, 7));
        if (rook != null) {
          newBoard.setPiece(BoardPosition(row, 5), rook.copyWith(hasMoved: true));
          newBoard.setPiece(BoardPosition(row, 7), null);
        }
      } else if (move.to.col == 2) {
        // Queenside: Move rook from (row, 0) to (row, 3)
        final rook = newBoard.pieceAt(BoardPosition(row, 0));
        if (rook != null) {
          newBoard.setPiece(BoardPosition(row, 3), rook.copyWith(hasMoved: true));
          newBoard.setPiece(BoardPosition(row, 0), null);
        }
      }
    } else {
      // Check for Aegis Shield on defending piece
      final targetPiece = newBoard.pieceAt(move.to);
      if (move.isCapture &&
          targetPiece != null &&
          targetPiece.equipment.any((r) => r.id == 'relic_aegis_shield')) {
        // Aegis Shield absorbs the lethal blow!
        final updatedEquipment = targetPiece.equipment
            .where((r) => r.id != 'relic_aegis_shield')
            .toList();
        final savedPiece = targetPiece.copyWith(equipment: updatedEquipment);

        // Find adjacent empty tile for defending piece to deflect to
        BoardPosition? safeTile;
        const directions = [
          [-1, 0], [1, 0], [0, -1], [0, 1],
          [-1, -1], [-1, 1], [1, -1], [1, 1]
        ];
        for (final dir in directions) {
          final candidate = move.to.offset(dir[0], dir[1]);
          if (candidate.isValid && candidate != move.from && newBoard.pieceAt(candidate) == null) {
            safeTile = candidate;
            break;
          }
        }

        if (safeTile != null) {
          newBoard.setPiece(safeTile, savedPiece);
          newBoard.setPiece(move.to, move.movedPiece.copyWith(hasMoved: true));
          newBoard.setPiece(move.from, null);
        } else {
          // No free tile: Defender stays on tile without shield, attacker remains on from
          newBoard.setPiece(move.to, savedPiece);
        }
      } else {
        // Standard move or normal capture
        newBoard.movePiece(move.from, move.to);

        if (move.isPromotion) {
          newBoard.setPiece(
            move.to,
            move.movedPiece.copyWith(type: PieceType.queen, hasMoved: true),
          );
        } else {
          newBoard.setPiece(
            move.to,
            move.movedPiece.copyWith(hasMoved: true),
          );
        }

        // Track captures in graveyard for Necromancy
        if (move.isCapture && move.capturedPiece != null) {
          final colorStr = move.capturedPiece!.color.name;
          final graveyardKey = 'graveyard_$colorStr';
          final graveyard = (newMeta[graveyardKey] as List<dynamic>?)?.cast<ChessPiece>() ?? <ChessPiece>[];
          graveyard.add(move.capturedPiece!);
          newMeta[graveyardKey] = graveyard;
        }
      }
    }

    final nextTurn = state.currentTurn.opposite;
    final whiteCheck = isKingInCheck(newBoard, PieceColor.white);
    final blackCheck = isKingInCheck(newBoard, PieceColor.black);

    GameState newState = state.copyWith(
      board: newBoard,
      currentTurn: nextTurn,
      moveHistory: [...state.moveHistory, move],
      whiteInCheck: whiteCheck,
      blackInCheck: blackCheck,
      cardMetadata: newMeta,
    );

    final newStatus = evaluateGameStatus(newState);
    return newState.copyWith(status: newStatus);
  }
}
