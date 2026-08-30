import 'game_state.dart';
import 'turn_phase.dart';
import 'action_log_entry.dart';
import 'match_snapshot.dart';
import 'match_result.dart';
import 'chess_ai.dart';
import 'chess_move.dart';
import '../../spells/domain/spellbook.dart';
import '../../spells/domain/spell.dart';
import '../../spells/domain/spells.dart';
import '../../relics/domain/relic_inventory.dart';
import '../../relics/domain/relics.dart';
import '../../board/domain/board_position.dart';
import '../../../shared/enums/piece_color.dart';

class MatchState {
  final GameState gameState;
  final TurnPhase phase;
  final Spellbook whiteSpellbook;
  final Spellbook blackSpellbook;
  final RelicInventory whiteRelics;
  final RelicInventory blackRelics;
  final List<ActionLogEntry> actionLog;
  final MatchSnapshot? undoSnapshot;
  final bool canUndo;
  final int turnNumber;
  final int secondsRemaining;
  final bool showTurnPass;
  final bool isLocalMode;
  final bool isAiMode;
  final bool isOnlineMode;
  final PieceColor? onlineColor;
  final AiDifficulty aiDifficulty;
  final MatchResult? result;
  final Set<BoardPosition> highlightedMoves;
  final BoardPosition? selectedTile;
  final DateTime matchStartTime;
  final ChessMove? lastMove;
  final Spell? lastPlayedSpell;
  final BoardPosition? lastSpellTarget;
  // Pending promotion: the move that triggered promotion, waiting for piece choice
  final ChessMove? pendingPromotion;
  // Cumulative stats for post-match summary
  final int playerCaptures;
  final int playerHealTotal;
  final ChessMove? hintMove;

  const MatchState({
    required this.gameState,
    required this.phase,
    required this.whiteSpellbook,
    required this.blackSpellbook,
    required this.whiteRelics,
    required this.blackRelics,
    this.actionLog = const [],
    this.undoSnapshot,
    this.canUndo = false,
    this.turnNumber = 1,
    this.secondsRemaining = 20,
    this.showTurnPass = false,
    this.isLocalMode = true,
    this.isAiMode = false,
    this.isOnlineMode = false,
    this.onlineColor,
    this.aiDifficulty = AiDifficulty.haunted,
    this.result,
    this.highlightedMoves = const {},
    this.selectedTile,
    required this.matchStartTime,
    this.lastMove,
    this.lastPlayedSpell,
    this.lastSpellTarget,
    this.pendingPromotion,
    this.playerCaptures = 0,
    this.playerHealTotal = 0,
    this.hintMove,
  });

  factory MatchState.initial() {
    final starterSpells = [
      const FireballSpell(),
      const SoulLeechSpell(),
      const FreezeSpell(),
    ];

    return MatchState(
      gameState: GameState.initial(),
      phase: TurnPhase.move,
      whiteSpellbook: Spellbook(
        spells: List.from(starterSpells),
        mana: 3,
        maxMana: 10,
      ),
      blackSpellbook: Spellbook(
        spells: List.from(starterSpells),
        mana: 3,
        maxMana: 10,
      ),
      whiteRelics: RelicInventory(relics: [RelicPool.getRandomRelic()]),
      blackRelics: RelicInventory(relics: [RelicPool.getRandomRelic()]),
      matchStartTime: DateTime.now(),
    );
  }

  MatchState copyWith({
    GameState? gameState,
    TurnPhase? phase,
    Spellbook? whiteSpellbook,
    Spellbook? blackSpellbook,
    RelicInventory? whiteRelics,
    RelicInventory? blackRelics,
    List<ActionLogEntry>? actionLog,
    MatchSnapshot? undoSnapshot,
    bool? canUndo,
    int? turnNumber,
    int? secondsRemaining,
    bool? showTurnPass,
    bool? isLocalMode,
    bool? isAiMode,
    bool? isOnlineMode,
    PieceColor? onlineColor,
    AiDifficulty? aiDifficulty,
    MatchResult? result,
    Set<BoardPosition>? highlightedMoves,
    BoardPosition? selectedTile,
    DateTime? matchStartTime,
    ChessMove? lastMove,
    Spell? lastPlayedSpell,
    BoardPosition? lastSpellTarget,
    ChessMove? pendingPromotion,
    int? playerCaptures,
    int? playerHealTotal,
    ChessMove? hintMove,
    bool clearUndo = false,
    bool clearSelectedTile = false,
    bool clearPendingPromotion = false,
    bool clearHint = false,
  }) {
    return MatchState(
      gameState: gameState ?? this.gameState,
      phase: phase ?? this.phase,
      whiteSpellbook: whiteSpellbook ?? this.whiteSpellbook,
      blackSpellbook: blackSpellbook ?? this.blackSpellbook,
      whiteRelics: whiteRelics ?? this.whiteRelics,
      blackRelics: blackRelics ?? this.blackRelics,
      actionLog: actionLog ?? this.actionLog,
      undoSnapshot: clearUndo ? null : (undoSnapshot ?? this.undoSnapshot),
      canUndo: clearUndo ? false : (canUndo ?? this.canUndo),
      turnNumber: turnNumber ?? this.turnNumber,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      showTurnPass: showTurnPass ?? this.showTurnPass,
      isLocalMode: isLocalMode ?? this.isLocalMode,
      isAiMode: isAiMode ?? this.isAiMode,
      isOnlineMode: isOnlineMode ?? this.isOnlineMode,
      onlineColor: onlineColor ?? this.onlineColor,
      aiDifficulty: aiDifficulty ?? this.aiDifficulty,
      result: result ?? this.result,
      highlightedMoves: highlightedMoves ?? this.highlightedMoves,
      selectedTile: clearSelectedTile ? null : (selectedTile ?? this.selectedTile),
      matchStartTime: matchStartTime ?? this.matchStartTime,
      lastMove: lastMove ?? this.lastMove,
      lastPlayedSpell: lastPlayedSpell ?? this.lastPlayedSpell,
      lastSpellTarget: lastSpellTarget ?? this.lastSpellTarget,
      pendingPromotion: clearPendingPromotion ? null : (pendingPromotion ?? this.pendingPromotion),
      playerCaptures: playerCaptures ?? this.playerCaptures,
      playerHealTotal: playerHealTotal ?? this.playerHealTotal,
      hintMove: clearHint ? null : (hintMove ?? this.hintMove),
    );
  }
}
