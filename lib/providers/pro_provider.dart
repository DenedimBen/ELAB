import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProProvider extends ChangeNotifier {
  bool _isPro = false; // Varsayılan: Ücretsiz Kullanıcı

  bool get isPro => _isPro;

  ProProvider() {
    _loadProStatus();
  }

  // Hafızadan Oku
  Future<void> _loadProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPro = prefs.getBool('is_pro_user') ?? false;
    notifyListeners();
  }

  // Satın Alma İşlemi (SİMÜLASYON)
  Future<void> activatePro() async {
    final prefs = await SharedPreferences.getInstance();
    _isPro = true;
    await prefs.setBool('is_pro_user', true);
    notifyListeners(); // Tüm uygulamaya "Reklamları Kaldır!" diye bağırır
  }

  // Üyeliği İptal Et (Test İçin)
  Future<void> deactivatePro() async {
    final prefs = await SharedPreferences.getInstance();
    _isPro = false;
    await prefs.setBool('is_pro_user', false);
    notifyListeners();
  }
}
