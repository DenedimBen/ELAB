import 'package:flutter/material.dart';
import '../services/ad_service.dart';

class BannerWrapper extends StatelessWidget {
  final Widget child; // İçine koyacağımız sayfa (Home, Tools vb.)
  
  const BannerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. ASIL SAYFA İÇERİĞİ (Kalan tüm alanı kaplasın)
        Expanded(
          child: child,
        ),

        // 2. REKLAM ALANI (En Altta Sabit)
        Container(
          width: double.infinity,
          color: const Color(0xFF1E2126), // Arka plan rengi (Sırıtmasın diye)
          child: SafeArea(
            top: false, // Üstten boşluk bırakma
            child: AdService().getBannerAdWidget(),
          ),
        ),
      ],
    );
  }
}
