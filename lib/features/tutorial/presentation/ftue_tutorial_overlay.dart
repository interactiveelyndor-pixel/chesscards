import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FtueTutorialOverlay extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onDismiss;
  final String imagePath; 
  final bool isLeftAligned;
  final Widget? highlightWidget;
  final Alignment? highlightAlignment;
  final EdgeInsetsGeometry? highlightPadding;
  final double? highlightBottom;
  final double? highlightTop;
  final bool showBarrier;

  const FtueTutorialOverlay({
    super.key,
    this.title = 'Elyndor',
    required this.message,
    this.onDismiss,
    this.imagePath = 'assets/images/elyndor.png',
    this.isLeftAligned = true,
    this.highlightWidget,
    this.highlightAlignment,
    this.highlightPadding,
    this.highlightBottom,
    this.highlightTop,
    this.showBarrier = true,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isNarrow = size.width < 460;
    final characterHeight = math.min(320.0, size.height * 0.38);

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onDismiss,
        child: Stack(
          children: [
            // Background Dimming
            Container(
              color: showBarrier
                  ? Colors.black.withValues(alpha: 0.72)
                  : Colors.black.withValues(alpha: 0.45),
            ),
            
            SafeArea(
              child: Stack(
                children: [
                  // Highlighted Widget for forced clicking (if any)
                  if (highlightWidget != null)
                    Positioned(
                      bottom: highlightBottom,
                      top: highlightTop,
                      left: 0,
                      right: 0,
                      child: Align(
                        alignment: highlightAlignment ?? Alignment.center,
                        child: Padding(
                          padding: highlightPadding ?? EdgeInsets.zero,
                          child: highlightWidget!,
                        ),
                      ),
                    ),

                  // The Character Image (Bottom Corner)
                  Positioned(
                    bottom: 0,
                    left: isLeftAligned ? (isNarrow ? -30 : -10) : null,
                    right: !isLeftAligned ? (isNarrow ? -30 : -10) : null,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: isNarrow ? 0.45 : 0.95,
                        child: Image.asset(
                          imagePath,
                          height: characterHeight,
                          errorBuilder: (context, error, stackTrace) {
                            return SizedBox(
                              height: characterHeight,
                              width: characterHeight * 0.7,
                              child: const Icon(Icons.person, size: 140, color: Color(0xFF8B4500)),
                            );
                          },
                        ).animate().slideY(begin: 0.6, curve: Curves.easeOutBack, duration: 450.ms),
                      ),
                    ),
                  ),

                  // The Dialogue Box
                  Positioned(
                    bottom: math.max(24.0, size.height * 0.05),
                    left: isNarrow
                        ? 16
                        : (isLeftAligned ? math.min(220.0, size.width * 0.35) : 24),
                    right: isNarrow
                        ? 16
                        : (!isLeftAligned ? math.min(220.0, size.width * 0.35) : 24),
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF120600).withValues(alpha: 0.97),
                          border: Border.all(color: const Color(0xFFFF9E00), width: 1.8),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF9E00).withValues(alpha: 0.35),
                              blurRadius: 22,
                              spreadRadius: 2,
                            ),
                            const BoxShadow(
                              color: Colors.black87,
                              blurRadius: 10,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF9E00),
                                    shape: BoxShape.circle,
                                  ),
                                ).animate(onPlay: (c) => c.repeat(reverse: true))
                                 .scale(begin: const Offset(0.7, 0.7), end: const Offset(1.3, 1.3), duration: 800.ms),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    title.toUpperCase(),
                                    style: GoogleFonts.cinzelDecorative(
                                      color: const Color(0xFFFFD166),
                                      fontSize: isNarrow ? 14 : 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              message,
                              style: GoogleFonts.cinzel(
                                color: const Color(0xFFF0EBE1),
                                fontSize: isNarrow ? 13 : 14.5,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.08, duration: 350.ms),
                            const SizedBox(height: 14),
                            // Tap anywhere to continue prompt
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Tap anywhere to continue',
                                  style: GoogleFonts.cinzel(
                                    color: const Color(0xFFFFBA08),
                                    fontSize: isNarrow ? 11 : 12,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.italic,
                                    letterSpacing: 0.5,
                                  ),
                                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                                 .shimmer(duration: 1800.ms, color: Colors.white),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.touch_app_rounded,
                                  size: 15,
                                  color: Color(0xFFFFBA08),
                                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                                 .scale(begin: const Offset(0.85, 0.85), end: const Offset(1.2, 1.2), duration: 700.ms),
                              ],
                            ),
                          ],
                        ),
                      ).animate().scaleXY(begin: 0.92, curve: Curves.easeOutBack, duration: 350.ms).fadeIn(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
