import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class ReactanceScreen extends StatefulWidget {
  const ReactanceScreen({super.key});

  @override
  State<ReactanceScreen> createState() => _ReactanceScreenState();
}

class _ReactanceScreenState extends State<ReactanceScreen> with SingleTickerProviderStateMixin {
  // --- DURUM DEĞİŞKENLERİ ---
  int mode = 0; // 0: X_L, 1: X_C, 2: Rezonans
  
  // Kontrolcüler
  final TextEditingController _freqController = TextEditingController();
  final TextEditingController _indController = TextEditingController(); // Bobin (L)
  final TextEditingController _capController = TextEditingController(); // Kondansatör (C)

  // Birim Çarpanları (Varsayılanlar)
  double freqMult = 1000.0; // kHz
  double indMult = 0.000001; // µH
  double capMult = 0.000000001; // nF
  
  String freqUnit = "kHz";
  String indUnit = "µH";
  String capUnit = "nF";

  // Animasyon
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // --- HESAPLAMA MOTORU ---
  String _calculate() {
    double f = (double.tryParse(_freqController.text) ?? 0) * freqMult;
    double l = (double.tryParse(_indController.text) ?? 0) * indMult;
    double c = (double.tryParse(_capController.text) ?? 0) * capMult;

    if (mode == 0) { // X_L = 2*pi*f*L
      if (f == 0 || l == 0) return "---";
      double xl = 2 * pi * f * l;
      return _formatOhms(xl);
    } 
    else if (mode == 1) { // X_C = 1 / (2*pi*f*C)
      if (f == 0 || c == 0) return "---";
      double xc = 1 / (2 * pi * f * c);
      return _formatOhms(xc);
    } 
    else { // Rezonans = 1 / (2*pi*sqrt(L*C))
      if (l == 0 || c == 0) return "---";
      double fr = 1 / (2 * pi * sqrt(l * c));
      return _formatFreq(fr);
    }
  }

  String _formatOhms(double val) {
    if (val >= 1e6) return "${(val / 1e6).toStringAsFixed(2)} MΩ";
    if (val >= 1e3) return "${(val / 1e3).toStringAsFixed(2)} kΩ";
    return "${val.toStringAsFixed(2)} Ω";
  }

  String _formatFreq(double val) {
    if (val >= 1e6) return "${(val / 1e6).toStringAsFixed(3)} MHz";
    if (val >= 1e3) return "${(val / 1e3).toStringAsFixed(3)} kHz";
    return "${val.toStringAsFixed(2)} Hz";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      body: Stack(
        children: [
          // 1. CANLI SİNÜS DALGASI (ARKA PLAN)
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: SineWavePainter(_animController.value, mode),
              );
            },
          ),

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
                        Text("REAKTANS & REZONANS", style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 2. MOD SEÇİCİ
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white10)),
                      child: Row(
                        children: [
                          _buildModeBtn("XL (Bobin)", 0),
                          _buildModeBtn("XC (Kond.)", 1),
                          _buildModeBtn("Rezonans", 2),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 3. SONUÇ EKRANI
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF353A40),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 5))],
                        border: Border.all(color: _getModeColor().withValues(alpha: 0.5))
                      ),
                      child: Column(
                        children: [
                          Text(
                            mode == 2 ? "REZONANS FREKANSI" : "REAKTANS (DİRENÇ)",
                            style: TextStyle(color: Colors.grey[400], fontSize: 10, letterSpacing: 2)
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _calculate(),
                            style: GoogleFonts.shareTechMono(
                              fontSize: 45,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [BoxShadow(color: _getModeColor().withValues(alpha: 0.6), blurRadius: 20)]
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 4. GİRİŞLER (Moda göre değişir)
                    if (mode != 2) // Rezonansta frekans girilmez, sonuçtur
                      _buildInputRow("Frekans (f)", _freqController, freqUnit, (val) => setState(() => freqUnit = val), {'Hz': 1.0, 'kHz': 1e3, 'MHz': 1e6}, (val) => freqMult = val),
                    
                    if (mode != 1) // X_C modunda Bobin (L) yok
                      _buildInputRow("Bobin (L)", _indController, indUnit, (val) => setState(() => indUnit = val), {'nH': 1e-9, 'µH': 1e-6, 'mH': 1e-3, 'H': 1.0}, (val) => indMult = val),
                    
                    if (mode != 0) // X_L modunda Kondansatör (C) yok
                      _buildInputRow("Kondansatör (C)", _capController, capUnit, (val) => setState(() => capUnit = val), {'pF': 1e-12, 'nF': 1e-9, 'µF': 1e-6, 'mF': 1e-3}, (val) => capMult = val),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getModeColor() {
    if (mode == 0) return Colors.tealAccent; // Bobin
    if (mode == 1) return Colors.purpleAccent; // Kondansatör
    return Colors.orangeAccent; // Rezonans
  }

  Widget _buildModeBtn(String title, int modeVal) {
    bool isSelected = mode == modeVal;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          mode = modeVal;
          _calculate();
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _getModeColor() : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(title, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.black : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildInputRow(String label, TextEditingController controller, String currentUnit, Function(String) onUnitChange, Map<String, double> units, Function(double) onMultChange) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF22252A),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10)
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none
                ),
                onChanged: (v) => setState(() {}),
              ),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentUnit,
                dropdownColor: const Color(0xFF353A40),
                icon: Icon(Icons.arrow_drop_down, color: _getModeColor()),
                style: TextStyle(color: _getModeColor(), fontWeight: FontWeight.bold),
                items: units.keys.map((String key) {
                  return DropdownMenuItem<String>(
                    value: key,
                    child: Text(key),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    onUnitChange(newValue);
                    onMultChange(units[newValue]!);
                    setState(() {});
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- SİNÜS DALGASI ANİMASYONU ---
class SineWavePainter extends CustomPainter {
  final double animationValue;
  final int mode;
  SineWavePainter(this.animationValue, this.mode);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (mode == 0 ? Colors.teal : mode == 1 ? Colors.purple : Colors.orange).withValues(alpha: 0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    double centerY = size.height / 2;
    
    // Dalga Çizimi
    for (double x = 0; x <= size.width; x++) {
      // Hareket efekti: animationValue * 2 * pi
      double y = centerY + 50 * sin((x / 50) + (animationValue * 2 * pi));
      if (x == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
    
    // İkinci Dalga (Ters Faz - Görsel Zenginlik)
    if (mode == 2) { // Rezonansta çift dalga
      final path2 = Path();
      for (double x = 0; x <= size.width; x++) {
        double y = centerY + 50 * cos((x / 50) + (animationValue * 2 * pi)); // Cos
        if (x == 0) path2.moveTo(x, y);
        else path2.lineTo(x, y);
      }
      paint.color = Colors.blue.withValues(alpha: 0.1);
      canvas.drawPath(path2, paint);
    }
  }
  @override
  bool shouldRepaint(covariant SineWavePainter oldDelegate) => true;
}