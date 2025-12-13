import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui; // <-- İŞTE BU EKSİKTİ (Animasyon için şart)

class OpAmpScreen extends StatefulWidget {
  const OpAmpScreen({super.key});

  @override
  State<OpAmpScreen> createState() => _OpAmpScreenState();
}

class _OpAmpScreenState extends State<OpAmpScreen> with SingleTickerProviderStateMixin {
  // --- DURUM DEĞİŞKENLERİ ---
  bool isInverting = true; // true: Eviren, false: Evirmeyen

  // Kontrolcüler
  final TextEditingController _vinController = TextEditingController(text: "1.0");
  final TextEditingController _rfController = TextEditingController(text: "10"); // Geri Besleme
  final TextEditingController _rinController = TextEditingController(text: "2");  // Giriş

  // Sonuçlar
  String voutResult = "---";
  String gainResult = "---";
  Color themeColor = Colors.cyanAccent;

  // Animasyon
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _calculate();
  }

  @override
  void dispose() {
    _animController.dispose();
    _vinController.dispose();
    _rfController.dispose();
    _rinController.dispose();
    super.dispose();
  }

  // --- HESAPLAMA MOTORU ---
  void _calculate() {
    double vin = double.tryParse(_vinController.text) ?? 0;
    double rf = double.tryParse(_rfController.text) ?? 0;
    double rin = double.tryParse(_rinController.text) ?? 0;

    if (rin == 0) {
      setState(() { voutResult = "Hata"; gainResult = "---"; });
      return;
    }

    double vout = 0;
    double gain = 0;

    if (isInverting) {
      // Eviren: Vout = -Vin * (Rf / Rin)
      gain = -(rf / rin);
      vout = vin * gain;
      themeColor = Colors.cyanAccent;
    } else {
      // Evirmeyen: Vout = Vin * (1 + Rf / Rin)
      gain = 1 + (rf / rin);
      vout = vin * gain;
      themeColor = Colors.orangeAccent;
    }

    setState(() {
      voutResult = "${vout.toStringAsFixed(2)} V";
      gainResult = "${gain.toStringAsFixed(2)} X";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      body: Stack(
        children: [
          // 1. CANLI ARKA PLAN (DEVRE YOLLARI)
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: CircuitTracePainter(_animController.value, themeColor),
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
                      Text("OP-AMP HESAPLA", style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 2. MOD SEÇİCİ
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white10)),
                    child: Row(
                      children: [
                        _buildModeBtn("EVİREN (Inverting)", true),
                        _buildModeBtn("EVİRMEYEN (Non-Inv.)", false),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 3. DİNAMİK DEVRE ŞEMASI
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: OpAmpSchematicPainter(isInverting: isInverting, color: themeColor),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 4. SONUÇ PANELİ
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF353A40),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: themeColor.withValues(alpha: 0.5)),
                      boxShadow: [BoxShadow(color: themeColor.withValues(alpha: 0.2), blurRadius: 15)]
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildResultItem("ÇIKIŞ (Vout)", voutResult, themeColor),
                        Container(width: 2, height: 50, color: Colors.white10),
                        _buildResultItem("KAZANÇ (Gain)", gainResult, Colors.white),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 5. GİRİŞLER
                  _buildInputBox("Giriş Voltajı (Vin)", "V", _vinController),
                  _buildInputBox("Giriş Direnci (Rin/R1)", "kΩ", _rinController),
                  _buildInputBox("Geri Besleme (Rf)", "kΩ", _rfController),

                  const SizedBox(height: 20),
                  // Formül Bilgisi
                  Text(
                    isInverting ? "Formül: Vout = -Vin × (Rf / Rin)" : "Formül: Vout = Vin × (1 + Rf / Rin)",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12, fontStyle: FontStyle.italic),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeBtn(String title, bool mode) {
    bool isSelected = isInverting == mode;
    Color color = mode ? Colors.cyanAccent : Colors.orangeAccent;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { isInverting = mode; _calculate(); }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: isSelected ? color : Colors.transparent),
            boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 10)] : []
          ),
          child: Text(title, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? color : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12, letterSpacing: 1)),
        const SizedBox(height: 5),
        Text(value, style: GoogleFonts.shareTechMono(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildInputBox(String label, String unit, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(color: const Color(0xFF22252A), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.grey), border: InputBorder.none),
              onChanged: (v) => _calculate(),
            ),
          ),
          Text(unit, style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 16))
        ],
      ),
    );
  }
}

