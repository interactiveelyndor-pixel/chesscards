import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/spell.dart';
import 'spell_emblem_painter.dart';

class GothicSpellCard extends StatefulWidget {
  final Spell spell;
  final bool isSelected;
  final bool canCast;
  final VoidCallback? onTap;

  const GothicSpellCard({
    super.key,
    required this.spell,
    required this.isSelected,
    required this.canCast,
    this.onTap,
  });

  @override
  State<GothicSpellCard> createState() => _GothicSpellCardState();
}

class _GothicSpellCardState extends State<GothicSpellCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final spell = widget.spell;
    final isSelected = widget.isSelected;
    final canCast = widget.canCast;

    final themeData = _getSpellTheme(spell.id);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: canCast ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: GestureDetector(
        onTap: canCast ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 130,
          margin: EdgeInsets.only(
            bottom: isSelected ? 8.0 : (_isHovered && canCast ? 4.0 : 0.0),
            top: isSelected ? 0.0 : (_isHovered && canCast ? 4.0 : 8.0),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: canCast
                  ? [
                      themeData.gradientTop,
                      themeData.gradientBottom,
                      const Color(0xFF07070F),
                    ]
                  : [
                      const Color(0xFF181822),
                      const Color(0xFF0F0F16),
                      const Color(0xFF06060A),
                    ],
              stops: const [0.0, 0.45, 1.0],
            ),
            border: Border.all(
              color: isSelected
                  ? AppColors.runeGold
                  : (_isHovered && canCast
                      ? themeData.accentColor
                      : (canCast
                          ? themeData.accentColor.withValues(alpha: 0.65)
                          : AppColors.dimGray.withValues(alpha: 0.6))),
              width: isSelected ? 2.2 : 1.4,
            ),
            boxShadow: [
              if (isSelected) ...[
                BoxShadow(
                  color: AppColors.runeGold.withValues(alpha: 0.5),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: themeData.accentColor.withValues(alpha: 0.6),
                  blurRadius: 8,
                ),
              ] else if (_isHovered && canCast) ...[
                BoxShadow(
                  color: themeData.accentColor.withValues(alpha: 0.45),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ] else if (canCast) ...[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ],
          ),
          child: Stack(
            children: [
              // ── Gothic Corner Filigree ────────────────────────────────────
              Positioned(
                top: 3,
                left: 3,
                child: Icon(
                  Icons.square,
                  size: 4,
                  color: canCast ? themeData.accentColor : Colors.white24,
                ),
              ),
              Positioned(
                top: 3,
                right: 3,
                child: Icon(
                  Icons.square,
                  size: 4,
                  color: canCast ? themeData.accentColor : Colors.white24,
                ),
              ),

              // ── Main Card Content ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 114,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top: Mana Cost Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Card Type Label
                            Text(
                              themeData.tag.toUpperCase(),
                              style: GoogleFonts.cinzel(
                                fontSize: 7.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: canCast
                                    ? themeData.accentColor
                                    : Colors.white38,
                              ),
                            ),
                            // Mana Gem Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: canCast
                                      ? [
                                          const Color(0xFF0077B6),
                                          const Color(0xFF03045E),
                                        ]
                                      : [
                                          const Color(0xFF2B2D42),
                                          const Color(0xFF1B1B22),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: canCast
                                      ? AppColors.ghostBlue.withValues(alpha: 0.9)
                                      : Colors.white24,
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.diamond_outlined,
                                    size: 8.5,
                                    color: canCast ? AppColors.ghostBlue : Colors.white38,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${spell.manaCost}',
                                    style: GoogleFonts.cinzel(
                                      fontSize: 9.0,
                                      fontWeight: FontWeight.w900,
                                      color: canCast ? Colors.white : Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 2),

                        // Middle: Custom Arcane Vector Emblem
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.55),
                            border: Border.all(
                              color: canCast
                                  ? themeData.accentColor.withValues(alpha: 0.4)
                                  : Colors.white12,
                              width: 1.0,
                            ),
                          ),
                          child: Center(
                            child: CustomPaint(
                              size: const Size(28, 28),
                              painter: SpellEmblemPainter(
                                spellId: spell.id,
                                isCasting: isSelected,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 2),

                        // Bottom: Title & Description
                        Text(
                          spell.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cinzel(
                            color: canCast
                                ? (isSelected ? AppColors.runeGold : Colors.white)
                                : Colors.white38,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.0,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          spell.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.raleway(
                            color: canCast
                                ? Colors.white.withValues(alpha: 0.7)
                                : Colors.white24,
                            fontSize: 7.0,
                            height: 1.1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _SpellVisualTheme _getSpellTheme(String spellId) {
    switch (spellId) {
      case 'spell_fireball':
        return _SpellVisualTheme(
          gradientTop: const Color(0xFF380808),
          gradientBottom: const Color(0xFF1E0404),
          accentColor: const Color(0xFFFF5500),
          tag: 'Infernal',
        );
      case 'spell_freeze':
        return _SpellVisualTheme(
          gradientTop: const Color(0xFF0A2239),
          gradientBottom: const Color(0xFF05111D),
          accentColor: const Color(0xFF00B4D8),
          tag: 'Frost',
        );
      case 'spell_blizzard':
        return _SpellVisualTheme(
          gradientTop: const Color(0xFF102A43),
          gradientBottom: const Color(0xFF081421),
          accentColor: const Color(0xFF90E0EF),
          tag: 'Tempest',
        );
      case 'spell_soul_leech':
        return _SpellVisualTheme(
          gradientTop: const Color(0xFF2A0845),
          gradientBottom: const Color(0xFF130420),
          accentColor: const Color(0xFF9D4EDD),
          tag: 'Necrotic',
        );
      case 'spell_wall_of_stone':
        return _SpellVisualTheme(
          gradientTop: const Color(0xFF2D2A26),
          gradientBottom: const Color(0xFF161412),
          accentColor: const Color(0xFFD4AF37),
          tag: 'Earth',
        );
      case 'spell_necromancy':
        return _SpellVisualTheme(
          gradientTop: const Color(0xFF0B2E1E),
          gradientBottom: const Color(0xFF05160E),
          accentColor: const Color(0xFF2DC653),
          tag: 'Reanimate',
        );
      case 'spell_lightning':
        return _SpellVisualTheme(
          gradientTop: const Color(0xFF24143D),
          gradientBottom: const Color(0xFF120921),
          accentColor: const Color(0xFFE0AAFF),
          tag: 'Storm',
        );
      default:
        return _SpellVisualTheme(
          gradientTop: const Color(0xFF1A1A2E),
          gradientBottom: const Color(0xFF0E0E1A),
          accentColor: AppColors.runeGold,
          tag: 'Arcane',
        );
    }
  }
}

class _SpellVisualTheme {
  final Color gradientTop;
  final Color gradientBottom;
  final Color accentColor;
  final String tag;

  _SpellVisualTheme({
    required this.gradientTop,
    required this.gradientBottom,
    required this.accentColor,
    required this.tag,
  });
}
