import 'relic.dart';

class RelicInventory {
  final List<Relic> relics;

  const RelicInventory({
    this.relics = const [],
  });

  RelicInventory copyWith({
    List<Relic>? relics,
  }) {
    return RelicInventory(
      relics: relics ?? this.relics,
    );
  }

  RelicInventory addRelic(Relic relic) {
    return RelicInventory(relics: [...relics, relic]);
  }

  RelicInventory removeRelic(String relicId) {
    final list = List<Relic>.from(relics);
    final idx = list.indexWhere((r) => r.id == relicId);
    if (idx != -1) {
      list.removeAt(idx);
    }
    return RelicInventory(relics: list);
  }
}
