import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// Google's public test unit ID. Swap for the real AdMob banner unit ID
// before Play release, alongside the app ID in AndroidManifest.xml.
const _testAndroidBannerUnitId = 'ca-app-pub-3940256099942544/6300978111';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;

  @override
  void initState() {
    super.initState();
    final ad = BannerAd(
      adUnitId: _testAndroidBannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _ad = ad as BannerAd),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    );
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null) return const SizedBox.shrink();
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
