import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class PowerCalculatorScreen extends StatefulWidget {
  const PowerCalculatorScreen({super.key});

  @override
  State<PowerCalculatorScreen> createState() => _PowerCalculatorScreenState();
}

class _PowerCalculatorScreenState extends State<PowerCalculatorScreen> with SingleTickerProviderStateMixin {
  int systemType = 0; // 0: DC, 1: AC-1Faz, 2: AC-3Faz

  final TextEditingController _voltController = TextEditingController(text: "220");
  final TextEditingController _ampController = TextEditingController(text: "10");
  final TextEditingController _pfController = TextEditingController(text: "0.85");

  String resActive = "---";
  String resApparent = "---";
  String resReactive = "---";
  String resAngle = "---";

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
    _voltController.dispose();
    _ampController.dispose();
    _pfController.dispose();
    super.dispose();
  }

  void _calculate() {
    double v = double.tryParse(_voltController.text) ?? 0;
    double i = double.tryParse(_ampController.text) ?? 0;
    double pf = double.tryParse(_pfController.text) ?? 1.0;

    if (v <= 0 || i <= 0) {
      _resetResults();
      return;
    }
    
    if (pf > 1) pf = 1;
    if (pf < 0) pf = 0;

    double p = 0; 
    double s = 0; 
    double q = 0; 
    double angle = acos(pf) * (180 / pi);

    if (systemType == 0) {
      // DC
      p = v * i;
      s = p; 
      q = 0;
      angle = 0;
    } else if (systemType == 1) {
      // AC 1-Faz
      s = v * i;
      p = s * pf;
      q = sqrt(s*s - p*p);
    } else {
      // AC 3-Faz
      s = sqrt(3) * v * i;
      p = s * pf;
      q = sqrt(s*s - p*p);
    }

    setState(() {
      resActive = _formatPower(p, "W");
      resApparent = _formatPower(s, "VA");
      resReactive = _formatPower(q, "VAR");
      resAngle = "${angle.toStringAsFixed(1)}°";
    });
  }

  void _resetResults() {
    setState(() { resActive = "---"; resApparent = "---"; resReactive = "---"; resAngle = "---"; });
  }

  String _formatPower(double val, String unit) {
    if (val >= 1e6) return "${(val / 1e6).toStringAsFixed(2)} M$unit";
    if (val >= 1e3) return "${(val / 1e3).toStringAsFixed(2)} k$unit";
    return "${val.toStringAsFixed(1)} $unit";
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor = systemType == 0 ? Colors.amber : (systemType == 1 ? Colors.cyanAccent : Colors.purpleAccent);

    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: PhaseFlowPainter(
                  animValue: _animController.value,
                  color: themeColor,
                  phaseType: systemType,
                  pf: double.tryParse(_pfController.text) ?? 1.0
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
                      Text("GÜÇ HESAPLA", style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // MOD SEÇİCİ
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white10)),
                    child: Row(
                      children: [
                        _buildModeBtn("DC", 0, Colors.amber),
                        _buildModeBtn("AC 1-FAZ", 1, Colors.cyanAccent),
                        _buildModeBtn("AC 3-FAZ", 2, Colors.purpleAccent),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // GÖRSEL GÜÇ ÜÇGENİ
                  if (systemType != 0)
                    Container(
                      height: 220,
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: themeColor.withValues(alpha: 0.5)),
                        boxShadow: [BoxShadow(color: themeColor.withValues(alpha: 0.1), blurRadius: 20)]
                      ),
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: Size.infinite,
                            painter: PowerTrianglePainter(
                              pf: double.tryParse(_pfController.text) ?? 0.85,
                              color: themeColor,
                              activeText: resActive,
                              reactiveText: resReactive,
                              apparentText: resApparent,
                              angleText: resAngle
                            ),
                          ),
                          Positioned(
                            right: 10, top: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.grey)),
                              child: Text("GÜÇ ÜÇGENİ", style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                            ),
                          )
                        ],
                      ),
                    ),

                  if (systemType == 0)
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("DC GÜÇ (P)", style: TextStyle(color: Colors.amber, letterSpacing: 2)),
                            const SizedBox(height: 10),
                            Text(resActive, style: GoogleFonts.shareTechMono(fontSize: 50, color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),

                  // GİRİŞLER
                  Row(
                    children: [
                      Expanded(child: _buildInputBox("Voltaj (V)", _voltController)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildInputBox("Akım (I)", _ampController)),
                    ],
                  ),
                  
                  const SizedBox(height: 15),

                  if (systemType != 0)
                    Column(
                      children: [
                        _buildInputBox("Güç Çarpanı (PF / Cos φ)", _pfController),
                        Slider(
                          value: double.tryParse(_pfController.text) ?? 0.85,
                          min: 0.0, max: 1.0,
                          activeColor: themeColor,
                          inactiveColor: Colors.grey[800],
                          onChanged: (val) {
                            setState(() {
                              _pfController.text = val.toStringAsFixed(2);
                              _calculate();
                            });
                          },
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // SONUÇ KARTLARI
                  if (systemType != 0)
                    Column(
                      children: [
                        _buildResultCard("AKTİF GÜÇ (P)", resActive, Colors.greenAccent),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _buildResultCard("GÖRÜNÜR (S)", resApparent, Colors.white)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildResultCard("REAKTİF (Q)", resReactive, Colors.redAccent)),
                          ],
                        )
                      ],
                    ),

                  const SizedBox(height: 30),

                  // BİLGİ
                  _buildInfoBox(themeColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeBtn(String title, int val, Color color) {
    bool isSelected = systemType == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { systemType = val; _calculate(); }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent, borderRadius: BorderRadius.circular(25), border: Border.all(color: isSelected ? color : Colors.transparent)),
          child: Text(title, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? color : Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
        ),
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
        decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.grey), border: InputBorder.none),
        onChanged: (v) => _calculate(),
      ),
    );
  }

  Widget _buildResultCard(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(val, style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoBox(Color color) {
    String desc = "";
    if (systemType == 0) {
      desc = "DC devrelerde faz farkı yoktur.\nFormül: P = V x I";
    } else if (systemType == 1) {
      desc = "AC devrelerde endüktif yükler faz farkı yaratır. PF enerjinin verimini gösterir.";
    } else {
      desc = "3 Fazlı sistemlerde toplam güç kök-3 kat sayısı ile hesaplanır.\nFormül: P = √3 x V x I x PF";
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(desc, style: TextStyle(color: Colors.grey[400], fontSize: 12, height: 1.3))),
        ],
      ),
    );
  }
}

