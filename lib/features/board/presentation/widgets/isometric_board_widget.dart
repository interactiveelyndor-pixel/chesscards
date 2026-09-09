import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/board_geometry.dart';
import '../models/board_tile.dart';
import '../painters/isometric_board_painter.dart';

import '../../../match/domain/game_state.dart';
import '../../../match/domain/chess_move.dart';
import '../../../spells/domain/spell.dart';
import '../../domain/board_position.dart';

class IsometricBoardWidget extends StatefulWidget {
  final GameState? gameState;
  final ValueChanged<BoardTile> onTileTap;
  final BoardTile? selectedTile;
  final BoardTile? hoveredTile;
  final Set<BoardPosition> highlightedMoves;
  final Set<BoardPosition> validCardTargets;
  final Set<BoardPosition> validSpellTargets;
  final ChessMove? lastMove;
  final Spell? lastPlayedCard;
  final Spell? lastPlayedSpell;
  final BoardPosition? lastCardTarget;
  final BoardPosition? lastSpellTarget;
  final double tileWidth;
  final double tileHeight;
  final String? equippedBoardId;
  final bool isFlipped;

  const IsometricBoardWidget({
    super.key,
    this.gameState,
    required this.onTileTap,
    this.selectedTile,
    this.hoveredTile,
    this.highlightedMoves = const {},
    this.validCardTargets = const {},
    this.validSpellTargets = const {},
    this.lastMove,
    this.lastPlayedCard,
    this.lastPlayedSpell,
    this.lastCardTarget,
    this.lastSpellTarget,
    this.tileWidth = 48,
    this.tileHeight = 48,
    this.equippedBoardId,
    this.isFlipped = false,
  });

  @override
  State<IsometricBoardWidget> createState() => _IsometricBoardWidgetState();
}

