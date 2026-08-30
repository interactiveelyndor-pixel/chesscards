import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/doll_event.dart';

class DollReactionBanner extends StatelessWidget {
  final DollEvent event;

  const DollReactionBanner({super.key, required this.event});

  static void showDollReaction(BuildContext context, DollEvent event) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 100,
          left: 20,
          right: 20,
          child: SafeArea(
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: DollReactionBanner(event: event)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.5, end: 0, duration: 400.ms, curve: Curves.easeOutBack)
                  .then(delay: 2.seconds)
                  .fadeOut(duration: 400.ms)
                  .slideY(begin: 0, end: -0.5, duration: 400.ms)
                  .callback(callback: (_) => entry.remove()),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.abyssBlack.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.ghostBlue.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.bloodWine.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        event.reaction.subtitle,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.candleIvory,
          fontStyle: FontStyle.italic,
          letterSpacing: 1.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
