import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResistorScreen extends StatefulWidget {
  const ResistorScreen({super.key});

  @override
  State<ResistorScreen> createState() => _ResistorScreenState();
}

class _ResistorScreenState extends State<ResistorScreen> {
  // --- DURUM DEĞİŞKENLERİ ---
  int bandCount = 4;

  int digit1 = 1; // Kahve
  int digit2 = 0; // Siyah
  int digit3 = 0; // Siyah
  int multiplier = 2; // Kırmızı
  int tolerance = 10; // Altın
  int ppm = 1; // Kahve

  // RENK VERİTABANI (TÜRKÇE İSİMLER EKLENDİ)
  final List<Map<String, dynamic>> colors = [
    {'name': 'Siyah',   'color': const Color(0xFF000000), 'val': 0, 'mult': 1.0, 'tol': null, 'ppm': 250},
    {'name': 'Kahve',   'color': const Color(0xFF795548), 'val': 1, 'mult': 10.0, 'tol': 1.0, 'ppm': 100},
    {'name': 'Kırmızı', 'color': const Color(0xFFF44336), 'val': 2, 'mult': 100.0, 'tol': 2.0, 'ppm': 50},
    {'name': 'Turuncu', 'color': const Color(0xFFFF9800), 'val': 3, 'mult': 1000.0, 'tol': null, 'ppm': 15},
    {'name': 'Sarı',    'color': const Color(0xFFFFEB3B), 'val': 4, 'mult': 10000.0, 'tol': null, 'ppm': 25},
    {'name': 'Yeşil',   'color': const Color(0xFF4CAF50), 'val': 5, 'mult': 100000.0, 'tol': 0.5, 'ppm': 20},
    {'name': 'Mavi',    'color': const Color(0xFF2196F3), 'val': 6, 'mult': 1000000.0, 'tol': 0.25, 'ppm': 10},
    {'name': 'Mor',     'color': const Color(0xFF9C27B0), 'val': 7, 'mult': 10000000.0, 'tol': 0.1, 'ppm': 5},
    {'name': 'Gri',     'color': const Color(0xFF9E9E9E), 'val': 8, 'mult': 0.0, 'tol': 0.05, 'ppm': 1},
    {'name': 'Beyaz',   'color': const Color(0xFFFFFFFF), 'val': 9, 'mult': 0.0, 'tol': null, 'ppm': null},
    {'name': 'Altın',   'color': const Color(0xFFFFD700), 'val': -1, 'mult': 0.1, 'tol': 5.0, 'ppm': null},
    {'name': 'Gümüş',   'color': const Color(0xFFC0C0C0), 'val': -2, 'mult': 0.01, 'tol': 10.0, 'ppm': null},
  ];

  // --- HESAPLAMA MOTORU ---
  String calculateResistance() {
    double baseVal = 0;
    
    if (bandCount == 4) {
      baseVal = (colors[digit1]['val'] * 10 + colors[digit2]['val']).toDouble();
    } else {
      baseVal = (colors[digit1]['val'] * 100 + colors[digit2]['val'] * 10 + colors[digit3]['val']).toDouble();
    }

    double totalOhms = baseVal * colors[multiplier]['mult'];
    return _formatOhms(totalOhms);
  }

  String _formatOhms(double ohms) {
    if (ohms >= 1000000000) return "${(ohms / 1000000000).toStringAsFixed(2).replaceAll('.00', '')} GΩ";
    if (ohms >= 1000000) return "${(ohms / 1000000).toStringAsFixed(2).replaceAll('.00', '')} MΩ";
    if (ohms >= 1000) return "${(ohms / 1000).toStringAsFixed(2).replaceAll('.00', '')} kΩ";
    return "${ohms.toStringAsFixed(2).replaceAll('.00', '')} Ω";
  }

  String getToleranceText() {
    return "±${colors[tolerance]['tol']}%";
  }

