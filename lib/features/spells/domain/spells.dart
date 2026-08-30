import 'spell.dart';
import 'spell_target_type.dart';

class FireballSpell extends Spell {
  const FireballSpell()
      : super(
          id: 'spell_fireball',
          name: 'Fireball',
          description: 'Hurls a ball of fire to destroy an enemy piece (excludes King & Queen).',
          manaCost: 7,
          targetType: SpellTargetType.enemyPiece,
          icon: '🔥',
        );
}

class TeleportSpell extends Spell {
  const TeleportSpell()
      : super(
          id: 'spell_teleport',
          name: 'Teleport',
          description: 'Instantly warp an allied piece to any empty square.',
          manaCost: 3,
          targetType: SpellTargetType.twoPieces, // First allied piece, then empty tile
          icon: '🌀',
        );
}

class FreezeSpell extends Spell {
  const FreezeSpell()
      : super(
          id: 'spell_freeze',
          name: 'Frost Bind',
          description: 'Encase an enemy piece in ice, preventing it from moving next turn.',
          manaCost: 2,
          targetType: SpellTargetType.enemyPiece,
          icon: '❄️',
        );
}

class BlizzardSpell extends Spell {
  const BlizzardSpell()
      : super(
          id: 'spell_blizzard',
          name: 'Blizzard',
          description: 'Summons a roaring blizzard that freezes all enemies in a 3x3 zone.',
          manaCost: 5,
          targetType: SpellTargetType.emptyTile,
          icon: '🌨️',
        );
}

class WallOfStoneSpell extends Spell {
  const WallOfStoneSpell()
      : super(
          id: 'spell_wall_of_stone',
          name: 'Wall of Stone',
          description: 'Conjure an impassable stone barrier on an empty tile.',
          manaCost: 2,
          targetType: SpellTargetType.emptyTile,
          icon: '🧱',
        );
}

class SoulLeechSpell extends Spell {
  const SoulLeechSpell()
      : super(
          id: 'spell_soul_leech',
          name: 'Soul Leech',
          description: 'Drain the life essence of an enemy, stealing 2 Mana.',
          manaCost: 1,
          targetType: SpellTargetType.enemyPiece,
          icon: '🩸',
        );
}

class LightningSpell extends Spell {
  const LightningSpell()
      : super(
          id: 'spell_lightning',
          name: 'Lightning Strike',
          description: 'Strike an enemy piece directly (excludes King & Queen).',
          manaCost: 7,
          targetType: SpellTargetType.enemyPiece,
          icon: '⚡',
        );
}

class NecromancySpell extends Spell {
  const NecromancySpell()
      : super(
          id: 'spell_necromancy',
          name: 'Necromancy',
          description: 'Raise a fallen ally piece from the grave onto an empty tile.',
          manaCost: 4,
          targetType: SpellTargetType.emptyTile,
          icon: '💀',
        );
}
