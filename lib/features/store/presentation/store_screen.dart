import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';
import '../application/store_controller.dart';
import '../domain/store_item.dart';
import '../domain/store_inventory.dart';
import '../domain/store_state.dart';
import '../../../../shared/widgets/gothic_background.dart';
import '../../../../core/services/ad_manager.dart';
import '../../../../core/audio/audio_service.dart';
import '../../../../core/audio/audio_enums.dart';
import '../../board/presentation/painters/isometric_board_painter.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  int _activeTabIndex = 0;
  String _selectedPreviewBoardId = 'board_crimson_crypt';

  final List<String> _tabs = [
    'CHESS BOARDS',
    'SOUL DOLLS',
    'OFFERINGS & GOLD',
  ];

  @override
  void initState() {
    super.initState();
    final currentEquipped = ref.read(storeControllerProvider).equippedBoardId;
    if (currentEquipped != null) {
      _selectedPreviewBoardId = currentEquipped;
    }
  }

  void _handlePurchase(StoreItem item, bool useSouls) async {
    final controller = ref.read(storeControllerProvider.notifier);
    final audio = ref.read(audioServiceProvider);
    final success = await controller.purchaseItem(item, useSouls);

    if (mounted) {
      if (success) {
        audio.playSfx(SfxType.cardPlay);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'UNLOCKED: ${item.name}',
              style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: const Color(0xFFFF7200),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'INSUFFICIENT TRIBUTES FOR ${item.name}.',
              style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: const Color(0xFFFF8888)),
            ),
            backgroundColor: const Color(0xFF220901),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleEquip(StoreItem item) {
    ref.read(audioServiceProvider).playSfx(SfxType.pieceMove);
    ref.read(storeControllerProvider.notifier).equipItem(item);
    if (item.type == StoreItemType.boardTheme) {
      setState(() => _selectedPreviewBoardId = item.id);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'EQUIPPED: ${item.name}',
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
        backgroundColor: const Color(0xFF140700).withValues(alpha: 0.96),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF8B4500), width: 2),
        ),
        title: Row(
          children: [
            Icon(item.iconData, color: const Color(0xFFFFB703), size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.name,
                style: GoogleFonts.cinzelDecorative(
                  color: const Color(0xFFFFB703),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.description,
              style: GoogleFonts.raleway(color: const Color(0xFFE0D0C0), fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Tribute Currency:',
              style: GoogleFonts.cinzel(
                color: AppColors.fogGray,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'CANCEL',
              style: GoogleFonts.cinzel(color: const Color(0xFF9D0208), fontWeight: FontWeight.bold),
            ),
          ),
          if (item.goldCost != null && item.goldCost! > 0)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF331400),
                side: const BorderSide(color: Color(0xFFFF9E00)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _handlePurchase(item, false);
              },
              icon: const Icon(Icons.monetization_on, color: Color(0xFFFFBA08), size: 16),
              label: Text(
                '${item.goldCost} GOLD',
                style: GoogleFonts.cinzel(color: const Color(0xFFFFF3E0), fontWeight: FontWeight.bold),
              ),
            ),
          if (item.soulCost != null && item.soulCost! > 0)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF220901),
                side: const BorderSide(color: Color(0xFFDC2F02)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _handlePurchase(item, true);
              },
              icon: const Icon(Icons.diamond_rounded, color: Color(0xFFDC2F02), size: 16),
              label: Text(
                '${item.soulCost} SOULS',
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

    return Scaffold(
      backgroundColor: AppColors.abyssBlack,
      body: GothicBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildTopHeader(storeState),
              _buildCategoryTabs(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_activeTabIndex == 0) ...[
                        _buildLiveBoardPreview(storeState),
                        const SizedBox(height: 16),
                        _buildBoardGrid(storeState),
                      ] else if (_activeTabIndex == 1) ...[
                        _buildDollGrid(storeState),
                      ] else ...[
                        _buildDailyGeneratorsSection(storeState),
                        const SizedBox(height: 16),
                        _buildCurrencyExchangeGrid(storeState),
                      ],
                      const SizedBox(height: 24),
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

  Widget _buildTopHeader(StoreState storeState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFCC7722)),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/menu');
              }
            },
          ),
          Expanded(
            child: Text(
              'CURSED SANCTUM',
              style: GoogleFonts.cinzelDecorative(
                color: const Color(0xFFFFB703),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                shadows: const [
                  Shadow(color: Colors.black, blurRadius: 10),
                ],
              ),
              textAlign: TextAlign.left,
            ),
          ),
          // Souls Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF220901),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFDC2F02), width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.diamond_rounded, color: Color(0xFFDC2F02), size: 14),
                const SizedBox(width: 4),
                Text(
                  '${storeState.soulFragments}',
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFFFF3E0),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Gold Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2B1700),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFB703), width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: Color(0xFFFFB703), size: 14),
                const SizedBox(width: 4),
                Text(
                  '${storeState.goldCoins}',
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFFFF3E0),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF140700).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFF5E2400), width: 1),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _activeTabIndex == index;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                ref.read(audioServiceProvider).playSfx(SfxType.buttonClick);
                setState(() => _activeTabIndex = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFFE85D04), Color(0xFF9D0208)],
                        )
                      : null,
                ),
                child: Text(
                  _tabs[index],
                  style: GoogleFonts.cinzel(
                    color: isSelected ? Colors.white : const Color(0xFFD48A42),
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLiveBoardPreview(StoreState storeState) {
    final equippedId = storeState.equippedBoardId ?? 'board_crimson_crypt';
    final previewBoard = StoreInventory.boardItems.firstWhere(
      (b) => b.id == _selectedPreviewBoardId,
      orElse: () => StoreInventory.boardItems.first,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF160902).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8B4500), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9D0208).withValues(alpha: 0.2),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.remove_red_eye_rounded, color: Color(0xFFFFB703), size: 16),
              const SizedBox(width: 8),
              Text(
                'LIVE ARENA PREVIEW: ${previewBoard.name}',
                style: GoogleFonts.cinzelDecorative(
                  color: const Color(0xFFFFB703),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              if (equippedId == previewBoard.id)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'EQUIPPED',
                    style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Interactive Board Canvas Preview (8x8 mini representation)
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 260,
                height: 170,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: const Color(0xFF3A1800)),
                ),
                child: CustomPaint(
                  painter: IsometricBoardPainter(
                    gameState: null,
                    selectedTile: null,
                    hoveredTile: null,
                    highlightedMoves: const {},
                    validCardTargets: const {},
                    validSpellTargets: const {},
                    isFlipped: false,
                    equippedBoardId: _selectedPreviewBoardId,
                    glowAnimationValue: 0.5,
                    tileWidth: 30.0,
                    tileHeight: 18.0,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            previewBoard.description,
            style: GoogleFonts.raleway(
              color: const Color(0xFFD48A42),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBoardGrid(StoreState storeState) {
    const boards = StoreInventory.boardItems;
    final equippedId = storeState.equippedBoardId ?? 'board_crimson_crypt';

    return Column(
      children: boards.map((board) {
        final isOwned = storeState.ownedItemIds.contains(board.id) || board.id == 'board_crimson_crypt';
        final isEquipped = equippedId == board.id;
        final isPreviewing = _selectedPreviewBoardId == board.id;

        return GestureDetector(
          onTap: () {
            ref.read(audioServiceProvider).playSfx(SfxType.buttonClick);
            setState(() => _selectedPreviewBoardId = board.id);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isPreviewing ? const Color(0xFF260D02) : const Color(0xFF140700).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isEquipped
                    ? const Color(0xFF059669)
                    : isPreviewing
                        ? const Color(0xFFFF9E00)
                        : const Color(0xFF4A1A00),
                width: isEquipped || isPreviewing ? 2.0 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isEquipped
                        ? const Color(0xFF059669).withValues(alpha: 0.2)
                        : const Color(0xFF331400),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(board.iconData, color: const Color(0xFFFFB703), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        board.name,
                        style: GoogleFonts.cinzel(
                          color: const Color(0xFFFFB703),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        board.description,
                        style: GoogleFonts.raleway(
                          color: const Color(0xFFD48A42),
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (isEquipped)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'IN USE',
                      style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  )
                else if (isOwned)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE85D04),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    onPressed: () => _handleEquip(board),
                    child: Text(
                      'EQUIP',
                      style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  )
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9D0208),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: () => _showPurchaseDialog(board),
                    child: Text(
                      'UNLOCK',
                      style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDollGrid(StoreState storeState) {
    const dolls = StoreInventory.dollItems;

    return Column(
      children: dolls.map((doll) {
        final isOwned = storeState.ownedItemIds.contains(doll.id);
        final isEquipped = storeState.equippedDollId == doll.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF140700).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEquipped ? const Color(0xFF059669) : const Color(0xFF4A1A00),
              width: isEquipped ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF331400),
                  shape: BoxShape.circle,
                ),
                child: Icon(doll.iconData, color: const Color(0xFFFFB703), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doll.name,
                      style: GoogleFonts.cinzel(
                        color: const Color(0xFFFFB703),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doll.description,
                      style: GoogleFonts.raleway(
                        color: const Color(0xFFD48A42),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (isEquipped)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                )
              else if (isOwned)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE85D04),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () => _handleEquip(doll),
                  child: Text(
                    'EQUIP',
                    style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9D0208),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () => _showPurchaseDialog(doll),
                  child: Text(
                    'UNLOCK',
                    style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDailyGeneratorsSection(StoreState storeState) {
    final soulClaimsLeft = (3 - storeState.dailyAdSoulsClaimed).clamp(0, 3);
    final goldClaimsLeft = (3 - storeState.dailyAdGoldClaimed).clamp(0, 3);

    return Column(
      children: [
        // Daily Soul Well
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: soulClaimsLeft > 0
                  ? [const Color(0xFF220901), const Color(0xFF4A1A00)]
                  : [const Color(0xFF1A1A1A), const Color(0xFF101010)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: soulClaimsLeft > 0 ? const Color(0xFFDC2F02) : Colors.white12,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF220901),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.diamond_rounded, color: Color(0xFFDC2F02), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAILY SOUL WELL',
                      style: GoogleFonts.cinzel(
                        color: const Color(0xFFFFB703),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      soulClaimsLeft > 0
                          ? 'Watch offering video for +100 Souls ($soulClaimsLeft/3 left)'
                          : 'Well depleted for today. Returns tomorrow.',
                      style: GoogleFonts.raleway(color: const Color(0xFFD48A42), fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: soulClaimsLeft > 0 ? const Color(0xFFDC2F02) : Colors.white12,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: soulClaimsLeft > 0
                    ? () async {
                        await AdManager.instance.showRewardedAd(
                          onRewarded: () async {
                            final success = await ref.read(storeControllerProvider.notifier).claimDailyAdSouls();
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '+100 SOULS DRAWN FROM THE WELL!',
                                    style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  backgroundColor: const Color(0xFFDC2F02),
                                ),
                              );
                            }
                          },
                        );
                      }
                    : null,
                icon: const Icon(Icons.video_collection_rounded, size: 14),
                label: Text(
                  soulClaimsLeft > 0 ? '+100 SOULS' : 'CLAIMED',
                  style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
        ),

        // Alchemist's Gold Transmutation
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: goldClaimsLeft > 0
                  ? [const Color(0xFF2B1700), const Color(0xFF5E3200)]
                  : [const Color(0xFF1A1A1A), const Color(0xFF101010)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: goldClaimsLeft > 0 ? const Color(0xFFFFB703) : Colors.white12,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF2B1700),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.monetization_on, color: Color(0xFFFFB703), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ALCHEMIST'S GOLD",
                      style: GoogleFonts.cinzel(
                        color: const Color(0xFFFFB703),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      goldClaimsLeft > 0
                          ? 'Transmute void energy into +300 Gold ($goldClaimsLeft/3 left)'
                          : 'Alchemist exhausted for today. Returns tomorrow.',
                      style: GoogleFonts.raleway(color: const Color(0xFFD48A42), fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldClaimsLeft > 0 ? const Color(0xFFFF9E00) : Colors.white12,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: goldClaimsLeft > 0
                    ? () async {
                        await AdManager.instance.showRewardedAd(
                          onRewarded: () async {
                            final success = await ref.read(storeControllerProvider.notifier).claimDailyAdGold();
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '+300 GOLD TRANSMUTED!',
                                    style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                  backgroundColor: const Color(0xFFFFB703),
                                ),
                              );
                            }
                          },
                        );
                      }
                    : null,
                icon: const Icon(Icons.video_collection_rounded, size: 14, color: Colors.black),
                label: Text(
                  goldClaimsLeft > 0 ? '+300 GOLD' : 'CLAIMED',
                  style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyExchangeGrid(StoreState storeState) {
    const currencyPacks = StoreInventory.currencies;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            'TREASURY & CURRENCY CONVERSION',
            style: GoogleFonts.cinzel(
              color: const Color(0xFFFFB703),
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        ...currencyPacks.map((pack) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF140700).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4A1A00)),
            ),
            child: Row(
              children: [
                Icon(pack.iconData, color: const Color(0xFFFFB703), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pack.name,
                        style: GoogleFonts.cinzel(
                          color: const Color(0xFFFFB703),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        pack.description,
                        style: GoogleFonts.raleway(color: const Color(0xFFD48A42), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pack.soulCost != null ? const Color(0xFFDC2F02) : const Color(0xFFFF9E00),
                    foregroundColor: pack.soulCost != null ? Colors.white : Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  onPressed: () => _handlePurchase(pack, pack.soulCost != null),
                  child: Text(
                    pack.soulCost != null ? '${pack.soulCost} SOULS' : '${pack.goldCost} GOLD',
                    style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
