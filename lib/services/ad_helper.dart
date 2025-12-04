import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  // TEST REKLAM ID'LERİ (Google'ın Resmi Test ID'leri - Güvenli)
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else {
      return 'ca-app-pub-3940256099942544/2934735716'; // iOS Test ID
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else {
      return 'ca-app-pub-3940256099942544/4411468910'; // iOS Test ID
    }
  }

  // Geçiş Reklamı Değişkeni
  InterstitialAd? _interstitialAd;

  // Reklamı Yükle
  void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (err) {
          print('Reklam Yüklenemedi: ${err.message}');
          _interstitialAd = null;
        },
      ),
    );
  }

  // Reklamı Göster
  void showInterstitial() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null; // Gösterdikten sonra sil
      loadInterstitial(); // Bir sonraki için yenisini yükle
    }
  }
}
