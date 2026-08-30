import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FtueTutorialOverlay extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onDismiss;
  // If the user uploaded an image, it will go here. Otherwise, a placeholder.
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
    return Positioned.fill(
      child: Stack(
        children: [
          // Background Dimming & Tap to Dismiss (if allowed)
          if (showBarrier)
            GestureDetector(
              onTap: onDismiss,
              child: Container(
                color: Colors.black.withValues(alpha: 0.6), // Dim the background
              ),
            )
          else if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              behavior: HitTestBehavior.translucent,
              child: const SizedBox.expand(),
            ),
          
          SafeArea(
            child: Stack(
              children: [
                // Highlighted Widget for forced clicking
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

                // The Character Image
                Positioned(
                  bottom: 0,
                  left: isLeftAligned ? -20 : null,
                  right: !isLeftAligned ? -20 : null,
                  child: Image.asset(
                    imagePath,
                    height: 350,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback placeholder if asset isn't generated yet
                      return Container(
                        height: 350,
                        width: 250,
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, const Color(0xFFCC7722).withValues(alpha: 0.2)],
                          ),
                        ),
                        child: const Icon(Icons.person, size: 200, color: Color(0xFF8B4500)),
                      );
                    },
                  ).animate().slideY(begin: 1.0, curve: Curves.easeOutBack, duration: 600.ms),
                ),

                // The Dialogue Box
                Positioned(
                  bottom: 50,
                  left: isLeftAligned ? 200 : 20,
                  right: !isLeftAligned ? 200 : 20,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF140700).withValues(alpha: 0.95),
                        border: Border.all(color: const Color(0xFFFF9E00), width: 2),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF9E00).withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title.toUpperCase(),
                            style: GoogleFonts.cinzelDecorative(
                              color: const Color(0xFFFFD166),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            message,
                            style: GoogleFonts.cinzel(
                              color: const Color(0xFFE5E5E5),
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.05, duration: 500.ms),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              'Tap anywhere to continue...',
                              style: GoogleFonts.cinzel(
                                color: const Color(0xFF8B4500),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ).animate(delay: 2.seconds).fadeIn(duration: 500.ms).then().shimmer(duration: 2.seconds),
                          ),
                        ],
                      ),
                    ).animate(delay: 400.ms).scaleXY(begin: 0.8, curve: Curves.easeOutBack, duration: 400.ms).fadeIn(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
