abstract class Relic {
  final String id;
  final String name;
  final String description;
  final String icon;

  const Relic({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Relic && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
