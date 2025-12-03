import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
// Araçların Ekranları
import 'resistor_screen.dart';         // Renk Kodlu Direnç
import 'capacitor_screen.dart';        // Kondansatör
import '../smd/smd_screen.dart';       // SMD Dedektif (Veritabanı Arama)
import 'smd_calculator_screen.dart';   // <-- YENİ: SMD Direnç Hesaplayıcı (Matematiksel)
import 'inductor_screen.dart';          // <-- YENİ: İndüktör Renk Kodu
import 'value_to_code_screen.dart';    // <-- YENİ: Değer -> Kod Çevirici

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                // HEADER (Geri butonu yok)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.navTools.toUpperCase(), style: GoogleFonts.orbitron(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 2, shadows: [const BoxShadow(color: Colors.amber, blurRadius: 15)])),
                      Text(AppLocalizations.of(context)!.calculationTools, style: TextStyle(color: Colors.grey[400], fontSize: 10, letterSpacing: 3)),
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
                      // 1. DİRENÇ RENK KODU
                      _buildToolCard(
                        context,
                        title: AppLocalizations.of(context)!.toolResistorCalc,
                        icon: Icons.palette, 
                        color: Colors.redAccent,
                        destination: const ResistorScreen(),
                      ),
                      
                      // 2. KONDANSATÖR
                      _buildToolCard(
                        context,
                        title: AppLocalizations.of(context)!.toolCapacitorDec,
                        icon: Icons.battery_charging_full,
                        color: Colors.greenAccent,
                        destination: const CapacitorScreen(),
                      ),
                      
                      // 3. SMD KOD DEDEKTİFİ (VERİTABANI ARAMA)
                      _buildToolCard(
                        context,
                        title: AppLocalizations.of(context)!.toolSmdSearch,
                        icon: Icons.qr_code_scanner,
                        color: Colors.blueAccent,
                        destination: const SmdScreen(),
                      ),

                      // 4. YENİ EKLENEN: SMD DİRENÇ HESAPLAYICI
                      _buildToolCard(
                        context,
                        title: AppLocalizations.of(context)!.toolSmdCalc,
                        icon: Icons.memory, // Çip ikonu
                        color: Colors.purpleAccent,
                        destination: const SmdCalculatorScreen(),
                      ),

                      // 5. YENİ EKLENEN: İNDÜKTÖR RENK KODU
                      _buildToolCard(
                        context,
                        title: AppLocalizations.of(context)!.toolInductorColor,
                        icon: Icons.all_inclusive, // Bobin benzeri ikon
                        color: Colors.tealAccent,
                        destination: const InductorScreen(),
                      ),

                      // 5. YENİ EKLENEN: DEĞER -> KOD ÇEVİRİCİ
                      _buildToolCard(
                        context,
                        title: AppLocalizations.of(context)!.toolValueToCode,
                        icon: Icons.swap_horiz, // Değişim ikonu
                        color: Colors.orangeAccent,
                        destination: const ValueToCodeScreen(),
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
              style: GoogleFonts.orbitron(color: isLocked ? Colors.grey : Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
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