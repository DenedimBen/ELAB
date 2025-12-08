import 'package:flutter/material.dart';

class PackageCoordinates {
  static const Map<String, List<Offset>> data = {
    // --- 1. TO-220 (MOSFET, Regülatör) ---
    'TO-220': [
      Offset(0.42, 0.92), 
      Offset(0.50, 0.92), 
      Offset(0.58, 0.92)
    ],

    // --- 2. TO-92 (Transistörler) ---
    'TO-92': [
      Offset(0.40, 0.90), 
      Offset(0.50, 0.90), 
      Offset(0.60, 0.90)
    ],

    // --- 3. TO-126 ---
    'TO-126': [
      Offset(0.40, 0.92), 
      Offset(0.50, 0.92), 
      Offset(0.60, 0.92)
    ],

    // --- 4. TO-3 (Metal Kılıf) ---
    'TO-3': [
      Offset(0.35, 0.65), 
      Offset(0.65, 0.65), 
      Offset(0.50, 0.30), 
    ],

    // --- 5. DİYOTLAR & ZENERLER (GÜNCELLENMİŞ) ---
    // Her iki kılıf için de standart hizalama:
    // Index 0: Sol Taraf (Anot)
    // Index 1: Sağ Taraf (Katot - Çizgili Taraf)
    
    'DO-41': [
      Offset(0.10, 0.50), // Sol
      Offset(0.90, 0.50), // Sağ
    ],
    
    // BURAYI KONTROL ET: DO-35 de DO-41 ile AYNI olmalı!
    'DO-35': [
      Offset(0.10, 0.50), // Sol
      Offset(0.90, 0.50), // Sağ
    ],

    // --- 6. ENTEGRELER ---
    'DIP-8': [
      Offset(0.15, 0.20), Offset(0.15, 0.40), Offset(0.15, 0.60), Offset(0.15, 0.80),
      Offset(0.85, 0.80), Offset(0.85, 0.60), Offset(0.85, 0.40), Offset(0.85, 0.20),
    ],
    'DIP-14': [
      Offset(0.15, 0.15), Offset(0.15, 0.26), Offset(0.15, 0.37), Offset(0.15, 0.48), 
      Offset(0.15, 0.59), Offset(0.15, 0.70), Offset(0.15, 0.81),
      Offset(0.85, 0.81), Offset(0.85, 0.70), Offset(0.85, 0.59), Offset(0.85, 0.48), 
      Offset(0.85, 0.37), Offset(0.85, 0.26), Offset(0.85, 0.15),
    ],
  };
}