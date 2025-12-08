import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../test_engine/test_screen.dart';

class ComponentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> componentData;

  const ComponentDetailScreen({super.key, required this.componentData});

  @override
  Widget build(BuildContext context) {
    // Verileri Güvenli Çek
    final String id = componentData['id'] ?? 'Unknown';
    final String package = componentData['package'] ?? 'N/A';
    final String category = componentData['category'] ?? 'General';
    final String desc = componentData['description'] ?? 'No description available.';
    final String pinout = componentData['pinout_code'] ?? '123';
    
    // Değerlerin sonuna birim ekle
    final String vMax = "${componentData['vmax']}V";
    final String iMax = "${componentData['imax']}A";
    final String pMax = "${componentData['power_max'] ?? '0'}W";

    return Scaffold(
      backgroundColor: const Color(0xFF121418), // Çok koyu gri (Cyberpunk Dark)
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 1. KAYAN BAŞLIK VE RESİM
              SliverAppBar(
                expandedHeight: 280.0,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF1E2126),
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(id, style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, shadows: [const Shadow(color: Colors.black, blurRadius: 10)])),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [const Color(0xFF2E3239), const Color(0xFF121418)],
                      ),
                    ),
                    child: Center(
                      child: Hero(
                        tag: id, // Animasyonlu geçiş için
                        child: Image.asset(
                          'assets/packages/${package.toLowerCase()}.png',
                          height: 180,
                          errorBuilder: (c, o, s) => const Icon(Icons.memory, size: 80, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 2. İÇERİK GÖVDESİ
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      // KATEGORİ VE KILIF ETİKETLERİ
                      Row(
                        children: [
                          _buildTag(category, Colors.blueAccent),
                          const SizedBox(width: 10),
                          _buildTag(package, Colors.amber),
                          const Spacer(),
                          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border, color: Colors.grey)),
                          IconButton(onPressed: () {}, icon: const Icon(Icons.share, color: Colors.grey)),
                        ],
                      ),
                      
                      const SizedBox(height: 25),

                      // HUD İSTATİSTİKLERİ (VOLTAJ - AKIM - GÜÇ)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatCard("MAX VOLTAGE", vMax, Icons.flash_on, Colors.amber),
                          _buildStatCard("MAX CURRENT", iMax, Icons.bolt, Colors.cyan),
                          _buildStatCard("MAX POWER", pMax, Icons.local_fire_department, Colors.redAccent),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // AÇIKLAMA BAŞLIĞI
                      Text("COMPONENT OVERVIEW", style: GoogleFonts.teko(color: Colors.grey, fontSize: 16, letterSpacing: 2)),
                      const Divider(color: Colors.white12),
                      
                      // AÇIKLAMA METNİ
                      Text(
                        desc,
                        style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                      ),

                      const SizedBox(height: 20),

                      // OTOMATİK OLUŞTURULAN "UYGULAMA ALANLARI" (Fake AI)
                      Text("TYPICAL APPLICATIONS", style: GoogleFonts.teko(color: Colors.grey, fontSize: 16, letterSpacing: 2)),
                      const Divider(color: Colors.white12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _generateApplications(category),
                      ),

                      const SizedBox(height: 30),

                      // PINOUT BİLGİSİ
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Icon(Icons.settings_input_component, color: Colors.grey),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("PIN CONFIGURATION", style: GoogleFonts.teko(color: Colors.amber, fontSize: 14)),
                                Text(
                                  pinout.split('').join(' - '), // GDS -> G - D - S
                                  style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            // Küçük Datasheet Butonu
                            OutlinedButton.icon(
                              onPressed: () {
                                // URL Launcher eklendiğinde burası çalışacak
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Datasheet indiriliyor... (Demo)")));
                              },
                              icon: const Icon(Icons.picture_as_pdf, size: 16),
                              label: const Text("PDF"),
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.white70, side: const BorderSide(color: Colors.white24)),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 100), // Buton için boşluk
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 3. SABİT ALT BUTON (START TEST)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black, Colors.black.withOpacity(0.0)],
                ),
              ),
              child: SizedBox(
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComponentTestScreen(
                          componentName: id,
                          packageType: package,
                          pinout: pinout,
                          scriptId: componentData['test_script_id'] ?? 'TEST_GENERIC',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 10,
                    shadowColor: Colors.amber.withOpacity(0.5),
                  ),
                  icon: const Icon(Icons.health_and_safety, size: 28),
                  label: Text("START DIAGNOSTIC TEST", style: GoogleFonts.oswald(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- YARDIMCI WIDGETLAR ---

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2126),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  // Kategoriye göre otomatik özellik uydurucu (Veritabanında olmasa bile dolu görünür)
  List<Widget> _generateApplications(String category) {
    List<String> apps = [];
    
    if (category == 'MOSFET') {
      apps = ["Motor Control", "Switching Power Supply", "Inverters", "LED Drivers"];
    } else if (category == 'BJT') {
      apps = ["Audio Amplification", "Signal Processing", "Switching", "General Purpose"];
    } else if (category == 'IC') {
      apps = ["Timer Circuits", "Pulse Generation", "Oscillators", "Control Systems"];
    } else if (category == 'DIODE') {
      apps = ["Rectification", "Protection", "Voltage Regulation", "Signal Clipping"];
    } else {
      apps = ["General Electronics", "PCB Design", "Prototyping"];
    }

    return apps.map((app) => Chip(
      label: Text(app),
      backgroundColor: Colors.white10,
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 11),
      padding: EdgeInsets.zero,
    )).toList();
  }
}