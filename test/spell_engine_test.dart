import 'package:flutter_test/flutter_test.dart';
import 'package:super_chess/features/board/domain/board_position.dart';
import 'package:super_chess/features/match/domain/match_state.dart';
import 'package:super_chess/features/spells/domain/spells.dart';
import 'package:super_chess/features/spells/domain/spell_engine.dart';
import 'package:super_chess/shared/enums/piece_color.dart';

void main() {
  group('SpellEngine Tests', () {
    test('Fireball costs 7 mana and destroys regular enemy piece', () {
      final initialMatch = MatchState.initial().copyWith(
        whiteSpellbook: MatchState.initial().whiteSpellbook.copyWith(mana: 8),
      );
      const target = BoardPosition(1, 0); // Black pawn

      final updatedMatch = SpellEngine.applySpell(
        state: initialMatch,
        spell: const FireballSpell(),
        casterColor: PieceColor.white,
        target: target,
      );

      expect(updatedMatch.gameState.board.pieceAt(target), isNull);
      expect(updatedMatch.whiteSpellbook.mana, 1); // 8 - 7 = 1
    });

    test('Fireball cannot target King or Queen', () {
      final state = MatchState.initial();
      final validTargets = SpellEngine.getValidTargets(
        const FireballSpell(),
        state.gameState.board,
        PieceColor.white,
      );

      const blackKingPos = BoardPosition(0, 4);
      const blackQueenPos = BoardPosition(0, 3);
      const blackPawnPos = BoardPosition(1, 0);

      expect(validTargets.contains(blackKingPos), isFalse);
      expect(validTargets.contains(blackQueenPos), isFalse);
      expect(validTargets.contains(blackPawnPos), isTrue);
    });

    test('Freeze freezes enemy piece', () {
      final initialMatch = MatchState.initial();
      const target = BoardPosition(1, 0); // Black pawn

      final updatedMatch = SpellEngine.applySpell(
        state: initialMatch,
        spell: const FreezeSpell(),
        casterColor: PieceColor.white,
        target: target,
      );

      final piece = updatedMatch.gameState.board.pieceAt(target);
      expect(piece, isNotNull);
      expect(piece!.isFrozen, isTrue);
    });
  });
}
