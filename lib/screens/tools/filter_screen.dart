import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> with SingleTickerProviderStateMixin {
  // --- DURUM DEĞİŞKENLERİ ---
  int circuitType = 0; // 0: RC, 1: RL
  int filterType = 0;  // 0: Low Pass, 1: High Pass

  final TextEditingController _resController = TextEditingController();
  final TextEditingController _capIndController = TextEditingController();

  // Birimler
  double rMult = 1000.0;
  double val2Mult = 0.000001; 
  String rUnit = "kΩ";
  String val2Unit = "µF"; 

  // Sonuçlar
  String resFc = "---"; 
  String resW = "---";  
  String resXc = "---"; 
  String resZ = "---";  
  String resPhase = "---";

  // Animasyon Kontrolcüsü
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    // Arka plan animasyonu için
    _animController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 3)
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // --- HESAPLAMA MOTORU ---
  void _calculate() {
    double r = (double.tryParse(_resController.text) ?? 0) * rMult;
    double val2 = (double.tryParse(_capIndController.text) ?? 0) * val2Mult;
    
    if (r <= 0 || val2 <= 0) {
      setState(() {
        resFc = "---"; resW = "---"; resXc = "---"; resZ = "---"; resPhase = "---";
      });
      return;
    }

    double fc = 0;
    double w = 0;
    double react = 0;
    double z = 0;
    double phase = 0;

    if (circuitType == 0) { 
      double c = val2;
      fc = 1 / (2 * pi * r * c);
      w = 2 * pi * fc;
      react = 1 / (w * c); 
      z = sqrt(r*r + react*react);
      phase = -atan(react / r) * (180 / pi);
    } else {
      double l = val2;
      fc = r / (2 * pi * l);
      w = 2 * pi * fc;
      react = w * l; 
      z = sqrt(r*r + react*react);
      phase = atan(react / r) * (180 / pi);
    }

    setState(() {
      resFc = _formatVal(fc, "Hz");
      resW = _formatVal(w, "rad/s");
      resXc = _formatVal(react, "Ω");
      resZ = _formatVal(z, "Ω");
      resPhase = "${phase.toStringAsFixed(1)}°";
    });
  }

  String _formatVal(double val, String unit) {
    if (val >= 1e6) return "${(val / 1e6).toStringAsFixed(2)} M$unit";
    if (val >= 1e3) return "${(val / 1e3).toStringAsFixed(2)} k$unit";
    if (val < 1 && val > 0) return "${(val * 1000).toStringAsFixed(1)} m$unit";
    return "${val.toStringAsFixed(2)} $unit";
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor = filterType == 0 ? Colors.cyanAccent : Colors.pinkAccent;
    String val2Label = circuitType == 0 ? "Kondansatör (C)" : "Bobin (L)";
    Map<String, double> val2Units = circuitType == 0 
      ? {'pF': 1e-12, 'nF': 1e-9, 'µF': 1e-6} 
      : {'µH': 1e-6, 'mH': 1e-3, 'H': 1.0};

    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      body: Stack(
        children: [
          // 1. CANLI ARKA PLAN (SİNYAL AKIŞI)
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: FilterSignalPainter(
                  animationValue: _animController.value,
                  color: themeColor,
                  isHighPass: filterType == 1,
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
                      Text("FİLTRE HESAPLA", style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // MOD SEÇİCİLER
                  Row(
                    children: [
                      Expanded(child: _buildToggleBtn("RC (Direnç-Kond.)", 0, circuitType, (v) { setState(() { circuitType = v; val2Unit = v==0?"µF":"mH"; val2Mult=v==0?1e-6:1e-3; _calculate(); }); })),
                      const SizedBox(width: 10),
                      Expanded(child: _buildToggleBtn("RL (Direnç-Bobin)", 1, circuitType, (v) { setState(() { circuitType = v; val2Unit = v==0?"µF":"mH"; val2Mult=v==0?1e-6:1e-3; _calculate(); }); })),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildToggleBtn("LOW PASS", 0, filterType, (v) { setState(() => filterType = v); _calculate(); }, color: Colors.cyanAccent)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildToggleBtn("HIGH PASS", 1, filterType, (v) { setState(() => filterType = v); _calculate(); }, color: Colors.pinkAccent)),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // GRAFİK (BODE PLOT)
                  Container(
                    height: 220,
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(30, 10, 10, 30),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: themeColor.withValues(alpha: 0.5)),
                      boxShadow: [BoxShadow(color: themeColor.withValues(alpha: 0.1), blurRadius: 20)]
                    ),
                    child: CustomPaint(
                      painter: BodePlotPainter(filterType, themeColor, resFc),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // SONUÇ TABLOSU
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
                    child: Column(
                      children: [
                        _buildResultRow("Kesme Frekansı (fc)", resFc, themeColor, isMain: true),
                        const Divider(color: Colors.grey),
                        _buildResultRow("Açısal Frekans (ω)", resW, Colors.white),
                        _buildResultRow(circuitType == 0 ? "Kapasitif Reaktans (Xc)" : "Endüktif Reaktans (Xl)", resXc, Colors.white70),
                        _buildResultRow("Empedans |Z|", resZ, Colors.white70),
                        _buildResultRow("Faz Farkı (φ)", resPhase, Colors.white70),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // GİRİŞLER
                  _buildInputRow("Direnç (R)", _resController, rUnit, (val) { setState(() => rUnit = val); _calculate(); }, {'Ω': 1.0, 'kΩ': 1e3, 'MΩ': 1e6}, (val) { rMult = val; _calculate(); }, themeColor),
                  const SizedBox(height: 15),
                  _buildInputRow(val2Label, _capIndController, val2Unit, (val) { setState(() => val2Unit = val); _calculate(); }, val2Units, (val) { val2Mult = val; _calculate(); }, themeColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color, {bool isMain = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: isMain ? 14 : 12)),
          Text(value, style: GoogleFonts.shareTechMono(color: color, fontSize: isMain ? 24 : 16, fontWeight: isMain ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(String title, int val, int groupVal, Function(int) onTap, {Color color = Colors.amber}) {
    bool isSelected = val == groupVal;
    return GestureDetector(
      onTap: () => onTap(val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: isSelected ? color.withValues(alpha: 0.2) : Colors.black26, borderRadius: BorderRadius.circular(10), border: Border.all(color: isSelected ? color : Colors.white10)),
        child: Text(title, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? color : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _buildInputRow(String label, TextEditingController controller, String currentUnit, Function(String) onUnitChange, Map<String, double> units, Function(double) onMultChange, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(color: const Color(0xFF22252A), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          Expanded(child: TextField(controller: controller, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.grey), border: InputBorder.none), onChanged: (v) => _calculate())),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentUnit, dropdownColor: const Color(0xFF353A40), icon: Icon(Icons.arrow_drop_down, color: color), style: TextStyle(color: color, fontWeight: FontWeight.bold),
              items: units.keys.map((String key) => DropdownMenuItem<String>(value: key, child: Text(key))).toList(),
              onChanged: (String? newValue) { if (newValue != null) { onUnitChange(newValue); onMultChange(units[newValue]!); } },
            ),
          )
        ],
      ),
    );
  }
}

// --- YENİ ARKA PLAN: SİNYAL AKIŞI (EKOLAYZER GİBİ) ---
class FilterSignalPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final bool isHighPass;
  
  FilterSignalPainter({required this.animationValue, required this.color, required this.isHighPass});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Ekrana dikey çubuklar (sinyal) çiziyoruz
    double barWidth = size.width / 20;

    for (int i = 0; i < 20; i++) {
      double x = i * barWidth;
      
      // Çubuk yüksekliğini hesapla
      // High Pass ise sağa doğru (i arttıkça) yükseklik artar
      // Low Pass ise sola doğru (i azaldıkça) yükseklik artar
      double heightFactor = isHighPass ? (i / 20) : (1 - (i / 20));
      
      // Animasyon etkisi (Dalgalanma)
      double wave = sin((i * 0.5) + (animationValue * 2 * pi));
      
      double barHeight = (size.height * 0.3) * heightFactor + (wave * 20);
      if (barHeight < 0) barHeight = 0;

      // Çubuğu çiz (Aşağıdan yukarı)
      canvas.drawLine(Offset(x + barWidth/2, size.height), Offset(x + barWidth/2, size.height - barHeight), paint);
      
      // Tepesine nokta koy
      canvas.drawCircle(Offset(x + barWidth/2, size.height - barHeight), 2, paint..style=PaintingStyle.fill);
    }
  }
  @override
  bool shouldRepaint(covariant FilterSignalPainter oldDelegate) => true;
}

class BodePlotPainter extends CustomPainter {
  final int type; // 0: Low, 1: High
  final Color color;
  final String fcText;
  BodePlotPainter(this.type, this.color, this.fcText);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 3..style = PaintingStyle.stroke;
    final axisPaint = Paint()..color = Colors.white30..strokeWidth = 1;
    const textStyle = TextStyle(color: Colors.white54, fontSize: 10);

    // Eksenleri Çiz
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), axisPaint); 
    canvas.drawLine(const Offset(0, 0), Offset(0, size.height), axisPaint); 

    _drawText(canvas, "0dB", const Offset(-25, 0), textStyle);
    _drawText(canvas, "-3dB", Offset(-25, size.height * 0.2), textStyle);
    _drawText(canvas, "Freq", Offset(size.width - 30, size.height + 5), textStyle);

    final path = Path();
    if (type == 0) {
      path.moveTo(0, 0); 
      path.lineTo(size.width * 0.4, 0); 
      path.quadraticBezierTo(size.width * 0.6, 0, size.width, size.height); 
    } else {
      path.moveTo(0, size.height);
      path.quadraticBezierTo(size.width * 0.4, size.height, size.width * 0.6, 0); 
      path.lineTo(size.width, 0); 
    }
    canvas.drawPath(path, paint);
    
    // -3dB Noktası
    if (fcText != "---") {
      final dotPaint = Paint()..color = Colors.white;
      double cx = type == 0 ? size.width * 0.6 : size.width * 0.4; // Kırılma noktası
      double cy = size.height * 0.2;
      canvas.drawCircle(Offset(cx, cy), 4, dotPaint);
    }
  }

  void _drawText(Canvas c, String text, Offset pos, TextStyle style) {
    final span = TextSpan(style: style, text: text);
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(c, pos);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
