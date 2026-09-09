import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';

class HowToPlayModal extends StatefulWidget {
  const HowToPlayModal({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const HowToPlayModal(),
    );
  }

  @override
  State<HowToPlayModal> createState() => _HowToPlayModalState();
}

class _HowToPlayModalState extends State<HowToPlayModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 620),
        decoration: BoxDecoration(
          color: AppColors.voidPanel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.runeGold.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.menu_book, color: AppColors.runeGold, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'HOW TO PLAY',
                    style: GoogleFonts.cinzel(
                      color: AppColors.runeGold,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.fogGray),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Tabs
            TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.runeGold,
              indicatorWeight: 3,
              labelColor: AppColors.runeGold,
              unselectedLabelColor: AppColors.fogGray,
              labelStyle: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.bold),
              unselectedLabelStyle: GoogleFonts.cinzel(fontSize: 13),
              tabs: const [
                Tab(text: 'BASICS & TURNS'),
                Tab(text: 'DUAL WIN RULES'),
                Tab(text: 'SPELLS & MANA'),
                Tab(text: 'RELICS & DOLLS'),
              ],
            ),
            const Divider(color: AppColors.dimGray, height: 1),
            // Tab Contents
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBasicsTab(),
                  _buildCombatTab(),
                  _buildSpellsTab(),
                  _buildRelicsTab(),
                ],
              ),
            ),
            // Close Action
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.runeGold,
                    foregroundColor: AppColors.abyssBlack,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'GOT IT, LET\'S PLAY!',
                    style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('1. Turn Lifecycle', Icons.sync),
        _buildInfoText(
          'Each turn consists of two distinct phases:\n'
          '• Phase 1 (Move): Make your standard chess move by tapping a piece.\n'
          '• Phase 2 (Spells): Cast magical spells from your spellbook using available Mana.\n'
          '• End Turn: Tap the "END TURN" button to pass the turn to your opponent.',
        ),
        const SizedBox(height: 14),
        _buildSectionHeader('2. Starting Perspective', Icons.flag),
        _buildInfoText(
          'In Single Player & AI battles, you always play from the White side (bottom).\n'
          'In Online Multiplayer, Player 1 plays White and Player 2 plays Black (with clear indicators).',
        ),
      ],
    );
  }

  Widget _buildCombatTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Double Win Conditions', Icons.military_tech),
        _buildInfoText(
          'You can win the battle in two different ways:\n\n'
          '👑 1. Checkmate:\n'
          'Trap the enemy King so it cannot escape check (Classic Chess Victory).\n\n'
          '❤️ 2. Commander Health Defeat:\n'
          'Reduce the enemy Commander\'s HP to 0. Every piece you capture deals direct HP damage based on piece value (Pawns: 10, Knights/Bishops: 25, Rooks: 40, Queens: 75), plus damage from offensive Spells!',
        ),
      ],
    );
  }

  Widget _buildSpellsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Mana Generation', Icons.bolt),
        _buildInfoText(
          'You gain +1 Mana at the start of each turn (capped at 10 Mana). Unspent Mana carries over to future turns for powerful high-cost spells.',
        ),
        const SizedBox(height: 14),
        _buildSectionHeader('Casting Spells', Icons.auto_fix_high),
        _buildInfoText(
          '• Fireball & Lightning: Incinerate or shock enemy pieces.\n'
          '• Freeze & Blizzard: Freeze enemy pieces, skipping their movement for 1 turn.\n'
          '• Wall of Stone: Summon impenetrable barricades to protect your king.\n'
          '• Necromancy: Resurrect captured pawns back onto the board.\n'
          '• Soul Leech: Siphon enemy Mana and damage their Commander.',
        ),
      ],
    );
  }

  Widget _buildRelicsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Relics & Passives', Icons.shield),
        _buildInfoText(
          'Equip mysterious relics from your inventory before or during battle. Relics provide game-changing passive enhancements like Mana regeneration, Aegis shields, or bonus capture rewards.',
        ),
        const SizedBox(height: 14),
        _buildSectionHeader('Soul Doll Companions', Icons.psychology),
        _buildInfoText(
          'Your Soul Doll acts as your avatar. As you level up and collect dolls in the store, each companion brings unique passive affinities and atmospheric reactions to your gameplay.',
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.candleIvory, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.cinzel(
              color: AppColors.runeGold,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Text(
      text,
      style: GoogleFonts.raleway(
        color: AppColors.fogGray,
        fontSize: 13.5,
        height: 1.45,
      ),
    );
  }
}
