import 'dart:math';
import '../../board/domain/board_position.dart';
import '../../board/domain/game_board.dart';
import '../../match/domain/match_state.dart';
import '../../pieces/domain/chess_piece.dart';
import '../../../shared/enums/piece_color.dart';
import '../../../shared/enums/piece_type.dart';
import 'spell.dart';
import 'spells.dart';
import 'spell_target_type.dart';

class SpellEngine {
  static final List<Spell> allSpells = [
    const FireballSpell(),
    const FreezeSpell(),
    const BlizzardSpell(),
    const WallOfStoneSpell(),
    const SoulLeechSpell(),
    const LightningSpell(),
    const NecromancySpell(),
  ];

  static Spell getRandomSpell() {
    final random = Random();
    return allSpells[random.nextInt(allSpells.length)];
  }

  static Set<BoardPosition> getValidTargets(
    Spell spell,
    GameBoard board,
    PieceColor playerColor,
  ) {
    final targets = <BoardPosition>{};
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final pos = BoardPosition(r, c);
        final piece = board.pieceAt(pos);

        switch (spell.targetType) {
          case SpellTargetType.none:
            break;
          case SpellTargetType.alliedPiece:
            if (piece != null && piece.color == playerColor) {
              targets.add(pos);
            }
            break;
          case SpellTargetType.enemyPiece:
            if (piece != null && piece.color != playerColor) {
              if ((spell.id == 'spell_fireball' || spell.id == 'spell_lightning') &&
                  (piece.type == PieceType.king || piece.type == PieceType.queen)) {
                break;
              }
              targets.add(pos);
            }
            break;
          case SpellTargetType.anyPiece:
            if (piece != null) {
              targets.add(pos);
            }
            break;
          case SpellTargetType.emptyTile:
            if (piece == null) {
              targets.add(pos);
            }
            break;
          case SpellTargetType.twoPieces:
            // First step: pick allied piece
            if (piece != null && piece.color == playerColor) {
              targets.add(pos);
            }
            break;
        }
      }
    }
    return targets;
  }

  static MatchState applySpell({
    required MatchState state,
    required Spell spell,
    required PieceColor casterColor,
    BoardPosition? target,
    BoardPosition? secondaryTarget,
  }) {
    final spellbook = casterColor == PieceColor.white ? state.whiteSpellbook : state.blackSpellbook;
    if (spellbook.mana < spell.manaCost) {
      return state;
    }

    final newBoard = state.gameState.board.clone();
    int manaDrained = 0;

    switch (spell.id) {
      case 'spell_fireball':
      case 'spell_lightning':
        if (target != null) {
          final piece = newBoard.pieceAt(target);
          if (piece != null &&
              piece.color != casterColor &&
              piece.type != PieceType.king &&
              piece.type != PieceType.queen) {
            if (piece.equipment.any((r) => r.id == 'relic_aegis_shield')) {
              // Aegis Shield absorbs the lethal spell!
              final updatedEq = piece.equipment.where((r) => r.id != 'relic_aegis_shield').toList();
              newBoard.setPiece(target, piece.copyWith(equipment: updatedEq));
            } else {
              newBoard.setPiece(target, null);
            }
          }
        }
        break;

      case 'spell_freeze':
        if (target != null) {
          final piece = newBoard.pieceAt(target);
          if (piece != null) {
            newBoard.setPiece(target, piece.copyWith(isFrozen: true));
          }
        }
        break;

      case 'spell_blizzard':
        if (target != null) {
          for (int dr = -1; dr <= 1; dr++) {
            for (int dc = -1; dc <= 1; dc++) {
              final pos = target.offset(dr, dc);
              if (pos.isValid) {
                final piece = newBoard.pieceAt(pos);
                if (piece != null && piece.color != casterColor) {
                  newBoard.setPiece(pos, piece.copyWith(isFrozen: true));
                }
              }
            }
          }
        }
        break;

      case 'spell_wall_of_stone':
        if (target != null && newBoard.pieceAt(target) == null) {
          // Impassable stone barrier
          newBoard.setPiece(
            target,
            ChessPiece(
              type: PieceType.rook,
              color: casterColor,
              isFrozen: true,
            ),
          );
        }
        break;

      case 'spell_teleport':
        if (target != null && secondaryTarget != null) {
          final piece = newBoard.pieceAt(target);
          if (piece != null && newBoard.pieceAt(secondaryTarget) == null) {
            newBoard.setPiece(secondaryTarget, piece);
            newBoard.setPiece(target, null);
          }
        }
        break;

      case 'spell_soul_leech':
        if (target != null) {
          final piece = newBoard.pieceAt(target);
          if (piece != null) {
            manaDrained = 2;
          }
        }
        break;

      case 'spell_necromancy':
        if (target != null && newBoard.pieceAt(target) == null) {
          final graveyard = (state.gameState.cardMetadata['graveyard_${casterColor.name}'] as List<dynamic>?)
              ?.cast<ChessPiece>();
          final pieceToRevive = (graveyard != null && graveyard.isNotEmpty)
              ? graveyard.last.copyWith(isFrozen: false)
              : ChessPiece(type: PieceType.pawn, color: casterColor);
          newBoard.setPiece(target, pieceToRevive);
        }
        break;
    }

    // Deduct mana and remove used spell from spellbook
    final currentSpells = List<Spell>.from(spellbook.spells);
    final spellIdx = currentSpells.indexWhere((s) => s.id == spell.id);
    if (spellIdx != -1) {
      currentSpells.removeAt(spellIdx);
    }

    // Opponent spellbook mana siphoning
    final oppColor = casterColor.opposite;
    var oppSpellbook = oppColor == PieceColor.white ? state.whiteSpellbook : state.blackSpellbook;
    if (manaDrained > 0) {
      final actualDrain = min(manaDrained, oppSpellbook.mana);
      oppSpellbook = oppSpellbook.copyWith(
        mana: max(0, oppSpellbook.mana - actualDrain),
      );
      manaDrained = actualDrain;
    }

    final newMana = (spellbook.mana - spell.manaCost + manaDrained).clamp(0, spellbook.maxMana);
    final updatedSpellbook = spellbook.copyWith(
      spells: currentSpells,
      mana: newMana,
    );

    final newGameState = state.gameState.copyWith(board: newBoard);

    return state.copyWith(
      gameState: newGameState,
      whiteSpellbook: casterColor == PieceColor.white ? updatedSpellbook : oppSpellbook,
      blackSpellbook: casterColor == PieceColor.black ? updatedSpellbook : oppSpellbook,
      lastPlayedSpell: spell,
      lastSpellTarget: target,
    );
  }
}