class PowerTrianglePainter extends CustomPainter {
  final double pf;
  final Color color;
  final String activeText, reactiveText, apparentText, angleText;
  
  PowerTrianglePainter({required this.pf, required this.color, required this.activeText, required this.reactiveText, required this.apparentText, required this.angleText});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final fillPaint = Paint()..color = color.withValues(alpha: 0.1)..style = PaintingStyle.fill;
    final textStyle = const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold);

    double angle = acos(pf); 
    double baseLen = size.width * 0.7; 
    double height = baseLen * tan(angle); 
    
    if (height > size.height * 0.8) {
      double scale = (size.height * 0.8) / height;
      baseLen *= scale;
      height *= scale;
    }

    double startX = (size.width - baseLen) / 2;
    double startY = size.height - 30;

    Path path = Path();
    path.moveTo(startX, startY); 
    path.lineTo(startX + baseLen, startY); 
    path.lineTo(startX + baseLen, startY - height); 
    path.close(); 

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    _drawText(canvas, "P (Aktif)", Offset(startX + baseLen/2, startY + 10), textStyle);
    _drawText(canvas, "Q (Reaktif)", Offset(startX + baseLen + 10, startY - height/2), textStyle);
    _drawText(canvas, "S (Görünür)", Offset(startX + baseLen/2 - 20, startY - height/2 - 10), textStyle);
    
    double arcSize = 40;
    canvas.drawArc(Rect.fromLTWH(startX - arcSize/2, startY - arcSize/2, arcSize, arcSize), 0, -angle, false, paint..strokeWidth=1);
    _drawText(canvas, angleText, Offset(startX + 45, startY - 10), const TextStyle(color: Colors.amber, fontSize: 10));
  }

  void _drawText(Canvas c, String text, Offset pos, TextStyle style) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
    tp.paint(c, pos);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PhaseFlowPainter extends CustomPainter {
  final double animValue;
  final Color color;
  final int phaseType;
  final double pf;

  PhaseFlowPainter({required this.animValue, required this.color, required this.phaseType, required this.pf});

  @override
  void paint(Canvas canvas, Size size) {
    final paintV = Paint()..color = color.withValues(alpha: 0.1)..strokeWidth = 2..style = PaintingStyle.stroke;
    final paintI = Paint()..color = Colors.white.withValues(alpha: 0.1)..strokeWidth = 2..style = PaintingStyle.stroke;

    if (phaseType == 0) {
      canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.4), paintV..strokeWidth=4);
      return;
    }

    double shiftI = acos(pf); 

    Path pathV = Path();
    Path pathI = Path();

    for (double x = 0; x <= size.width; x++) {
      double ang = (x / size.width) * 4 * pi - (animValue * 2 * pi);
      double yV = size.height/2 + sin(ang) * 50;
      double yI = size.height/2 + sin(ang - shiftI) * 40; 

      if (x==0) { pathV.moveTo(x, yV); pathI.moveTo(x, yI); }
      else { pathV.lineTo(x, yV); pathI.lineTo(x, yI); }
    }
    
    canvas.drawPath(pathV, paintV);
    canvas.drawPath(pathI, paintI);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}