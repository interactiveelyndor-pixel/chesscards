import 'package:flutter/material.dart';
import 'store_item.dart';

class StoreInventory {
  static const List<StoreItem> boardItems = [
    StoreItem(
      id: 'board_crimson_crypt',
      name: 'CRIMSON CRYPT',
      description: 'Classic gothic mahogany & bone ivory tiles illuminated by eerie candlelight.',
      type: StoreItemType.boardTheme,
      goldCost: 0,
      soulCost: 0,
      iconData: Icons.castle_rounded,
    ),
    StoreItem(
      id: 'board_void_marble',
      name: 'VOID MARBLE',
      description: 'Polished ethereal moonstone and dark cosmic abyss tiles laced with glowing astral cyan ink.',
      type: StoreItemType.boardTheme,
      goldCost: 1200,
      soulCost: 300,
      iconData: Icons.auto_awesome_mosaic_rounded,
    ),
    StoreItem(
      id: 'board_emerald_necropolis',
      name: 'EMERALD NECROPOLIS',
      description: 'Spectral phantom jade and ancient slate tiles with ghost-fire emerald etchings.',
      type: StoreItemType.boardTheme,
      goldCost: 2000,
      soulCost: 500,
      iconData: Icons.blur_on_rounded,
    ),
    StoreItem(
      id: 'board_infernal_magma',
      name: 'INFERNAL MAGMA',
      description: 'Charred volcanic ash and molten magma rock with burning hellfire amber accents.',
      type: StoreItemType.boardTheme,
      goldCost: 3500,
      soulCost: 800,
      iconData: Icons.local_fire_department_rounded,
    ),
  ];

  static const List<StoreItem> dollItems = [
    StoreItem(
      id: 'doll_crimson_wraith',
      name: 'CRIMSON WRAITH',
      description: 'A cursed commander steeped in ancient blood rituals (+15% Spell Crit aura).',
      type: StoreItemType.doll,
      goldCost: 1500,
      soulCost: 400,
      iconData: Icons.face_sharp,
    ),
    StoreItem(
      id: 'doll_abyssal_shade',
      name: 'ABYSSAL SHADE',
      description: 'Forged from the deepest cosmic shadows (+2 starting Mana).',
      type: StoreItemType.doll,
      goldCost: 2200,
      soulCost: 600,
      iconData: Icons.face_retouching_natural,
    ),
    StoreItem(
      id: 'doll_golden_effigy',
      name: 'GOLDEN EFFIGY',
      description: 'A symbol of blinding celestial power (+10 HP Commander barrier).',
      type: StoreItemType.doll,
      goldCost: 3500,
      soulCost: 1000,
      iconData: Icons.face_2,
    ),
  ];

  static const List<StoreItem> currencies = [
    StoreItem(
      id: 'currency_gold_pouch',
      name: 'GOLD POUCH (+500)',
      description: 'Exchange 150 Soul Fragments for a pouch of 500 Gold Coins.',
      type: StoreItemType.currency,
      soulCost: 150,
      iconData: Icons.monetization_on,
    ),
    StoreItem(
      id: 'currency_gold_chest',
      name: 'GOLD CHEST (+1,500)',
      description: 'Exchange 400 Soul Fragments for a massive chest of 1,500 Gold Coins.',
      type: StoreItemType.currency,
      soulCost: 400,
      iconData: Icons.savings_rounded,
    ),
    StoreItem(
      id: 'currency_soul_shard',
      name: 'SOUL SHARD (+100)',
      description: 'Transmute 800 Gold Coins into 100 Soul Fragments.',
      type: StoreItemType.currency,
      goldCost: 800,
      iconData: Icons.diamond_rounded,
    ),
  ];

  static List<StoreItem> getItemsByType(StoreItemType type) {
    switch (type) {
      case StoreItemType.boardTheme:
        return boardItems;
      case StoreItemType.doll:
        return dollItems;
      case StoreItemType.currency:
        return currencies;
      default:
        return [];
    }
  }
}
