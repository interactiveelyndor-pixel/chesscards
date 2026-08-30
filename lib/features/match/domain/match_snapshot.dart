import 'game_state.dart';
import '../../spells/domain/spellbook.dart';
import '../../relics/domain/relic_inventory.dart';
import 'turn_phase.dart';

class MatchSnapshot {
  final GameState gameState;
  final Spellbook whiteSpellbook;
  final Spellbook blackSpellbook;
  final RelicInventory whiteRelics;
  final RelicInventory blackRelics;
  final TurnPhase phase;

  const MatchSnapshot({
    required this.gameState,
    required this.whiteSpellbook,
    required this.blackSpellbook,
    required this.whiteRelics,
    required this.blackRelics,
    required this.phase,
  });
}
