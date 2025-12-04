import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class VoltageDropScreen extends StatefulWidget {
  const VoltageDropScreen({super.key});

  @override
  State<VoltageDropScreen> createState() => _VoltageDropScreenState();
}

class _VoltageDropScreenState extends State<VoltageDropScreen> with SingleTickerProviderStateMixin {
  // --- DURUM DEĞİŞKENLERİ ---
  
  // Materyaller ve Özdirençleri (Ohm.mm^2/m)
  final List<Map<String, dynamic>> materials = [
    {'name': 'Bakır (Copper)', 'rho': 0.0172, 'color': const Color(0xFFB87333)},
    {'name': 'Alüminyum',      'rho': 0.0282, 'color': const Color(0xFFB0BEC5)},
    {'name': 'Altın',          'rho': 0.0244, 'color': const Color(0xFFFFD700)},
    {'name': 'Gümüş',          'rho': 0.0159, 'color': const Color(0xFFC0C0C0)},
    {'name': 'Demir',          'rho': 0.1000, 'color': const Color(0xFF5D4037)},
  ];
  int selectedMatIdx = 0; // Varsayılan Bakır

  // Kablo Boyut Birimleri
  final List<String> sizeUnits = ['mm²', 'mm (Çap)', 'mm (Yarıçap)', 'AWG', 'kcmil'];
  String selectedSizeUnit = 'mm²';

  // Faz Tipi
  int phaseType = 0; // 0: DC (2-Tel), 1: AC Monofaze, 2: AC Trifaze

  // Kontrolcüler
  final TextEditingController _voltController = TextEditingController(text: "12");
  final TextEditingController _ampController = TextEditingController(text: "5");
  final TextEditingController _distController = TextEditingController(text: "10"); // Metre
  final TextEditingController _sizeController = TextEditingController(text: "2.5"); // mm2

  // Sonuçlar
  double dropVolt = 0.0;
  double dropPercent = 0.0;
  double outVolt = 0.0;
  
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

