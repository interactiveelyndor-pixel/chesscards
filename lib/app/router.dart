import 'package:go_router/go_router.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/menu/presentation/main_menu_screen.dart';
import '../features/menu/presentation/mode_selection_screen.dart';
import '../features/menu/presentation/difficulty_screen.dart';
import '../features/match/presentation/match_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/collection/presentation/doll_collection_screen.dart';
import '../features/store/presentation/store_screen.dart';
import '../features/multiplayer/presentation/lobby_screen.dart';
import '../features/achievements/presentation/achievements_screen.dart';
import '../features/leaderboard/presentation/leaderboard_screen.dart';
import '../features/daily/presentation/daily_hub_screen.dart';
import '../features/daily/presentation/daily_nightmare_puzzle_screen.dart';
import '../features/profile/presentation/profile_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: '/daily',
      builder: (context, state) => const DailyHubScreen(),
    ),
    GoRoute(
      path: '/daily-puzzle',
      builder: (context, state) => const DailyNightmarePuzzleScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/menu',
      builder: (context, state) => const MainMenuScreen(),
    ),
    GoRoute(
      path: '/mode-select',
      builder: (context, state) => const ModeSelectionScreen(),
    ),
    GoRoute(
      path: '/lobby',
      builder: (context, state) => const LobbyScreen(),
    ),
    GoRoute(
      path: '/achievements',
      builder: (context, state) => const AchievementsScreen(),
    ),
    GoRoute(
      path: '/difficulty',
      builder: (context, state) => const DifficultyScreen(),
    ),
    GoRoute(
      path: '/collection',
      builder: (context, state) => const DollCollectionScreen(),
    ),
    GoRoute(
      path: '/store',
      builder: (context, state) => const StoreScreen(),
    ),
    GoRoute(
      path: '/match',
      builder: (context, state) => const MatchScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
