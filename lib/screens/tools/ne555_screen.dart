import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:ui' as ui; // Animasyon için

class Ne555Screen extends StatefulWidget {
  const Ne555Screen({super.key});

  @override
  State<Ne555Screen> createState() => _Ne555ScreenState();
}

class _Ne555ScreenState extends State<Ne555Screen> with SingleTickerProviderStateMixin {
  // --- DURUM DEĞİŞKENLERİ ---
  int mode = 0; // 0: Astable, 1: Astable (<50%), 2: Monostable
  
  // Kontrolcüler
  final TextEditingController _r1Controller = TextEditingController(text: "10");
  final TextEditingController _r2Controller = TextEditingController(text: "10");
  final TextEditingController _c1Controller = TextEditingController(text: "100");

  // Birim Çarpanları
  double r1Mult = 1000.0; // kΩ
  double r2Mult = 1000.0; // kΩ
  double c1Mult = 0.000000001; // nF
  
  String r1Unit = "kΩ";
  String r2Unit = "kΩ";
  String c1Unit = "nF";

  // Sonuçlar
  String resFreq = "---";
  String resPeriod = "---";
  String resDuty = "---";
  String resTHigh = "---";
  String resTLow = "---";
  
  // Hesaplama Değerleri (Grafik için)
  double valTHigh = 0;
  double valTLow = 0;
  double valPeriod = 0;