// --- DİNAMİK OP-AMP ŞEMA ÇİZİCİ ---
class OpAmpSchematicPainter extends CustomPainter {
  final bool isInverting;
  final Color color;
  OpAmpSchematicPainter({required this.isInverting, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke;
    final glowPaint = Paint()..color = color.withValues(alpha: 0.4)..strokeWidth = 4..style = PaintingStyle.stroke..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final resistorPaint = Paint()..color = Colors.grey[400]!..strokeWidth = 2..style = PaintingStyle.stroke;

    double cx = size.width / 2;
    double cy = size.height / 2;
    double triSize = 60;

    // Op-Amp Üçgeni
    Path triPath = Path();
    triPath.moveTo(cx + triSize, cy); 
    triPath.lineTo(cx - triSize + 20, cy - triSize + 10); 
    triPath.lineTo(cx - triSize + 20, cy + triSize - 10); 
    triPath.close();
    canvas.drawPath(triPath, glowPaint);
    canvas.drawPath(triPath, paint);

    _drawText(canvas, "-", Offset(cx - triSize + 25, cy - 25), color, 20, true);
    _drawText(canvas, "+", Offset(cx - triSize + 25, cy + 10), color, 20, true);

    if (isInverting) {
      // EVİREN MOD
      canvas.drawLine(Offset(20, cy - 30), Offset(cx - triSize - 30, cy - 30), paint); // Vin yolu
      _drawResistor(canvas, Offset(cx - triSize - 30, cy - 30), Offset(cx - triSize + 20, cy - 30), resistorPaint); // Rin
      _drawText(canvas, "Rin", Offset(cx - triSize - 15, cy - 55), Colors.grey);
      _drawText(canvas, "Vin", Offset(0, cy - 35), color);

      canvas.drawLine(Offset(cx - triSize + 20, cy + 20), Offset(cx - triSize + 20, cy + 50), paint);
      _drawGND(canvas, Offset(cx - triSize + 20, cy + 50), paint);
    } else {
      // EVİRMEYEN MOD
      canvas.drawLine(Offset(20, cy + 20), Offset(cx - triSize + 20, cy + 20), paint);
      _drawText(canvas, "Vin", Offset(0, cy + 15), color);

       _drawGND(canvas, Offset(cx - triSize - 30, cy + 10), paint);
      canvas.drawLine(Offset(cx - triSize - 30, cy - 10), Offset(cx - triSize - 30, cy - 30), paint);
      _drawResistor(canvas, Offset(cx - triSize - 30, cy - 30), Offset(cx - triSize + 20, cy - 30), resistorPaint);
      _drawText(canvas, "Rin", Offset(cx - triSize - 15, cy - 55), Colors.grey);
    }

    // Geri Besleme (Rf)
    canvas.drawLine(Offset(cx - triSize + 20, cy - 30), Offset(cx - triSize + 20, cy - 70), paint);
    _drawResistor(canvas, Offset(cx - triSize + 20, cy - 70), Offset(cx + triSize, cy - 70), resistorPaint);
    canvas.drawLine(Offset(cx + triSize, cy - 70), Offset(cx + triSize, cy), paint);
    _drawText(canvas, "Rf", Offset(cx, cy - 95), Colors.grey);

    canvas.drawLine(Offset(cx + triSize, cy), Offset(size.width - 20, cy), paint);
    _drawText(canvas, "Vout", Offset(size.width - 35, cy - 20), color);
  }

  void _drawResistor(Canvas canvas, Offset start, Offset end, Paint paint) {
    double midX = (start.dx + end.dx) / 2;
    double width = 40;
    double height = 10;
    Rect rect = Rect.fromCenter(center: Offset(midX, start.dy), width: width, height: height);
    canvas.drawRect(rect, paint..style=PaintingStyle.stroke);
    canvas.drawLine(start, Offset(midX - width/2, start.dy), paint);
    canvas.drawLine(Offset(midX + width/2, start.dy), end, paint);
  }

  void _drawGND(Canvas canvas, Offset pos, Paint paint) {
    canvas.drawLine(pos, Offset(pos.dx, pos.dy + 10), paint);
    canvas.drawLine(Offset(pos.dx - 15, pos.dy + 10), Offset(pos.dx + 15, pos.dy + 10), paint);
    canvas.drawLine(Offset(pos.dx - 8, pos.dy + 15), Offset(pos.dx + 8, pos.dy + 15), paint);
    canvas.drawLine(Offset(pos.dx - 2, pos.dy + 20), Offset(pos.dx + 2, pos.dy + 20), paint);
  }

  void _drawText(Canvas c, String text, Offset pos, Color color, [double fontSize = 14, bool bold = false]) {
    final textSpan = TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: bold ? FontWeight.bold : FontWeight.normal));
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(c, pos);
  }
  @override
  bool shouldRepaint(covariant OpAmpSchematicPainter oldDelegate) => oldDelegate.isInverting != isInverting || oldDelegate.color != color;
}

// --- ARKA PLAN ANİMASYONU ---
class CircuitTracePainter extends CustomPainter {
  final double animValue;
  final Color color;
  CircuitTracePainter(this.animValue, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.05)..strokeWidth = 1.5..style = PaintingStyle.stroke;
    final flowPaint = Paint()..color = color.withValues(alpha: 0.3)..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    Path path1 = Path()..moveTo(0, size.height * 0.2)..lineTo(size.width * 0.3, size.height * 0.2)..lineTo(size.width * 0.4, size.height * 0.4)..lineTo(size.width, size.height * 0.4);
    Path path2 = Path()..moveTo(size.width * 0.1, 0)..lineTo(size.width * 0.1, size.height * 0.6)..lineTo(size.width * 0.5, size.height * 0.8)..lineTo(size.width * 0.5, size.height);
    
    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);

    _drawFlow(canvas, path1, animValue, flowPaint);
    _drawFlow(canvas, path2, (animValue + 0.5) % 1.0, flowPaint);
  }

  void _drawFlow(Canvas canvas, Path path, double progress, Paint paint) {
    ui.PathMetrics pathMetrics = path.computeMetrics(); // <-- DÜZELTİLDİ (ui.PathMetrics)
    for (ui.PathMetric pathMetric in pathMetrics) { // <-- DÜZELTİLDİ (ui.PathMetric)
      double length = pathMetric.length;
      double start = length * progress;
      double end = start + length * 0.1;
      canvas.drawPath(pathMetric.extractPath(start, end), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CircuitTracePainter oldDelegate) => true;
}
