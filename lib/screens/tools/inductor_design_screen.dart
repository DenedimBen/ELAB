import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class InductorDesignScreen extends StatefulWidget {
  const InductorDesignScreen({super.key});

  @override
  State<InductorDesignScreen> createState() => _InductorDesignScreenState();
}

class _InductorDesignScreenState extends State<InductorDesignScreen> with SingleTickerProviderStateMixin {
  // --- DURUM DEĞİŞKENLERİ ---
  double turns = 10.0;      // Sarım Sayısı (N)
  double diameter = 10.0;   // Bobin Çapı (mm) (D)
  double wireGauge = 1.0;   // Tel Kalınlığı (mm) (d)
  
  // Sonuçlar
  String resInductance = "---";
  String resWireLength = "---";
  String resCoilLength = "---";

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _calculate();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // --- HESAPLAMA MOTORU (Wheeler Formülü - Air Core) ---
  void _calculate() {
    // Formül (Inç bazlı olduğu için mm -> inç çevirimi yapıyoruz)
    // L (uH) = (d^2 * n^2) / (18d + 40l)
    // d: Bobin çapı (inç)
    // l: Bobin uzunluğu (inç) -> (Sarım Sayısı * Tel Kalınlığı)
    
    double d_inch = diameter / 25.4;
    double l_inch = (turns * wireGauge) / 25.4;
    
    double numerator = pow(d_inch, 2).toDouble() * pow(turns, 2).toDouble();
    double denominator = (18 * d_inch) + (40 * l_inch);
    
    double inductance = numerator / denominator; // MikroHenry (uH)

    // Tel Uzunluğu (Çevre * Tur Sayısı)
    double wireLenMm = (pi * diameter) * turns;
    double coilLenMm = turns * wireGauge;

    setState(() {
      // İndüktans
      if (inductance < 1) {
        resInductance = "${(inductance * 1000).toStringAsFixed(1)} nH";
      } else {
        resInductance = "${inductance.toStringAsFixed(2)} µH";
      }

      // Tel Uzunluğu
      if (wireLenMm > 1000) {
        resWireLength = "${(wireLenMm / 1000).toStringAsFixed(2)} m";
      } else {
        resWireLength = "${wireLenMm.toStringAsFixed(0)} mm";
      }

      // Bobin Boyu
      resCoilLength = "${coilLenMm.toStringAsFixed(1)} mm";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      body: Stack(
        children: [
          // Izgara Arka Plan
          CustomPaint(size: Size.infinite, painter: GridPainter()),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // HEADER
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back, color: Colors.grey), onPressed: () => Navigator.pop(context)),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("BOBİN TASARLA", style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
                          Text("HAVA ÇEKİRDEKLİ (AIR CORE)", style: TextStyle(color: Colors.grey[500], fontSize: 10, letterSpacing: 2)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 1. SONUÇ EKRANI (BÜYÜK)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF353A40),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.5)),
                      boxShadow: [BoxShadow(color: Colors.orangeAccent.withValues(alpha: 0.2), blurRadius: 20)]
                    ),
                    child: Column(
                      children: [
                        Text("HESAPLANAN İNDÜKTANS", style: TextStyle(color: Colors.grey[400], fontSize: 10, letterSpacing: 2)),
                        const SizedBox(height: 5),
                        Text(
                          resInductance,
                          style: GoogleFonts.shareTechMono(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [BoxShadow(color: Colors.orangeAccent.withValues(alpha: 0.6), blurRadius: 20)]
                          ),
                        ),
                        const Divider(color: Colors.white10, height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMiniInfo("GEREKEN TEL", resWireLength, Icons.linear_scale),
                            _buildMiniInfo("BOBİN BOYU", resCoilLength, Icons.straighten),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 2. GÖRSEL BOBİN SİMÜLASYONU
                  SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: CoilVisualizerPainter(
                        turns: turns,
                        diameter: diameter,
                        wireWidth: wireGauge,
                        animValue: _animController.value
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                  // 3. KONTROLLER (SLIDER)
                  _buildSlider("SARIM SAYISI (N)", turns, 1, 50, (v) => setState(() { turns = v; _calculate(); }), "Tur"),
                  _buildSlider("BOBİN ÇAPI (D)", diameter, 2, 100, (v) => setState(() { diameter = v; _calculate(); }), "mm"),
                  _buildSlider("TEL KALINLIĞI (d)", wireGauge, 0.1, 5.0, (v) => setState(() { wireGauge = v; _calculate(); }), "mm"),

                  const SizedBox(height: 20),
                  
                  // BİLGİ KUTUSU
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)),
                    child: const Text(
                      "Bu araç, hava çekirdekli (nüvesiz) tek katmanlı bobinler içindir. RF devreleri, antenler ve filtreler için idealdir.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInfo(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        const SizedBox(height: 5),
        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSlider(String title, double value, double min, double max, Function(double) onChanged, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            Text("${value.toStringAsFixed(1)} $unit", style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(activeTrackColor: Colors.orangeAccent, thumbColor: Colors.white, overlayColor: Colors.orangeAccent.withValues(alpha: 0.2)),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

// --- BOBİN GÖRSELLEŞTİRİCİ ---
class CoilVisualizerPainter extends CustomPainter {
  final double turns;
  final double diameter;
  final double wireWidth;
  final double animValue;

  CoilVisualizerPainter({required this.turns, required this.diameter, required this.wireWidth, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final wirePaint = Paint()
      ..color = const Color(0xFFB87333) // Bakır Rengi
      ..style = PaintingStyle.stroke
      ..strokeWidth = wireWidth * 2 // Görsel olarak biraz kalınlaştır
      ..strokeCap = StrokeCap.round;

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (wireWidth * 2) / 3;

    double cx = size.width / 2;
    double cy = size.height / 2;
    
    // Görsel ölçekleme (Ekrana sığdırmak için)
    double scaleFactor = 1.5; 
    double visualDiameter = diameter * scaleFactor; 
    double coilHeight = turns * wireWidth * 2; // Bobin uzunluğu
    
    // Eğer çok uzunsa küçült
    if (coilHeight > size.height) coilHeight = size.height - 20;
    
    double startY = cy - (coilHeight / 2);
    double loopHeight = coilHeight / turns;

    // Bobini Çiz (Sinüs dalgası gibi sarmal)
    for (int i = 0; i < turns; i++) {
      double y = startY + (i * loopHeight);
      
      Rect oval = Rect.fromCenter(center: Offset(cx, y), width: visualDiameter, height: loopHeight);
      
      // Ön Yüz (Daha parlak)
      canvas.drawArc(oval, 0, pi, false, wirePaint);
      canvas.drawArc(oval, 0.5, 2, false, highlightPaint); // Işık yansıması
      
      // Arka Yüz (Daha koyu - Derinlik hissi için)
      final backPaint = Paint()..color = const Color(0xFF8D6E63)..style = PaintingStyle.stroke..strokeWidth = wireWidth * 2;
      canvas.drawArc(oval, pi, pi, false, backPaint);
    }

    // Manyetik Alan Efekti (Hareketli Çizgiler)
    final fieldPaint = Paint()..color = Colors.blueAccent.withValues(alpha: 0.1 * sin(animValue * pi))..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), fieldPaint);
    canvas.drawCircle(Offset(cx, cy), visualDiameter * 0.8, fieldPaint);
  }

  @override
  bool shouldRepaint(covariant CoilVisualizerPainter oldDelegate) => true;
}

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