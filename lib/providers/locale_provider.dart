import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale;

  // Başlangıçta varsayılan dil (Telefonun dili neyse o olsun istersek null bırakabiliriz ama şimdilik Türkçe başlasın)
  LocaleProvider() : _locale = const Locale('tr') {
    _loadFromPrefs(); // Hafızadan oku
  }

  Locale get locale => _locale;

  // Dili Değiştirme Fonksiyonu
  void setLocale(Locale locale) {
    if (!['tr', 'en'].contains(locale.languageCode)) return;

    _locale = locale;
    _saveToPrefs(locale); // Kaydet
    notifyListeners(); // TÜM UYGULAMAYI GÜNCELLE 🔔
  }

  // Hafızadan Okuma
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? langCode = prefs.getString('language_code');
    
    if (langCode != null) {
      _locale = Locale(langCode);
      notifyListeners();
    }
  }

  // Hafızaya Yazma
  Future<void> _saveToPrefs(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }
}
