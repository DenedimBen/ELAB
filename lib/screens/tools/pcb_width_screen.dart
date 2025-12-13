import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class PcbWidthScreen extends StatefulWidget {
  const PcbWidthScreen({super.key});

  @override
  State<PcbWidthScreen> createState() => _PcbWidthScreenState();
}

class _PcbWidthScreenState extends State<PcbWidthScreen> with SingleTickerProviderStateMixin {
  // --- GİRİŞLER ---
  final TextEditingController _currentController = TextEditingController(text: "1.0"); // Amper
  final TextEditingController _tempController = TextEditingController(text: "10");   // Sıcaklık Artışı (°C)
  final TextEditingController _lenController = TextEditingController(text: "10");    // Uzunluk (cm)
  
  // Seçenekler
  double copperThickness = 1.0; // oz/ft^2 (1oz = 35µm)
  bool isInternal = false; // İç katman mı Dış katman mı?

  // --- SONUÇLAR ---
  String resWidth = "---";
  String resResistance = "---";
  String resDrop = "---";
  String resPower = "---";
  
  // Görsel Efekt İçin
  double heatFactor = 0.0; // 0 (Soğuk) - 1 (Sıcak)

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
    _currentController.dispose();
    _tempController.dispose();
    _lenController.dispose();
    super.dispose();
  }

  // --- IPC-2221 FORMÜLÜ İLE HESAPLAMA ---
  void _calculate() {
    double i = double.tryParse(_currentController.text) ?? 0;
    double tempRise = double.tryParse(_tempController.text) ?? 0;
    double lengthCm = double.tryParse(_lenController.text) ?? 0;

    if (i <= 0 || tempRise <= 0 || lengthCm <= 0) {
      setState(() { resWidth = "---"; heatFactor = 0; });
      return;
    }

    // IPC-2221 Standart Katsayıları
    double k = isInternal ? 0.024 : 0.048;
    double b = 0.44;
    double c = 0.725;

    // 1. Gerekli Alan (mils^2) = (I / (k * dT^b)) ^ (1/c)
    double areaMils2 = pow((i / (k * pow(tempRise, b))), (1 / c)).toDouble();

    // 2. Genişlik (mils) = Area / (Thickness * 1.378)
    // 1 oz bakır = 1.378 mils kalınlık
    double thicknessMils = copperThickness * 1.378;
    double widthMils = areaMils2 / thicknessMils;

    // 3. Birim Çevirme (mils -> mm) (1 mil = 0.0254 mm)
    double widthMm = widthMils * 0.0254;

    // --- EKSTRA HESAPLAR (Direnç, Voltaj, Güç) ---
    // Direnç R = rho * L / A
    // Bakır Özdirenç (rho) = 1.724e-8 Ohm.m (25°C)
    // Sıcaklık arttıkça direnç artar: R_hot = R * (1 + alpha * dT)
    
    double widthMeters = widthMm / 1000;
    double thickMeters = (copperThickness * 35) / 1000000; // 1oz ~ 35um
    double areaM2 = widthMeters * thickMeters;
    double lenMeters = lengthCm / 100;

    double resist = (1.724e-8 * lenMeters) / areaM2;
    // Sıcaklık düzeltmesi (Bakır alpha = 0.00393)
    resist = resist * (1 + 0.00393 * tempRise);

    double vDrop = i * resist;
    double powerLoss = i * i * resist;

    setState(() {
      resWidth = "${widthMm.toStringAsFixed(3)} mm";
      resResistance = "${(resist * 1000).toStringAsFixed(1)} mΩ"; // MiliOhm
      resDrop = "${vDrop.toStringAsFixed(3)} V";
      resPower = "${(powerLoss * 1000).toStringAsFixed(0)} mW";

      // Isı Faktörü (Görsel için): Akım yoğunluğuna göre renk değişsin
      // Basit bir simülasyon: Sıcaklık artışı 10C ise yeşil, 50C ise kırmızı
      heatFactor = (tempRise / 50.0).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Isıya göre renk: Mavi -> Yeşil -> Sarı -> Kırmızı
    Color statusColor = Color.lerp(Colors.cyanAccent, Colors.redAccent, heatFactor)!;

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
                      Text("PCB YOL HESAPLA", style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
                    ],
                  ),
                  Text("(IPC-2221 Standardı)", style: TextStyle(color: Colors.grey[500], fontSize: 12)),

                  const SizedBox(height: 30),

                  // 1. GÖRSEL SİMÜLASYON (CANLI PCB YOLU)
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF004D40), // PCB Yeşili (Mask)
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24, width: 2),
                      boxShadow: [BoxShadow(color: statusColor.withValues(alpha: 0.3), blurRadius: 20)]
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CustomPaint(
                        painter: PcbTracePainter(
                          animValue: _animController.value,
                          color: statusColor,
                          heatLevel: heatFactor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text("Simülasyon: Akım arttıkça yol ısınır (Renk değişir)", style: TextStyle(color: Colors.grey[500], fontSize: 10)),

                  const SizedBox(height: 30),

                  // 2. SONUÇLAR (GRID)
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF353A40),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      children: [
                        Text("GEREKEN MİNİMUM GENİŞLİK", style: TextStyle(color: Colors.grey[400], fontSize: 10, letterSpacing: 1)),
                        Text(resWidth, style: GoogleFonts.shareTechMono(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white, shadows: [BoxShadow(color: statusColor, blurRadius: 20)])),
                        const Divider(color: Colors.grey),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMiniResult("YOL DİRENCİ", resResistance),
                            _buildMiniResult("VOLTAJ DÜŞÜMÜ", resDrop),
                            _buildMiniResult("GÜÇ KAYBI", resPower),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 3. GİRİŞLER
                  Row(
                    children: [
                      Expanded(child: _buildInputBox("Akım (Amper)", _currentController)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildInputBox("Sıcaklık Artışı (°C)", _tempController)),
                    ],
                  ),
                  
                  const SizedBox(height: 15),
                  
                  _buildInputBox("Yol Uzunluğu (cm)", _lenController),

                  const SizedBox(height: 20),
                  
                  // 4. AYARLAR (KALINLIK VE KATMAN)
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      children: [
                        // Bakır Kalınlığı
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Bakır Kalınlığı:", style: TextStyle(color: Colors.white70)),
                            DropdownButton<double>(
                              value: copperThickness,
                              dropdownColor: const Color(0xFF353A40),
                              style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                              underline: Container(),
                              items: const [
                                DropdownMenuItem(value: 0.5, child: Text("0.5 oz (18µm)")),
                                DropdownMenuItem(value: 1.0, child: Text("1.0 oz (35µm)")),
                                DropdownMenuItem(value: 2.0, child: Text("2.0 oz (70µm)")),
                                DropdownMenuItem(value: 3.0, child: Text("3.0 oz (105µm)")),
                              ],
                              onChanged: (v) => setState(() { copperThickness = v!; _calculate(); }),
                            ),
                          ],
                        ),
                        
                        const Divider(color: Colors.white10),

                        // Katman Tipi
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Katman Tipi:", style: TextStyle(color: Colors.white70)),
                            Row(
                              children: [
                                _buildRadioBtn("Dış (External)", false),
                                const SizedBox(width: 10),
                                _buildRadioBtn("İç (Internal)", true),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 5. BİLGİ
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(border: Border.all(color: Colors.white10), borderRadius: BorderRadius.circular(10)),
                    child: const Text(
                      "Hesaplamalar IPC-2221 standardına dayanır. Yüksek akımlı yolların ısınıp kalkmaması için önerilen minimum genişliktir.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 11),
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

  Widget _buildInputBox(String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(color: const Color(0xFF22252A), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.grey, fontSize: 12), border: InputBorder.none),
        onChanged: (v) => _calculate(),
      ),
    );
  }

  Widget _buildMiniResult(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRadioBtn(String title, bool val) {
    bool selected = isInternal == val;
    return GestureDetector(
      onTap: () => setState(() { isInternal = val; _calculate(); }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? Colors.amber.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.amber : Colors.grey),
        ),
        child: Text(title, style: TextStyle(color: selected ? Colors.amber : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// --- PCB GÖRSEL ÇİZİCİ ---
class PcbTracePainter extends CustomPainter {
  final double animValue;
  final Color color;
  final double heatLevel; // 0.0 - 1.0
  
  PcbTracePainter({required this.animValue, required this.color, required this.heatLevel});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. PCB Padleri (Giriş Çıkış Noktaları)
    final padPaint = Paint()..color = const Color(0xFFFFD700)..style = PaintingStyle.fill; // Altın kaplama
    canvas.drawCircle(Offset(30, size.height/2), 15, padPaint);
    canvas.drawCircle(Offset(size.width - 30, size.height/2), 15, padPaint);

    // 2. Yol (Trace)
    // Isıya göre genişlik biraz değişebilir ama sabit görsel daha iyi durur
    double traceHeight = 20.0; 
    
    // Yol Rengi: Soğuksa Bakır rengi, Sıcaksa Parlayan Kırmızı
    Color traceColor = Color.lerp(const Color(0xFFB87333), Colors.redAccent, heatLevel)!;

    final tracePaint = Paint()
      ..color = traceColor
      ..style = PaintingStyle.fill;
    
    final glowPaint = Paint()
      ..color = traceColor.withValues(alpha: 0.6 * heatLevel) // Isındıkça parlar
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    Rect traceRect = Rect.fromCenter(center: Offset(size.width/2, size.height/2), width: size.width - 60, height: traceHeight);
    
    // Glow (Sadece sıcaksa çiz)
    if (heatLevel > 0.2) canvas.drawRect(traceRect, glowPaint);
    canvas.drawRect(traceRect, tracePaint);

    // 3. Akım Efekti (Elektronlar)
    // Isındıkça elektronlar hızlansın veya renk değiştirsin
    final electronPaint = Paint()..color = Colors.white.withValues(alpha: 0.8)..style = PaintingStyle.fill;
    
    double startX = 30;
    double endX = size.width - 30;
    double totalLen = endX - startX;
    
    // 5 tane elektron akıyor
    for(int i=0; i<5; i++) {
      double progress = (animValue + (i * 0.2)) % 1.0;
      double x = startX + (progress * totalLen);
      
      // Isındıkça elektronlar "titrer" veya "kızarır"
      canvas.drawCircle(Offset(x, size.height/2), 2, electronPaint);
    }
  }
  @override
  bool shouldRepaint(covariant PcbTracePainter oldDelegate) => true;
}

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
