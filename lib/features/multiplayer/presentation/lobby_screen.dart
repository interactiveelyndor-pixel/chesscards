import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/network/network_service.dart';
import '../../match/application/match_controller.dart';
import '../../../../shared/widgets/gothic_background.dart';
import '../../../../shared/widgets/gothic_button.dart';
import '../../../../shared/widgets/flying_bats.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  bool _isSearching = false;
  bool _matchStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSearch();
    });
  }

  void _startSearch() async {
    setState(() {
      _isSearching = true;
      _matchStarted = false;
    });
    final network = ref.read(networkServiceProvider);
    
    network.onMatchStart = (opponentId) {
      _matchStarted = true;
      ref.read(matchControllerProvider.notifier).startOnlineMatch(isPlayer1: network.isPlayer1); 

      if (mounted) {
        context.go('/match');
      }
    };

    try {
      await network.findMatch();
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    if (!_matchStarted) {
      ref.read(networkServiceProvider).leaveMatch();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.abyssBlack,
      body: GothicBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // --- Top App Bar Area ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFCC7722)),
                      onPressed: () {
                        if (_isSearching) {
                          ref.read(networkServiceProvider).leaveMatch();
                        }
                        context.go('/menu');
                      },
                    ),
                    Expanded(
                      child: Text(
                        _isSearching ? 'SUMMONING OPPONENT...' : 'MULTIPLAYER LOBBY',
                        style: GoogleFonts.cinzelDecorative(
                          color: const Color(0xFFFFB703),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3.0,
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
                    const SizedBox(width: 48), // Balance
                  ],
                ),
              ).animate(target: _isSearching ? 1 : 0).fadeIn(duration: 800.ms).slideY(begin: -0.2),

              const SizedBox(height: 10),

              // --- Sub-header ---
              Text(
                _isSearching ? 'THE VOID IS LISTENING' : 'FIND A WORTHY ADVERSARY',
                style: GoogleFonts.cinzel(
                  color: const Color(0xFFD48A42),
                  fontSize: 11,
                  letterSpacing: 6.0,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms, duration: 800.ms),

              const SizedBox(height: 40),
              const FlyingBats(height: 80),
              const Spacer(),

              // --- Search Indicator ---
              if (_isSearching)
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF9D0208).withOpacity(0.1),
                        border: Border.all(
                          color: const Color(0xFFDC2F02).withOpacity(0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9D0208).withOpacity(0.4),
                            blurRadius: 50,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.wifi_tethering_rounded,
                        size: 60,
                        color: Color(0xFFFFBA08),
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1500.ms)
                    .shimmer(duration: 1500.ms, color: const Color(0xFFFF7200)),
                    
                    const SizedBox(height: 40),
                    const CircularProgressIndicator(color: Color(0xFFE85D04))
                        .animate()
                        .fadeIn(delay: 500.ms),
                  ],
                ),

              // --- Find Match Button ---
              if (!_isSearching)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GothicButton(
                    label: 'SEARCH FOR MATCH',
                    icon: Icons.wifi_rounded,
                    isPrimary: true,
                    glowColor: const Color(0xFFFF9E00),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFF7200), Color(0xFF220901)],
                    ),
                    onTap: _startSearch,
                    delay: 0,
                  ),
                ),

              const Spacer(),

              // --- Back Button ---
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: TextButton.icon(
                  onPressed: () {
                    if (_isSearching) {
                      setState(() => _isSearching = false);
                      ref.read(networkServiceProvider).leaveMatch();
                    } else {
                      context.pop();
                    }
                  },
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF8B4500)),
                  label: Text(
                    _isSearching ? 'CANCEL SEARCH' : 'BACK TO MENU',
                    style: GoogleFonts.cinzel(
                      color: const Color(0xFFCC7722),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
