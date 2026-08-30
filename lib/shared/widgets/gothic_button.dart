import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

// ────────────────────────────────────────
// Premium Gothic Button
// ────────────────────────────────────────
class GothicButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback? onTap;
  final int delay;
  final Color glowColor;
  final String? imageAsset;
  final bool isPrimary;

  const GothicButton({
    super.key,
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.delay = 0,
    this.glowColor = const Color(0xFFC1121F),
    this.imageAsset,
    this.isPrimary = false,
  });

  @override
  State<GothicButton> createState() => _GothicButtonState();
}

class _GothicButtonState extends State<GothicButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = widget.onTap == null;
    return GestureDetector(
      onTapDown: disabled ? null : (_) {
        HapticFeedback.lightImpact();
        setState(() => _pressed = true);
      },
      onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, _) {
          final glowStrength = _pressed ? 0.0 : (0.3 + _pulseAnim.value * 0.35);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
            width: double.infinity,
            height: widget.isPrimary ? 72 : 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: disabled
                  ? []
                  : [
                      // Ember glow pulse
                      BoxShadow(
                        color: widget.glowColor.withValues(alpha: glowStrength),
                        blurRadius: 20 + _pulseAnim.value * 10,
                        spreadRadius: 2,
                      ),
                      // Hard shadow bottom
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.7),
                        offset: Offset(0, _pressed ? 1 : 5),
                        blurRadius: 4,
                      ),
                    ],
            ),
            child: ClipPath(
              clipper: _BannerClipper(),
              child: Stack(
                children: [
                  // Main gradient body
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: disabled
                            ? const LinearGradient(
                                colors: [Color(0xFF1E1729), Color(0xFF0D0B14)])
                            : widget.gradient,
                      ),
                    ),
                  ),

                  // Stone/wood grain noise texture (painted)
                  Positioned.fill(
                    child: CustomPaint(painter: _GrainTexturePainter()),
                  ),

                  // Top highlight edge (bevel effect)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.55),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Inner top highlight band
                  Positioned(
                    top: 3,
                    left: 0,
                    right: 0,
                    height: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.18),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Bottom dark shadow band
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 18,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.6),
                            Colors.black.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),

                  // Decorative border overlay on top of gradient
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _BannerBorderPainter(
                        color: widget.glowColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ),

                  // Button Content
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon Medallion
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.35),
                            border: Border.all(
                              color: widget.glowColor.withValues(alpha: 0.7),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.glowColor.withValues(alpha: 0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.icon,
                            color: disabled
                                ? const Color(0xFF666666)
                                : const Color(0xFFFFD166),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Embossed label
                        Text(
                          widget.label,
                          style: GoogleFonts.cinzel(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: disabled
                                ? const Color(0xFF666666)
                                : const Color(0xFFFFF3E0),
                            letterSpacing: 2.5,
                            shadows: disabled
                                ? null
                                : [
                                    // Dark bottom shadow
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.8),
                                      offset: const Offset(0, 2),
                                      blurRadius: 3,
                                    ),
                                    // Outer warm glow
                                    Shadow(
                                      color: widget.glowColor.withValues(alpha: 0.5),
                                      offset: const Offset(0, 0),
                                      blurRadius: 8,
                                    ),
                                  ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: widget.delay + 250),
            duration: 500.ms)
        .slideY(begin: 0.2, curve: Curves.easeOutCubic);
  }
}

// Tapered banner shape clipper — pointed left/right ends
class _BannerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const notch = 12.0;
    final path = Path()
      ..moveTo(notch, 0)
      ..lineTo(size.width - notch, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width - notch, size.height)
      ..lineTo(notch, size.height)
      ..lineTo(0, size.height / 2)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Subtle grain noise texture painter
class _GrainTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(99);
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.04);
    for (int i = 0; i < 120; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final r = 0.5 + rand.nextDouble() * 1.2;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Banner border painter matching the clipped shape
class _BannerBorderPainter extends CustomPainter {
  final Color color;
  _BannerBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const notch = 12.0;
    final path = Path()
      ..moveTo(notch, 0)
      ..lineTo(size.width - notch, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width - notch, size.height)
      ..lineTo(notch, size.height)
      ..lineTo(0, size.height / 2)
      ..close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
