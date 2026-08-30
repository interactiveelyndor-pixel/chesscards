import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../domain/spell.dart';
import 'widgets/gothic_spell_card.dart';

class SpellScrollBar extends StatelessWidget {
  final List<Spell> spells;
  final int currentMana;
  final Spell? selectedSpell;
  final ValueChanged<Spell> onSpellTap;

  const SpellScrollBar({
    super.key,
    required this.spells,
    required this.currentMana,
    required this.selectedSpell,
    required this.onSpellTap,
  });

  @override
  Widget build(BuildContext context) {
    if (spells.isEmpty) {
      return Container(
        height: 90,
        alignment: Alignment.center,
        child: Text(
          'Spellbook is depleted... Mana gathers each turn.',
          style: GoogleFonts.cinzel(
            color: Colors.white38,
            fontStyle: FontStyle.italic,
            fontSize: 12,
          ),
        ),
      );
    }

    return SizedBox(
      height: 114,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        itemCount: spells.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final spell = spells[index];
          final isSelected = selectedSpell?.id == spell.id;
          final canCast = currentMana >= spell.manaCost;

          return GothicSpellCard(
            spell: spell,
            isSelected: isSelected,
            canCast: canCast,
            onTap: () => onSpellTap(spell),
          );
        },
      ),
    );
  }
}
