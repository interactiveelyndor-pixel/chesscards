import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:super_chess/theme/app_colors.dart';
import 'package:super_chess/shared/widgets/gothic_background.dart';
import 'package:super_chess/shared/widgets/gothic_button.dart';
import '../application/daily_controller.dart';
import '../domain/daily_reward_state.dart';
import '../domain/daily_contract.dart';

class DailyHubScreen extends ConsumerStatefulWidget {
  const DailyHubScreen({super.key});

  @override
  ConsumerState<DailyHubScreen> createState() => _DailyHubScreenState();
}

class _DailyHubScreenState extends ConsumerState<DailyHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dailyState = ref.watch(dailyControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.abyssBlack,
      body: GothicBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.candleIvory),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DAILY RITUALS',
                            style: GoogleFonts.cinzelDecorative(
                              color: AppColors.runeGold,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            'The spirits demand daily tribute...',
                            style: GoogleFonts.cinzel(
                              color: AppColors.fogGray,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Tab Bar ─────────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF140700),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF4A1A00), width: 1.5),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.center,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9E00), Color(0xFF8B4500)],
                    ),
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: AppColors.fogGray,
                  labelStyle: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 12),
                  unselectedLabelStyle: GoogleFonts.cinzel(fontSize: 11),
                  tabs: const [
                    Tab(icon: Icon(Icons.wb_twilight, size: 16), text: '7-Day Séance'),
                    Tab(icon: Icon(Icons.history_edu, size: 16), text: "Witch's Ledger"),
                    Tab(icon: Icon(Icons.auto_awesome, size: 16), text: 'Nightmare'),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Tab Views ───────────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _SeanceTab(rewardState: dailyState.rewardState),
                    _ContractsTab(
                      contracts: dailyState.contracts,
                      allCompleted: dailyState.allContractsCompleted,
                      masterChestClaimed: dailyState.masterChestClaimed,
                    ),
                    _NightmareTab(puzzle: dailyState.puzzle),
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

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1: 7-DAY SÉANCE (DAILY LOGIN RITUAL)
// ─────────────────────────────────────────────────────────────────────────────
class _SeanceTab extends ConsumerWidget {
  final DailyRewardState rewardState;

  const _SeanceTab({required this.rewardState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B0B00).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFF9E00), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9E00).withValues(alpha: 0.2),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, color: Color(0xFFFF9E00), size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day ${rewardState.currentStreak} of 7 Lit',
                        style: GoogleFonts.cinzelDecorative(
                          color: AppColors.candleIvory,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rewardState.hasClaimedToday
                          ? 'Offering claimed! Return tomorrow at midnight.'
                          : 'A new tribute awaits your summon!',
                        style: GoogleFonts.cinzel(
                          color: rewardState.hasClaimedToday ? AppColors.fogGray : AppColors.runeGold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!rewardState.hasClaimedToday)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9E00),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    onPressed: () {
                      ref.read(dailyControllerProvider.notifier).claimDailyLoginReward();
                    },
                    child: Text(
                      'CLAIM',
                      style: GoogleFonts.cinzel(fontWeight: FontWeight.w900),
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.06, duration: 800.ms),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 7-Day Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: 7,
            itemBuilder: (context, index) {
              final reward = DailyRewardState.schedule[index];
              final isPast = index + 1 < rewardState.currentStreak ||
                  (index + 1 == rewardState.currentStreak && rewardState.hasClaimedToday);
              final isCurrent = index + 1 == rewardState.currentStreak && !rewardState.hasClaimedToday;
              final isDay7 = index == 6;

              final (IconData dayIcon, Color dayColor) = switch (index) {
                0 => (Icons.wb_twilight, AppColors.soulFlame),
                1 => (Icons.shield_rounded, AppColors.ghostBlue),
                2 => (Icons.auto_awesome, AppColors.cursePurple),
                3 => (Icons.gps_fixed_rounded, AppColors.soulFlame),
                4 => (Icons.diamond_outlined, AppColors.ghostBlue),
                5 => (Icons.wb_sunny_rounded, AppColors.runeGold),
                _ => (Icons.workspace_premium, AppColors.runeGold),
              };

              return Container(
                decoration: BoxDecoration(
                  color: isCurrent
                      ? const Color(0xFF381500)
                      : (isPast ? const Color(0xFF0F0703) : const Color(0xFF140700)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent
                        ? const Color(0xFFFF9E00)
                        : (isPast ? const Color(0xFF4A1A00) : const Color(0xFF2A0F00)),
                    width: isCurrent ? 2.0 : 1.0,
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'DAY ${reward.day}',
                      style: GoogleFonts.cinzel(
                        color: isCurrent ? AppColors.runeGold : AppColors.fogGray,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      dayIcon,
                      color: isPast ? const Color(0xFF777777) : dayColor,
                      size: isDay7 ? 28 : 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reward.description,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cinzel(
                        color: isPast ? const Color(0xFF777777) : AppColors.candleIvory,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isPast) ...[
                      const SizedBox(height: 2),
                      const Icon(Icons.check_circle, color: Color(0xFF55A630), size: 14),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2: WITCH'S LEDGER (DAILY CONTRACTS)
// ─────────────────────────────────────────────────────────────────────────────
class _ContractsTab extends ConsumerWidget {
  final List<DailyContract> contracts;
  final bool allCompleted;
  final bool masterChestClaimed;

  const _ContractsTab({
    required this.contracts,
    required this.allCompleted,
    required this.masterChestClaimed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Master Cursed Chest Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF220901),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: allCompleted ? const Color(0xFFFF9E00) : const Color(0xFF4A1A00),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.inventory_2, color: AppColors.runeGold, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Master Cursed Chest',
                        style: GoogleFonts.cinzelDecorative(
                          color: AppColors.candleIvory,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Complete all 3 daily bounties for +500 Souls!',
                        style: GoogleFonts.cinzel(
                          color: AppColors.fogGray,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                if (allCompleted && !masterChestClaimed)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9E00),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    onPressed: () {
                      ref.read(dailyControllerProvider.notifier).claimMasterChest();
                    },
                    child: Text('CLAIM', style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 11)),
                  )
                else if (masterChestClaimed)
                  const Icon(Icons.check_circle, color: Color(0xFF55A630), size: 24)
                else
                  Text(
                    '${contracts.where((c) => c.isCompleted).length}/3',
                    style: GoogleFonts.cinzel(color: AppColors.runeGold, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Contracts List
          ...contracts.map((contract) {
            final (IconData cIcon, Color cColor) = switch (contract.id) {
              'contract_first_blood' => (Icons.shield_outlined, AppColors.soulFlame),
              'contract_arcane_master' => (Icons.auto_awesome, AppColors.cursePurple),
              'contract_frost_curse' => (Icons.ac_unit, AppColors.ghostBlue),
              _ => (Icons.stars_rounded, AppColors.runeGold),
            };

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF140700),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: contract.isCompleted
                      ? const Color(0xFFFF9E00).withValues(alpha: 0.8)
                      : const Color(0xFF381500),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(cIcon, color: cColor, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contract.title,
                              style: GoogleFonts.cinzel(
                                color: AppColors.candleIvory,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              contract.description,
                              style: GoogleFonts.cinzel(color: AppColors.fogGray, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      if (contract.isCompleted && !contract.isClaimed)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9E00),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          ),
                          onPressed: () {
                            ref.read(dailyControllerProvider.notifier).claimContract(contract.id);
                          },
                          child: Text('CLAIM', style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 10)),
                        )
                      else if (contract.isClaimed)
                        const Icon(Icons.check_circle, color: Color(0xFF55A630), size: 20)
                      else
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.blur_on, color: AppColors.ghostBlue, size: 14),
                            const SizedBox(width: 3),
                            Text(
                              '+${contract.soulReward}',
                              style: GoogleFonts.cinzel(color: AppColors.runeGold, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: contract.progressRatio,
                      minHeight: 6,
                      backgroundColor: const Color(0xFF220901),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        contract.isCompleted ? const Color(0xFF55A630) : const Color(0xFFFF9E00),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${contract.currentValue} / ${contract.targetValue}',
                      style: GoogleFonts.cinzel(color: AppColors.fogGray, fontSize: 9),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3: THE DAILY NIGHTMARE (TACTICAL SPELL PUZZLE)
// ─────────────────────────────────────────────────────────────────────────────
class _NightmareTab extends ConsumerWidget {
  final dynamic puzzle;

  const _NightmareTab({required this.puzzle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isCompleted = puzzle.isCompleted;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2E0854), Color(0xFF140224)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF9D4EDD), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9D4EDD).withValues(alpha: 0.3),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFFE0AAFF), size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            puzzle.title,
                            style: GoogleFonts.cinzelDecorative(
                              color: const Color(0xFFE0AAFF),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Daily Tactical Spell Puzzle',
                            style: GoogleFonts.cinzel(color: AppColors.fogGray, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF55A630),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'SOLVED',
                          style: GoogleFonts.cinzel(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  puzzle.lore,
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFC77DFF),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: Color(0xFFFFD166), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reward: +${puzzle.soulReward} Souls, +${puzzle.xpReward} XP',
                          style: GoogleFonts.cinzel(color: AppColors.candleIvory, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GothicButton(
                  label: isCompleted ? 'REPLAY TODAY\'S PUZZLE' : 'ENTER TODAY\'S PUZZLE',
                  icon: Icons.play_arrow_rounded,
                  isPrimary: !isCompleted,
                  glowColor: const Color(0xFF9D4EDD),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B2CBF), Color(0xFF240046)],
                  ),
                  onTap: () {
                    context.push('/daily-puzzle');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Endless Hardcore Nightmare Mode Card ────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2A0909), Color(0xFF140202)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFDC2F02), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFDC2F02).withValues(alpha: 0.25),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.all_inclusive_rounded, color: Color(0xFFFFBA08), size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ENDLESS HARDCORE',
                            style: GoogleFonts.cinzelDecorative(
                              color: const Color(0xFFFFBA08),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Unlimited Master Chess Tactical Puzzles',
                            style: GoogleFonts.cinzel(color: AppColors.fogGray, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Test your mastery against an infinite gauntlet of hardcore tactical puzzles. Solve continuous puzzles to build streaks and reap unlimited Lost Souls!',
                  style: GoogleFonts.cinzel(
                    color: AppColors.candleIvory,
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 16),
                GothicButton(
                  label: 'PLAY ENDLESS NIGHTMARE',
                  icon: Icons.bolt_rounded,
                  isPrimary: true,
                  glowColor: const Color(0xFFDC2F02),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDC2F02), Color(0xFF370617)],
                  ),
                  onTap: () {
                    context.push('/daily-puzzle');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
