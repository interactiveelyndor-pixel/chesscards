import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static final TextStyle displayLarge = GoogleFonts.creepster(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: 2.0,
  );

  static final TextStyle titleLarge = GoogleFonts.cinzel(
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle titleMedium = GoogleFonts.cinzel(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
}
