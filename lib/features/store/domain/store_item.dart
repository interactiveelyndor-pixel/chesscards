import 'package:flutter/material.dart';

enum StoreItemType { doll, cardPack, boardTheme, currency }

class StoreItem {
  final String id;
  final String name;
  final String description;
  final StoreItemType type;
  final int? soulCost;
  final int? goldCost;
  final IconData iconData;

  const StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.soulCost,
    this.goldCost,
    required this.iconData,
  });

  bool get isPremium => soulCost != null;
}
