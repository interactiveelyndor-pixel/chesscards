import 'dart:math';
import 'package:flutter/material.dart';

// ────────────────────────────────────────
// Atmospheric Flying Bats
// ────────────────────────────────────────
class FlyingBats extends StatefulWidget {
  final double height;
  const FlyingBats({super.key, this.height = 60});

  @override
  State<FlyingBats> createState() => _FlyingBatsState();
}

class _FlyingBatsState extends State<FlyingBats>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return SizedBox(
          height: widget.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Bat 1 — flies left to right
              Positioned(
                left: t * 320 - 30,
                top: 10 + sin(t * pi * 2) * 12,
                child: _BatIcon(size: 22, opacity: (0.5 + sin(t * pi) * 0.3).clamp(0.2, 0.8)),
              ),
              // Bat 2 — flies right to left, offset phase
              Positioned(
                right: t * 280 - 20,
                top: 30 + sin((t + 0.5) * pi * 2) * 10,
                child: _BatIcon(size: 16, opacity: (0.4 + sin((t + 0.3) * pi) * 0.3).clamp(0.2, 0.7), flip: true),
              ),
              // Bat 3 — slow floater
              Positioned(
                left: 60 + sin(t * pi * 1.5) * 80,
                top: 20 + cos(t * pi * 1.5) * 15,
                child: _BatIcon(size: 13, opacity: (0.3 + sin(t * pi * 0.8) * 0.2).clamp(0.15, 0.55)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BatIcon extends StatelessWidget {
  final double size;
  final double opacity;
  final bool flip;

  const _BatIcon({required this.size, required this.opacity, this.flip = false});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flip ? -1 : 1,
      child: Opacity(
        opacity: opacity,
        child: Icon(
          Icons.paragliding, // Closest built-in wing shape
          size: size,
          color: const Color(0xFF1A0800),
        ),
      ),
    );
  }
}
