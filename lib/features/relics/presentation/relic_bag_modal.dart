import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/relic_icon_widget.dart';
import '../../../../theme/app_colors.dart';
import '../domain/relic.dart';
import '../domain/relic_inventory.dart';
import '../../board/domain/board_position.dart';
import '../../match/domain/game_state.dart';

class RelicBagModal extends StatelessWidget {
  final RelicInventory inventory;
  final GameState gameState;
  final BoardPosition? selectedTile;
  final Function(Relic relic, BoardPosition targetPiece) onEquipRelic;

  const RelicBagModal({
    super.key,
    required this.inventory,
    required this.gameState,
    required this.selectedTile,
    required this.onEquipRelic,
  });

  @override
  Widget build(BuildContext context) {
    final selectedPiece =
        selectedTile != null ? gameState.board.pieceAt(selectedTile!) : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.voidPanel,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: AppColors.cursePurple.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.inventory_2, color: AppColors.runeGold, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Relics & Equipment',
                      style: GoogleFonts.cinzel(
                        color: AppColors.runeGold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              selectedPiece != null
                  ? 'Equipping to: ${selectedPiece.color.name.toUpperCase()} ${selectedPiece.type.name.toUpperCase()} at ${selectedTile!.algebraic}'
                  : 'Select a friendly piece on the board first, or choose a relic below to see its power.',
              style: GoogleFonts.raleway(
                color: selectedPiece != null
                    ? AppColors.ghostBlue
                    : Colors.white60,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            if (inventory.relics.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                child: Text(
                  'Your Relic bag is empty.\nCapture enemy pieces to loot powerful Relics!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    color: Colors.white54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: inventory.relics.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final relic = inventory.relics[index];
                    return Container(
                      width: 165,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1729),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF483A61),
                          width: 2.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF0F0B18),
                            offset: Offset(0, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              RelicIconWidget(relicId: relic.id, size: 24),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  relic.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cinzel(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Text(
                              relic.description,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (selectedPiece != null && selectedTile != null)
                            SizedBox(
                              width: double.infinity,
                              height: 30,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC1121F),
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(
                                      color: Color(0xFFFF4D6D),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  onEquipRelic(relic, selectedTile!);
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Equip Piece',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
