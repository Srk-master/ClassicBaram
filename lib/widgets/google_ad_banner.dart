/*import 'package:flutter/material.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';

class GoogleAdBanner extends StatefulWidget {
  final String adUnitId;

  const GoogleAdBanner(
      {
        super.key,
        required this.adUnitId
      }
      ); //광고 단위 id
  @override
  State<StatefulWidget> createState() => _GoogleAdBannerState();
}

class _GoogleAdBannerState extends State<GoogleAdBanner> {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();

    //배너 광고 초기화
    _bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: widget.adUnitId,
        request: AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            setState(() {
              _isAdLoaded = true;
            });
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('Ad failed to load: $error');
            ad.dispose();
          },
        ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isAdLoaded
        ? Container(
            alignment: Alignment.center,
            width: _bannerAd.size.width.toDouble(),
            height: _bannerAd.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd),
        )
        : SizedBox(
            height: 50,
            child: Center(child: Text('Loading Ad...')),
        );
  }
}*/