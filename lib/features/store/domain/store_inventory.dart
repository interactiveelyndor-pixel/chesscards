import 'package:flutter/material.dart';
import 'store_item.dart';

class StoreInventory {
  static const List<StoreItem> featuredItems = [
    StoreItem(
      id: 'pack_haunted_doll',
      name: 'HAUNTED DOLL PACK',
      description: 'Unlock 3 rare cursed dolls.',
      type: StoreItemType.cardPack,
      soulCost: 499,
      iconData: Icons.card_giftcard,
    ),
    StoreItem(
      id: 'pack_curse_card',
      name: 'CURSE CARD PACK',
      description: 'A pack of 5 random curse cards.',
      type: StoreItemType.cardPack,
      goldCost: 299,
      iconData: Icons.card_giftcard,
    ),
    StoreItem(
      id: 'currency_gold_pack',
      name: 'GOLD COINS PACK',
      description: 'Get 500 Gold Coins instantly.',
      type: StoreItemType.currency,
      soulCost: 199,
      iconData: Icons.monetization_on,
    ),
  ];

  static const List<StoreItem> dollItems = [
    StoreItem(
      id: 'doll_crimson_wraith',
      name: 'CRIMSON WRAITH',
      description: 'A doll steeped in ancient blood rituals.',
      type: StoreItemType.doll,
      soulCost: 1200,
      iconData: Icons.face,
    ),
    StoreItem(
      id: 'doll_abyssal_shade',
      name: 'ABYSSAL SHADE',
      description: 'Forged from the deepest shadows.',
      type: StoreItemType.doll,
      goldCost: 850,
      iconData: Icons.face_retouching_natural,
    ),
    StoreItem(
      id: 'doll_golden_effigy',
      name: 'GOLDEN EFFIGY',
      description: 'A symbol of pure, blinding light.',
      type: StoreItemType.doll,
      soulCost: 2500,
      iconData: Icons.face_2,
    ),
  ];

  static const List<StoreItem> cardItems = [
    StoreItem(
      id: 'card_oblivion',
      name: 'OBLIVION CARD',
      description: 'A single, ultra-rare card to annihilate foes.',
      type: StoreItemType.cardPack,
      soulCost: 800,
      iconData: Icons.style,
    ),
    StoreItem(
      id: 'card_deck_expansion',
      name: 'DECK EXPANSION',
      description: 'Increase your maximum deck size by 5.',
      type: StoreItemType.cardPack,
      goldCost: 1500,
      iconData: Icons.library_add,
    ),
  ];

  static const List<StoreItem> boardItems = [
    StoreItem(
      id: 'board_blood_moon',
      name: 'BLOOD MOON THEME',
      description: 'Bathe the battlefield in a crimson glow.',
      type: StoreItemType.boardTheme,
      soulCost: 1500,
      iconData: Icons.grid_on,
    ),
    StoreItem(
      id: 'board_void_marble',
      name: 'VOID MARBLE THEME',
      description: 'Sleek, cold, unforgiving marble.',
      type: StoreItemType.boardTheme,
      goldCost: 2000,
      iconData: Icons.grid_view,
    ),
  ];

  static const List<StoreItem> currencies = [
    StoreItem(
      id: 'currency_soul_shard',
      name: '100 SOUL FRAGMENTS',
      description: 'Purchase premium currency.',
      type: StoreItemType.currency,
      goldCost: 1000,
      iconData: Icons.diamond,
    ),
  ];

  static List<StoreItem> getItemsByType(StoreItemType type) {
    return {
      ...featuredItems.where((i) => i.type == type),
      ...dollItems.where((i) => i.type == type),
      ...cardItems.where((i) => i.type == type),
      ...boardItems.where((i) => i.type == type),
      ...currencies.where((i) => i.type == type),
    }.toList(); // Remove duplicates
  }
}
