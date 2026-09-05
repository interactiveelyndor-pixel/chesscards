import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

/// Reusable Unity Ads Banner Ad Widget.
///
/// Places a [UnityBannerAd] banner with built-in top padding (default 50px)
/// to avoid accidental clicks from players trying to tap chess pieces or interactive items.
class UnityBannerAdWidget extends StatelessWidget {
  final String placementId;
  final double topPadding;
  final double bottomPadding;

  const UnityBannerAdWidget({
    super.key,
    this.placementId = 'Banner_Android',
    this.topPadding = 4.0,
    this.bottomPadding = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    // Return empty on web/desktop so no dead space is shown
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50.0,
          child: Center(
            child: UnityBannerAd(
              placementId: placementId,
              onLoad: (id) {
                debugPrint('Unity Ads Banner Loaded: $id');
              },
              onClick: (id) {
                debugPrint('Unity Ads Banner Clicked: $id');
              },
              onFailed: (id, error, message) {
                debugPrint('Unity Ads Banner Failed ($id): $error - $message');
              },
            ),
          ),
        ),
      ),
    );
  }
}
