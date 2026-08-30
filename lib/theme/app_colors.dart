import 'package:flutter/material.dart';

class AppColors {
  // Core backgrounds
  static const Color abyssBlack      = Color(0xFF06060E);
  static const Color hauntedCharcoal = Color(0xFF0F0F1A);
  static const Color deepVoid        = Color(0xFF161625);
  static const Color voidPanel       = Color(0xFF12121E);

  // Accent colors
  static const Color cursePurple   = Color(0xFF9D4EDD);
  static const Color cursePurpleLight = Color(0xFFBB77FF);
  static const Color bloodWine     = Color(0xFFC1121F);
  static const Color bloodWineDark = Color(0xFF7B0000);
  static const Color ghostBlue     = Color(0xFF00B4D8);
  static const Color ghostBlueDark = Color(0xFF006080);
  static const Color spectralGreen = Color(0xFF2DC653);
  static const Color runeGold      = Color(0xFFD4AF37);
  static const Color runeGoldDim   = Color(0xFF8A6F20);
  static const Color soulFlame     = Color(0xFFFF5500);

  // Neutral/text
  static const Color candleIvory   = Color(0xFFF5EDD6);
  static const Color fogGray       = Color(0xFF6E6E8A);
  static const Color dimGray       = Color(0xFF2E2E45);

  // Kept for backwards compat
  static const Color emeraldHeal   = Color(0xFF2DC653);

  // Gradients
  static const List<Color> purpleGlow   = [Color(0xFF9D4EDD), Color(0xFF5A0089)];
  static const List<Color> redGlow      = [Color(0xFFC1121F), Color(0xFF7B0000)];
  static const List<Color> cyanGlow     = [Color(0xFF00B4D8), Color(0xFF006080)];
  static const List<Color> goldGlow     = [Color(0xFFD4AF37), Color(0xFF8A6F20)];

  // Glassmorphism helpers
  static Color glass(double opacity) => Color.fromRGBO(15, 15, 26, opacity);
}
