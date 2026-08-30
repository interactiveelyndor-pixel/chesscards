import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:super_chess/core/audio/audio_enums.dart';
import 'package:super_chess/core/audio/audio_service.dart';
import 'package:super_chess/theme/app_colors.dart';
import 'package:super_chess/shared/widgets/gothic_background.dart';
import 'package:super_chess/shared/widgets/gothic_button.dart';
import 'package:super_chess/features/board/domain/board_position.dart';
import 'package:super_chess/features/board/presentation/models/board_tile.dart';
import 'package:super_chess/features/board/presentation/widgets/isometric_board_widget.dart';
import 'package:super_chess/features/match/domain/chess_engine.dart';
import 'package:super_chess/features/match/domain/game_state.dart';
import 'package:super_chess/features/match/domain/game_status.dart';
import 'package:super_chess/features/spells/domain/spell.dart';
import 'package:super_chess/features/spells/domain/spell_engine.dart';
import 'package:super_chess/features/spells/presentation/mana_bar_widget.dart';
import 'package:super_chess/features/spells/presentation/spell_scroll_bar.dart';
import 'package:super_chess/features/match/domain/chess_move.dart';
import '../application/daily_controller.dart';
import '../domain/daily_puzzle.dart';
import 'package:super_chess/shared/enums/piece_color.dart';

class DailyNightmarePuzzleScreen extends ConsumerStatefulWidget {
  final String? initialPuzzleId;
  const DailyNightmarePuzzleScreen({super.key, this.initialPuzzleId});

  @override
  ConsumerState<DailyNightmarePuzzleScreen> createState() =>
      _DailyNightmarePuzzleScreenState();
}

