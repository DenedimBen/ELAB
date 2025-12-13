import 'package:flutter/foundation.dart'; // kIsWeb için
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'providers/locale_provider.dart';
import 'providers/pro_provider.dart';
import 'services/ad_service.dart';

void main() async {
  // print("1. Uygulama Başlatılıyor...");
  WidgetsFlutterBinding.ensureInitialized();
  
  // Timeago Locale Ayarları (Türkçe ve İngilizce) - DÜZELTİLDİ
  timeago.setLocaleMessages('tr', timeago.TrMessages());
  timeago.setLocaleMessages('en', timeago.EnMessages());
  
  // print("2. Binding Hazır, Firebase Kontrol Ediliyor...");
  try {
    if (kIsWeb) {
      // print("Web platformu algılandı. Firebase config kontrol ediliyor...");
      // Web için Firebase options gerekli. Eğer yoksa hata vermemesi için try-catch ile sarmalıyoruz.
      // Not: Gerçek bir proje için firebase_options.dart kullanılmalıdır.
      try {
          await Firebase.initializeApp();
          // print("3. Firebase (Web) BAŞARILI!");
      } catch (e) {
          // print("UYARI: Web için Firebase başlatılamadı (Config eksik olabilir). Uygulama devam ediyor... Hata: $e");
      }
    } else {
      // Android/iOS için otomatik config
      await Firebase.initializeApp();
      // print("3. Firebase (Mobil) BAŞARILI!");
    }
  } catch (e) {
    // print("Firebase genel hatası: $e");
  }
  
  // print("4. AdMob Başlatılıyor...");
  await AdService().init();
  
  // print("5. Arayüz Çiziliyor...");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        ChangeNotifierProvider(create: (context) => ProProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. PROVIDER'I DİNLE (Dil değişince burası tetiklenir)
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-LAB',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121418),
        primaryColor: Colors.amber,
      ),
      
      // 3. DİL AYARLARINI BURAYA BAĞLA 🔗
      locale: localeProvider.locale, // Seçili dil
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr'), // Türkçe
        Locale('en'), // İngilizce
      ],
      
      home: const SplashScreen(),
    );
  }
}
