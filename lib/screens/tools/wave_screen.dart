import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class WaveScreen extends StatefulWidget {
  const WaveScreen({super.key});

  @override
  State<WaveScreen> createState() => _WaveScreenState();
}

class _WaveScreenState extends State<WaveScreen> with SingleTickerProviderStateMixin {
  // --- DURUM DEĞİŞKENLERİ ---
  int calcMode = 0; // 0: Frekans -> Diğerleri, 1: Periyot -> Diğerleri, 2: Dalga Boyu -> Diğerleri
  int waveMedium = 0; // 0: Elektromanyetik (Işık Hızı), 1: Ses (Hava)

  final TextEditingController _inputController = TextEditingController();
  
  // Birimler
  double inputMult = 1.0; 
  String inputUnit = "Hz"; // Başlangıç

  // Sabitler
  final double speedOfLight = 299792458; // m/s
  final double speedOfSound = 343;       // m/s (20°C hava)

  // Sonuçlar
  String resFreq = "---";
  String resPeriod = "---";
  String resWavelength = "---";
  
  // Görsel Animasyon İçin Değerler
  double visualFreq = 1.0; // Çizim sıklığı

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _updateUnitList(); // İlk birimleri ayarla
  }

  @override
  void dispose() {
    _animController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  // --- BİRİM LİSTESİ (Moda göre değişir) ---
  Map<String, double> get currentUnits {
    if (calcMode == 0) return {'Hz': 1.0, 'kHz': 1e3, 'MHz': 1e6, 'GHz': 1e9};
    if (calcMode == 1) return {'ms': 1e-3, 'µs': 1e-6, 'ns': 1e-9, 's': 1.0};
    return {'mm': 1e-3, 'cm': 1e-2, 'm': 1.0, 'km': 1000.0};
  }

  void _updateUnitList() {
    setState(() {
      inputUnit = currentUnits.keys.first;
      inputMult = currentUnits.values.first;
      _calculate();
    });
  }

  // --- HESAPLAMA MOTORU ---
  void _calculate() {
    double val = double.tryParse(_inputController.text.replaceAll(',', '.')) ?? 0;
    if (val <= 0) {
      setState(() { resFreq = "---"; resPeriod = "---"; resWavelength = "---"; visualFreq = 1.0; });
      return;
    }

    double inputValBase = val * inputMult; // Temel birime çevir (Hz, s, m)
    double v = (waveMedium == 0) ? speedOfLight : speedOfSound; // Hız seçimi

    double f = 0, t = 0, lambda = 0;

    if (calcMode == 0) { // Girdi: Frekans
      f = inputValBase;
      t = 1 / f;
      lambda = v / f;
    } else if (calcMode == 1) { // Girdi: Periyot
      t = inputValBase;
      f = 1 / t;
      lambda = v * t;
    } else { // Girdi: Dalga Boyu
      lambda = inputValBase;
      f = v / lambda;
      t = 1 / f;
    }

    // Görsel Frekans Ayarı (Animasyon için normalize et)
    // Çok yüksek frekanslarda çizgi simsiyah olmasın diye logaritmik ölçekleme
    visualFreq = (log(f + 1) / ln10).clamp(0.5, 10.0);

    setState(() {
      resFreq = _formatVal(f, "Hz");
      resPeriod = _formatVal(t, "s");
      resWavelength = _formatVal(lambda, "m");
    });
  }

  String _formatVal(double val, String baseUnit) {
    if (baseUnit == "Hz") {
      if (val >= 1e9) return "${(val / 1e9).toStringAsFixed(3)} GHz";
      if (val >= 1e6) return "${(val / 1e6).toStringAsFixed(3)} MHz";
      if (val >= 1e3) return "${(val / 1e3).toStringAsFixed(2)} kHz";
    }
    if (baseUnit == "s") {
      if (val < 1e-6) return "${(val * 1e9).toStringAsFixed(2)} ns";
      if (val < 1e-3) return "${(val * 1e6).toStringAsFixed(2)} µs";
      if (val < 1) return "${(val * 1e3).toStringAsFixed(2)} ms";
    }
    if (baseUnit == "m") {
      if (val < 1e-2) return "${(val * 1e3).toStringAsFixed(2)} mm";
      if (val < 1) return "${(val * 100).toStringAsFixed(2)} cm";
      if (val >= 1000) return "${(val / 1000).toStringAsFixed(2)} km";
    }
    return "${val.toStringAsFixed(2)} $baseUnit";
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor = Colors.cyanAccent;
    if (calcMode == 1) themeColor = Colors.pinkAccent;
    if (calcMode == 2) themeColor = Colors.orangeAccent;

    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      body: Stack(
        children: [
          // 1. CANLI DALGA ANİMASYONU (ARKA PLAN)
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: PropagationWavePainter(
                  animationValue: _animController.value,
                  color: themeColor,
                  frequency: visualFreq,
                ),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("DALGA ANALİZÖRÜ", style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                            Text("Frekans • Periyot • Lambda", style: TextStyle(color: Colors.grey[500], fontSize: 10, letterSpacing: 2)),
                          ],
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 2. ORTAM SEÇİMİ (HIZ)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)),
                    child: Row(
                      children: [
                        _buildRadioBtn("IŞIK / RF (EM Dalga)", 0, Icons.wb_sunny),
                        _buildRadioBtn("SES (Hava)", 1, Icons.volume_up),
                      ],
                    ),
                  ),

                  // 3. MOD SEÇİMİ (NE GİRİLECEK?)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildModeChip("FREKANS GİR", 0, Colors.cyanAccent),
                        const SizedBox(width: 10),
                        _buildModeChip("PERİYOT GİR", 1, Colors.pinkAccent),
                        const SizedBox(width: 10),
                        _buildModeChip("DALGA BOYU GİR", 2, Colors.orangeAccent),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 4. GİRİŞ ALANI
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF353A40),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: themeColor.withValues(alpha: 0.5)),
                      boxShadow: [BoxShadow(color: themeColor.withValues(alpha: 0.2), blurRadius: 15)]
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(hintText: "Değer...", hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none),
                            onChanged: (v) => _calculate(),
                          ),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: inputUnit,
                            dropdownColor: const Color(0xFF2E3239),
                            style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 18),
                            items: currentUnits.keys.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() {
                                  inputUnit = v;
                                  inputMult = currentUnits[v]!;
                                  _calculate();
                                });
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 5. SONUÇLAR
                  _buildResultCard("FREKANS (f)", resFreq, Colors.cyanAccent, calcMode == 0),
                  const SizedBox(height: 10),
                  _buildResultCard("PERİYOT (T)", resPeriod, Colors.pinkAccent, calcMode == 1),
                  const SizedBox(height: 10),
                  _buildResultCard("DALGA BOYU (λ)", resWavelength, Colors.orangeAccent, calcMode == 2),

                  const SizedBox(height: 30),

                  // 6. BİLGİ KUTUSU
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)),
                    child: Column(
                      children: [
                        const Row(children: [Icon(Icons.info_outline, color: Colors.amber, size: 18), SizedBox(width: 10), Text("FORMÜLLER", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))]),
                        const SizedBox(height: 10),
                        _buildFormulaText("λ (Lambda) = v / f"),
                        _buildFormulaText("f (Frekans) = 1 / T"),
                        _buildFormulaText("v (Işık) ≈ 300,000 km/s"),
                        _buildFormulaText("v (Ses) ≈ 343 m/s"),
                      ],
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

  Widget _buildFormulaText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        const Icon(Icons.arrow_right, color: Colors.grey, size: 16),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
    );
  }

  Widget _buildRadioBtn(String title, int val, IconData icon) {
    bool isSelected = waveMedium == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { waveMedium = val; _calculate(); }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 20),
              const SizedBox(height: 5),
              Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeChip(String title, int mode, Color color) {
    bool isSelected = calcMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          calcMode = mode;
          _inputController.clear();
          _updateUnitList();
          _resetResults();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.black26,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.transparent),
        ),
        child: Text(title, style: TextStyle(color: isSelected ? color : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _buildResultCard(String title, String value, Color color, bool isInput) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: isInput ? color.withValues(alpha: 0.05) : Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isInput ? color.withValues(alpha: 0.3) : Colors.transparent)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          Text(value, style: GoogleFonts.shareTechMono(color: isInput ? color : Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _resetResults() {
    resFreq = "---"; resPeriod = "---"; resWavelength = "---"; visualFreq = 1.0;
  }
}

// --- HAREKETLİ DALGA EFEKTİ ---
class PropagationWavePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double frequency; // Görsel sıklık

  PropagationWavePainter({required this.animationValue, required this.color, required this.frequency});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    double centerY = size.height / 2;
    
    // Dalga Hareketi (Sola doğru akıyor)
    double shift = animationValue * 2 * pi; 

    for (double x = 0; x <= size.width; x+=2) {
      // Sinüs Dalgası: Genlik * sin(Frekans * x + Faz)
      // frequency değişkeni dalgaları sıklaştırır
      double y = centerY + 60 * sin((x / size.width * 2 * pi * frequency) - shift);
      
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Glow Efekti
    final glowPaint = Paint()..color = color.withValues(alpha: 0.05)..strokeWidth = 10..style = PaintingStyle.stroke..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant PropagationWavePainter oldDelegate) => true;
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
