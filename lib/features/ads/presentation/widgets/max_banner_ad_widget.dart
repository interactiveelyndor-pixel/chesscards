import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:applovin_max/applovin_max.dart';

/// Reusable AppLovin MAX Banner Ad Widget.
///
/// Places an AppLovin [MaxAdView] banner with built-in top padding (default 50px)
/// to prevent accidental clicks when players interact with interactive game elements
/// or chess pieces.
class MaxBannerAdWidget extends StatelessWidget {
  final String adUnitId;
  final double topPadding;
  final double bottomPadding;

  const MaxBannerAdWidget({
    super.key,
    this.adUnitId = 'YOUR_BANNER_AD_UNIT_ID',
    this.topPadding = 50.0,
    this.bottomPadding = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    // Only render native MaxAdView on supported mobile platforms
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS)) {
      return Padding(
        padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
        child: const SizedBox(height: 50),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50.0,
          child: Center(
            child: MaxAdView(
              adUnitId: adUnitId,
              adFormat: AdFormat.banner,
              listener: AdViewAdListener(
                onAdLoadedCallback: (ad) {
                  debugPrint('AppLovin MAX Banner loaded: ${ad.adUnitId}');
                },
                onAdLoadFailedCallback: (adUnitId, error) {
                  debugPrint('AppLovin MAX Banner failed to load: $adUnitId (${error.message})');
                },
                onAdClickedCallback: (ad) {
                  debugPrint('AppLovin MAX Banner clicked: ${ad.adUnitId}');
                },
                onAdExpandedCallback: (ad) {},
                onAdCollapsedCallback: (ad) {},
              ),
            ),
          ),
        ),
      ),
    );
  }
}