  String getPPMText() {
    if (bandCount != 6) return "";
    var p = colors[ppm]['ppm'];
    return p != null ? "$p ppm" : "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      body: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: GridPainter()),

          SafeArea(
            child: Column(
              children: [
                // 1. HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      Text("DIRENC HESAPLAYICI", style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
                    ],
                  ),
                ),

                // 2. MOD SEÇİCİ
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white10)),
                  child: Row(
                    children: [4, 5, 6].map((bands) {
                      bool isSelected = bandCount == bands;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => bandCount = bands),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.amber : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: isSelected ? [BoxShadow(color: Colors.amber.withValues(alpha: 0.4), blurRadius: 10)] : []
                            ),
                            child: Text("$bands BANT", textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.black : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // 3. SONUÇ EKRANI
                Column(
                  children: [
                    Text(calculateResistance(), style: GoogleFonts.shareTechMono(fontSize: 60, color: Colors.white, fontWeight: FontWeight.bold, shadows: [const BoxShadow(color: Colors.white24, blurRadius: 15)])),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(getToleranceText(), style: TextStyle(color: colors[tolerance]['color'], fontSize: 20, fontWeight: FontWeight.bold)),
                        if (bandCount == 6) ...[
                          const SizedBox(width: 15),
                          Text(getPPMText(), style: const TextStyle(color: Colors.blueAccent, fontSize: 16)),
                        ]
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 20),

                // 4. DİRENÇ GÖRSELİ
                Center(
                  child: SizedBox(
                    width: 320, height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(width: 320, height: 6, color: Colors.grey[600]),
                        Container(
                          width: 240, height: 70,
                          decoration: BoxDecoration(
                            color: bandCount > 4 ? const Color(0xFF81D4FA) : const Color(0xFFE0C9A6),
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5))],
                            gradient: LinearGradient(
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: bandCount > 4 ? [const Color(0xFFB3E5FC), const Color(0xFF0288D1)] : [const Color(0xFFF0E0C0), const Color(0xFF8D6E63)]
                            )
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildResistorBand(colors[digit1]['color']),
                            const SizedBox(width: 12),
                            _buildResistorBand(colors[digit2]['color']),
                            if (bandCount > 4) ...[const SizedBox(width: 12), _buildResistorBand(colors[digit3]['color'])],
                            const SizedBox(width: 12),
                            _buildResistorBand(colors[multiplier]['color']),
                            const SizedBox(width: 25),
                            _buildResistorBand(colors[tolerance]['color']),
                            if (bandCount == 6) ...[const SizedBox(width: 12), _buildResistorBand(colors[ppm]['color'])],
                          ],
                        )
                      ],
                    ),
                  ),
                ),

                // 5. SEÇİM PANELLERİ
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 30),
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                    decoration: const BoxDecoration(
                      color: Color(0xFF22252A),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                      boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)]
                    ),
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 20),
                      children: [
                        _buildColorRow("1. BANT", digit1, (v) => setState(() => digit1 = v), limit: 9),
                        _buildColorRow("2. BANT", digit2, (v) => setState(() => digit2 = v), limit: 9),
                        if (bandCount > 4) _buildColorRow("3. BANT", digit3, (v) => setState(() => digit3 = v), limit: 9),
                        _buildColorRow("CARPAN", multiplier, (v) => setState(() => multiplier = v), limit: 11),
                        _buildColorRow("TOLERANS", tolerance, (v) => setState(() => tolerance = v), isTolerance: true),
                        if (bandCount == 6) _buildColorRow("PPM (Temp)", ppm, (v) => setState(() => ppm = v), isPPM: true),
                      ],
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

  Widget _buildResistorBand(Color color) {
    return Container(width: 12, height: 70, color: color);
  }

  // GÜNCELLENMİŞ RENK SATIRI (İSİMLER EKLENDİ)
  Widget _buildColorRow(String title, int selectedIdx, Function(int) onSelect, {int limit = 12, bool isTolerance = false, bool isPPM = false}) {
    List<int> validIndices = [];
    if (isTolerance) {
      validIndices = [1, 2, 5, 6, 7, 8, 10, 11];
    } else if (isPPM) {
      validIndices = [0, 1, 2, 3, 4, 5, 6, 7, 8];
    } else {
      for (int i = 0; i <= limit; i++) validIndices.add(i);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 8),
            child: Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          SizedBox(
            height: 60, // Yüksekliği artırdım (Yazı sığsın diye)
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: validIndices.length,
              itemBuilder: (context, index) {
                int colorIdx = validIndices[index];
                bool isSelected = selectedIdx == colorIdx;
                bool isWhite = colors[colorIdx]['color'] == const Color(0xFFFFFFFF);

                return GestureDetector(
                  onTap: () => onSelect(colorIdx),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      children: [
                        // RENK TOPU
                        Container(
                          width: 35, height: 35,
                          decoration: BoxDecoration(
                            color: colors[colorIdx]['color'],
                            shape: BoxShape.circle,
                            border: isSelected 
                              ? Border.all(color: Colors.white, width: 2) 
                              : (isWhite ? Border.all(color: Colors.grey) : null),
                            boxShadow: isSelected ? [BoxShadow(color: colors[colorIdx]['color'].withValues(alpha: 0.6), blurRadius: 10)] : []
                          ),
                          child: isSelected ? const Icon(Icons.check, size: 20, color: Colors.grey) : null,
                        ),
                        const SizedBox(height: 4),
                        // RENK İSMİ (YENİ)
                        Text(
                          colors[colorIdx]['name'],
                          style: TextStyle(
                            color: isSelected ? Colors.amber : Colors.grey[600], // Seçiliyse Parlak Sarı
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
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