import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // İstersen ekle
import '../../l10n/generated/app_localizations.dart'; // Dil Destegi

// --- ARAÇLARIN IMPORTLARI ---
import 'resistor_screen.dart';
import 'capacitor_screen.dart';
import '../smd/smd_screen.dart';
import 'smd_calculator_screen.dart';
import 'inductor_screen.dart';
import 'value_to_code_screen.dart';
import 'ohms_law_screen.dart';
import 'filter_screen.dart';
import 'voltage_divider_screen.dart';
import 'reactance_screen.dart';
import 'opamp_screen.dart';
import 'capacitor_charge_screen.dart';
import 'regulator_screen.dart';
import 'ne555_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dil çevirisi için (Hata verirse burayı geçici olarak kaldırabilirsin)
    final text = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      body: Stack(
        children: [
          // Ortak Grid Arka Plan
          CustomPaint(size: Size.infinite, painter: GridPainter()),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(text.navTools.toUpperCase(), style: GoogleFonts.orbitron(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 2, shadows: [const BoxShadow(color: Colors.amber, blurRadius: 15)])),
                      Text(text.calculationTools, style: TextStyle(color: Colors.grey[400], fontSize: 10, letterSpacing: 3)),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ARAÇ LİSTESİ (GRID)
                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.all(20),
                    crossAxisCount: 2, // Yan yana 2 kutu
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.1, // Kareye yakın dikdörtgen
                    children: [
                      // 1. DİRENÇ RENK
                      _buildToolCard(context, title: text.toolResistorCalc, icon: Icons.palette, color: Colors.redAccent, destination: const ResistorScreen()),
                      
                      // 2. KONDANSATÖR
                      _buildToolCard(context, title: text.toolCapacitorDec, icon: Icons.battery_charging_full, color: Colors.greenAccent, destination: const CapacitorScreen()),
                      
                      // 3. SMD KOD (DATABASE)
                      _buildToolCard(context, title: text.toolSmdSearch, icon: Icons.qr_code_scanner, color: Colors.blueAccent, destination: const SmdScreen()),

                      // 4. SMD DİRENÇ HESAPLA
                      _buildToolCard(context, title: text.toolSmdCalc, icon: Icons.memory, color: Colors.purpleAccent, destination: const SmdCalculatorScreen()),

                      // 5. İNDÜKTÖR
                      _buildToolCard(context, title: text.toolInductorColor, icon: Icons.all_inclusive, color: Colors.tealAccent, destination: const InductorScreen()),

                      // 6. DEĞER -> KOD
                      _buildToolCard(context, title: text.toolValueToCode, icon: Icons.swap_horiz, color: Colors.orangeAccent, destination: const ValueToCodeScreen()),
                      
                      // 7. OHM KANUNU
                      _buildToolCard(context, title: "OHM KANUNU\nHESAPLA", icon: Icons.flash_on, color: Colors.yellowAccent, destination: const OhmsLawScreen()),

                      // 8. FİLTRE
                      _buildToolCard(context, title: "FİLTRE (RC/RL)\nHESAPLA", icon: Icons.graphic_eq, color: Colors.cyanAccent, destination: const FilterScreen()),

                      // 9. GERİLİM BÖLÜCÜ
                      _buildToolCard(context, title: "GERİLİM\nBÖLÜCÜ", icon: Icons.call_split, color: Colors.deepOrangeAccent, destination: const VoltageDividerScreen()),

                      // 10. REAKTANS / RL
                      _buildToolCard(context, title: "REAKTANS &\nEMPEDANS", icon: Icons.waves, color: Colors.lightBlueAccent, destination: const ReactanceScreen()),

                      // 11. OP-AMP
                      _buildToolCard(context, title: "OP-AMP\nHESAPLA", icon: Icons.developer_board, color: Colors.pinkAccent, destination: const OpAmpScreen()),
                      
                      // 12. KONDANSATÖR ŞARJ (OSİLOSKOP)
                      _buildToolCard(context, title: "RC ŞARJ\nSİMÜLATÖRÜ", icon: Icons.show_chart, color: Colors.lightGreenAccent, destination: const CapacitorChargeScreen()),

                      // 13. VOLTAJ REGÜLATÖRÜ
                      _buildToolCard(context, title: "VOLTAJ\nREGÜLATÖRÜ", icon: Icons.tune, color: Colors.cyanAccent, destination: const RegulatorScreen()),

                      // 14. YENİ: NE555 HESAPLAYICI
                      _buildToolCard(
                        context,
                        title: "NE555\nHESAPLA",
                        icon: Icons.timer,
                        color: Colors.tealAccent,
                        destination: const Ne555Screen(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, {required String title, required IconData icon, required Color color, Widget? destination, bool isLocked = false}) {
    return GestureDetector(
      onTap: () {
        if (!isLocked && destination != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bu özellik yakında gelecek!")));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF353A40),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isLocked ? Colors.grey.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: isLocked 
              ? [const Color(0xFF25282F), const Color(0xFF202329)]
              : [const Color(0xFF353A40), const Color(0xFF2B2F36)]
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isLocked ? Colors.grey.withValues(alpha: 0.05) : color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: isLocked ? [] : [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 15)]
              ),
              child: Icon(icon, size: 32, color: isLocked ? Colors.grey : color),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(color: isLocked ? Colors.grey : Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }
}

// Grid Painter
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.03)..strokeWidth = 1;
    const double step = 40.0;
    for (double x = 0; x < size.width; x += step) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += step) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}