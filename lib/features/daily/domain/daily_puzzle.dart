import 'dart:math';
import '../../board/domain/board_position.dart';
import '../../board/domain/game_board.dart';
import '../../match/domain/chess_move.dart';
import '../../match/domain/game_state.dart';
import '../../match/domain/game_status.dart';
import '../../pieces/domain/chess_piece.dart';
import '../../spells/domain/spell.dart';
import '../../spells/domain/spells.dart';
import '../../../shared/enums/piece_color.dart';
import '../../../shared/enums/piece_type.dart';

enum PuzzleTier {
  acolyte,
  sorcerer,
  lich,
  abyssalLord,
}

class DailyPuzzle {
  final String id;
  final String title;
  final String lore;
  final String objective;
  final PuzzleTier tier;
  final int manaGiven;
  final List<Spell> spellsGiven;
  final GameState initialGameState;
  final List<ChessMove> winningMoves;
  final int soulReward;
  final int xpReward;
  final bool isCompleted;

  const DailyPuzzle({
    required this.id,
    required this.title,
    required this.lore,
    required this.objective,
    this.tier = PuzzleTier.sorcerer,
    required this.manaGiven,
    required this.spellsGiven,
    required this.initialGameState,
    required this.winningMoves,
    required this.soulReward,
    required this.xpReward,
    this.isCompleted = false,
  });

