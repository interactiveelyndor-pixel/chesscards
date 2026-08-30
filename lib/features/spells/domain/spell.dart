import 'spell_target_type.dart';

abstract class Spell {
  final String id;
  final String name;
  final String description;
  final int manaCost;
  final SpellTargetType targetType;
  final String icon;

  const Spell({
    required this.id,
    required this.name,
    required this.description,
    required this.manaCost,
    required this.targetType,
    required this.icon,
  });
}