  // Animasyon
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
    _c1Controller.dispose();
    super.dispose();
  }

  // --- HESAPLAMA MOTORU ---
  void _calculate() {
    double r1 = (double.tryParse(_r1Controller.text) ?? 0) * r1Mult;
    double c1 = (double.tryParse(_c1Controller.text) ?? 0) * c1Mult;
    
    if (r1 <= 0 || c1 <= 0) { _resetResults(); return; }

    if (mode == 2) { 
      // --- MONOSTABLE MODU ---
      // T = 1.1 * R1 * C1
      valTHigh = 1.1 * r1 * c1;
      valTLow = 0; // Monostable'da T_low yoktur (tetiklenene kadar)
      valPeriod = 0; // Tek atım

      setState(() {
        resTHigh = _formatTime(valTHigh);
        resTLow = "---";
        resFreq = "--- (Tek Atım)";
        resPeriod = "---";
        resDuty = "---";
      });

    } else {
      // --- ASTABLE MODLARI ---
      double r2 = (double.tryParse(_r2Controller.text) ?? 0) * r2Mult;
      if (r2 <= 0) { _resetResults(); return; }

      if (mode == 0) {
        // Standart Astable (Duty > 50%)
        // T_high = 0.693 * (R1 + R2) * C1
        // T_low = 0.693 * R2 * C1
        valTHigh = 0.693 * (r1 + r2) * c1;
        valTLow = 0.693 * r2 * c1;
      } else {
        // Astable (Duty < 50%) - Diyotlu
        // T_high = 0.693 * R1 * C1
        // T_low = 0.693 * R2 * C1
        valTHigh = 0.693 * r1 * c1;
        valTLow = 0.693 * r2 * c1;
      }

      valPeriod = valTHigh + valTLow;
      double freq = 1 / valPeriod;
      double duty = (valTHigh / valPeriod) * 100;

      setState(() {
        resTHigh = _formatTime(valTHigh);
        resTLow = _formatTime(valTLow);
        resFreq = _formatFreq(freq);
        resPeriod = _formatTime(valPeriod);
        resDuty = "${duty.toStringAsFixed(1)}%";
      });
    }
  }

  void _resetResults() {
    setState(() {
      resFreq = "---"; resPeriod = "---"; resDuty = "---"; resTHigh = "---"; resTLow = "---";
      valTHigh = 0; valTLow = 0; valPeriod = 0;
    });
  }

  String _formatFreq(double val) {
    if (val >= 1e6) return "${(val / 1e6).toStringAsFixed(3)} MHz";
    if (val >= 1e3) return "${(val / 1e3).toStringAsFixed(3)} kHz";
    return "${val.toStringAsFixed(2)} Hz";
  }

  String _formatTime(double val) {
    if (val >= 1) return "${val.toStringAsFixed(3)} s";
    if (val >= 1e-3) return "${(val * 1e3).toStringAsFixed(2)} ms";
    if (val >= 1e-6) return "${(val * 1e6).toStringAsFixed(1)} µs";
    return "${(val * 1e9).toStringAsFixed(0)} ns";
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor = mode == 0 ? Colors.cyanAccent : (mode == 1 ? Colors.purpleAccent : Colors.orangeAccent);
    String r2Label = mode == 1 ? "R2 (Deşarj Direnci)" : "R2 Direnci";

    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      body: Stack(
        children: [
          // 1. CANLI ARKA PLAN (NE555 İÇ YAPISI)
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: NE555InternalFlowPainter(_animController.value, themeColor, mode),
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
                      Text("NE555 HESAPLAYICI", style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
                    ],
                  ),
                  Text("(Zamanlayıcı & Osilatör)", style: TextStyle(color: Colors.grey[500], fontSize: 12)),

                  const SizedBox(height: 20),

                  // 2. MOD SEÇİCİ
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white10)),
                    child: Row(
                      children: [
                        _buildModeBtn("ASTABLE\n(Kararsız)", 0, Colors.cyanAccent),
                        _buildModeBtn("ASTABLE\n(<50% Duty)", 1, Colors.purpleAccent),
                        _buildModeBtn("MONOSTABLE\n(Tek Kararlı)", 2, Colors.orangeAccent),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 3. CANLI GRAFİK (OSİLOSKOP)
                  Container(
                    height: 200,
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: themeColor.withValues(alpha: 0.5)),
                      boxShadow: [BoxShadow(color: themeColor.withValues(alpha: 0.2), blurRadius: 20)]
                    ),
                    child: Stack(
                      children: [
                        CustomPaint(size: Size.infinite, painter: ScopeGridPainter()),
                        AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            return CustomPaint(
                              size: Size.infinite,
                              painter: NE555WaveformPainter(
                                animationValue: _animController.value,
                                color: themeColor,
                                mode: mode,
                                tHigh: valTHigh,
                                tLow: valTLow,
                                period: valPeriod
                              ),
                            );
                          },
                        ),
                        // Etiketler
                        Positioned(top: 10, right: 10, child: Text("Output (Pin 3)", style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 10))),
                        Positioned(bottom: 30, right: 10, child: Text("Vc (Pin 6/2)", style: TextStyle(color: themeColor.withValues(alpha: 0.7), fontSize: 10))),
                      ],
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
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildResultItem("FREKANS (f)", resFreq, themeColor, isMain: true),
                            Container(width: 2, height: 50, color: Colors.white10),
                            _buildResultItem("PERİYOT (T)", resPeriod, Colors.white),
                          ],
                        ),
                        const Divider(color: Colors.white10, height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildResultItem("GÖREV (Duty)", resDuty, Colors.white70),
                            _buildResultItem("T_HIGH (Açık)", resTHigh, Colors.greenAccent),
                            _buildResultItem("T_LOW (Kapalı)", resTLow, Colors.redAccent),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 5. GİRİŞLER
                  _buildInputRow("R1 Direnci", _r1Controller, r1Unit, (v) { setState(() => r1Unit = v); _calculate(); }, {'Ω': 1.0, 'kΩ': 1e3, 'MΩ': 1e6}, (v) { r1Mult = v; _calculate(); }, themeColor),
                  
                  if (mode != 2) // Monostable'da R2 yok
                    _buildInputRow(r2Label, _r2Controller, r2Unit, (v) { setState(() => r2Unit = v); _calculate(); }, {'Ω': 1.0, 'kΩ': 1e3, 'MΩ': 1e6}, (v) { r2Mult = v; _calculate(); }, themeColor),

                  _buildInputRow("C1 Kondansatör", _c1Controller, c1Unit, (v) { setState(() => c1Unit = v); _calculate(); }, {'pF': 1e-12, 'nF': 1e-9, 'µF': 1e-6, 'mF': 1e-3}, (v) { c1Mult = v; _calculate(); }, themeColor),

                  const SizedBox(height: 30),

                  // 6. BİLGİ KUTUSU
                  _buildInfoBox(themeColor),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeBtn(String title, int val, Color color) {
    bool isSelected = mode == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { mode = val; _calculate(); }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isSelected ? color : Colors.transparent),
          ),
          child: Text(title, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? color : Colors.grey, fontWeight: FontWeight.bold, fontSize: 10)),
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value, Color color, {bool isMain = false}) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: isMain ? 12 : 10, letterSpacing: 1)),
        const SizedBox(height: 5),
        Text(value, style: GoogleFonts.shareTechMono(fontSize: isMain ? 24 : 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildInputRow(String label, TextEditingController controller, String currentUnit, Function(String) onUnitChange, Map<String, double> units, Function(double) onMultChange, Color color) {
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

  Widget _buildInfoBox(Color color) {
    String title = "";
    String desc = "";
    String formula = "";

    if (mode == 0) {
      title = "ASTABLE (Kararsız) MOD";
      desc = "Çıkış, sürekli olarak yüksek ve düşük arasında gidip gelir (Kare Dalga Osilatör). R1, R2 ve C1 frekansı belirler.\nBu modda Duty Cycle her zaman %50'den büyüktür (T_high > T_low).";
      formula = "T_high = 0.693 × (R1 + R2) × C1\nT_low = 0.693 × R2 × C1\nf = 1.44 / ((R1 + 2R2) × C1)";
    } else if (mode == 1) {
      title = "ASTABLE (<50% Duty) MOD";
      desc = "Diyot eklenerek kondansatörün şarj ve deşarj yolları ayrılır. R1 şarjı, R2 deşarjı kontrol eder.\nBu sayede Duty Cycle %50'nin altına düşürülebilir (T_high < T_low).";
      formula = "T_high = 0.693 × R1 × C1\nT_low = 0.693 × R2 × C1\nf = 1.44 / ((R1 + R2) × C1)";
    } else {
      title = "MONOSTABLE (Tek Kararlı) MOD";
      desc = "Tetikleme (Trigger) sinyali geldiğinde çıkış belirli bir süre (T) yüksek olur, sonra tekrar düşer.\nZamanlayıcı (Timer) uygulamaları için kullanılır.";
      formula = "T (Süre) = 1.1 × R1 × C1";
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(Icons.info_outline, color: color, size: 18), const SizedBox(width: 10), Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 10),
          Text(desc, style: TextStyle(color: Colors.grey[400], fontSize: 12, height: 1.3)),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(5)),
            child: Text(formula, style: GoogleFonts.shareTechMono(color: color, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// --- CANLI GRAFİK ÇİZİCİ (OSİLOSKOP) ---
class NE555WaveformPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final int mode;
  final double tHigh;
  final double tLow;
  final double period;

  NE555WaveformPainter({required this.animationValue, required this.color, required this.mode, required this.tHigh, required this.tLow, required this.period});

  @override
  void paint(Canvas canvas, Size size) {
    if (period == 0 && mode != 2) return;
    
    final outPaint = Paint()..color = color..strokeWidth = 3..style = PaintingStyle.stroke;
    final vcPaint = Paint()..color = color.withValues(alpha: 0.5)..strokeWidth = 2..style = PaintingStyle.stroke;

    // Grafik ölçekleme (Ekrana sığdırma)
    double timeScale = size.width / (mode == 2 ? tHigh * 2 : period * 2); // 2 periyot göster
    double vScale = size.height / 3; // Voltaj ölçeği (Vcc'yi 3'e böl)

    // Hareket Efekti (Sola kaydırma)
    double xOffset = (animationValue * size.width) * -1;
    
    canvas.save();
    canvas.translate(xOffset, 0); // Çizimi kaydır

    Path outPath = Path();
    Path vcPath = Path();

    // Monostable Modu (Tek Atım)
    if (mode == 2) {
      if (tHigh == 0) return;
      double triggerTime = size.width * 0.1; // Tetikleme anı
      double pulseWidth = tHigh * timeScale;

      // Output (Kare Dalga)
      outPath.moveTo(0, size.height);
      outPath.lineTo(triggerTime, size.height); // Düşük başla
      outPath.lineTo(triggerTime, 0); // Yüksel
      outPath.lineTo(triggerTime + pulseWidth, 0); // Yüksek kal
      outPath.lineTo(triggerTime + pulseWidth, size.height); // Düş
      outPath.lineTo(size.width * 2, size.height); // Düşük devam et

      // Vc (Kondansatör Şarjı - Üstel Eğri)
      vcPath.moveTo(0, size.height);
      vcPath.lineTo(triggerTime, size.height);
      for (double t = 0; t <= pulseWidth; t += 2) {
        // Vc = Vcc * (1 - e^(-t/RC)) -> Basitleştirilmiş görsel
        double normalizedT = t / pulseWidth;
        double y = size.height - (vScale * 2 * (1 - exp(-normalizedT * 1.1))); // 2/3 Vcc'ye kadar şarj
        vcPath.lineTo(triggerTime + t, y);
      }
       vcPath.lineTo(triggerTime + pulseWidth, size.height); // Deşarj
       vcPath.lineTo(size.width * 2, size.height);
    } 
    // Astable Modları (Sürekli Kare Dalga)
    else {
      double highWidth = tHigh * timeScale;
      double lowWidth = tLow * timeScale;
      double totalWidth = highWidth + lowWidth;

      // 3 periyot çizelim ki kayarken boşluk olmasın
      for (int i = 0; i < 3; i++) {
        double startX = i * totalWidth;

        // Output
        outPath.moveTo(startX, 0); // Yüksek başla
        outPath.lineTo(startX + highWidth, 0); // Yüksek kal
        outPath.lineTo(startX + highWidth, size.height); // Düş
        outPath.lineTo(startX + totalWidth, size.height); // Düşük kal
        outPath.lineTo(startX + totalWidth, 0); // Yüksel

        // Vc (Şarj/Deşarj Üstel Eğrileri)
        // Şarj (1/3 Vcc -> 2/3 Vcc)
        vcPath.moveTo(startX, size.height - vScale); // 1/3 Vcc'den başla
        for (double t = 0; t <= highWidth; t += 2) {
           double normalizedT = t / highWidth;
           // Görsel olarak yaklaşık bir şarj eğrisi (1/3'ten 2/3'e)
           double y = (size.height - vScale) - (vScale * (1 - exp(-normalizedT * 2))); 
           vcPath.lineTo(startX + t, y);
        }
        // Deşarj (2/3 Vcc -> 1/3 Vcc)
        vcPath.lineTo(startX + highWidth, size.height - vScale * 2); // 2/3 Vcc noktası
        for (double t = 0; t <= lowWidth; t += 2) {
            double normalizedT = t / lowWidth;
            // Görsel deşarj eğrisi
            double y = (size.height - vScale) - (vScale * exp(-normalizedT * 2));
            vcPath.lineTo(startX + highWidth + t, y);
        }
      }
    }

    // Çizimleri tekrarla (Sonsuz döngü için)
    Path loopOut = Path.from(outPath); loopOut.shift(Offset(size.width, 0));
    Path loopVc = Path.from(vcPath); loopVc.shift(Offset(size.width, 0));

    canvas.drawPath(outPath, outPaint);
    canvas.drawPath(loopOut, outPaint);
    
    canvas.drawPath(vcPath, vcPaint);
    canvas.drawPath(loopVc, vcPaint);

    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant NE555WaveformPainter oldDelegate) => true;
}

// Osiloskop Izgarası
class ScopeGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white10..strokeWidth = 1;
    for(double x=0; x<=size.width; x+=size.width/5) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for(double y=0; y<=size.height; y+=size.height/3) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    
    final axisPaint = Paint()..color = Colors.white24..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), axisPaint); // GND
    _drawText(canvas, "GND", Offset(5, size.height - 15), Colors.white30);
    _drawText(canvas, "Vcc", Offset(5, 5), Colors.white30);
  }
  void _drawText(Canvas c, String text, Offset pos, Color color) {
    final textSpan = TextSpan(text: text, style: TextStyle(color: color, fontSize: 10));
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    textPainter.paint(c, pos);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- ARKA PLAN ANİMASYONU (NE555 İÇ YAPISI AKIŞI) ---
class NE555InternalFlowPainter extends CustomPainter {
  final double animValue;
  final Color color;
  final int mode;
  NE555InternalFlowPainter(this.animValue, this.color, this.mode);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.05)..strokeWidth = 2..style = PaintingStyle.stroke;
    final flowPaint = Paint()..color = color.withValues(alpha: 0.2)..strokeWidth = 4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    // NE555 Blok Diyagramı (Basitleştirilmiş)
    double cx = size.width / 2; double cy = size.height / 2;
    Rect chipRect = Rect.fromCenter(center: Offset(cx, cy), width: size.width * 0.8, height: size.height * 0.6);
    canvas.drawRect(chipRect, paint);

    // İç Yollar (Komparatörler, Flip-Flop)
    Path path1 = Path()..moveTo(chipRect.left, cy - 50)..lineTo(cx - 50, cy - 50)..lineTo(cx, cy)..lineTo(cx + 50, cy)..lineTo(chipRect.right, cy); // Üst yol
    Path path2 = Path()..moveTo(chipRect.left, cy + 50)..lineTo(cx - 50, cy + 50)..lineTo(cx, cy)..lineTo(chipRect.right, cy + 50); // Alt yol
    
    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);

    // Akış Animasyonu
    _drawFlow(canvas, path1, animValue, flowPaint);
    _drawFlow(canvas, path2, (animValue + 0.5) % 1.0, flowPaint);
  }

  void _drawFlow(Canvas canvas, Path path, double progress, Paint paint) {
    ui.PathMetrics pathMetrics = path.computeMetrics();
    for (ui.PathMetric pathMetric in pathMetrics) {
      double length = pathMetric.length;
      double start = length * progress;
      double end = start + length * 0.2;
      canvas.drawPath(pathMetric.extractPath(start, end), paint);
    }
  }
  @override
  bool shouldRepaint(covariant NE555InternalFlowPainter oldDelegate) => true;
}