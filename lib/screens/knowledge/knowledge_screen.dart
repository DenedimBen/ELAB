import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';
import 'package:flutter_application_1/screens/knowledge/knowledge_detail_screen.dart';

class KnowledgeScreen extends StatelessWidget {
  const KnowledgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context)!;

    // --- KATEGORİ VERİLERİ (SADECE TEORİK BİLGİLER) ---
    final List<Map<String, dynamic>> categories = [
      {
        "title": text.kbPinouts, // Konnektör Pinoutları (USB, HDMI vb.)
        "color": const Color(0xFF2962FF), // Mavi
        "icon": Icons.cable, 
        "items": [
          {"name": "USB Types (A, B, C)", "icon": Icons.usb, "path": "assets/pinouts/usb_types.png", "desc": "Pin configurations"},
          {"name": "RJ45 Ethernet", "icon": Icons.lan, "path": "assets/pinouts/rj45.png", "desc": "T568A vs T568B"},
          {"name": "HDMI Pinout", "icon": Icons.tv, "path": "assets/pinouts/hdmi.png", "desc": "Standard HDMI Connector"},
        ]
      },
      {
        "title": text.kbProtocols,
        "color": const Color(0xFF00C853), // Yeşil
        "icon": Icons.compare_arrows,
        "items": [
          {"name": "I2C (Inter-Integrated Circuit)", "icon": Icons.share, "path": "assets/protocols/i2c.png", "desc": "SDA, SCL - Address based"},
          {"name": "SPI (Serial Peripheral Interface)", "icon": Icons.cable, "path": "assets/protocols/spi.png", "desc": "MISO, MOSI, SCK, CS"},
          {"name": "UART (Serial)", "icon": Icons.settings_ethernet, "path": "assets/protocols/uart.png", "desc": "TX, RX - Asynchronous"},
          {"name": "CAN Bus", "icon": Icons.directions_car, "path": "assets/protocols/canbus.png", "desc": "Automotive protocol"},
        ]
      },
      {
        "title": text.kbCheatsheets,
        "color": const Color(0xFFFFAB00), // Amber
        "icon": Icons.table_chart,
        "items": [
          {"name": "AWG Kablo Cetveli", "icon": Icons.linear_scale, "path": "assets/tables/awg.png", "desc": "Amper taşıma kapasiteleri"},
          {"name": "IP Koruma Sınıfları", "icon": Icons.water_drop, "path": "assets/tables/ip_ratings.png", "desc": "IP67, IP68 anlamları"},
          {"name": "PCB Yol Genişliği", "icon": Icons.map, "path": "assets/tables/pcb_trace.png", "desc": "1oz Bakır için akım değerleri"},
          {"name": "Pil Voltajları", "icon": Icons.battery_charging_full, "path": "assets/tables/batteries.png", "desc": "Li-Ion, LiFePO4, NiMH"},
        ]
      },
      {
        "title": text.kbSymbols,
        "color": const Color(0xFFD50000), // Kırmızı
        "icon": Icons.extension,
        "items": [
          {"name": "Temel Bileşenler", "icon": Icons.check_box_outline_blank, "path": "assets/symbols/basic.png", "desc": "Direnç, Kapasitör, Bobin"},
          {"name": "Yarı İletkenler", "icon": Icons.device_hub, "path": "assets/symbols/semiconductors.png", "desc": "Diyot, Transistör, MOSFET"},
          {"name": "Anahtarlar & Röleler", "icon": Icons.toggle_on, "path": "assets/symbols/switches.png", "desc": "SPST, DPDT, Röle"},
        ]
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1E2126),
      appBar: AppBar(
        title: Text(text.knowledgeBase, style: GoogleFonts.orbitron(color: Colors.amber, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.1,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryDetailScreen(
                      title: cat['title'],
                      items: cat['items'],
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (cat['color'] as Color).withOpacity(0.2),
                      (cat['color'] as Color).withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: (cat['color'] as Color).withOpacity(0.5), width: 1),
                  boxShadow: [BoxShadow(color: (cat['color'] as Color).withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: (cat['color'] as Color).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(cat['icon'], size: 40, color: cat['color']),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      cat['title'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.teko(
                        color: Colors.white, 
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1
                      ),
                    ),
                    Text(
                      "${(cat['items'] as List).length} İçerik",
                      style: TextStyle(color: Colors.grey[400], fontSize: 10),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}