class _DailyNightmarePuzzleScreenState
    extends ConsumerState<DailyNightmarePuzzleScreen> {
  late DailyPuzzle _puzzle;
  late GameState _gameState;
  late int _mana;
  BoardPosition? _selectedTile;
  Set<BoardPosition> _highlightedMoves = {};
  Spell? _selectedSpell;
  Set<BoardPosition> _validSpellTargets = {};
  bool _isVictory = false;
  bool _isDefeat = false;
  int _nightmareStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadPuzzle(widget.initialPuzzleId != null
        ? DailyPuzzle.getPuzzleById(widget.initialPuzzleId!)
        : DailyPuzzle.getTodayPuzzle());
  }

  void _loadPuzzle(DailyPuzzle puzzle) {
    setState(() {
      _puzzle = puzzle;
      _gameState = puzzle.initialGameState;
      _mana = puzzle.manaGiven;
      _selectedTile = null;
      _highlightedMoves = {};
      _selectedSpell = null;
      _validSpellTargets = {};
      _isVictory = false;
      _isDefeat = false;
    });
  }

  void _resetCurrentPuzzle() {
    _loadPuzzle(_puzzle);
  }

  void _nextNightmarePuzzle() {
    final next = DailyPuzzle.getRandomNightmarePuzzle(_puzzle.id);
    _loadPuzzle(next);
  }

  void _onTileTap(BoardTile tile) {
    if (_isVictory || _isDefeat) return;

    final pos = BoardPosition(tile.row, tile.col);

    if (_selectedSpell != null) {
      if (_validSpellTargets.contains(pos)) {
        _castSpell(_selectedSpell!, pos);
      } else {
        setState(() {
          _selectedSpell = null;
          _validSpellTargets = {};
        });
      }
      return;
    }

    final piece = _gameState.board.pieceAt(pos);

    if (_selectedTile == null) {
      if (piece != null && piece.color == PieceColor.white) {
        final legalMoves = ChessEngine.generateLegalMoves(_gameState, pos);
        setState(() {
          _selectedTile = pos;
          _highlightedMoves = legalMoves.map((m) => m.to).toSet();
        });
      }
    } else {
      if (_highlightedMoves.contains(pos)) {
        _executeMove(_selectedTile!, pos);
      } else {
        if (piece != null && piece.color == PieceColor.white) {
          final legalMoves = ChessEngine.generateLegalMoves(_gameState, pos);
          setState(() {
            _selectedTile = pos;
            _highlightedMoves = legalMoves.map((m) => m.to).toSet();
          });
        } else {
          setState(() {
            _selectedTile = null;
            _highlightedMoves = {};
          });
        }
      }
    }
  }

  void _selectSpell(Spell spell) {
    if (_isVictory || _isDefeat) return;
    if (_mana < spell.manaCost) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'NOT ENOUGH MANA',
            style: GoogleFonts.cinzel(color: AppColors.runeGold, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF1B0B00),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    final targets = SpellEngine.getValidTargets(
      spell,
      _gameState.board,
      PieceColor.white,
    );

    setState(() {
      _selectedSpell = spell;
      _validSpellTargets = targets;
      _selectedTile = null;
      _highlightedMoves = {};
    });
  }

  void _castSpell(Spell spell, BoardPosition target) {
    HapticFeedback.mediumImpact();
    ref.read(audioServiceProvider).playSfx(SfxType.cardPlay);

    final newBoard = _gameState.board.clone();
    final targetPiece = newBoard.pieceAt(target);

    if (spell.id == 'spell_freeze' && targetPiece != null) {
      newBoard.setPiece(target, targetPiece.copyWith(isFrozen: true));
    } else if (spell.id == 'spell_fireball') {
      newBoard.setPiece(target, null);
    }

    final updatedGameState = _gameState.copyWith(board: newBoard);

    setState(() {
      _gameState = updatedGameState;
      _mana -= spell.manaCost;
      _selectedSpell = null;
      _validSpellTargets = {};
    });
  }

  void _executeMove(BoardPosition from, BoardPosition to) {
    final piece = _gameState.board.pieceAt(from);
    if (piece == null) return;

    final move = ChessMove(from: from, to: to, movedPiece: piece);
    final isWinning = _puzzle.winningMoves.any((w) => w.from == from && w.to == to);

    final newGameState = ChessEngine.makeMove(_gameState, move);

    setState(() {
      _gameState = newGameState;
      _selectedTile = null;
      _highlightedMoves = {};
    });

    if (isWinning || newGameState.status == GameStatus.checkmate) {
      // VICTORY!
      HapticFeedback.heavyImpact();
      ref.read(audioServiceProvider).playSfx(SfxType.checkmate);
      ref.read(dailyControllerProvider.notifier).completeEndlessPuzzle(_puzzle);

      setState(() {
        _isVictory = true;
        _nightmareStreak += 1;
      });
    } else {
      // DEFEAT / WRONG MOVE
      HapticFeedback.vibrate();
      ref.read(audioServiceProvider).playSfx(SfxType.error);
      setState(() {
        _isDefeat = true;
        _nightmareStreak = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GothicBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // ── Top Bar ───────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.candleIvory),
                          onPressed: () => context.pop(),
                        ),
                        Column(
                          children: [
                            Text(
                              _puzzle.title.toUpperCase(),
                              style: GoogleFonts.cinzelDecorative(
                                color: AppColors.runeGold,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7B2CBF).withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFF9D4EDD), width: 1),
                                  ),
                                  child: Text(
                                    _puzzle.tier.name.toUpperCase(),
                                    style: GoogleFonts.cinzel(
                                      color: const Color(0xFFE0AAFF),
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (_nightmareStreak > 0) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    'STREAK: $_nightmareStreak 🔥',
                                    style: GoogleFonts.cinzel(
                                      color: const Color(0xFFFF9E00),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, color: AppColors.runeGold),
                          onPressed: _resetCurrentPuzzle,
                          tooltip: 'Reset Puzzle',
                        ),
                      ],
                    ),
                  ),

                  // ── Objective & Lore Banner ──────────────────────────────
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B0B00),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDC2F02), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFFFF9E00), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _puzzle.objective,
                            style: GoogleFonts.cinzel(
                              color: AppColors.candleIvory,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Chess Board Area ─────────────────────────────────────
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: IsometricBoardWidget(
                          gameState: _gameState,
                          selectedTile: _selectedTile != null
                              ? BoardTile(_selectedTile!.row, _selectedTile!.col)
                              : null,
                          highlightedMoves: _highlightedMoves,
                          validSpellTargets: _validSpellTargets,
                          onTileTap: _onTileTap,
                        ),
                      ),
                    ),
                  ),

                  // ── Bottom Spell Hand & Mana ─────────────────────────────
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF140700),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF7B2CBF), width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ARCANE HAND',
                              style: GoogleFonts.cinzel(
                                color: AppColors.candleIvory,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ManaBarWidget(currentMana: _mana, maxMana: _puzzle.manaGiven),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SpellScrollBar(
                          spells: _puzzle.spellsGiven,
                          currentMana: _mana,
                          selectedSpell: _selectedSpell,
                          onSpellTap: _selectSpell,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ── Victory Modal with Next Puzzle ────────────────────────────
              if (_isVictory)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.85),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B0B00),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.runeGold, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.runeGold.withValues(alpha: 0.3),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.workspace_premium, color: AppColors.runeGold, size: 52),
                            const SizedBox(height: 12),
                            Text(
                              'NIGHTMARE CONQUERED',
                              style: GoogleFonts.cinzelDecorative(
                                color: AppColors.runeGold,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '+${_puzzle.soulReward} Lost Souls & +${_puzzle.xpReward} XP Earned!',
                              style: GoogleFonts.cinzel(color: AppColors.candleIvory, fontSize: 12),
                            ),
                            const SizedBox(height: 20),
                            GothicButton(
                              label: 'NEXT HARDCORE CHALLENGE',
                              icon: Icons.skip_next_rounded,
                              isPrimary: true,
                              glowColor: const Color(0xFFFF9E00),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF9E00), Color(0xFF8B4500)],
                              ),
                              onTap: _nextNightmarePuzzle,
                            ),
                            const SizedBox(height: 10),
                            GothicButton(
                              label: 'RETURN TO HUB',
                              icon: Icons.arrow_back_rounded,
                              isPrimary: false,
                              glowColor: AppColors.fogGray,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF381500), Color(0xFF140700)],
                              ),
                              onTap: () => context.pop(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Defeat Modal ──────────────────────────────────────────────
              if (_isDefeat)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.85),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E0202),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFDC2F02), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFDC2F02).withValues(alpha: 0.3),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.dangerous_outlined, color: Color(0xFFDC2F02), size: 52),
                            const SizedBox(height: 12),
                            Text(
                              'THE ABYSS CONSUMES YOU',
                              style: GoogleFonts.cinzelDecorative(
                                color: const Color(0xFFDC2F02),
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Incorrect tactical move. The spirits reclaim their ground.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cinzel(color: AppColors.fogGray, fontSize: 11),
                            ),
                            const SizedBox(height: 20),
                            GothicButton(
                              label: 'TRY AGAIN',
                              icon: Icons.refresh_rounded,
                              isPrimary: true,
                              glowColor: const Color(0xFFDC2F02),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF9D0208), Color(0xFF370617)],
                              ),
                              onTap: _resetCurrentPuzzle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
