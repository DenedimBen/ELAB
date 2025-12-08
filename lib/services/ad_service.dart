import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class AdService {
  // Singleton Yapısı (Her yerden aynı servise erişmek için)
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  int _interactionCount = 0; // Tıklama sayacı
  final int _adFrequency = 3; // Kaç tıklamada bir reklam çıksın?

  // --- REKLAM KİMLİKLERİ (Şu an Test ID'leri - Canlıya geçerken değiştir!) ---
  final String _bannerId = 'ca-app-pub-3940256099942544/6300978111';
  final String _interstitialId = 'ca-app-pub-3940256099942544/1033173712';

  // 1. SERVİSİ BAŞLAT
  Future<void> init() async {
    await MobileAds.instance.initialize();
    _loadInterstitialAd(); // İlk reklamı hafızaya al
  }

  // 2. GEÇİŞ REKLAMINI YÜKLE (Hafızada beklet)
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          // Reklam kapatılınca yenisini yükle
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitialAd(); // Bir sonraki için hazırla
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (err) {
          debugPrint('Reklam Yüklenemedi: $err');
        },
      ),
    );
  }

  // 3. GEÇİŞ REKLAMINI GÖSTER (Mantıksal Kontrol ile)
  // force: true ise (Test sonu gibi) sayaca bakmadan gösterir.
  void showInterstitialAd({bool force = false}) {
    _interactionCount++;
    
    // Eğer zorunluysa VEYA sayaç dolduysa göster
    if (force || _interactionCount >= _adFrequency) {
      if (_interstitialAd != null) {
        _interstitialAd!.show();
        _interactionCount = 0; // Sayacı sıfırla
      }
    }
  }

  // 4. BANNER REKLAM OLUŞTUR (Widget Olarak Döndür)
  Widget getBannerAdWidget() {
    return _BannerAdContainer(adUnitId: _bannerId);
  }
}

// --- BANNER WIDGET (Özel İç Sınıf) ---
class _BannerAdContainer extends StatefulWidget {
  final String adUnitId;
  const _BannerAdContainer({required this.adUnitId});

  @override
  State<_BannerAdContainer> createState() => _BannerAdContainerState();
}

class _BannerAdContainerState extends State<_BannerAdContainer> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.banner, // Standart Banner (320x50)
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Banner hatası: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) return const SizedBox.shrink(); // Yüklenmediyse boşluk
    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
