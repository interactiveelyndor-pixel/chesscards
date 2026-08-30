import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:applovin_max/applovin_max.dart';

final adManagerProvider = Provider<AdManager>((ref) {
  return AdManager.instance;
});

/// Central AdManager to handle full-screen interstitial and rewarded video ads via AppLovin MAX.
class AdManager {
  static final AdManager instance = AdManager._internal();
  AdManager._internal();

  static const String interstitialAdUnitId = 'YOUR_INTERSTITIAL_ID';
  static const String rewardedAdUnitId = 'YOUR_REWARDED_ID';

  bool _isInterstitialReady = false;
  int _interstitialRetryAttempt = 0;

  bool _isRewardedReady = false;
  int _rewardedRetryAttempt = 0;

  VoidCallback? _onRewardedCallback;

  bool get _isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Attaches InterstitialListener & RewardedAdListener to pre-load full-screen ads on startup.
  void initialize() {
    if (!_isSupportedPlatform) return;

    try {
      // ── Interstitial Ad Listener ──────────────────────────────────────
      AppLovinMAX.setInterstitialListener(
        InterstitialListener(
          onAdLoadedCallback: (ad) {
            _isInterstitialReady = true;
            _interstitialRetryAttempt = 0;
            debugPrint('AppLovin MAX Interstitial Loaded: ${ad.adUnitId}');
          },
          onAdLoadFailedCallback: (adUnitId, error) {
            _isInterstitialReady = false;
            _interstitialRetryAttempt++;
            final retryDelay = Duration(seconds: min(64, pow(2, min(6, _interstitialRetryAttempt)).toInt()));
            debugPrint('AppLovin MAX Interstitial Load Failed ($adUnitId): ${error.message}. Retrying in ${retryDelay.inSeconds}s');
            Future.delayed(retryDelay, () {
              loadInterstitial();
            });
          },
          onAdDisplayedCallback: (ad) {
            debugPrint('AppLovin MAX Interstitial Displayed: ${ad.adUnitId}');
          },
          onAdDisplayFailedCallback: (ad, error) {
            _isInterstitialReady = false;
            debugPrint('AppLovin MAX Interstitial Display Failed: ${error.message}');
            loadInterstitial();
          },
          onAdClickedCallback: (ad) {
            debugPrint('AppLovin MAX Interstitial Clicked: ${ad.adUnitId}');
          },
          onAdHiddenCallback: (ad) {
            _isInterstitialReady = false;
            debugPrint('AppLovin MAX Interstitial Dismissed. Immediately triggering background pre-load for next ad...');
            loadInterstitial();
          },
        ),
      );

      // ── Rewarded Ad Listener ──────────────────────────────────────────
      AppLovinMAX.setRewardedAdListener(
        RewardedAdListener(
          onAdLoadedCallback: (ad) {
            _isRewardedReady = true;
            _rewardedRetryAttempt = 0;
            debugPrint('AppLovin MAX Rewarded Ad Loaded: ${ad.adUnitId}');
          },
          onAdLoadFailedCallback: (adUnitId, error) {
            _isRewardedReady = false;
            _rewardedRetryAttempt++;
            final retryDelay = Duration(seconds: min(64, pow(2, min(6, _rewardedRetryAttempt)).toInt()));
            debugPrint('AppLovin MAX Rewarded Ad Load Failed ($adUnitId): ${error.message}. Retrying in ${retryDelay.inSeconds}s');
            Future.delayed(retryDelay, () {
              loadRewardedAd();
            });
          },
          onAdDisplayedCallback: (ad) {
            debugPrint('AppLovin MAX Rewarded Ad Displayed: ${ad.adUnitId}');
          },
          onAdDisplayFailedCallback: (ad, error) {
            _isRewardedReady = false;
            debugPrint('AppLovin MAX Rewarded Ad Display Failed: ${error.message}');
            loadRewardedAd();
          },
          onAdClickedCallback: (ad) {
            debugPrint('AppLovin MAX Rewarded Ad Clicked: ${ad.adUnitId}');
          },
          onAdHiddenCallback: (ad) {
            _isRewardedReady = false;
            debugPrint('AppLovin MAX Rewarded Ad Dismissed. Immediately triggering background pre-load for next ad...');
            loadRewardedAd();
          },
          onAdReceivedRewardCallback: (ad, reward) {
            debugPrint('AppLovin MAX Rewarded Ad Completed! Granting player reward: ${reward.label}');
            _onRewardedCallback?.call();
            _onRewardedCallback = null;
          },
        ),
      );

      // Initial pre-load on app startup
      loadInterstitial();
      loadRewardedAd();
    } catch (e) {
      debugPrint('AdManager.initialize platform error: $e');
    }
  }

  /// Pre-loads an interstitial ad in the background.
  void loadInterstitial() {
    if (!_isSupportedPlatform) return;
    try {
      debugPrint('Pre-loading AppLovin MAX Interstitial: $interstitialAdUnitId');
      AppLovinMAX.loadInterstitial(interstitialAdUnitId);
    } catch (e) {
      debugPrint('AdManager.loadInterstitial platform error: $e');
    }
  }

  /// Pre-loads a rewarded ad in the background on startup and after dismissals.
  void loadRewardedAd() {
    if (!_isSupportedPlatform) return;
    try {
      debugPrint('Pre-loading AppLovin MAX Rewarded Ad: $rewardedAdUnitId');
      AppLovinMAX.loadRewardedAd(rewardedAdUnitId);
    } catch (e) {
      debugPrint('AdManager.loadRewardedAd platform error: $e');
    }
  }

  /// Shows the interstitial ad if ready. Call this exclusively on game-over states.
  Future<bool> showGameOverInterstitial() async {
    if (!_isSupportedPlatform) return false;

    try {
      final isReady = await AppLovinMAX.isInterstitialReady(interstitialAdUnitId) ?? _isInterstitialReady;
      if (isReady) {
        debugPrint('Showing Game-Over Interstitial Ad: $interstitialAdUnitId');
        AppLovinMAX.showInterstitial(interstitialAdUnitId);
        return true;
      } else {
        debugPrint('Game-Over Interstitial was not ready. Triggering background pre-load.');
        loadInterstitial();
        return false;
      }
    } catch (e) {
      debugPrint('AdManager.showGameOverInterstitial platform error: $e');
      return false;
    }
  }

  /// Triggers a rewarded video ad.
  /// If the video is successfully completed by the user, [onRewarded] callback is executed.
  Future<bool> showRewardedAd({required VoidCallback onRewarded}) async {
    if (!_isSupportedPlatform) {
      // In development/test/unsupported platforms, grant reward directly for simulation
      onRewarded();
      return true;
    }

    try {
      final isReady = await AppLovinMAX.isRewardedAdReady(rewardedAdUnitId) ?? _isRewardedReady;
      if (isReady) {
        _onRewardedCallback = onRewarded;
        debugPrint('Showing Rewarded Ad: $rewardedAdUnitId');
        AppLovinMAX.showRewardedAd(rewardedAdUnitId);
        return true;
      } else {
        debugPrint('Rewarded Ad was not ready. Triggering background load.');
        loadRewardedAd();
        return false;
      }
    } catch (e) {
      debugPrint('AdManager.showRewardedAd platform error: $e');
      return false;
    }
  }

  bool get isInterstitialReady => _isInterstitialReady;
  bool get isRewardedReady => _isRewardedReady;
}