  // --- HESAPLAMA MOTORU ---
  void _calculate() {
    double volt = double.tryParse(_voltController.text) ?? 0;
    double amp = double.tryParse(_ampController.text) ?? 0;
    double dist = double.tryParse(_distController.text) ?? 0;
    double sizeInput = double.tryParse(_sizeController.text) ?? 0;

    if (volt <= 0 || amp <= 0 || dist <= 0 || sizeInput <= 0) {
      setState(() { dropVolt = 0; dropPercent = 0; outVolt = 0; });
      return;
    }

    // 1. Kesit Alanını (mm²) Hesapla
    double areaMM2 = 0;
    
    if (selectedSizeUnit == 'mm²') {
      areaMM2 = sizeInput;
    } else if (selectedSizeUnit == 'mm (Çap)') {
      areaMM2 = pi * pow((sizeInput / 2), 2);
    } else if (selectedSizeUnit == 'mm (Yarıçap)') {
      areaMM2 = pi * pow(sizeInput, 2);
    } else if (selectedSizeUnit == 'AWG') {
      // AWG to mm² formülü: 0.127 * 92^((36-AWG)/39) -> Çap
      double diameter = 0.127 * pow(92, (36 - sizeInput) / 39);
      areaMM2 = pi * pow((diameter / 2), 2);
    } else if (selectedSizeUnit == 'kcmil') {
      areaMM2 = sizeInput * 0.5067;
    }

    // 2. Direnci Hesapla: R = rho * L / A
    // L (Toplam Kablo Boyu): DC ve AC Mono'da gidiş-dönüş (2x), Trifaze'de kök3 çarpımı
    double effectiveLen = dist;
    if (phaseType == 0 || phaseType == 1) {
      effectiveLen = dist * 2; // Gidiş - Dönüş
    } else {
      effectiveLen = dist * 1.732; // Kök 3 (Trifaze)
    }

    double rho = materials[selectedMatIdx]['rho'];
    double resistance = (rho * effectiveLen) / areaMM2;

    // 3. Voltaj Düşümü: V = I * R
    double drop = amp * resistance;
    
    setState(() {
      dropVolt = drop;
      outVolt = volt - drop;
      dropPercent = (drop / volt) * 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color matColor = materials[selectedMatIdx]['color'];
    // Eğer kayıp %3'ten fazlaysa uyarı rengi (Kırmızı), değilse Yeşil
    Color statusColor = dropPercent > 3.0 ? Colors.redAccent : Colors.greenAccent;
    if (dropPercent > 10.0) statusColor = const Color(0xFFFF0000); // Kritik Isınma

    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      body: Stack(
        children: [
          // 1. HAREKETLİ ARKA PLAN (KABLO AKIŞI)
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: CableFlowPainter(
                  animValue: _animController.value,
                  color: statusColor,
                  intensity: dropPercent // Kayıp arttıkça akış gerginleşsin
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
                      Text("GERİLİM DÜŞÜMÜ", style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
                    ],
                  ),
                  
                  const SizedBox(height: 20),

                  // 2. SONUÇ EKRANI (DURUM BAR)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF353A40),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 2),
                      boxShadow: [BoxShadow(color: statusColor.withValues(alpha: 0.2), blurRadius: 20)]
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildResultItem("KAYIP (V)", "${dropVolt.toStringAsFixed(2)} V", Colors.white),
                            _buildResultItem("ÇIKIŞ (V)", "${outVolt.toStringAsFixed(2)} V", statusColor),
                          ],
                        ),
                        const Divider(color: Colors.grey, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              dropPercent > 3 ? Icons.warning_amber : Icons.check_circle, 
                              color: statusColor
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "KAYIP ORANI: %${dropPercent.toStringAsFixed(2)}",
                              style: GoogleFonts.shareTechMono(color: statusColor, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        if (dropPercent > 3)
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text("UYARI: %3'ün üzeri önerilmez!", style: TextStyle(color: Colors.red[200], fontSize: 10)),
                          )
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 3. GÖRSEL KABLO SİMÜLASYONU
                  // Kablo kalınlığı girilen değere göre değişsin (Görsel efekt)
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10)
                    ),
                    child: Center(
                      child: CustomPaint(
                        size: const Size(300, 80),
                        painter: RealisticCablePainter(
                          color: matColor,
                          thickness: 20 + (double.tryParse(_sizeController.text) ?? 0).clamp(0, 40), // Kalınlık efekti
                          isHot: dropPercent > 5.0
                        ),
                      ),
                    ),
                  ),
                  const Text("Kablo Kesiti Önizleme", style: TextStyle(color: Colors.grey, fontSize: 10)),

                  const SizedBox(height: 30),

                  // 4. GİRİŞLER
                  
                  // Materyal Seçimi
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(color: const Color(0xFF22252A), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedMatIdx,
                        dropdownColor: const Color(0xFF353A40),
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down, color: matColor),
                        items: List.generate(materials.length, (index) => DropdownMenuItem(
                          value: index,
                          child: Row(
                            children: [
                              CircleAvatar(backgroundColor: materials[index]['color'], radius: 5),
                              const SizedBox(width: 10),
                              Text(materials[index]['name'], style: const TextStyle(color: Colors.white)),
                            ],
                          )
                        )),
                        onChanged: (val) => setState(() { selectedMatIdx = val!; _calculate(); }),
                      ),
                    ),
                  ),

                  // Voltaj ve Akım
                  Row(
                    children: [
                      Expanded(child: _buildInputBox("Voltaj (V)", _voltController)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildInputBox("Akım (A)", _ampController)),
                    ],
                  ),

                  // Mesafe
                  _buildInputBox("Mesafe (Metre)", _distController),

                  // Kablo Boyutu
                  Row(
                    children: [
                      Expanded(flex: 2, child: _buildInputBox("Kablo Boyutu", _sizeController)),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(15)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedSizeUnit,
                              dropdownColor: const Color(0xFF353A40),
                              style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                              isExpanded: true,
                              items: sizeUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                              onChanged: (v) => setState(() { selectedSizeUnit = v!; _calculate(); }),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Faz Tipi (Butonlar)
                  Row(
                    children: [
                      _buildPhaseBtn("DC (2-Tel)", 0),
                      _buildPhaseBtn("AC (1-Faz)", 1),
                      _buildPhaseBtn("AC (3-Faz)", 2),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // BİLGİ
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)),
                    child: const Text(
                      "Kablo direnci nedeniyle voltaj, yük tarafına gidene kadar düşer. %3'ten fazla kayıp cihazların verimsiz çalışmasına veya kablonun ısınmasına neden olabilir.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
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
      margin: const EdgeInsets.only(bottom: 15),
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

  Widget _buildPhaseBtn(String title, int val) {
    bool isSelected = phaseType == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { phaseType = val; _calculate(); }),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.amber.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? Colors.amber : Colors.white10)
          ),
          child: Text(title, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.amber : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        Text(value, style: GoogleFonts.shareTechMono(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// --- GÖRSEL KABLO ÇİZİCİ ---
class RealisticCablePainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool isHot;
  RealisticCablePainter({required this.color, required this.thickness, required this.isHot});

  @override
  void paint(Canvas canvas, Size size) {
    double cy = size.height / 2;
    
    // Kablo İçi (Metal)
    final metalPaint = Paint()
      ..shader = LinearGradient(
        colors: isHot ? [Colors.red, Colors.orange] : [color.withValues(alpha: 0.6), color, color.withValues(alpha: 0.6)],
        begin: Alignment.topCenter, end: Alignment.bottomCenter
      ).createShader(Rect.fromLTWH(0, cy - thickness/2, size.width, thickness));
    
    canvas.drawRect(Rect.fromCenter(center: Offset(size.width/2, cy), width: size.width - 20, height: thickness), metalPaint);

    // Kablo Dışı (Yalıtkan - Kesik)
    final insulationPaint = Paint()..color = Colors.grey[800]!..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawRect(Rect.fromCenter(center: Offset(size.width/2, cy), width: size.width - 20, height: thickness + 4), insulationPaint);
    
    // Isınma Efekti (Duman/Hare)
    if (isHot) {
      final glowPaint = Paint()..color = Colors.red.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      canvas.drawRect(Rect.fromCenter(center: Offset(size.width/2, cy), width: size.width, height: thickness + 10), glowPaint);
    }
  }
  @override
  bool shouldRepaint(covariant RealisticCablePainter oldDelegate) => true;
}

// --- ARKA PLAN AKIŞI ---
class CableFlowPainter extends CustomPainter {
  final double animValue;
  final Color color;
  final double intensity;
  CableFlowPainter({required this.animValue, required this.color, required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.05)..strokeWidth = 2..style = PaintingStyle.stroke;
    
    double spacing = 40.0;
    double offset = animValue * spacing;

    // Elektron akışı efekti
    for (double x = -spacing; x < size.width; x += spacing) {
      double drawX = x + offset;
      canvas.drawLine(Offset(drawX, 0), Offset(drawX - 20, size.height), paint);
    }
    
    if (intensity > 5.0) { // Çok akım/kayıp varsa parlasın
      final glowPaint = Paint()..color = Colors.red.withValues(alpha: 0.1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);
    }
  }
  @override
  bool shouldRepaint(covariant CableFlowPainter oldDelegate) => true;
}