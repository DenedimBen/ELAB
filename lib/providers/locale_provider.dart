import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('tr'); // Varsayılan Türkçe

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  // Dili değiştir ve kaydet
  void setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners(); // Tüm uygulamaya haber ver
    
    // Hafızaya kaydet
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  // Açılışta hafızadan oku
  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('language_code');
    
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }
}
