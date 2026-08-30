import '../../board/domain/game_board.dart';
import '../../../shared/enums/piece_color.dart';
import 'game_status.dart';
import 'chess_move.dart';

class GameState {
  final GameBoard board;
  final PieceColor currentTurn;
  final GameStatus status;
  final List<ChessMove> moveHistory;
  final bool whiteInCheck;
  final bool blackInCheck;

  // Card System State
  final Map<String, dynamic> cardMetadata;

  const GameState({
    required this.board,
    required this.currentTurn,
    required this.status,
    required this.moveHistory,
    required this.whiteInCheck,
    required this.blackInCheck,
    this.cardMetadata = const {},
  });

  factory GameState.initial() {
    return GameState(
      board: GameBoard.initial(),
      currentTurn: PieceColor.white,
      status: GameStatus.ongoing,
      moveHistory: [],
      whiteInCheck: false,
      blackInCheck: false,
    );
  }

  GameState copyWith({
    GameBoard? board,
    PieceColor? currentTurn,
    GameStatus? status,
    List<ChessMove>? moveHistory,
    bool? whiteInCheck,
    bool? blackInCheck,
    Map<String, dynamic>? cardMetadata,
  }) {
    return GameState(
      board: board ?? this.board,
      currentTurn: currentTurn ?? this.currentTurn,
      status: status ?? this.status,
      moveHistory: moveHistory ?? List.from(this.moveHistory),
      whiteInCheck: whiteInCheck ?? this.whiteInCheck,
      blackInCheck: blackInCheck ?? this.blackInCheck,
      cardMetadata: cardMetadata ?? Map.from(this.cardMetadata),
    );
  }
}
