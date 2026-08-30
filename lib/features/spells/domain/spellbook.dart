import 'spell.dart';

class Spellbook {
  final List<Spell> spells;
  final int mana;
  final int maxMana;

  const Spellbook({
    this.spells = const [],
    this.mana = 1,
    this.maxMana = 10,
  });

  Spellbook copyWith({
    List<Spell>? spells,
    int? mana,
    int? maxMana,
  }) {
    return Spellbook(
      spells: spells ?? this.spells,
      mana: mana ?? this.mana,
      maxMana: maxMana ?? this.maxMana,
    );
  }

  bool canAfford(Spell spell) {
    return mana >= spell.manaCost;
  }

  Spellbook addSpell(Spell spell) {
    if (spells.length >= 6) return this; // Hand limit of 6 spells
    return copyWith(spells: [...spells, spell]);
  }

  Spellbook removeSpell(String spellId) {
    final list = List<Spell>.from(spells);
    final idx = list.indexWhere((s) => s.id == spellId);
    if (idx != -1) {
      list.removeAt(idx);
    }
    return copyWith(spells: list);
  }

  Spellbook gainMana(int amount) {
    return copyWith(mana: (mana + amount).clamp(0, maxMana));
  }
}
