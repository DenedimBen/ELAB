import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'providers/locale_provider.dart';

void main() async {
  print("1. Uygulama Başlatılıyor...");
  WidgetsFlutterBinding.ensureInitialized();
  
  print("2. Binding Hazır, Firebase Kontrol Ediliyor...");
  try {
    // Android'de google-services.json otomatik başlatır, web'de manuel başlatırız
    await Firebase.initializeApp();
    print("3. Firebase BAŞARILI!");
  } catch (e) {
    print("Firebase hatası (normal olabilir): $e");
  }
  
  print("4. Arayüz Çiziliyor...");
  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-LAB',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF2E3239),
        primaryColor: Colors.amber,
      ),
      
      // --- DİL AYARLARI ---
      locale: provider.locale,
      supportedLocales: const [
        Locale('tr'), // Türkçe
        Locale('en'), // İngilizce
        Locale('es'), // İspanyolca
        Locale('zh'), // Çince
        Locale('hi'), // Hintçe
        Locale('ar'), // Arapça
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // -------------------

      home: const SplashScreen(),
    );
  }
}