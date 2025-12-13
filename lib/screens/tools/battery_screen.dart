import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class BatteryScreen extends StatefulWidget {
  const BatteryScreen({super.key});

  @override
  State<BatteryScreen> createState() => _BatteryScreenState();
}

class _BatteryScreenState extends State<BatteryScreen> with SingleTickerProviderStateMixin {
  // --- DURUM DEĞİŞKENLERİ ---
  final TextEditingController _capacityController = TextEditingController(text: "2500");
  final TextEditingController _loadController = TextEditingController(text: "500");
  
  // Birimler
  String capUnit = "mAh"; // mAh, Ah
  String loadUnit = "mA";  // mA, A
  
  // Verimlilik (Genelde Li-Ion için %85-90, Kurşun Asit için %50-70)
  double efficiency = 0.85; 

  // Sonuç
  String resultTime = "---";
  
  // Animasyon
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _calculate();
  }

  @override
  void dispose() {
    _animController.dispose();
    _capacityController.dispose();
    _loadController.dispose();
    super.dispose();
  }

  // --- HESAPLAMA MOTORU (DÜZELTİLDİ) ---
  void _calculate() {
    double cap = double.tryParse(_capacityController.text) ?? 0;
    double load = double.tryParse(_loadController.text) ?? 0;

    if (cap <= 0 || load <= 0) {
      setState(() => resultTime = "---");
      return;
    }

    // Her şeyi temel birime (Amper Saat ve Amper) çevir
    double capAh = (capUnit == "mAh") ? cap / 1000 : cap;
    double loadA = (loadUnit == "mA") ? load / 1000 : load;

    // Formül: Zaman = (Kapasite / Yük) * Verimlilik
    double hours = (capAh / loadA) * efficiency;

    // Saati Dakikaya çevirip formatla
    int h = hours.floor();
    int m = ((hours - h) * 60).round();

    setState(() {
      // DÜZELTME BURADA YAPILDI: Rakamları ($h ve $m) metne ekledik
      if (h > 0) {
        resultTime = "$h Saat $m Dk";
      } else {
        resultTime = "$m Dakika";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      body: Stack(
        children: [
          // 1. CANLI ARKA PLAN (BALONCUKLAR)
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: BubbleBackgroundPainter(_animController.value),
              );
            },
          ),

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
                      Text("PİL ÖMRÜ HESAPLA", style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 2. GÖRSEL BATARYA (SIVI ANİMASYONLU)
                  Center(
                    child: SizedBox(
                      width: 150, height: 250,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Batarya Kabuğu
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 4),
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.black26
                            ),
                          ),
                          // Batarya Kafası (+ Kutbu)
                          Positioned(
                            top: -10,
                            child: Container(
                              width: 60, height: 20,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                            ),
                          ),
                          // Sıvı (Animasyonlu)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedBuilder(
                              animation: _animController,
                              builder: (context, child) {
                                return CustomPaint(
                                  size: const Size(150, 250),
                                  painter: BatteryLiquidPainter(
                                    animationValue: _animController.value,
                                    percentage: efficiency, // Verimlilik seviyesine göre dolu görünsün
                                    color: _getBatteryColor(),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Üzerindeki İkon
                          const Center(child: Icon(Icons.energy_savings_leaf, color: Colors.white54, size: 50)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 3. SONUÇ EKRANI
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                    decoration: BoxDecoration(
                      color: const Color(0xFF353A40),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getBatteryColor().withValues(alpha: 0.5)),
                      boxShadow: [BoxShadow(color: _getBatteryColor().withValues(alpha: 0.2), blurRadius: 20)]
                    ),
                    child: Column(
                      children: [
                        Text("TAHMİNİ ÇALIŞMA SÜRESİ", style: TextStyle(color: Colors.grey[400], fontSize: 12, letterSpacing: 1)),
                        const SizedBox(height: 10),
                        Text(
                          resultTime,
                          style: GoogleFonts.shareTechMono(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 4. GİRİŞLER
                  _buildInputRow("Pil Kapasitesi", _capacityController, capUnit, (val) => setState(() { capUnit = val; _calculate(); }), ['mAh', 'Ah']),
                  const SizedBox(height: 15),
                  _buildInputRow("Çekilen Akım (Yük)", _loadController, loadUnit, (val) => setState(() { loadUnit = val; _calculate(); }), ['mA', 'A']),

                  const SizedBox(height: 30),

                  // 5. VERİMLİLİK SLIDER
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Pil Tipi / Verimlilik", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          Text("${(efficiency * 100).toInt()}%", style: TextStyle(color: _getBatteryColor(), fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      SliderTheme(
                        data: SliderThemeData(activeTrackColor: _getBatteryColor(), thumbColor: Colors.white, overlayColor: _getBatteryColor().withValues(alpha: 0.2)),
                        child: Slider(
                          value: efficiency,
                          min: 0.5, max: 1.0,
                          onChanged: (v) {
                            setState(() {
                              efficiency = v;
                              _calculate();
                            });
                          },
                        ),
                      ),
                      const Text("Li-Ion: %85-90 | NiMH: %80 | Kurşun Asit: %60", style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBatteryColor() {
    if (efficiency > 0.8) return Colors.greenAccent;
    if (efficiency > 0.6) return Colors.amberAccent;
    return Colors.redAccent;
  }

  Widget _buildInputRow(String label, TextEditingController controller, String currentUnit, Function(String) onUnitChange, List<String> units) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(color: const Color(0xFF22252A), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          Expanded(child: TextField(controller: controller, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.grey), border: InputBorder.none), onChanged: (v) => _calculate())),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentUnit, dropdownColor: const Color(0xFF353A40), icon: Icon(Icons.arrow_drop_down, color: _getBatteryColor()), style: TextStyle(color: _getBatteryColor(), fontWeight: FontWeight.bold),
              items: units.map((String key) => DropdownMenuItem<String>(value: key, child: Text(key))).toList(),
              onChanged: (String? newValue) { if (newValue != null) { onUnitChange(newValue); } },
            ),
          )
        ],
      ),
    );
  }
}

// --- SIVI ANİMASYONU ---
class BatteryLiquidPainter extends CustomPainter {
  final double animationValue;
  final double percentage;
  final Color color;

  BatteryLiquidPainter({required this.animationValue, required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.6)..style = PaintingStyle.fill;
    
    double height = size.height * percentage;
    double top = size.height - height;

    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, top);

    // Dalga Hareketi
    for (double x = 0; x <= size.width; x++) {
      double waveHeight = 5.0;
      double y = top + sin((x / size.width * 2 * pi) + (animationValue * 2 * pi)) * waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant BatteryLiquidPainter oldDelegate) => true;
}

// --- ARKA PLAN BALONCUKLARI ---
class BubbleBackgroundPainter extends CustomPainter {
  final double animationValue;
  BubbleBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.05)..style = PaintingStyle.fill;
    final random = Random(42); // Sabit rastgelelik

    for (int i = 0; i < 20; i++) {
      double x = random.nextDouble() * size.width;
      double speed = random.nextDouble() * 0.5 + 0.5;
      double yStart = size.height + (random.nextDouble() * 100);
      double y = (yStart - (animationValue * size.height * speed)) % (size.height + 50);
      
      double radius = random.nextDouble() * 5 + 2;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  @override
  bool shouldRepaint(covariant BubbleBackgroundPainter oldDelegate) => true;
}
