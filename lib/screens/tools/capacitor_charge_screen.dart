import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:ui' as ui;

class CapacitorChargeScreen extends StatefulWidget {
  const CapacitorChargeScreen({super.key});

  @override
  State<CapacitorChargeScreen> createState() => _CapacitorChargeScreenState();
}

class _CapacitorChargeScreenState extends State<CapacitorChargeScreen> with SingleTickerProviderStateMixin {
  // --- DURUM DEĞİŞKENLERİ ---
  double voltage = 5.0;     // Kaynak Voltajı (V)
  double resistance = 10.0; // Direnç (kΩ)
  double capacitance = 100.0; // Kondansatör (µF)
  
  bool isCharging = true; // Şarj mı Deşarj mı?
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    // Grafik çizim animasyonu (3 saniye sürecek)
    _animController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 3)
    );
    // Başlangıçta animasyonu oynat
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // --- HESAPLAMALAR ---
  double get tau => (resistance * 1000) * (capacitance / 1000000); // T = R*C (Saniye)
  double get fullTime => 5 * tau; // Tam şarj süresi (5T)

  void _toggleCharge(bool charge) {
    setState(() {
      isCharging = charge;
      _animController.reset();
      _animController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    Color curveColor = isCharging ? Colors.greenAccent : Colors.redAccent;

    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      body: Stack(
        children: [
          // Izgara Arka Plan
          CustomPaint(size: Size.infinite, painter: GridPainter()),

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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("RC ŞARJ / DEŞARJ", style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                            Text("OSİLOSKOP SİMÜLASYONU", style: TextStyle(color: Colors.grey[500], fontSize: 10, letterSpacing: 2)),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 1. OSİLOSKOP EKRANI (GRAFİK)
                    Container(
                      height: 250,
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111), // Ekran siyahı
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[800]!, width: 4),
                        boxShadow: [BoxShadow(color: curveColor.withValues(alpha: 0.2), blurRadius: 20)]
                      ),
                      child: Stack(
                        children: [
                          // Izgara Çizgileri
                          CustomPaint(size: Size.infinite, painter: ScopeGridPainter()),
                          
                          // Eğri Çizimi (Animasyonlu)
                          AnimatedBuilder(
                            animation: _animController,
                            builder: (context, child) {
                              return CustomPaint(
                                size: Size.infinite,
                                painter: CurvePainter(
                                  progress: _animController.value,
                                  isCharging: isCharging,
                                  color: curveColor,
                                  tau: tau,
                                  maxTime: fullTime * 1.2, // Grafikte biraz boşluk bırak
                                ),
                              );
                            },
                          ),

                          // Anlık Değerler (Köşede)
                          Align(
                            alignment: Alignment.topRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(isCharging ? "CHARGING..." : "DISCHARGING...", style: TextStyle(color: curveColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                Text("Vc: ${voltage.toStringAsFixed(1)}V", style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 16)),
                                Text("t: ${fullTime.toStringAsFixed(2)}s", style: GoogleFonts.shareTechMono(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 2. BİLGİ KARTLARI
                    Row(
                      children: [
                        Expanded(child: _buildInfoCard("ZAMAN SABİTİ (τ)", "${(tau * 1000).toStringAsFixed(0)} ms", Colors.blueAccent)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildInfoCard("TAM DOLUM (5τ)", "${fullTime.toStringAsFixed(2)} s", Colors.orangeAccent)),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // 3. KONTROL BUTONLARI (ŞARJ / DEŞARJ)
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _toggleCharge(true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                color: isCharging ? Colors.green.withValues(alpha: 0.2) : Colors.black26,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isCharging ? Colors.green : Colors.white10),
                                boxShadow: isCharging ? [BoxShadow(color: Colors.green.withValues(alpha: 0.2), blurRadius: 10)] : []
                              ),
                              child: Column(
                                children: const [
                                  Icon(Icons.battery_charging_full, color: Colors.green),
                                  SizedBox(height: 5),
                                  Text("ŞARJ ET", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _toggleCharge(false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                color: !isCharging ? Colors.red.withValues(alpha: 0.2) : Colors.black26,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: !isCharging ? Colors.red : Colors.white10),
                                boxShadow: !isCharging ? [BoxShadow(color: Colors.red.withValues(alpha: 0.2), blurRadius: 10)] : []
                              ),
                              child: Column(
                                children: const [
                                  Icon(Icons.battery_alert, color: Colors.red), // Deşarj ikonu
                                  SizedBox(height: 5),
                                  Text("DEŞARJ ET", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // 4. AYARLAR (SLIDER)
                    _buildSlider("KAYNAK VOLTAJI (Vs)", voltage, 1, 24, (v) => setState(() { voltage = v; _animController.forward(from: 0); }), "V"),
                    _buildSlider("DİRENÇ (R)", resistance, 1, 100, (v) => setState(() { resistance = v; _animController.forward(from: 0); }), "kΩ"),
                    _buildSlider("KONDANSATÖR (C)", capacitance, 10, 1000, (v) => setState(() { capacitance = v; _animController.forward(from: 0); }), "µF"),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF22252A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3))
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(value, style: GoogleFonts.shareTechMono(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSlider(String title, double value, double min, double max, Function(double) onChanged, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            Text("${value.toStringAsFixed(0)} $unit", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(activeTrackColor: Colors.amber, thumbColor: Colors.white, overlayColor: Colors.amber.withValues(alpha: 0.2)),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }
}

// --- GRAFİK ÇİZİCİ (EĞRİ) ---
class CurvePainter extends CustomPainter {
  final double progress;
  final bool isCharging;
  final Color color;
  final double tau;
  final double maxTime;

  CurvePainter({required this.progress, required this.isCharging, required this.color, required this.tau, required this.maxTime});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Grafik genişliği boyunca nokta nokta çiz
    // progress (0.0 -> 1.0) animasyonun neresindeyiz onu gösterir.
    double drawWidth = size.width * progress;

    for (double x = 0; x <= drawWidth; x++) {
      // X eksenini zamana çevir (0 -> maxTime)
      double t = (x / size.width) * maxTime;
      
      double yVal = 0;
      if (isCharging) {
        // Şarj Formülü: Vc = Vs * (1 - e^(-t/RC))
        // Burada Vs'yi grafik yüksekliği (size.height) olarak normaliz ediyoruz (0-1 arası)
        double normalizedV = (1 - exp(-t / tau));
        yVal = size.height - (normalizedV * size.height * 0.9); // 0.9 padding için
      } else {
        // Deşarj Formülü: Vc = Vs * e^(-t/RC)
        double normalizedV = exp(-t / tau);
        yVal = size.height - (normalizedV * size.height * 0.9);
      }

      if (x == 0) path.moveTo(x, yVal);
      else path.lineTo(x, yVal);
    }

    // Glow Efekti (Çizginin arkasına bulanık kalın çizgi)
    final glowPaint = Paint()..color = color.withValues(alpha: 0.3)..strokeWidth = 8..style = PaintingStyle.stroke..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(path, glowPaint);
    
    // Ana Çizgi
    canvas.drawPath(path, paint);
    
    // Uç Noktaya Daire
    if (drawWidth > 0) {
        // Son noktayı bulmak için tekrar hesapla
        double t = (drawWidth / size.width) * maxTime;
        double endY = isCharging ? size.height - ((1 - exp(-t / tau)) * size.height * 0.9) : size.height - (exp(-t / tau) * size.height * 0.9);
        canvas.drawCircle(Offset(drawWidth, endY), 5, Paint()..color = Colors.white);
    }
  }
  @override
  bool shouldRepaint(covariant CurvePainter oldDelegate) => true;
}

// Osiloskop Izgarası
class ScopeGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white10..strokeWidth = 1;
    // Dikey Çizgiler
    for(double x=0; x<=size.width; x+=size.width/10) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    // Yatay Çizgiler
    for(double y=0; y<=size.height; y+=size.height/5) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    
    // Orta Eksenler
    final axisPaint = Paint()..color = Colors.white24..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), axisPaint); // X Ekseni
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), axisPaint); // Y Ekseni
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.03)..strokeWidth = 1;
    const double step = 40.0;
    for (double x = 0; x < size.width; x += step) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += step) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}