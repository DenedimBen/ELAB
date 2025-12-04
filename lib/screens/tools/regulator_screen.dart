import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class RegulatorScreen extends StatefulWidget {
  const RegulatorScreen({super.key});

  @override
  State<RegulatorScreen> createState() => _RegulatorScreenState();
}

class _RegulatorScreenState extends State<RegulatorScreen> with SingleTickerProviderStateMixin {
  int calcMode = 0; // 0: Vout Hesapla, 1: R2 Hesapla
  
  final TextEditingController _r1Controller = TextEditingController(text: "240"); 
  final TextEditingController _r2Controller = TextEditingController(text: "1000");
  final TextEditingController _voutTargetController = TextEditingController(text: "5.0");

  String resultText = "---";
  String resultUnit = "";
  final double vRef = 1.25; 

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
    _r1Controller.dispose();
    _r2Controller.dispose();
    _voutTargetController.dispose();
    super.dispose();
  }

  void _calculate() {
    double r1 = double.tryParse(_r1Controller.text) ?? 0;
    
    if (calcMode == 0) {
      double r2 = double.tryParse(_r2Controller.text) ?? 0;
      if (r1 <= 0) { setState(() => resultText = "Hata"); return; }
      
      double vout = vRef * (1 + (r2 / r1));
      setState(() {
        resultText = vout.toStringAsFixed(2);
        resultUnit = "V";
      });
    } else {
      double vTarget = double.tryParse(_voutTargetController.text) ?? 0;
      if (r1 <= 0 || vTarget < vRef) { setState(() => resultText = "Hata"); return; }

      double r2Need = r1 * ((vTarget / vRef) - 1);
      setState(() {
        resultText = r2Need.toStringAsFixed(0);
        resultUnit = "Ω";
      });
    }
  }

  String _getSchematicLabel(String type) {
    if (type == 'R1') return "${_r1Controller.text}Ω";
    if (type == 'R2') return calcMode == 0 ? "${_r2Controller.text}Ω" : "$resultText$resultUnit";
    if (type == 'Vout') return calcMode == 0 ? "$resultText$resultUnit" : "${_voutTargetController.text}V";
    return "";
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor = Colors.cyanAccent;

    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: RegulationFlowPainter(_animController.value, themeColor),
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
                      Text("VOLTAJ REGÜLATÖRÜ", style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
                    ],
                  ),
                  Text("(LM317 Tipi)", style: TextStyle(color: Colors.grey[500], fontSize: 12)),

                  const SizedBox(height: 20),

                  // MOD SEÇİCİ
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white10)),
                    child: Row(
                      children: [
                        _buildModeBtn("ÇIKIŞ (Vout) BUL", 0),
                        _buildModeBtn("DİRENÇ (R2) BUL", 1),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // DİNAMİK ŞEMA
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: LM317SchematicPainter(
                        r1Lbl: _getSchematicLabel('R1'),
                        r2Lbl: _getSchematicLabel('R2'),
                        voutLbl: _getSchematicLabel('Vout'),
                        color: themeColor
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // SONUÇ PANELİ
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                    decoration: BoxDecoration(
                      color: const Color(0xFF353A40),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: themeColor.withValues(alpha: 0.5)),
                      boxShadow: [BoxShadow(color: themeColor.withValues(alpha: 0.2), blurRadius: 20)]
                    ),
                    child: Column(
                      children: [
                        Text(calcMode == 0 ? "HESAPLANAN ÇIKIŞ (Vout)" : "GEREKEN DİRENÇ (R2)", style: TextStyle(color: Colors.grey[400], fontSize: 12, letterSpacing: 1)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(resultText, style: GoogleFonts.shareTechMono(fontSize: 45, fontWeight: FontWeight.bold, color: themeColor)),
                            const SizedBox(width: 5),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(resultUnit, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: themeColor)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // GİRİŞLER
                  if (calcMode == 0) ...[
                    _buildInputBox("Sabit Direnç (R1)", "Ω", _r1Controller),
                    _buildInputBox("Ayarlı Direnç (R2)", "Ω", _r2Controller),
                  ] else ...[
                     _buildInputBox("İstenen Voltaj (Vout)", "V", _voutTargetController),
                    _buildInputBox("Sabit Direnç (R1)", "Ω", _r1Controller),
                  ],

                  const SizedBox(height: 30),

                  // BİLGİ KUTUSU
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10)
                    ),
                    child: Column(
                      children: [
                        const Row(children: [Icon(Icons.info_outline, color: Colors.amber, size: 18), SizedBox(width: 10), Text("NASIL ÇALIŞIR?", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))]),
                        const SizedBox(height: 10),
                        Text(
                          "LM317, çıkış (OUT) ile ayar (ADJ) bacakları arasında sabit 1.25V (Vref) tutmaya çalışır. R1 üzerindeki bu sabit voltaj bir akım oluşturur. Bu akım R2 üzerinden geçerek çıkış voltajını belirler.\n\nGenellikle R1 için 240Ω önerilir.",
                          style: TextStyle(color: Colors.grey[400], fontSize: 12, height: 1.3),
                        ),
                        const SizedBox(height: 10),
                        Text("Formül: Vout = 1.25V × (1 + R2/R1)", style: GoogleFonts.shareTechMono(color: themeColor, fontSize: 12)),
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

  Widget _buildModeBtn(String title, int mode) {
    bool isSelected = calcMode == mode;
    Color color = Colors.cyanAccent;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { calcMode = mode; _calculate(); }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: isSelected ? color : Colors.transparent),
          ),
          child: Text(title, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? color : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
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
          Text(unit, style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 16))
        ],
      ),
    );
  }
}