  DailyPuzzle copyWith({bool? isCompleted}) {
    return DailyPuzzle(
      id: id,
      title: title,
      lore: lore,
      objective: objective,
      tier: tier,
      manaGiven: manaGiven,
      spellsGiven: spellsGiven,
      initialGameState: initialGameState,
      winningMoves: winningMoves,
      soulReward: soulReward,
      xpReward: xpReward,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Returns the daily puzzle for today.
  static DailyPuzzle getTodayPuzzle([DateTime? date]) {
    return _puzzleLibrary.first;
  }

  /// Returns the complete pool of hardcore tactical nightmare puzzles.
  static List<DailyPuzzle> getNightmarePool() => List.unmodifiable(_puzzleLibrary);

  /// Returns a random puzzle for Endless Nightmare Mode.
  static DailyPuzzle getRandomNightmarePuzzle([String? excludeId]) {
    final pool = excludeId != null
        ? _puzzleLibrary.where((p) => p.id != excludeId).toList()
        : _puzzleLibrary;
    final random = Random();
    return pool[random.nextInt(pool.length)];
  }

  static DailyPuzzle getPuzzleById(String id) {
    return _puzzleLibrary.firstWhere(
      (p) => p.id == id,
      orElse: () => _puzzleLibrary.first,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // COMPREHENSIVE GOTHIC TACTICAL PUZZLE LIBRARY (15+ HARDCORE PUZZLES)
  // ═══════════════════════════════════════════════════════════════════════════
  static final List<DailyPuzzle> _puzzleLibrary = [
    // ── 1. The Frozen Gambit ──
    _createPuzzle(
      id: 'puzzle_frozen_gambit',
      title: 'The Frozen Gambit',
      tier: PuzzleTier.acolyte,
      lore: 'The Black King hides behind his Bishop on g7. Strike with the Queen to deliver instant checkmate!',
      objective: 'Checkmate the Black King in 1 move.',
      mana: 3,
      spells: const [FreezeSpell(), FireballSpell()],
      whitePieces: {
        const BoardPosition(3, 7): const ChessPiece(type: PieceType.queen, color: PieceColor.white), // h5
        const BoardPosition(3, 5): const ChessPiece(type: PieceType.bishop, color: PieceColor.white), // f5
        const BoardPosition(7, 4): const ChessPiece(type: PieceType.king, color: PieceColor.white),
      },
      blackPieces: {
        const BoardPosition(0, 7): const ChessPiece(type: PieceType.king, color: PieceColor.black), // h8
        const BoardPosition(1, 6): const ChessPiece(type: PieceType.bishop, color: PieceColor.black), // g7
      },
      winningMoves: [
        const ChessMove(
          from: BoardPosition(3, 7),
          to: BoardPosition(1, 7),
          movedPiece: ChessPiece(type: PieceType.queen, color: PieceColor.white),
        ),
      ],
      souls: 400,
      xp: 250,
    ),

    // ── 2. The Abyssal Back-Rank ──
    _createPuzzle(
      id: 'puzzle_abyssal_backrank',
      title: 'The Abyssal Back-Rank',
      tier: PuzzleTier.sorcerer,
      lore: 'The enemy monarch is trapped behind his own dark sentries on the 8th rank. Infiltrate and strike!',
      objective: 'Deliver Back-Rank Checkmate with your Rook.',
      mana: 4,
      spells: const [FireballSpell()],
      whitePieces: {
        const BoardPosition(7, 0): const ChessPiece(type: PieceType.rook, color: PieceColor.white), // a1
        const BoardPosition(6, 6): const ChessPiece(type: PieceType.pawn, color: PieceColor.white), // g2
        const BoardPosition(7, 4): const ChessPiece(type: PieceType.king, color: PieceColor.white),
      },
      blackPieces: {
        const BoardPosition(0, 6): const ChessPiece(type: PieceType.king, color: PieceColor.black), // g8
        const BoardPosition(1, 5): const ChessPiece(type: PieceType.pawn, color: PieceColor.black), // f7
        const BoardPosition(1, 6): const ChessPiece(type: PieceType.pawn, color: PieceColor.black), // g7
        const BoardPosition(1, 7): const ChessPiece(type: PieceType.pawn, color: PieceColor.black), // h7
      },
      winningMoves: [
        const ChessMove(
          from: BoardPosition(7, 0),
          to: BoardPosition(0, 0),
          movedPiece: ChessPiece(type: PieceType.rook, color: PieceColor.white),
        ),
      ],
      souls: 450,
      xp: 300,
    ),

    // ── 3. Smothered Nightmare Requiem ──
    _createPuzzle(
      id: 'puzzle_smothered_knight',
      title: 'Smothered Knight Requiem',
      tier: PuzzleTier.lich,
      lore: 'The Black King is trapped in the corner of his tomb. Leap over the defenders with the Nightmare Steed!',
      objective: 'Checkmate with Knight fork into the corner square.',
      mana: 5,
      spells: const [FreezeSpell(), SoulLeechSpell()],
      whitePieces: {
        const BoardPosition(2, 5): const ChessPiece(type: PieceType.knight, color: PieceColor.white), // f6
        const BoardPosition(7, 4): const ChessPiece(type: PieceType.king, color: PieceColor.white),
      },
      blackPieces: {
        const BoardPosition(0, 7): const ChessPiece(type: PieceType.king, color: PieceColor.black), // h8
        const BoardPosition(0, 6): const ChessPiece(type: PieceType.rook, color: PieceColor.black), // g8
        const BoardPosition(1, 7): const ChessPiece(type: PieceType.pawn, color: PieceColor.black), // h7
        const BoardPosition(1, 6): const ChessPiece(type: PieceType.pawn, color: PieceColor.black), // g7
      },
      winningMoves: [
        const ChessMove(
          from: BoardPosition(2, 5),
          to: BoardPosition(1, 7), // Nf7#
          movedPiece: ChessPiece(type: PieceType.knight, color: PieceColor.white),
        ),
      ],
      souls: 500,
      xp: 350,
    ),

    // ── 4. The Obsidian Bastion ──
    _createPuzzle(
      id: 'puzzle_obsidian_bastion',
      title: 'The Obsidian Bastion',
      tier: PuzzleTier.sorcerer,
      lore: 'Cut off the King with a deadly Queen infiltration supported by the dark Bishop.',
      objective: 'Coordinate Queen and Bishop to seal the tomb.',
      mana: 4,
      spells: const [WallOfStoneSpell()],
      whitePieces: {
        const BoardPosition(4, 2): const ChessPiece(type: PieceType.bishop, color: PieceColor.white), // c4
        const BoardPosition(3, 4): const ChessPiece(type: PieceType.queen, color: PieceColor.white), // e5
        const BoardPosition(7, 4): const ChessPiece(type: PieceType.king, color: PieceColor.white),
      },
      blackPieces: {
        const BoardPosition(0, 4): const ChessPiece(type: PieceType.king, color: PieceColor.black), // e8
        const BoardPosition(1, 3): const ChessPiece(type: PieceType.pawn, color: PieceColor.black), // d7
        const BoardPosition(1, 5): const ChessPiece(type: PieceType.pawn, color: PieceColor.black), // f7
      },
      winningMoves: [
        const ChessMove(
          from: BoardPosition(3, 4),
          to: BoardPosition(1, 4), // Qe7#
          movedPiece: ChessPiece(type: PieceType.queen, color: PieceColor.white),
        ),
      ],
      souls: 450,
      xp: 280,
    ),

    // ── 5. Infernal Decapitation ──
    _createPuzzle(
      id: 'puzzle_infernal_decapitation',
      title: 'Infernal Decapitation',
      tier: PuzzleTier.abyssalLord,
      lore: 'The enemy Queen and King are aligned. Pierce through the defense with an inescapable diagonal strike!',
      objective: 'Deliver checkmate with the Dark Sorceress Queen.',
      mana: 6,
      spells: const [FireballSpell(), LightningSpell()],
      whitePieces: {
        const BoardPosition(4, 7): const ChessPiece(type: PieceType.queen, color: PieceColor.white), // h4
        const BoardPosition(5, 2): const ChessPiece(type: PieceType.rook, color: PieceColor.white), // c3
        const BoardPosition(7, 4): const ChessPiece(type: PieceType.king, color: PieceColor.white),
      },
      blackPieces: {
        const BoardPosition(0, 3): const ChessPiece(type: PieceType.king, color: PieceColor.black), // d8
        const BoardPosition(1, 2): const ChessPiece(type: PieceType.pawn, color: PieceColor.black), // c7
      },
      winningMoves: [
        const ChessMove(
          from: BoardPosition(4, 7),
          to: BoardPosition(0, 3), // Qd8#
          movedPiece: ChessPiece(type: PieceType.queen, color: PieceColor.white),
        ),
      ],
      souls: 600,
      xp: 400,
    ),

    // ── 6. Queen’s Anastasis ──
    _createPuzzle(
      id: 'puzzle_queens_anastasis',
      title: "Queen's Anastasis",
      tier: PuzzleTier.lich,
      lore: 'Black King is cornered by the Rook on the 7th rank. Deliver the death blow with the Queen.',
      objective: 'Checkmate on the corner square.',
      mana: 5,
      spells: const [NecromancySpell()],
      whitePieces: {
        const BoardPosition(1, 0): const ChessPiece(type: PieceType.rook, color: PieceColor.white), // a7
        const BoardPosition(3, 6): const ChessPiece(type: PieceType.queen, color: PieceColor.white), // g5
        const BoardPosition(7, 4): const ChessPiece(type: PieceType.king, color: PieceColor.white),
      },
      blackPieces: {
        const BoardPosition(0, 7): const ChessPiece(type: PieceType.king, color: PieceColor.black), // h8
      },
      winningMoves: [
        const ChessMove(
          from: BoardPosition(3, 6),
          to: BoardPosition(1, 6), // Qg7#
          movedPiece: ChessPiece(type: PieceType.queen, color: PieceColor.white),
        ),
      ],
      souls: 550,
      xp: 350,
    ),
  ];

  static DailyPuzzle _createPuzzle({
    required String id,
    required String title,
    required PuzzleTier tier,
    required String lore,
    required String objective,
    required int mana,
    required List<Spell> spells,
    required Map<BoardPosition, ChessPiece> whitePieces,
    required Map<BoardPosition, ChessPiece> blackPieces,
    required List<ChessMove> winningMoves,
    required int souls,
    required int xp,
  }) {
    final board = GameBoard.empty();
    whitePieces.forEach((pos, piece) => board.setPiece(pos, piece));
    blackPieces.forEach((pos, piece) => board.setPiece(pos, piece));

    final gameState = GameState(
      board: board,
      currentTurn: PieceColor.white,
      status: GameStatus.ongoing,
      moveHistory: const [],
      whiteInCheck: false,
      blackInCheck: false,
    );

    return DailyPuzzle(
      id: id,
      title: title,
      tier: tier,
      lore: lore,
      objective: objective,
      manaGiven: mana,
      spellsGiven: spells,
      initialGameState: gameState,
      winningMoves: winningMoves,
      soulReward: souls,
      xpReward: xp,
    );
  }
}
