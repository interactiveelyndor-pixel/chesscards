import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';
import '../../../../shared/enums/piece_color.dart';

class CheckmateOverlay extends StatelessWidget {
  final PieceColor winner;
  final VoidCallback onRematch;
  final VoidCallback onExit;

  const CheckmateOverlay({
    super.key,
    required this.winner,
    required this.onRematch,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final bool playerWon = winner == PieceColor.white;
    final String headline = playerWon ? 'VICTORY' : 'DEFEAT';
    final Color accentColor =
        playerWon ? AppColors.spectralGreen : AppColors.bloodWine;
    final String flavour = playerWon
        ? 'The curse bows to your mastery.'
        : 'The darkness claims your soul.';

    return Stack(
      children: [
        // Full-screen black backdrop
        Positioned.fill(
          child: Container(color: AppColors.abyssBlack.withValues(alpha: 0.95))
              .animate()
              .fadeIn(duration: 800.ms),
        ),

        // Animated fog/particle layer
        Positioned.fill(
          child: _ParticleLayer(accentColor: accentColor),
        ),

        // Content
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Central sigil
              _OccultSigil(color: accentColor)
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 1000.ms)
                  .scaleXY(
                      begin: 0.5, end: 1.0, curve: Curves.easeOutBack),

              const SizedBox(height: 32),

              // Headline
              Text(
                headline,
                style: GoogleFonts.cinzel(
                  color: accentColor,
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 14,
                  shadows: [
                    Shadow(
                      color: accentColor.withValues(alpha: 0.9),
                      blurRadius: 50,
                    ),
                    Shadow(
                      color: accentColor.withValues(alpha: 0.4),
                      blurRadius: 100,
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 700.ms, duration: 800.ms)
                  .slideY(begin: 0.4, end: 0, curve: Curves.easeOut),

              const SizedBox(height: 16),

              // Divider ornament
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 1,
                    color: accentColor.withValues(alpha: 0.4),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.auto_fix_high,
                      size: 14,
                      color: accentColor.withValues(alpha: 0.6),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 1,
                    color: accentColor.withValues(alpha: 0.4),
                  ),
                ],
              ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),

              const SizedBox(height: 20),

              // Flavour text
              Text(
                flavour,
                textAlign: TextAlign.center,
                style: GoogleFonts.raleway(
                  color: AppColors.candleIvory.withValues(alpha: 0.7),
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(delay: 1200.ms, duration: 800.ms),

              const SizedBox(height: 64),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RitualButton(
                    label: 'PLAY AGAIN',
                    color: accentColor,
                    onTap: onRematch,
                  ),
                  const SizedBox(width: 32),
                  _RitualButton(
                    label: 'MAIN MENU',
                    color: AppColors.fogGray,
                    onTap: onExit,
                  ),
                ],
              ).animate().fadeIn(delay: 1800.ms, duration: 700.ms),
            ],
          ),
        ),
      ],
    );
  }
}

class _OccultSigil extends StatelessWidget {
  final Color color;
  const _OccultSigil({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulsing glow
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 0.9, end: 1.1, duration: 2000.ms),

          // Outer ring
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
            ),
          ),

          // Inner ring
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: color.withValues(alpha: 0.3), width: 1),
            ),
          ),

          // Icon
          Icon(
            Icons.sports_esports,
            size: 44,
            color: color,
            shadows: [
              Shadow(color: color.withValues(alpha: 0.9), blurRadius: 24),
            ],
          ),
        ],
      ),
    );
  }
}

class _RitualButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RitualButton(
      {required this.label, required this.color, required this.onTap});

  @override
  State<_RitualButton> createState() => _RitualButtonState();
}

class _RitualButtonState extends State<_RitualButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: 200.ms,
          padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            color: _hovered
                ? widget.color.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _hovered
                  ? widget.color.withValues(alpha: 0.9)
                  : widget.color.withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.3),
                      blurRadius: 20,
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.cinzel(
              color: _hovered ? widget.color : widget.color.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 4,
            ),
          ),
        ),
      ),
    );
  }
}

class _ParticleLayer extends StatefulWidget {
  final Color accentColor;
  const _ParticleLayer({required this.accentColor});

  @override
  State<_ParticleLayer> createState() => _ParticleLayerState();
}

class _ParticleLayerState extends State<_ParticleLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter:
            _ParticlePainter(_ctrl.value, widget.accentColor),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double t;
  final Color color;

  _ParticlePainter(this.t, this.color);

  static const int _count = 30;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < _count; i++) {
      final double phase = (i / _count + t) % 1.0;
      final double x = size.width * ((i * 0.37 + 0.1) % 1.0);
      final double y = size.height * (1.0 - phase);
      final double alpha = (phase < 0.2
          ? phase / 0.2
          : phase > 0.8
              ? (1 - phase) / 0.2
              : 1.0) *
          0.35;
      final double radius = 1.5 + 2.0 * ((i * 0.17) % 1.0);
      paint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => old.t != t;
}
