import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class GothicButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? buttonColor;

  const GothicButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.buttonColor,
  });

  @override
  State<GothicButton> createState() => _GothicButtonState();
}

class _GothicButtonState extends State<GothicButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    final baseColor = widget.buttonColor ?? const Color(0xFF261D33);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
        onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
        onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: isDisabled
                ? const Color(0xFF191422)
                : (_isHovered ? const Color(0xFF381F4B) : baseColor),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDisabled
                  ? const Color(0xFF2B223B)
                  : (_isHovered ? const Color(0xFFFFD166) : const Color(0xFF6B4E8F)),
              width: 2.4,
            ),
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFF0F0B18),
                      offset: Offset(0, _isPressed ? 1 : 4),
                      blurRadius: 0,
                    ),
                    if (_isHovered)
                      BoxShadow(
                        color: const Color(0xFFFFD166).withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                  ],
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.cinzel(
              color: isDisabled ? AppColors.fogGray : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
            textAlign: TextAlign.center,
          ),
        ).animate(target: _isHovered && !isDisabled ? 1 : 0)
         .scale(end: const Offset(1.03, 1.03), duration: 150.ms),
      ),
    );
  }
}
