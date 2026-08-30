import 'dart:math';
import 'relic.dart';

class BootsOfHasteRelic extends Relic {
  const BootsOfHasteRelic()
      : super(
          id: 'relic_boots_of_haste',
          name: 'Boots of Haste',
          description: 'Equipped piece can advance 2 squares forward at any time.',
          icon: '🥾',
        );
}

class AegisShieldRelic extends Relic {
  const AegisShieldRelic()
      : super(
          id: 'relic_aegis_shield',
          name: 'Aegis Shield',
          description: 'Absorbs the first lethal blow, saving the piece from capture.',
          icon: '🛡️',
        );
}

class SniperBowRelic extends Relic {
  const SniperBowRelic()
      : super(
          id: 'relic_sniper_bow',
          name: "Sniper's Bow",
          description: 'Allows piece to strike diagonally or straight through obstacles.',
          icon: '🏹',
        );
}

class RingOfManaRelic extends Relic {
  const RingOfManaRelic()
      : super(
          id: 'relic_ring_of_mana',
          name: 'Ring of Mana',
          description: 'Generates +1 extra Mana at the start of every turn.',
          icon: '💍',
        );
}

class RelicPool {
  static final List<Relic> allRelics = [
    const BootsOfHasteRelic(),
    const AegisShieldRelic(),
    const SniperBowRelic(),
    const RingOfManaRelic(),
  ];

  static Relic getRandomRelic() {
    final random = Random();
    return allRelics[random.nextInt(allRelics.length)];
  }
}
