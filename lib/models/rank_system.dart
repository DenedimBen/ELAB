import 'package:flutter/material.dart';

class Rank {
  final String title;
  final int minXP;
  final Color color;
  final IconData icon;

  Rank(this.title, this.minXP, this.color, this.icon);
}

class RankSystem {
  static final List<Rank> ranks = [
    Rank("Lehim Dumanı", 0, Colors.grey, Icons.smoking_rooms),
    Rank("Direnç Okuyucu", 100, const Color(0xFF795548), Icons.code),
    Rank("Kapasitör Şarjı", 300, Colors.deepOrange, Icons.battery_charging_full),
    Rank("Devre Çırağı", 600, Colors.amber, Icons.build),
    Rank("Transistör Terbiyecisi", 1000, Colors.lightGreen, Icons.settings_input_component),
    Rank("Mantık Kapısı", 1500, Colors.cyan, Icons.memory),
    Rank("Op-Amp Ustası", 2200, Colors.purpleAccent, Icons.graphic_eq),
    Rank("PCB Mimarı", 3000, Colors.greenAccent, Icons.map),
    Rank("Gömülü Sistemci", 4000, Colors.blueAccent, Icons.developer_board),
    Rank("Silikon Mühendisi", 5500, Colors.indigoAccent, Icons.computer),
    Rank("Yüksek Frekans", 7500, Colors.redAccent, Icons.wifi_tethering),
    Rank("Kuantum Mekaniği", 10000, Colors.deepPurple, Icons.auto_awesome),
    Rank("Yapay Zeka Çekirdeği", 15000, Colors.tealAccent, Icons.psychology),
    Rank("Tekillik", 25000, const Color(0xFFFFD700), Icons.all_inclusive), // Altın
    Rank("E-LAB EFSANESİ", 50000, const Color(0xFFB9F2FF), Icons.diamond), // Elmas
    Rank("SİSTEM YÖNETİCİSİ", 100000, const Color(0xFF00FF00), Icons.terminal), // Matrix
  ];

  // XP'ye göre hangi rütbede olduğunu bulur
  static Rank getRank(int xp) {
    for (int i = ranks.length - 1; i >= 0; i--) {
      if (xp >= ranks[i].minXP) {
        return ranks[i];
      }
    }
    return ranks[0];
  }

  // Bir sonraki seviyeye ne kadar kaldığını bulur (0.0 - 1.0 arası)
  static double getProgress(int xp) {
    for (int i = 0; i < ranks.length - 1; i++) {
      if (xp >= ranks[i].minXP && xp < ranks[i + 1].minXP) {
        int currentLevelXP = xp - ranks[i].minXP;
        int nextLevelGap = ranks[i + 1].minXP - ranks[i].minXP;
        return currentLevelXP / nextLevelGap;
      }
    }
    return 1.0; // Son seviye
  }
  
  // Sonraki seviyenin puanı
  static int getNextLevelXP(int xp) {
    for (int i = 0; i < ranks.length - 1; i++) {
      if (xp < ranks[i + 1].minXP) {
        return ranks[i + 1].minXP;
      }
    }
    return xp; // Max seviye
  }
}
