import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LedScreen extends StatefulWidget {
  const LedScreen({super.key});

  @override
  State<LedScreen> createState() => _LedScreenState();
}

class _LedScreenState extends State<LedScreen> {
  // --- DURUM DEĞİŞKENLERİ ---
  double sourceVoltage = 12.0; // Kaynak Voltajı (Vs)
  double ledCurrent = 20.0;    // LED Akımı (mA)

  // LED RENKLERİ VE VOLTAJLARI (Vf)
  final List<Map<String, dynamic>> ledTypes = [
    {'name': 'Kırmızı', 'color': Colors.red,    'vf': 2.0},
    {'name': 'Yeşil',   'color': Colors.green,  'vf': 2.2}, // Standart yeşil
    {'name': 'Mavi',    'color': Colors.blue,   'vf': 3.2},
    {'name': 'Sarı',    'color': Colors.yellow, 'vf': 2.1},
    {'name': 'Beyaz',   'color': Colors.white,  'vf': 3.2},
    {'name': 'Mor (UV)','color': Colors.purple, 'vf': 3.4},
    {'name': 'Turuncu', 'color': Colors.orange, 'vf': 2.0},
  ];
  
  int selectedLedIdx = 0; // Varsayılan Kırmızı

  // --- HESAPLAMA ---
  String _calculateResistor() {
    double vf = ledTypes[selectedLedIdx]['vf']; // LED Voltajı
    
    if (sourceVoltage <= vf) return "Voltaj Yetersiz!";
    
    // R = (Vs - Vf) / I
    double r = (sourceVoltage - vf) / (ledCurrent / 1000.0); // mA -> A çevirimi
    
    if (r < 0) return "Hata";
    
    // Standart değerlere yuvarlama yapılabilir ama şimdilik tam değer gösterelim
    return _formatOhms(r);
  }
  
  String _getPower() {
    double vf = ledTypes[selectedLedIdx]['vf'];
    if (sourceVoltage <= vf) return "-";
    
    // P = I^2 * R  veya  P = V_r * I
    double vR = sourceVoltage - vf;
    double p = vR * (ledCurrent / 1000.0);
    
    return "${(p * 1000).toStringAsFixed(0)} mW"; // Miliwatt
  }

  String _formatOhms(double ohms) {
    if (ohms >= 1000000) return "${(ohms / 1000000).toStringAsFixed(2)} MΩ";
    if (ohms >= 1000) return "${(ohms / 1000).toStringAsFixed(2)} kΩ";
    return "${ohms.toStringAsFixed(1)} Ω";
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = ledTypes[selectedLedIdx]['color'] as Color;
    final selectedVf = ledTypes[selectedLedIdx]['vf'] as double;

    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      body: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: GridPainter()),
          
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // HEADER
                    Row(
                      children: [
                        IconButton(icon: const Icon(Icons.arrow_back, color: Colors.grey), onPressed: () => Navigator.pop(context)),
                        const SizedBox(width: 10),
                        Text("LED DİRENÇ", style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
                      ],
                    ),
                    
                    const SizedBox(height: 20),

                    // 1. CANLI LED GÖRSELİ
                    Center(
                      child: Container(
                        width: 180, height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black26,
                          boxShadow: [
                            // LED'in Parlaması (Glow Efekti)
                            BoxShadow(
                              color: selectedColor.withValues(alpha: 0.6), 
                              blurRadius: 60, 
                              spreadRadius: 10
                            )
                          ],
                          border: Border.all(color: Colors.white10, width: 2)
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // LED İkonu
                            Icon(Icons.lightbulb, size: 100, color: selectedColor),
                            // Voltaj Bilgisi
                            Positioned(
                              bottom: 30,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                                child: Text("${selectedVf}V", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // 2. SONUÇ PANELİ (DİRENÇ)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF353A40),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 5))]
                      ),
                      child: Column(
                        children: [
                          Text("GEREKEN DİRENÇ", style: TextStyle(color: Colors.grey[400], fontSize: 10, letterSpacing: 2)),
                          const SizedBox(height: 5),
                          Text(
                            _calculateResistor(),
                            style: GoogleFonts.shareTechMono(fontSize: 45, color: Colors.white, fontWeight: FontWeight.bold, shadows: [const BoxShadow(color: Colors.blueAccent, blurRadius: 20)]),
                          ),
                          const SizedBox(height: 10),
                          // Güç Bilgisi
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                            child: Text("Harcanan Güç: ${_getPower()}", style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // 3. AYARLAR
                    // Kaynak Voltajı Slider
                    _buildSlider("KAYNAK VOLTAJI (Vs)", sourceVoltage, 3.0, 24.0, (v) => setState(() => sourceVoltage = v), "V"),
                    const SizedBox(height: 15),
                    // LED Akımı Slider
                    _buildSlider("LED AKIMI (I)", ledCurrent, 1.0, 50.0, (v) => setState(() => ledCurrent = v), "mA"),
                    
                    const SizedBox(height: 30),
                    
                    // 4. LED RENGİ SEÇİCİ
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: ledTypes.length,
                        itemBuilder: (context, index) {
                          final led = ledTypes[index];
                          bool isSelected = selectedLedIdx == index;
                          return GestureDetector(
                            onTap: () => setState(() => selectedLedIdx = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: isSelected ? 50 : 40,
                              decoration: BoxDecoration(
                                color: led['color'],
                                shape: BoxShape.circle,
                                border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                                boxShadow: [BoxShadow(color: (led['color'] as Color).withValues(alpha: 0.5), blurRadius: 10)]
                              ),
                            ),
                          );
                        },
                      ),
                    )

                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSlider(String title, double value, double min, double max, Function(double) onChanged, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.bold)),
            Text("${value.toStringAsFixed(1)} $unit", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.amber,
            inactiveTrackColor: Colors.grey[800],
            thumbColor: Colors.white,
            overlayColor: Colors.amber.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// Grid Painter (Aynı)
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.03)..strokeWidth = 1;
    const double step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
