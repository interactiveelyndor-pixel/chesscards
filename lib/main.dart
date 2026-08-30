import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:applovin_max/applovin_max.dart';
import 'app/app.dart';
import 'core/services/settings_service.dart';
import 'core/services/ad_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // Initialize AppLovin MAX SDK before game UI loads
  try {
    if (!kIsWeb) {
      await AppLovinMAX.initialize('YOUR_SDK_KEY');
      // Attach InterstitialListener and pre-load full-screen interstitial ad on launch
      AdManager.instance.initialize();
    }
  } catch (e) {
    debugPrint('AppLovin MAX initialization error: $e');
  }

  try {
    // Non-blocking Firebase init with timeout
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 2));

    if (!kIsWeb) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    }
  } catch (e) {
    debugPrint('Firebase init (non-blocking fallback): $e');
  }

  // Lock orientation to portrait (mobile only)
  if (!kIsWeb) {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } catch (_) {}
  }

  final prefs = await SharedPreferences.getInstance();
  final settingsService = SettingsService(prefs);

  FlutterNativeSplash.remove();

  runApp(
    ProviderScope(
      overrides: [
        settingsServiceProvider.overrideWithValue(settingsService),
      ],
      child: const ChessParanoiaApp(),
    ),
  );
}
