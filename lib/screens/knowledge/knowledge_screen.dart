import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';

class KnowledgeScreen extends StatelessWidget {
  const KnowledgeScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context)!;

    // ZENGİNLEŞTİRİLMİŞ BİLGİ BANKASI
    final List<Map<String, dynamic>> topics = [
      {
        "title": text.basicLaws,
        "icon": Icons.balance,
        "color": Colors.amber,
        "items": [
          {"t": "Ohm Kanunu", "f": "V = I × R", "d": "Voltaj = Akım x Direnç. Elektroniğin en temel yasasıdır."},
          {"t": "Güç (DC)", "f": "P = V × I", "d": "Güç, voltaj ve akımın çarpımıdır."},
          {"t": "Kirchhoff Akım (KCL)", "f": "ΣIgiren = ΣIçıkan", "d": "Bir düğüme giren akımların toplamı, çıkanlara eşittir."},
        ]
      },
      {
        "title": text.acCircuits,
        "icon": Icons.waves,
        "color": Colors.cyanAccent,
        "items": [
          {"t": "Frekans", "f": "f = 1 / T", "d": "Saniyedeki döngü sayısı. T = Periyot."},
          {"t": "Empedans (Z)", "f": "Z = √(R² + X²)", "d": "AC devrelerdeki toplam direnç (Reel + Sanal)."},
          {"t": "Rezonans", "f": "f = 1 / (2π√LC)", "d": "Endüktif ve Kapasitif reaktansın eşitlendiği an."},
        ]
      },
      {
        "title": text.catDiodes,
        "icon": Icons.flash_on,
        "color": Colors.orangeAccent,
        "items": [
          {"t": "İletim Voltajı (Vf)", "f": "Si: 0.7V, Ge: 0.3V", "d": "Diyotun iletime geçmesi için gereken minimum voltaj."},
          {"t": "Zener Diyot", "f": "Vz = Sabit", "d": "Ters polaramada belirli bir voltajı sabit tutar."},
        ]
      },
      {
        "title": text.digitalLogic,
        "icon": Icons.memory,
        "color": Colors.greenAccent,
        "items": [
          {"t": "AND Kapısı", "f": "Y = A . B", "d": "Sadece her iki giriş de 1 ise çıkış 1 olur."},
          {"t": "OR Kapısı", "f": "Y = A + B", "d": "Girişlerden en az biri 1 ise çıkış 1 olur."},
          {"t": "Logic Levels", "f": "TTL: 5V, CMOS: 3.3V", "d": "Dijital devrelerin lojik 1 ve 0 voltaj seviyeleri."},
        ]
      },
      {
        "title": "SMD KODLARI",
        "icon": Icons.qr_code,
        "color": Colors.purpleAccent,
        "items": [
          {"t": "Direnç (3 Digit)", "f": "103 = 10kΩ", "d": "İlk iki rakam değer, son rakam sıfır sayısı."},
          {"t": "Kondansatör", "f": "104 = 100nF", "d": "PikoFarad (pF) cinsinden hesaplanır."},
        ]
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF202329),
      body: CustomScrollView(
        slivers: [
          // 1. HAVALI KAYAN BAŞLIK (SLIVER APP BAR)
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF202329),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(text.knowledgeBase, 
                  style: GoogleFonts.orbitron(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16,
                      shadows: const [BoxShadow(color: Colors.blueAccent, blurRadius: 10)]
                  )),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.blue.withValues(alpha: 0.2), const Color(0xFF202329)]
                  )
                ),
                child: Center(child: Icon(Icons.menu_book, size: 80, color: Colors.white.withValues(alpha: 0.1))),
              ),
            ),
          ),

          // 2. İÇERİK LİSTESİ
          SliverPadding(
            padding: const EdgeInsets.all(15),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final category = topics[index];
                  return _buildCategoryGroup(category);
                },
                childCount: topics.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGroup(Map<String, dynamic> category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: const Color(0xFF30353C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (category['color'] as Color).withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))]
      ),
      child: Column(
        children: [
          // Kategori Başlığı
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: (category['color'] as Color).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20))
            ),
            child: Row(
              children: [
                Icon(category['icon'], color: category['color']),
                const SizedBox(width: 15),
                Text(category['title'], style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          // Maddeler
          ...((category['items'] as List).map((item) => _buildInfoTile(item, category['color']))),
        ],
      ),
    );
  }

  Widget _buildInfoTile(Map<String, String> item, Color color) {
    return ExpansionTile(
      collapsedIconColor: Colors.grey,
      iconColor: color,
      title: Text(item['t']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(item['f']!, style: TextStyle(color: color, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Text(item['d']!, style: const TextStyle(color: Colors.grey, height: 1.4)),
        )
      ],
    );
  }
}