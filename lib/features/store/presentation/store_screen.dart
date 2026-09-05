import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../theme/app_colors.dart';
import '../application/store_controller.dart';
import '../domain/store_item.dart';
import '../domain/store_inventory.dart';
import '../../../../shared/widgets/gothic_background.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  int _activeTabIndex = 0;

  final List<String> _tabs = [
    'FEATURED',
    'DOLLS',
    'CARDS',
    'BOARDS',
    'CURRENCY',
  ];

  List<StoreItem> _getItemsForActiveTab() {
    switch (_activeTabIndex) {
      case 0:
        return StoreInventory.featuredItems;
      case 1:
        return StoreInventory.getItemsByType(StoreItemType.doll);
      case 2:
        return StoreInventory.getItemsByType(StoreItemType.cardPack);
      case 3:
        return StoreInventory.getItemsByType(StoreItemType.boardTheme);
      case 4:
        return StoreInventory.getItemsByType(StoreItemType.currency);
      default:
        return [];
    }
  }

  void _handlePurchase(StoreItem item, bool useSouls) async {
    final controller = ref.read(storeControllerProvider.notifier);
    final success = await controller.purchaseItem(item, useSouls);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CLAIMED: ${item.name}'),
            backgroundColor: const Color(0xFF6A040F),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('NOT ENOUGH OFFERINGS FOR ${item.name}.'),
            backgroundColor: const Color(0xFF1A0A00),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleEquip(StoreItem item) {
    ref.read(storeControllerProvider.notifier).equipItem(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('EQUIPPED: ${item.name}'),
        backgroundColor: const Color(0xFFE85D04),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPurchaseDialog(StoreItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF140700).withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF6B2700), width: 2),
        ),
        title: Text(
          item.name.toUpperCase(),
          style: GoogleFonts.cinzelDecorative(
            color: const Color(0xFFFFB703),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          item.description,
          style: GoogleFonts.raleway(color: const Color(0xFFD48A42)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'CANCEL',
              style: GoogleFonts.cinzel(color: const Color(0xFF9D0208), fontWeight: FontWeight.bold),
            ),
          ),
          if (item.goldCost != null)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF331400),
                side: const BorderSide(color: Color(0xFFFF9E00)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _handlePurchase(item, false);
              },
              icon: const Icon(Icons.circle, color: Color(0xFFFFBA08), size: 16),
              label: Text(
                '${item.goldCost}',
                style: GoogleFonts.cinzel(color: const Color(0xFFFFF3E0), fontWeight: FontWeight.bold),
              ),
            ),
          if (item.soulCost != null)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF220901),
                side: const BorderSide(color: Color(0xFFDC2F02)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _handlePurchase(item, true);
              },
              icon: const Icon(Icons.diamond, color: Color(0xFFDC2F02), size: 16),
              label: Text(
                '${item.soulCost}',
                style: GoogleFonts.cinzel(color: const Color(0xFFFFF3E0), fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeState = ref.watch(storeControllerProvider);
    final activeItems = _getItemsForActiveTab();

    return Scaffold(
      backgroundColor: AppColors.abyssBlack,
      body: GothicBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // --- Top App Bar Area ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFCC7722)),
                      onPressed: () => context.go('/menu'),
                    ),
                    const Spacer(),
                    Text(
                      'THE EMPORIUM',
                      style: GoogleFonts.cinzelDecorative(
                        color: const Color(0xFFFFB703),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4.0,
                      ),
                    ),
                    const Spacer(),
                    // Currencies
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF140700).withOpacity(0.8),
                        border: Border.all(color: const Color(0xFF6B2700)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.diamond, color: Color(0xFFDC2F02), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${storeState.soulFragments}',
                            style: GoogleFonts.cinzel(color: const Color(0xFFFFF3E0), fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.circle, color: Color(0xFFFFBA08), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${storeState.goldCoins}',
                            style: GoogleFonts.cinzel(color: const Color(0xFFFFF3E0), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- Main Layout ---
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Sidebar Tabs ---
                    Container(
                      width: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0400).withOpacity(0.6),
                        border: const Border(right: BorderSide(color: Color(0xFF4A1A00))),
                      ),
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _tabs.length,
                        itemBuilder: (context, index) {
                          final isActive = _activeTabIndex == index;
                          return InkWell(
                            onTap: () => setState(() => _activeTabIndex = index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                              decoration: BoxDecoration(
                                color: isActive ? const Color(0xFF220901) : Colors.transparent,
                                border: Border(
                                  left: BorderSide(
                                    color: isActive ? const Color(0xFFFF7200) : Colors.transparent,
                                    width: 4,
                                  ),
                                ),
                              ),
                              child: Text(
                                _tabs[index],
                                style: GoogleFonts.cinzel(
                                  color: isActive ? const Color(0xFFFF9E00) : const Color(0xFF8B4500),
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                                  letterSpacing: 1.5,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // --- Grid Area ---
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: activeItems.isEmpty
                            ? Center(
                                child: Text(
                                  'THE SHELVES ARE BARE...',
                                  style: GoogleFonts.cinzel(
                                    color: const Color(0xFF8B4500),
                                    fontSize: 16,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              )
                            : GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : (MediaQuery.of(context).size.width > 500 ? 3 : 2),
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                  childAspectRatio: 0.7,
                                ),
                                itemCount: activeItems.length,
                                itemBuilder: (context, index) {
                                  final item = activeItems[index];
                                  final isOwned = storeState.ownedItemIds.contains(item.id);
                                  final isEquipped = storeState.equippedDollId == item.id || storeState.equippedBoardId == item.id;
                                  final canAffordWithGold = item.goldCost != null && storeState.goldCoins >= item.goldCost!;
                                  final canAffordWithSouls = item.soulCost != null && storeState.soulFragments >= item.soulCost!;
                                  final canAfford = canAffordWithGold || canAffordWithSouls;

                                  return _StoreItemCard(
                                    item: item,
                                    isOwned: isOwned,
                                    isEquipped: isEquipped,
                                    canAfford: canAfford,
                                    onTap: () {
                                      if (isOwned && item.type != StoreItemType.currency && item.type != StoreItemType.cardPack) {
                                        if (!isEquipped) {
                                          _handleEquip(item);
                                        }
                                        return;
                                      }
                                      _showPurchaseDialog(item);
                                    },
                                  ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideY(begin: 0.1);
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreItemCard extends StatelessWidget {
  final StoreItem item;
  final bool isOwned;
  final bool isEquipped;
  final bool canAfford;
  final VoidCallback onTap;

  const _StoreItemCard({
    required this.item,
    required this.isOwned,
    required this.isEquipped,
    required this.canAfford,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUniqueItem = item.type != StoreItemType.currency && item.type != StoreItemType.cardPack;
    final opacity = (isOwned && isUniqueItem && !isEquipped) ? 0.6 : 1.0;

    Color borderColor = const Color(0xFF4A1A00);
    if (isEquipped) {
      borderColor = const Color(0xFFFF9E00);
    } else if (isOwned && isUniqueItem) {
      borderColor = const Color(0xFF9D0208);
    }

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: opacity,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF140700).withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isEquipped ? 2.5 : 1.5),
            boxShadow: isEquipped ? [
              BoxShadow(
                color: const Color(0xFFFF6D00).withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 1,
              )
            ] : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image / Icon Area
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D0200),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                  child: Center(
                    child: Icon(
                      _getIconForType(item.type),
                      size: 48,
                      color: const Color(0xFFD48A42),
                    ),
                  ),
                ),
              ),
              
              // Name & Cost Area
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cinzel(
                          color: const Color(0xFFFFF3E0),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      if (isEquipped)
                        Text(
                          'EQUIPPED',
                          style: GoogleFonts.cinzel(
                            color: const Color(0xFFFFBA08),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        )
                      else if (isOwned && isUniqueItem)
                        Text(
                          'OWNED',
                          style: GoogleFonts.cinzel(
                            color: const Color(0xFFDC2F02),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (item.goldCost != null) ...[
                              const Icon(Icons.circle, color: Color(0xFFFFBA08), size: 12),
                              const SizedBox(width: 4),
                              Text(
                                '${item.goldCost}',
                                style: TextStyle(
                                  color: canAfford ? const Color(0xFFFFF3E0) : const Color(0xFF9D0208),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              if (item.soulCost != null) const SizedBox(width: 8),
                            ],
                            if (item.soulCost != null) ...[
                              const Icon(Icons.diamond, color: Color(0xFFDC2F02), size: 12),
                              const SizedBox(width: 4),
                              Text(
                                '${item.soulCost}',
                                style: TextStyle(
                                  color: canAfford ? const Color(0xFFFFF3E0) : const Color(0xFF9D0208),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(StoreItemType type) {
    switch (type) {
      case StoreItemType.doll:
        return Icons.smart_toy_rounded;
      case StoreItemType.cardPack:
        return Icons.style_rounded;
      case StoreItemType.boardTheme:
        return Icons.grid_4x4_rounded;
      case StoreItemType.currency:
        return Icons.monetization_on_rounded;
    }
  }
}
