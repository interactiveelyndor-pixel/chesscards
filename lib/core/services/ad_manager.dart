import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

final adManagerProvider = Provider<AdManager>((ref) {
  return AdManager.instance;
});

/// Central AdManager to handle Unity Ads initialization, banners, interstitials, and rewarded video ads.
class AdManager {
  static final AdManager instance = AdManager._internal();
  AdManager._internal();

  /// Default Unity Game ID (Replace with your Unity Game ID from cloud.unity.com)
  static const String defaultGameId = '5834912';

  /// Standard Unity Placement IDs
  static const String interstitialPlacementId = 'Interstitial_Android';
  static const String rewardedPlacementId = 'Rewarded_Android';
  static const String bannerPlacementId = 'Banner_Android';

  bool _isInitialized = false;
  bool _isInterstitialReady = false;
  bool _isRewardedReady = false;

  bool get isInitialized => _isInitialized;
  bool get isInterstitialReady => _isInterstitialReady;
  bool get isRewardedReady => _isRewardedReady;

  bool get _isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Initializes the Unity Ads SDK before game UI loads.
  void initialize({String gameId = defaultGameId, bool testMode = true}) {
    if (!_isSupportedPlatform) return;

    try {
      UnityAds.init(
        gameId: gameId,
        testMode: testMode,
        onComplete: () {
          _isInitialized = true;
          debugPrint('Unity Ads Initialized successfully with Game ID: $gameId (testMode: $testMode)');
          loadInterstitial();
          loadRewardedAd();
        },
        onFailed: (error, message) {
          _isInitialized = false;
          debugPrint('Unity Ads Initialization Failed: $error - $message');
        },
      );
    } catch (e) {
      debugPrint('AdManager.initialize platform error: $e');
    }
  }

  /// Pre-loads an interstitial ad in the background.
  void loadInterstitial({String placementId = interstitialPlacementId}) {
    if (!_isSupportedPlatform) return;
    try {
      debugPrint('Pre-loading Unity Ads Interstitial: $placementId');
      UnityAds.load(
        placementId: placementId,
        onComplete: (id) {
          _isInterstitialReady = true;
          debugPrint('Unity Ads Interstitial Loaded: $id');
        },
        onFailed: (id, error, message) {
          _isInterstitialReady = false;
          debugPrint('Unity Ads Interstitial Load Failed ($id): $error - $message');
        },
      );
    } catch (e) {
      debugPrint('AdManager.loadInterstitial platform error: $e');
    }
  }

  /// Pre-loads a rewarded ad in the background on startup and after dismissals.
  void loadRewardedAd({String placementId = rewardedPlacementId}) {
    if (!_isSupportedPlatform) return;
    try {
      debugPrint('Pre-loading Unity Ads Rewarded Ad: $placementId');
      UnityAds.load(
        placementId: placementId,
        onComplete: (id) {
          _isRewardedReady = true;
          debugPrint('Unity Ads Rewarded Ad Loaded: $id');
        },
        onFailed: (id, error, message) {
          _isRewardedReady = false;
          debugPrint('Unity Ads Rewarded Ad Load Failed ($id): $error - $message');
        },
      );
    } catch (e) {
      debugPrint('AdManager.loadRewardedAd platform error: $e');
    }
  }

  /// Shows the interstitial ad if ready. Call this exclusively on game-over states.
  Future<bool> showGameOverInterstitial({String placementId = interstitialPlacementId}) async {
    if (!_isSupportedPlatform) return false;

    try {
      debugPrint('Showing Game-Over Unity Interstitial Ad: $placementId');
      UnityAds.showVideoAd(
        placementId: placementId,
        onStart: (id) => debugPrint('Unity Interstitial Started: $id'),
        onClick: (id) => debugPrint('Unity Interstitial Clicked: $id'),
        onSkipped: (id) {
          _isInterstitialReady = false;
          debugPrint('Unity Interstitial Skipped: $id. Pre-loading next...');
          loadInterstitial();
        },
        onComplete: (id) {
          _isInterstitialReady = false;
          debugPrint('Unity Interstitial Completed: $id. Pre-loading next...');
          loadInterstitial();
        },
        onFailed: (id, error, message) {
          _isInterstitialReady = false;
          debugPrint('Unity Interstitial Show Failed ($id): $error - $message');
          loadInterstitial();
        },
      );
      return true;
    } catch (e) {
      debugPrint('AdManager.showGameOverInterstitial platform error: $e');
      return false;
    }
  }

  /// Triggers a rewarded video ad.
  /// If the video is completed by the user, the [onRewarded] callback is executed.
  Future<bool> showRewardedAd({
    String placementId = rewardedPlacementId,
    required VoidCallback onRewarded,
  }) async {
    if (!_isSupportedPlatform) {
      // In development/test/unsupported platforms, grant reward directly for simulation
      onRewarded();
      return true;
    }

    try {
      debugPrint('Showing Unity Rewarded Ad: $placementId');
      UnityAds.showVideoAd(
        placementId: placementId,
        onStart: (id) => debugPrint('Unity Rewarded Video Started: $id'),
        onClick: (id) => debugPrint('Unity Rewarded Video Clicked: $id'),
        onSkipped: (id) {
          _isRewardedReady = false;
          debugPrint('Unity Rewarded Video Skipped: $id. No reward granted. Pre-loading next...');
          loadRewardedAd();
        },
        onComplete: (id) {
          _isRewardedReady = false;
          debugPrint('Unity Rewarded Video Completed! Granting player reward: $id');
          onRewarded();
          loadRewardedAd();
        },
        onFailed: (id, error, message) {
          _isRewardedReady = false;
          debugPrint('Unity Rewarded Video Show Failed ($id): $error - $message');
          loadRewardedAd();
        },
      );
      return true;
    } catch (e) {
      debugPrint('AdManager.showRewardedAd platform error: $e');
      return false;
    }
  }
}
