import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../shared/enums/piece_color.dart';
import '../../../../shared/enums/piece_type.dart';
import '../../../pieces/domain/chess_piece.dart';

class HanddrawnPiecePainter {
  static void drawPiece({
    required Canvas canvas,
    required Offset center,
    required double size,
    required ChessPiece piece,
    double glowIntensity = 1.0,
  }) {
    final isWhite = piece.color == PieceColor.white;
    final isFrozen = piece.isFrozen;

    // Palette
    const Color inkColor = Color(0xFF110E18);
    final Color fillColor = isFrozen
        ? const Color(0xFFB2EBF2)
        : (isWhite ? const Color(0xFFF5EFEB) : const Color(0xFF282333));
    final Color shadeColor = isFrozen
        ? const Color(0xFF80DEEA)
        : (isWhite ? const Color(0xFFD6C7B8) : const Color(0xFF1A1624));
    final Color glowColor = isFrozen
        ? Colors.cyanAccent
        : (isWhite ? const Color(0xFF64B5F6) : const Color(0xFFFF5252));

    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final Paint shadePaint = Paint()
      ..color = shadeColor
      ..style = PaintingStyle.fill;

    final Paint inkPaint = Paint()
      ..color = inkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(2.0, size * 0.045)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint hatchPaint = Paint()
      ..color = inkColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.2, size * 0.025)
      ..strokeCap = StrokeCap.round;

