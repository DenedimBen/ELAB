import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VoltageDividerScreen extends StatefulWidget {
  const VoltageDividerScreen({super.key});

  @override
  State<VoltageDividerScreen> createState() => _VoltageDividerScreenState();
}

class _VoltageDividerScreenState extends State<VoltageDividerScreen> with SingleTickerProviderStateMixin {
  // Kontrolcüler
  final TextEditingController _vinController = TextEditingController(text: "12");
  final TextEditingController _r1Controller = TextEditingController(text: "10");
  final TextEditingController _r2Controller = TextEditingController(text: "10");

  // Birimler
  double r1Mult = 1000.0; // kΩ
  double r2Mult = 1000.0; // kΩ
  String r1Unit = "kΩ";
  String r2Unit = "kΩ";

  // Sonuç
  String voutResult = "6.00 V";
  
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
    super.dispose();
  }

  void _calculate() {
    double vin = double.tryParse(_vinController.text) ?? 0;
    double r1 = (double.tryParse(_r1Controller.text) ?? 0) * r1Mult;
    double r2 = (double.tryParse(_r2Controller.text) ?? 0) * r2Mult;

    if (r1 + r2 == 0) {
      setState(() => voutResult = "0.00 V");
      return;
    }

    // Formül: Vout = Vin * (R2 / (R1 + R2))
    double vout = vin * (r2 / (r1 + r2));

    setState(() {
      voutResult = "${vout.toStringAsFixed(2)} V";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      body: Stack(
        children: [
          // 1. ARKA PLAN DEVRE YOLU (ANIMASYONLU)
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: CircuitFlowPainter(_animController.value),
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back, color: Colors.grey), onPressed: () => Navigator.pop(context)),
                      const SizedBox(width: 10),
                      Text("GERİLİM BÖLÜCÜ", style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          // --- 1. GİRİŞ VOLTAJI (VIN) ---
                          _buildNode("GİRİŞ (Vin)", Colors.redAccent, _vinController, null, null, isVoltage: true),
                          
                          const SizedBox(height: 10),
                          
                          // --- 2. R1 DİRENÇ ---
                          _buildResistorBox("R1 (Üst Direnç)", Colors.blueAccent, _r1Controller, r1Unit, (val) { setState(() => r1Unit = val); _updateMults(); }),

                          // --- 3. ÇIKIŞ VOLTAJI (VOUT - MERKEZ) ---
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.greenAccent, width: 2),
                              boxShadow: [
                                BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.4), blurRadius: 30, spreadRadius: 5)
                              ]
                            ),
                            child: Column(
                              children: [
                                Text("ÇIKIŞ (Vout)", style: TextStyle(color: Colors.greenAccent.withValues(alpha: 0.8), fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                Text(
                                  voutResult,
                                  style: GoogleFonts.shareTechMono(fontSize: 50, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),

                          // --- 4. R2 DİRENÇ ---
                          _buildResistorBox("R2 (Alt Direnç)", Colors.purpleAccent, _r2Controller, r2Unit, (val) { setState(() => r2Unit = val); _updateMults(); }),

                          const SizedBox(height: 20),

                          // --- 5. GND ---
                          const Icon(Icons.download, color: Colors.grey, size: 30),
                          const Text("GND (0V)", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateMults() {
    r1Mult = r1Unit == "Ω" ? 1.0 : (r1Unit == "kΩ" ? 1000.0 : 1000000.0);
    r2Mult = r2Unit == "Ω" ? 1.0 : (r2Unit == "kΩ" ? 1000.0 : 1000000.0);
    _calculate();
  }

  // VOLTAJ GİRİŞ KUTUSU
  Widget _buildNode(String label, Color color, TextEditingController controller, String? unitVal, Function(String)? onUnitChange, {bool isVoltage = false}) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: const Color(0xFF22252A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.5)),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10)]
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(border: InputBorder.none, hintText: "0", hintStyle: TextStyle(color: Colors.grey)),
                  onChanged: (v) => _calculate(),
                ),
              ),
              Text(isVoltage ? "V" : "", style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold))
            ],
          ),
        ),
      ],
    );
  }

  // DİRENÇ KUTUSU (Birim Seçmeli)
  Widget _buildResistorBox(String label, Color color, TextEditingController controller, String unitVal, Function(String) onUnitChange) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF353A40),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Row(
        children: [
          // Direnç İkonu
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.linear_scale, color: color), // Direnç temsili
          ),
          const SizedBox(width: 15),
          
          // Değer Girişi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero, hintText: "0", hintStyle: TextStyle(color: Colors.grey)),
                  onChanged: (v) => _calculate(),
                ),
              ],
            ),
          ),

          // Birim Seçici
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: unitVal,
                dropdownColor: const Color(0xFF353A40),
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
                icon: Icon(Icons.arrow_drop_down, color: color),
                items: ['Ω', 'kΩ', 'MΩ'].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                onChanged: (val) => onUnitChange(val!),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// --- SİNYAL AKIŞI ÇİZİCİSİ (DEVRE YOLU) ---
class CircuitFlowPainter extends CustomPainter {
  final double animValue;
  CircuitFlowPainter(this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.05)..strokeWidth = 2..style = PaintingStyle.stroke;
    final flowPaint = Paint()..color = Colors.amber.withValues(alpha: 0.4)..strokeWidth = 4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;

    double cx = size.width / 2;
    
    // Ana Hat (Dikey Çizgi)
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), paint);

    // Akım Efekti (Kesik çizgiler aşağı akıyor)
    double dashHeight = 20;
    double gap = 30;
    double total = dashHeight + gap;
    double offset = animValue * total;

    for (double y = -total; y < size.height; y += total) {
      double startY = y + offset;
      if (startY > size.height) continue;
      canvas.drawLine(Offset(cx, startY), Offset(cx, startY + dashHeight), flowPaint);
    }
    
    // Yatay Izgara (Süs)
    final gridPaint = Paint()..color = Colors.white.withValues(alpha: 0.02)..strokeWidth = 1;
    for(double y=0; y<size.height; y+=40) canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
  }
  @override
  bool shouldRepaint(covariant CircuitFlowPainter oldDelegate) => true;
}