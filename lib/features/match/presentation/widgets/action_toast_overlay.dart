import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/action_log_entry.dart';

class ActionToastOverlay extends StatefulWidget {
  final ActionLogEntry? latestAction;

  const ActionToastOverlay({super.key, required this.latestAction});

  @override
  State<ActionToastOverlay> createState() => _ActionToastOverlayState();
}

class _ActionToastOverlayState extends State<ActionToastOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  ActionLogEntry? _currentAction;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _checkNewAction(widget.latestAction);
  }

  @override
  void didUpdateWidget(covariant ActionToastOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.latestAction != oldWidget.latestAction && widget.latestAction != null) {
      _checkNewAction(widget.latestAction);
    }
  }

  void _checkNewAction(ActionLogEntry? action) {
    if (action == null) return;
    
    setState(() {
      _currentAction = action;
    });
    
    _controller.forward(from: 0);
    
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentAction == null) return const SizedBox.shrink();

    return Positioned(
      top: 100, // Just below the top HUD
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: _controller,
          child: Center(
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.5),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.abyssBlack.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _currentAction!.isImportant ? AppColors.bloodWine : AppColors.ghostBlue,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_currentAction!.isImportant ? AppColors.bloodWine : AppColors.ghostBlue).withValues(alpha: 0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Text(
                  _currentAction!.text,
                  style: TextStyle(
                    color: AppColors.candleIvory,
                    fontSize: 16,
                    fontWeight: _currentAction!.isImportant ? FontWeight.bold : FontWeight.normal,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