// --- DİNAMİK ŞEMA ÇİZİCİ (LM317) ---
class LM317SchematicPainter extends CustomPainter {
  final String r1Lbl;
  final String r2Lbl;
  final String voutLbl;
  final Color color;
  LM317SchematicPainter({required this.r1Lbl, required this.r2Lbl, required this.voutLbl, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke;
    final glowPaint = Paint()..color = color.withValues(alpha: 0.3)..strokeWidth = 4..style = PaintingStyle.stroke..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final wirePaint = Paint()..color = Colors.grey[500]!..strokeWidth = 2..style = PaintingStyle.stroke;

    double cx = size.width / 2;
    double cy = size.height / 3;

    // LM317 Kutusu
    Rect icRect = Rect.fromCenter(center: Offset(cx, cy), width: 80, height: 60);
    canvas.drawRect(icRect, glowPaint);
    canvas.drawRect(icRect, paint);
    _drawText(canvas, "LM317", Offset(cx - 25, cy - 10), color, 16, true);

    // Bacaklar
    canvas.drawLine(Offset(cx - 40, cy), Offset(cx - 80, cy), wirePaint); // IN
    _drawText(canvas, "Vin", Offset(cx - 110, cy - 10), Colors.grey);

    canvas.drawLine(Offset(cx + 40, cy), Offset(cx + 120, cy), wirePaint); // OUT
    canvas.drawCircle(Offset(cx + 120, cy), 4, paint..style=PaintingStyle.fill); 

    canvas.drawLine(Offset(cx, cy + 30), Offset(cx, cy + 60), wirePaint); // ADJ
    
    // R1
    canvas.drawLine(Offset(cx + 60, cy), Offset(cx + 60, cy + 60), wirePaint); 
    canvas.drawLine(Offset(cx + 60, cy + 60), Offset(cx, cy + 60), wirePaint); 
    Rect r1Rect = Rect.fromCenter(center: Offset(cx + 30, cy + 60), width: 40, height: 15);
    canvas.drawRect(r1Rect, wirePaint);
    _drawText(canvas, "R1", Offset(cx + 25, cy + 40), Colors.grey[400]!, 10);
    _drawText(canvas, r1Lbl, Offset(cx + 20, cy + 75), color, 12, true);

    // R2
    canvas.drawLine(Offset(cx, cy + 60), Offset(cx, cy + 120), wirePaint); 
    Rect r2Rect = Rect.fromCenter(center: Offset(cx, cy + 120), width: 15, height: 40);
    canvas.drawRect(r2Rect, wirePaint);
    _drawText(canvas, "R2", Offset(cx + 15, cy + 115), Colors.grey[400]!, 10);
    _drawText(canvas, r2Lbl, Offset(cx - 30, cy + 115), color, 12, true);

    // GND
    canvas.drawLine(Offset(cx, cy + 140), Offset(cx, cy + 160), wirePaint);
    _drawGND(canvas, Offset(cx, cy + 160), wirePaint);

    // Vout
    _drawText(canvas, "Vout", Offset(cx + 130, cy - 25), color, 16, true);
    _drawText(canvas, voutLbl, Offset(cx + 130, cy), color, 20, true);
  }

  void _drawGND(Canvas canvas, Offset pos, Paint paint) {
    canvas.drawLine(Offset(pos.dx - 15, pos.dy), Offset(pos.dx + 15, pos.dy), paint);
    canvas.drawLine(Offset(pos.dx - 8, pos.dy + 5), Offset(pos.dx + 8, pos.dy + 5), paint);
    canvas.drawLine(Offset(pos.dx - 2, pos.dy + 10), Offset(pos.dx + 2, pos.dy + 10), paint);
  }

  // --- HATA DÜZELTİLDİ: PARAMETRELER OPSİYONEL YAPILDI ---
  void _drawText(Canvas c, String text, Offset pos, Color color, [double fontSize = 14, bool bold = false]) {
    final textSpan = TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: bold ? FontWeight.bold : FontWeight.normal));
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(c, pos);
  }
  @override
  bool shouldRepaint(covariant LM317SchematicPainter oldDelegate) => true;
}

// ARKA PLAN ANİMASYONU
class RegulationFlowPainter extends CustomPainter {
  final double animValue;
  final Color color;
  RegulationFlowPainter(this.animValue, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.1)..strokeWidth = 2..style = PaintingStyle.stroke;
    final flowPaint = Paint()..color = color.withValues(alpha: 0.3)..strokeWidth = 4..style = PaintingStyle.stroke..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    Path chaoticPath = Path();
    for (double i = 0; i < size.height; i += 20) {
      chaoticPath.moveTo(0, i);
      for (double x = 0; x < size.width * 0.4; x += 10) {
        double noise = sin((x + i + animValue * 500) * 0.05) * 10;
        chaoticPath.lineTo(x, i + noise);
      }
    }
    canvas.drawPath(chaoticPath, paint);

    Path stablePath = Path();
    for (double i = 0; i < size.height; i += 20) {
      stablePath.moveTo(size.width * 0.6, i);
      stablePath.lineTo(size.width, i);
    }
    canvas.drawPath(stablePath, flowPaint);
  }
  @override
  bool shouldRepaint(covariant RegulationFlowPainter oldDelegate) => true;
}