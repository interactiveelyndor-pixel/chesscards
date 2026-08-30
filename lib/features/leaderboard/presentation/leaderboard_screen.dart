import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../theme/app_colors.dart';
import '../../../../shared/widgets/gothic_background.dart';
import '../application/leaderboard_service.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaderboardServiceProvider).ensurePlayerRegistered();
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPlayersAsync = ref.watch(topPlayersProvider);
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

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
                    Expanded(
                      child: Text(
                        'LEADERBOARD',
                        style: GoogleFonts.cinzelDecorative(
                          color: const Color(0xFFFFB703),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4.0,
                          shadows: const [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance for back button
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.2),

              const SizedBox(height: 20),
              
              // --- Headers ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Row(
                  children: [
                    const SizedBox(width: 40), // Rank offset
                    Expanded(
                      flex: 3,
                      child: Text('NAME', style: _headerStyle()),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('WINS', style: _headerStyle(), textAlign: TextAlign.right),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('SOULS', style: _headerStyle(), textAlign: TextAlign.right),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFFCC7722), thickness: 1, indent: 24, endIndent: 24),

              // --- List ---
              Expanded(
                child: topPlayersAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF9E00)),
                  ),
                  error: (error, stack) => Center(
                    child: Text('Failed to load the abyss: $error', style: const TextStyle(color: Colors.red)),
                  ),
                  data: (players) {
                    if (players.isEmpty) {
                      return Center(
                        child: Text(
                          'NO SOULS CLAIMED YET...',
                          style: GoogleFonts.cinzel(color: const Color(0xFFAD5C00), fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        final player = players[index];
                        final rank = index + 1;
                        final isMe = player.uid == currentUid;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFFCC7722).withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isMe ? Border.all(color: const Color(0xFFFF9E00), width: 1.5) : null,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 30,
                                child: Text(
                                  '#$rank',
                                  style: GoogleFonts.cinzel(
                                    color: _getRankColor(rank, isMe),
                                    fontWeight: FontWeight.bold,
                                    fontSize: rank <= 3 ? 18 : 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  player.displayName,
                                  style: GoogleFonts.cinzel(
                                    color: isMe ? const Color(0xFFFFD166) : const Color(0xFFD48A42),
                                    fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${player.multiplayerWins}',
                                  style: GoogleFonts.cinzel(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${player.totalSouls}',
                                  style: GoogleFonts.cinzelDecorative(
                                    color: const Color(0xFFFF9E00),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideX(begin: -0.1);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _headerStyle() {
    return GoogleFonts.cinzel(
      color: const Color(0xFF8B4500),
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 2.0,
    );
  }

  Color _getRankColor(int rank, bool isMe) {
    if (rank == 1) return const Color(0xFFFFD700); // Gold
    if (rank == 2) return const Color(0xFFC0C0C0); // Silver
    if (rank == 3) return const Color(0xFFCD7F32); // Bronze
    return isMe ? const Color(0xFFFF9E00) : const Color(0xFFAD5C00);
  }
}
