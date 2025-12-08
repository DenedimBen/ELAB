import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../test_engine/test_screen.dart'; // Test ekranını buraya bağlıyoruz

class ComponentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> componentData; 
  // Örn: {'id': 'IRF3205', 'type': 'MOSFET', 'package': 'TO-220', 'vmax': '55V'}

  const ComponentDetailScreen({super.key, required this.componentData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2126),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(componentData['id'], style: GoogleFonts.orbitron(color: Colors.amber, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ÜST KISIM: BÜYÜK RESİM VE ÖZET
            Center(
              child: Container(
                height: 200,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Image.asset('assets/packages/${componentData['package'].toString().toLowerCase()}.png'),
              ),
            ),
            const SizedBox(height: 30),

            // 2. TEKNİK ÖZELLİKLER (DATASHEET ÖZETİ)
            Text("TEKNİK ÖZET", style: TextStyle(color: Colors.grey[400], letterSpacing: 2, fontSize: 12)),
            const SizedBox(height: 10),
            _buildInfoRow("Kılıf Tipi", componentData['package']),
            _buildInfoRow("Maks. Voltaj", componentData['vmax'] ?? '-'),
            _buildInfoRow("Maks. Akım", componentData['imax'] ?? '-'),
            _buildInfoRow("Polarite", componentData['polarity'] ?? '-'),

            const Spacer(),

            // 3. AKSİYON ALANI (TEST BUTONU)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2E35),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  const Text("Bu bileşenin sağlamlığından şüphe mi ediyorsun?", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber, // Dikkat çekici renk
                        foregroundColor: Colors.black,
                        elevation: 10,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.health_and_safety, size: 28),
                      label: Text("SAĞLAMLIK TESTİNİ BAŞLAT", style: GoogleFonts.oswald(fontSize: 18, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        // TEST EKRANINA GİT
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ComponentTestScreen(
                              componentName: componentData['id'],
                              packageType: componentData['package'],
                              
                              // VERİTABANINDAN GELEN GERÇEK VERİLER:
                              pinout: componentData['pinout_code'] ?? 'GDS', // Örn: GDS
                              scriptId: componentData['test_script_id'] ?? 'TEST_GENERIC', // Örn: TEST_MOS_N
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