class _IsometricBoardWidgetState extends State<IsometricBoardWidget> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _moveController;
  late AnimationController _spellController;
  late AnimationController _captureController;
  ChessMove? _animatingMove;
  Spell? _animatingCard;
  BoardPosition? _animatingCardTarget;
  BoardPosition? _captureTarget;
  BoardTile? _localHover;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _spellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _captureController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void didUpdateWidget(IsometricBoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastMove != oldWidget.lastMove && widget.lastMove != null) {
      _animatingMove = widget.lastMove;
      _moveController.forward(from: 0.0);
      if (widget.lastMove!.isCapture) {
        _captureTarget = widget.lastMove!.to;
        _captureController.forward(from: 0.0);
      }
    }
    final spellToAnimate = widget.lastPlayedSpell ?? widget.lastPlayedCard;
    final oldSpell = oldWidget.lastPlayedSpell ?? oldWidget.lastPlayedCard;
    if (spellToAnimate != oldSpell && spellToAnimate != null) {
      _animatingCard = spellToAnimate;
      _animatingCardTarget = widget.lastSpellTarget ?? widget.lastCardTarget;
      _spellController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _moveController.dispose();
    _spellController.dispose();
    _captureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        // Fog Overlay
        Positioned.fill(
          child: AnimatedOpacity(
            opacity: 0.15,
            duration: const Duration(seconds: 5),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.transparent, AppColors.ghostBlue, Colors.transparent],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .slideX(begin: -0.1, end: 0.1, duration: 10.seconds),
        ),
        
        // Dust Particles
        ...List.generate(15, (index) => _buildDustParticle(screenSize)),

        // The Board
        Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Allow the board to take up much more space. Since we're in a Stack now, 
              // maxHeight is the full screen height.
              final double maxBoardSize = min(constraints.maxWidth, constraints.maxHeight * 0.95);
              final double boardSize = maxBoardSize; 
              final double dynamicTileSize = boardSize / 8;

              return MouseRegion(
                onHover: (e) {
                  final Offset localPos = e.localPosition;
                  final Offset boardPos = Offset(
                    localPos.dx - (constraints.maxWidth - 8 * dynamicTileSize) / 2,
                    localPos.dy - (constraints.maxHeight - 8 * dynamicTileSize) / 2,
                  );
                  final BoardTile? tile = BoardGeometry.screenToBoard(boardPos, dynamicTileSize, dynamicTileSize, isFlipped: widget.isFlipped);
                  if (tile != _localHover) {
                    setState(() {
                      _localHover = tile;
                    });
                  }
                },
                onExit: (_) => setState(() => _localHover = null),
                child: GestureDetector(
                  onTapUp: (details) {
                    final Offset localPos = details.localPosition;
                    final Offset boardPos = Offset(
                      localPos.dx - (constraints.maxWidth - 8 * dynamicTileSize) / 2,
                      localPos.dy - (constraints.maxHeight - 8 * dynamicTileSize) / 2,
                    );
                    final BoardTile? tile = BoardGeometry.screenToBoard(boardPos, dynamicTileSize, dynamicTileSize, isFlipped: widget.isFlipped);
                    if (tile != null) {
                      widget.onTileTap(tile);
                    }
                  },
                  onLongPressStart: (details) {
                    final Offset localPos = details.localPosition;
                    final Offset boardPos = Offset(
                      localPos.dx - (constraints.maxWidth - 8 * dynamicTileSize) / 2,
                      localPos.dy - (constraints.maxHeight - 8 * dynamicTileSize) / 2,
                    );
                    final BoardTile? tile = BoardGeometry.screenToBoard(boardPos, dynamicTileSize, dynamicTileSize, isFlipped: widget.isFlipped);
                    if (tile != null && widget.gameState != null) {
                      final piece = widget.gameState!.board.pieceAt(BoardPosition(tile.row, tile.col));
                      if (piece != null) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${piece.color.name.toUpperCase()} ${piece.type.name.toUpperCase()}'),
                            backgroundColor: AppColors.voidPanel,
                            duration: const Duration(seconds: 1),
                          )
                        );
                      }
                    }
                  },
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_glowController, _moveController]),
                    builder: (context, child) {
                      return RepaintBoundary(
                        child: Container(
                          color: Colors.transparent, // Capture taps
                          width: double.infinity,
                          height: double.infinity,
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: IsometricBoardPainter(
                              gameState: widget.gameState,
                              selectedTile: widget.selectedTile,
                              hoveredTile: widget.hoveredTile ?? _localHover,
                              highlightedMoves: widget.highlightedMoves,
                              validCardTargets: widget.validCardTargets,
                              animatingMove: _animatingMove,
                              moveAnimationProgress: Curves.easeInOutCubic.transform(_moveController.value),
                              tileWidth: dynamicTileSize,
                              tileHeight: dynamicTileSize,
                              glowAnimationValue: _glowController.value,
                              equippedBoardId: widget.equippedBoardId,
                              isFlipped: widget.isFlipped,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }
          ).animate()
           .fadeIn(duration: 1.seconds)
           .scale(begin: const Offset(0.95, 0.95), duration: 800.ms, curve: Curves.easeOutBack),
        ),

        // Spell Particle Effect Overlay
        if (_animatingCard != null && _animatingCardTarget != null)
          AnimatedBuilder(
            animation: _spellController,
            builder: (context, child) {
              if (!_spellController.isAnimating) return const SizedBox.shrink();
              
              return LayoutBuilder(
                builder: (context, constraints) {
                  final double maxBoardSize = min(constraints.maxWidth, constraints.maxHeight * 0.95);
                  final double boardSize = maxBoardSize;
                  final double dynamicTileSize = boardSize / 8;
                  
                  final Offset center = BoardGeometry.boardToScreen(
                    _animatingCardTarget!.row, 
                    _animatingCardTarget!.col, 
                    dynamicTileSize, 
                    dynamicTileSize,
                    isFlipped: widget.isFlipped,
                  );
                  
                  // Add the board offset
                  final Offset boardOffset = Offset(
                    (constraints.maxWidth - 8 * dynamicTileSize) / 2,
                    (constraints.maxHeight - 8 * dynamicTileSize) / 2,
                  );
                  
                  final double scale = Curves.easeOutBack.transform(_spellController.value);
                  final double opacity = 1.0 - _spellController.value;
                  
                  return Positioned(
                    left: boardOffset.dx + center.dx - dynamicTileSize * 1.5,
                    top: boardOffset.dy + center.dy - dynamicTileSize * 1.5,
                    child: _buildCardSpellEffect(_animatingCard!, scale, opacity, dynamicTileSize * 3),
                  );
                }
              );
            },
          ),
          
        // Capture Explosion Overlay
        if (_captureTarget != null)
          AnimatedBuilder(
            animation: _captureController,
            builder: (context, child) {
              if (!_captureController.isAnimating) return const SizedBox.shrink();
              
              return LayoutBuilder(
                builder: (context, constraints) {
                  final double maxBoardSize = min(constraints.maxWidth, constraints.maxHeight * 0.95);
                  final double boardSize = maxBoardSize;
                  final double dynamicTileSize = boardSize / 8;
                  
                  final Offset center = BoardGeometry.boardToScreen(
                    _captureTarget!.row, 
                    _captureTarget!.col, 
                    dynamicTileSize, 
                    dynamicTileSize,
                    isFlipped: widget.isFlipped,
                  );
                  
                  final Offset boardOffset = Offset(
                    (constraints.maxWidth - 8 * dynamicTileSize) / 2,
                    (constraints.maxHeight - 8 * dynamicTileSize) / 2,
                  );
                  
                  final double progress = _captureController.value;
                  final double scale = Curves.easeOutQuad.transform(progress);
                  final double opacity = 1.0 - progress;
                  final double size = dynamicTileSize * 3;
                  
                  return Positioned(
                    left: boardOffset.dx + center.dx - size / 2,
                    top: boardOffset.dy + center.dy - size / 2,
                    child: Stack(
                      alignment: Alignment.center,
                      children: List.generate(12, (index) {
                        final random = Random(index * 10);
                        return Container(
                          width: size * 0.2,
                          height: size * 0.2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.bloodWine.withValues(alpha: opacity),
                            boxShadow: [
                              BoxShadow(color: Colors.redAccent.withValues(alpha: opacity * 0.5), blurRadius: 8),
                            ],
                          ),
                        ).animate()
                         .move(
                           begin: const Offset(0, 0),
                           end: Offset(
                             (random.nextDouble() - 0.5) * size * scale,
                             (random.nextDouble() - 0.5) * size * scale,
                           ),
                           duration: 800.ms,
                           curve: Curves.easeOutCirc,
                         )
                         .scale(begin: const Offset(1.0, 1.0), end: const Offset(0.2, 0.2))
                         .fadeOut(duration: 800.ms);
                      }),
                    ),
                  );
                }
              );
            },
          ),

        // Vignette Overlay
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.transparent, AppColors.abyssBlack.withValues(alpha: 0.9)],
                  radius: 0.8,
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardSpellEffect(Spell card, double scale, double opacity, double size) {
    if (card.id == 'spell_necromancy' || card.id == 'necromancy') {
      // Green skull particles
      return Stack(
        alignment: Alignment.center,
        children: List.generate(5, (index) {
          final random = Random(index);
          return Transform.translate(
            offset: Offset(random.nextDouble() * size - size / 2,
                random.nextDouble() * size - size / 2),
            child: Icon(Icons.dangerous,
                    color: Colors.greenAccent.withValues(alpha: opacity),
                    size: size / 2)
                .animate()
                .scale(
                    begin: const Offset(0.5, 0.5),
                    end: Offset(scale * 1.5, scale * 1.5),
                    duration: 800.ms)
                .rotate(
                    begin: random.nextDouble() * -0.2,
                    end: random.nextDouble() * 0.2)
                .fadeOut(duration: 800.ms),
          );
        }),
      );
    } else if (card.id == 'spell_fireball' ||
        card.id == 'spell_lightning' ||
        card.id == 'spell_soul_leech') {
      // Red/Orange radial flame burst
      return Container(
        width: size * scale * 2,
        height: size * scale * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.orangeAccent.withValues(alpha: opacity * 0.9),
              AppColors.bloodWine.withValues(alpha: opacity * 0.5),
              Colors.transparent,
            ],
          ),
        ),
      )
          .animate()
          .scale(curve: Curves.easeOutExpo, duration: 600.ms)
          .fadeOut(duration: 800.ms);
    } else if (card.id == 'spell_freeze' || card.id == 'spell_blizzard') {
      // Frost blue ice burst
      return Container(
        width: size * scale * 2.2,
        height: size * scale * 2.2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.cyanAccent.withValues(alpha: opacity * 0.8),
              AppColors.ghostBlue.withValues(alpha: opacity * 0.4),
              Colors.transparent,
            ],
          ),
        ),
      )
          .animate()
          .scale(curve: Curves.easeOutBack, duration: 700.ms)
          .fadeOut(duration: 800.ms);
    } else if (card.id == 'spell_wall_of_stone') {
      // Earth rise / stone dust smoke
      return Stack(
        alignment: Alignment.center,
        children: List.generate(8, (index) {
          final random = Random(index * 2);
          return Container(
            width: size * 0.8,
            height: size * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cursePurple.withValues(alpha: opacity * 0.6),
              boxShadow: [
                BoxShadow(
                    color: AppColors.cursePurpleLight
                        .withValues(alpha: opacity * 0.4),
                    blurRadius: 12,
                    spreadRadius: 6),
              ],
            ),
          )
              .animate()
              .move(
                begin: const Offset(0, 0),
                end: Offset(random.nextDouble() * size - size / 2,
                    random.nextDouble() * size - size / 2),
                duration: 600.ms,
                curve: Curves.easeOutCirc,
              )
              .scale(
                  begin: const Offset(0.2, 0.2),
                  end: Offset(scale * 1.2, scale * 1.2))
              .fadeOut(duration: 700.ms);
        }),
      );
    }

    // Default effect
    return Transform.scale(
      scale: scale * 1.5,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.cursePurple.withValues(alpha: 0.8),
                AppColors.bloodWine.withValues(alpha: 0.4),
                Colors.transparent,
              ],
            ),
          ),
          child: const Center(
            child: Icon(Icons.flash_on, color: AppColors.candleIvory, size: 48),
          ),
        ),
      ),
    );
  }

  Widget _buildDustParticle(Size size) {
    final random = Random();
    final double startX = random.nextDouble() * size.width;
    final double startY = random.nextDouble() * size.height;
    final double endY = startY - 100 - random.nextDouble() * 100;
    
    return Positioned(
      left: startX,
      top: startY,
      child: Container(
        width: 2,
        height: 2,
        decoration: BoxDecoration(
          color: AppColors.candleIvory.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
      ).animate(onPlay: (controller) => controller.repeat())
       .moveY(begin: 0, end: endY - startY, duration: Duration(seconds: 5 + random.nextInt(5)))
       .fadeIn(duration: 1.seconds)
       .fadeOut(delay: 3.seconds, duration: 2.seconds),
    );
  }
}