    final Paint eyeGlowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 * glowIntensity);

    final Paint eyeCorePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);

    final double s = size * 0.45; // Unit scale (-s to +s)

    // Draw bottom shadow ellipse
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(Rect.fromCenter(center: Offset(0, s * 0.88), width: s * 1.5, height: s * 0.45), shadowPaint);

    switch (piece.type) {
      case PieceType.pawn:
        _drawPawn(canvas, s, fillPaint, shadePaint, inkPaint, hatchPaint, eyeGlowPaint, eyeCorePaint);
        break;
      case PieceType.knight:
        _drawKnight(canvas, s, fillPaint, shadePaint, inkPaint, hatchPaint, eyeGlowPaint, eyeCorePaint);
        break;
      case PieceType.bishop:
        _drawBishop(canvas, s, fillPaint, shadePaint, inkPaint, hatchPaint, eyeGlowPaint, eyeCorePaint);
        break;
      case PieceType.rook:
        _drawRook(canvas, s, fillPaint, shadePaint, inkPaint, hatchPaint, eyeGlowPaint, eyeCorePaint);
        break;
      case PieceType.queen:
        _drawQueen(canvas, s, fillPaint, shadePaint, inkPaint, hatchPaint, eyeGlowPaint, eyeCorePaint);
        break;
      case PieceType.king:
        _drawKing(canvas, s, fillPaint, shadePaint, inkPaint, hatchPaint, eyeGlowPaint, eyeCorePaint);
        break;
    }

    canvas.restore();
  }

  // --- ♟️ PAWN: Hooded Skeleton Sentry with Bone Dagger ---
  static void _drawPawn(Canvas canvas, double s, Paint fill, Paint shade, Paint ink, Paint hatch, Paint eyeGlow, Paint eyeCore) {
    // Body / Robe
    final Path body = Path()
      ..moveTo(-s * 0.45, s * 0.8)
      ..quadraticBezierTo(-s * 0.4, s * 0.1, -s * 0.25, -s * 0.1)
      ..lineTo(s * 0.25, -s * 0.1)
      ..quadraticBezierTo(s * 0.4, s * 0.1, s * 0.45, s * 0.8)
      ..quadraticBezierTo(0, s * 0.9, -s * 0.45, s * 0.8)
      ..close();
    canvas.drawPath(body, fill);
    canvas.drawPath(body, ink);

    // Cross-hatching on right side
    for (int i = 0; i < 4; i++) {
      final y = s * (0.2 + i * 0.15);
      canvas.drawLine(Offset(s * 0.1, y), Offset(s * 0.38, y - s * 0.08), hatch);
    }

    // Hood / Head
    final Path hood = Path()
      ..moveTo(0, -s * 0.85)
      ..quadraticBezierTo(s * 0.5, -s * 0.7, s * 0.38, -s * 0.1)
      ..quadraticBezierTo(0, -s * 0.05, -s * 0.38, -s * 0.1)
      ..quadraticBezierTo(-s * 0.5, -s * 0.7, 0, -s * 0.85)
      ..close();
    canvas.drawPath(hood, fill);
    canvas.drawPath(hood, ink);

    // Dark face cavity
    final Path faceHole = Path()
      ..addOval(Rect.fromCenter(center: Offset(0, -s * 0.4), width: s * 0.45, height: s * 0.38));
    canvas.drawPath(faceHole, Paint()..color = const Color(0xFF140F1E));
    canvas.drawPath(faceHole, ink);

    // Glowing Eyes
    canvas.drawCircle(Offset(-s * 0.1, -s * 0.4), s * 0.07, eyeGlow);
    canvas.drawCircle(Offset(-s * 0.1, -s * 0.4), s * 0.035, eyeCore);
    canvas.drawCircle(Offset(s * 0.1, -s * 0.4), s * 0.07, eyeGlow);
    canvas.drawCircle(Offset(s * 0.1, -s * 0.4), s * 0.035, eyeCore);
  }

  // --- ♞ KNIGHT: Stylized Horned Nightmare Steed ---
  static void _drawKnight(Canvas canvas, double s, Paint fill, Paint shade, Paint ink, Paint hatch, Paint eyeGlow, Paint eyeCore) {
    final Path horse = Path()
      ..moveTo(-s * 0.4, s * 0.8)
      ..quadraticBezierTo(-s * 0.5, s * 0.2, -s * 0.3, -s * 0.2) // Back neck
      ..lineTo(-s * 0.25, -s * 0.7) // Ear back
      ..lineTo(-s * 0.1, -s * 0.5) // Ear inside
      ..quadraticBezierTo(s * 0.2, -s * 0.8, s * 0.3, -s * 0.5) // Forehead / Snout top
      ..lineTo(s * 0.65, -s * 0.2) // Muzzle tip
      ..lineTo(s * 0.45, s * 0.05) // Muzzle bottom
      ..quadraticBezierTo(s * 0.1, -s * 0.05, s * 0.15, s * 0.3) // Throat
      ..quadraticBezierTo(s * 0.3, s * 0.55, s * 0.4, s * 0.8) // Chest
      ..close();

    canvas.drawPath(horse, fill);

    // Dark mane spikes
    final Path mane = Path()
      ..moveTo(-s * 0.3, -s * 0.2)
      ..lineTo(-s * 0.55, -s * 0.05)
      ..lineTo(-s * 0.35, s * 0.15)
      ..lineTo(-s * 0.6, s * 0.35)
      ..lineTo(-s * 0.38, s * 0.5)
      ..close();
    canvas.drawPath(mane, shade);
    canvas.drawPath(mane, ink);

    canvas.drawPath(horse, ink);

    // Horn / Jagged Crest
    final Path horn = Path()
      ..moveTo(s * 0.05, -s * 0.6)
      ..lineTo(s * 0.25, -s * 0.95)
      ..lineTo(s * 0.18, -s * 0.5)
      ..close();
    canvas.drawPath(horn, fill);
    canvas.drawPath(horn, ink);

    // Muzzle nostrils & jawline
    canvas.drawLine(Offset(s * 0.45, -s * 0.15), Offset(s * 0.55, -s * 0.12), ink);

    // Glowing Eye
    canvas.drawCircle(Offset(s * 0.15, -s * 0.35), s * 0.09, eyeGlow);
    canvas.drawCircle(Offset(s * 0.15, -s * 0.35), s * 0.045, eyeCore);

    // Cross-hatch neck shading
    canvas.drawLine(Offset(-s * 0.1, s * 0.2), Offset(s * 0.15, s * 0.1), hatch);
    canvas.drawLine(Offset(-s * 0.1, s * 0.35), Offset(s * 0.2, s * 0.25), hatch);
    canvas.drawLine(Offset(-s * 0.1, s * 0.5), Offset(s * 0.25, s * 0.4), hatch);
  }

  // --- ♝ BISHOP: Plague Doctor Occult Sorcerer ---
  static void _drawBishop(Canvas canvas, double s, Paint fill, Paint shade, Paint ink, Paint hatch, Paint eyeGlow, Paint eyeCore) {
    // Tall Robe
    final Path robe = Path()
      ..moveTo(-s * 0.45, s * 0.8)
      ..quadraticBezierTo(-s * 0.35, s * 0.1, -s * 0.2, -s * 0.2)
      ..lineTo(s * 0.2, -s * 0.2)
      ..quadraticBezierTo(s * 0.35, s * 0.1, s * 0.45, s * 0.8)
      ..close();
    canvas.drawPath(robe, fill);
    canvas.drawPath(robe, ink);

    // Occult Pointed Hat / Mitre
    final Path hat = Path()
      ..moveTo(-s * 0.35, -s * 0.2)
      ..quadraticBezierTo(-s * 0.1, -s * 0.6, 0, -s * 0.95)
      ..quadraticBezierTo(s * 0.1, -s * 0.6, s * 0.35, -s * 0.2)
      ..close();
    canvas.drawPath(hat, fill);
    canvas.drawPath(hat, ink);

    // Mitre Cross / Sigil
    canvas.drawLine(Offset(0, -s * 0.4), Offset(0, -s * 0.75), ink);
    canvas.drawLine(Offset(-s * 0.12, -s * 0.6), Offset(s * 0.12, -s * 0.6), ink);

    // Plague Beak / Mask
    final Path beak = Path()
      ..moveTo(-s * 0.15, -s * 0.2)
      ..quadraticBezierTo(0, -s * 0.05, s * 0.45, 0)
      ..quadraticBezierTo(0, s * 0.05, -s * 0.15, 0)
      ..close();
    canvas.drawPath(beak, shade);
    canvas.drawPath(beak, ink);

    // Goggle Eyes
    canvas.drawCircle(Offset(-s * 0.05, -s * 0.22), s * 0.08, eyeGlow);
    canvas.drawCircle(Offset(-s * 0.05, -s * 0.22), s * 0.04, eyeCore);

    // Staff in hand
    canvas.drawLine(Offset(-s * 0.35, -s * 0.6), Offset(-s * 0.35, s * 0.85), ink);
    canvas.drawCircle(Offset(-s * 0.35, -s * 0.65), s * 0.1, eyeGlow);
    canvas.drawCircle(Offset(-s * 0.35, -s * 0.65), s * 0.05, eyeCore);
  }

  // --- ♜ ROOK: Cracked Gothic Gargoyle Watchtower ---
  static void _drawRook(Canvas canvas, double s, Paint fill, Paint shade, Paint ink, Paint hatch, Paint eyeGlow, Paint eyeCore) {
    // Tower Base & Body
    final Path tower = Path()
      ..moveTo(-s * 0.5, s * 0.8)
      ..lineTo(-s * 0.38, -s * 0.3)
      ..lineTo(s * 0.38, -s * 0.3)
      ..lineTo(s * 0.5, s * 0.8)
      ..close();
    canvas.drawPath(tower, fill);
    canvas.drawPath(tower, ink);

    // Battlements (3 Crenels)
    final Path top = Path()
      ..moveTo(-s * 0.48, -s * 0.3)
      ..lineTo(-s * 0.48, -s * 0.75) // Left horn
      ..lineTo(-s * 0.25, -s * 0.75)
      ..lineTo(-s * 0.25, -s * 0.5) // Left gap
      ..lineTo(-s * 0.1, -s * 0.5)
      ..lineTo(-s * 0.1, -s * 0.75) // Center merlon
      ..lineTo(s * 0.1, -s * 0.75)
      ..lineTo(s * 0.1, -s * 0.5) // Right gap
      ..lineTo(s * 0.25, -s * 0.5)
      ..lineTo(s * 0.25, -s * 0.75)
      ..lineTo(s * 0.48, -s * 0.75) // Right horn
      ..lineTo(s * 0.48, -s * 0.3)
      ..close();
    canvas.drawPath(top, fill);
    canvas.drawPath(top, ink);

    // Iron Portcullis / Gate
    final Path gate = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, s * 0.45), width: s * 0.38, height: s * 0.55),
        const Radius.circular(8),
      ));
    canvas.drawPath(gate, Paint()..color = const Color(0xFF140F1E));
    canvas.drawPath(gate, ink);
    // Gate bars
    canvas.drawLine(Offset(-s * 0.08, s * 0.2), Offset(-s * 0.08, s * 0.7), ink);
    canvas.drawLine(Offset(s * 0.08, s * 0.2), Offset(s * 0.08, s * 0.7), ink);
    canvas.drawLine(Offset(-s * 0.16, s * 0.45), Offset(s * 0.16, s * 0.45), ink);

    // Glowing Arrow Slit
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, -s * 0.05), width: s * 0.1, height: s * 0.25), const Radius.circular(2)),
      eyeGlow,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, -s * 0.05), width: s * 0.04, height: s * 0.18), const Radius.circular(1)),
      eyeCore,
    );

    // Brickwork sketches
    canvas.drawLine(Offset(-s * 0.3, 0), Offset(-s * 0.12, 0), hatch);
    canvas.drawLine(Offset(s * 0.12, s * 0.1), Offset(s * 0.32, s * 0.1), hatch);
  }

  // --- ♛ QUEEN: Dark Sorceress Queen with Spiked Crown ---
  static void _drawQueen(Canvas canvas, double s, Paint fill, Paint shade, Paint ink, Paint hatch, Paint eyeGlow, Paint eyeCore) {
    // Voluminous Gothic Dress
    final Path dress = Path()
      ..moveTo(-s * 0.55, s * 0.8)
      ..quadraticBezierTo(-s * 0.4, s * 0.1, -s * 0.15, -s * 0.1)
      ..lineTo(s * 0.15, -s * 0.1)
      ..quadraticBezierTo(s * 0.4, s * 0.1, s * 0.55, s * 0.8)
      ..close();
    canvas.drawPath(dress, fill);
    canvas.drawPath(dress, ink);

    // Shadowy inner corset
    final Path corset = Path()
      ..moveTo(-s * 0.15, -s * 0.1)
      ..lineTo(s * 0.15, -s * 0.1)
      ..lineTo(s * 0.08, s * 0.35)
      ..lineTo(-s * 0.08, s * 0.35)
      ..close();
    canvas.drawPath(corset, shade);
    canvas.drawPath(corset, ink);

    // Spiked Crown
    final Path crown = Path()
      ..moveTo(-s * 0.4, -s * 0.4)
      ..lineTo(-s * 0.45, -s * 0.85) // Spike 1
      ..lineTo(-s * 0.22, -s * 0.55)
      ..lineTo(-s * 0.2, -s * 0.95) // Spike 2
      ..lineTo(0, -s * 0.6)
      ..lineTo(s * 0.2, -s * 0.95) // Spike 3
      ..lineTo(s * 0.22, -s * 0.55)
      ..lineTo(s * 0.45, -s * 0.85) // Spike 4
      ..lineTo(s * 0.4, -s * 0.4)
      ..close();
    canvas.drawPath(crown, fill);
    canvas.drawPath(crown, ink);

    // Crown Center Gem
    canvas.drawCircle(Offset(0, -s * 0.48), s * 0.08, eyeGlow);
    canvas.drawCircle(Offset(0, -s * 0.48), s * 0.04, eyeCore);

    // Face / Veil
    canvas.drawOval(Rect.fromCenter(center: Offset(0, -s * 0.25), width: s * 0.35, height: s * 0.3), Paint()..color = const Color(0xFF140F1E));
    canvas.drawOval(Rect.fromCenter(center: Offset(0, -s * 0.25), width: s * 0.35, height: s * 0.3), ink);

    // Glowing Eyes
    canvas.drawCircle(Offset(-s * 0.08, -s * 0.25), s * 0.06, eyeGlow);
    canvas.drawCircle(Offset(s * 0.08, -s * 0.25), s * 0.06, eyeGlow);

    // Floating Occult Orb
    canvas.drawCircle(Offset(s * 0.38, s * 0.1), s * 0.12, eyeGlow);
    canvas.drawCircle(Offset(s * 0.38, s * 0.1), s * 0.06, eyeCore);
  }

  // --- ♚ KING: Horned Monarch with Greatsword ---
  static void _drawKing(Canvas canvas, double s, Paint fill, Paint shade, Paint ink, Paint hatch, Paint eyeGlow, Paint eyeCore) {
    // Heavy Mantle / Armor
    final Path armor = Path()
      ..moveTo(-s * 0.55, s * 0.8)
      ..lineTo(-s * 0.45, s * 0.0) // Left pauldron
      ..lineTo(-s * 0.2, -s * 0.15)
      ..lineTo(s * 0.2, -s * 0.15)
      ..lineTo(s * 0.45, s * 0.0) // Right pauldron
      ..lineTo(s * 0.55, s * 0.8)
      ..close();
    canvas.drawPath(armor, fill);
    canvas.drawPath(armor, ink);

    // Horned Royal Crown
    final Path kingCrown = Path()
      ..moveTo(-s * 0.38, -s * 0.4)
      ..lineTo(-s * 0.42, -s * 0.75) // Left horn
      ..lineTo(-s * 0.18, -s * 0.55)
      ..lineTo(0, -s * 0.95) // Center cross peak
      ..lineTo(s * 0.18, -s * 0.55)
      ..lineTo(s * 0.42, -s * 0.75) // Right horn
      ..lineTo(s * 0.38, -s * 0.4)
      ..close();
    canvas.drawPath(kingCrown, fill);
    canvas.drawPath(kingCrown, ink);

    // Royal Cross atop Crown
    canvas.drawLine(Offset(0, -s * 0.8), Offset(0, -s * 1.05), ink);
    canvas.drawLine(Offset(-s * 0.1, -s * 0.95), Offset(s * 0.1, -s * 0.95), ink);

    // Face / Skull Shroud
    canvas.drawOval(Rect.fromCenter(center: Offset(0, -s * 0.28), width: s * 0.4, height: s * 0.35), Paint()..color = const Color(0xFF140F1E));
    canvas.drawOval(Rect.fromCenter(center: Offset(0, -s * 0.28), width: s * 0.4, height: s * 0.35), ink);

    // Glowing Eyes
    canvas.drawCircle(Offset(-s * 0.1, -s * 0.28), s * 0.07, eyeGlow);
    canvas.drawCircle(Offset(s * 0.1, -s * 0.28), s * 0.07, eyeGlow);

    // Runic Greatsword planted in front
    canvas.drawLine(Offset(0, -s * 0.05), Offset(0, s * 0.85), ink);
    canvas.drawLine(Offset(-s * 0.15, s * 0.1), Offset(s * 0.15, s * 0.1), ink); // Crossguard
    canvas.drawCircle(Offset(0, -s * 0.05), s * 0.05, eyeGlow); // Pommel gem
  }
}
