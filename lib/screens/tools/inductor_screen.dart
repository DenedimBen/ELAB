import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InductorScreen extends StatefulWidget {
  const InductorScreen({super.key});

  @override
  State<InductorScreen> createState() => _InductorScreenState();
}

class _InductorScreenState extends State<InductorScreen> {
  int type = 0; // 0: Axial (Bacaklı), 1: SMD (Yonga)

  // Seçili Renkler
  int band1 = 1; // Kahve
  int band2 = 0; // Siyah
  int band3 = 2; // Kırmızı (Çarpan)
  int band4 = 10; // Gümüş (Tolerans)

  final List<Map<String, dynamic>> colors = [
    {'name': 'Siyah',   'color': const Color(0xFF1A1A1A), 'val': 0, 'mult': 1.0,      'tol': 20},
    {'name': 'Kahve',   'color': const Color(0xFF795548), 'val': 1, 'mult': 10.0,     'tol': 1},
    {'name': 'Kırmızı', 'color': const Color(0xFFD32F2F), 'val': 2, 'mult': 100.0,    'tol': 2},
    {'name': 'Turuncu', 'color': const Color(0xFFFF9800), 'val': 3, 'mult': 1000.0,   'tol': 3},
    {'name': 'Sarı',    'color': const Color(0xFFFFEB3B), 'val': 4, 'mult': 10000.0,  'tol': 4},
    {'name': 'Yeşil',   'color': const Color(0xFF4CAF50), 'val': 5, 'mult': 0.0,      'tol': null},
    {'name': 'Mavi',    'color': const Color(0xFF2196F3), 'val': 6, 'mult': 0.0,      'tol': null},
    {'name': 'Mor',     'color': const Color(0xFF9C27B0), 'val': 7, 'mult': 0.0,      'tol': null},
    {'name': 'Gri',     'color': const Color(0xFF9E9E9E), 'val': 8, 'mult': 0.0,      'tol': null},
    {'name': 'Beyaz',   'color': const Color(0xFFFFFFFF), 'val': 9, 'mult': 0.0,      'tol': null},
    {'name': 'Altın',   'color': const Color(0xFFFFD700), 'val': -1, 'mult': 0.1,     'tol': 5},
    {'name': 'Gümüş',   'color': const Color(0xFFC0C0C0), 'val': -2, 'mult': 0.01,    'tol': 10},
  ];

  String _calculate() {
    double base = (colors[band1]['val'] * 10 + colors[band2]['val']).toDouble();
    double multiplier = colors[band3]['mult'];
    double value = base * multiplier;

    if (value < 1) {
      return "${(value * 1000).toStringAsFixed(0)} nH";
    } else if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(2).replaceAll('.00', '')} mH";
    } else {
      return "${value.toStringAsFixed(1).replaceAll('.0', '')} µH";
    }
  }

  String _getTolerance() {
    if (type == 1) return ""; 
    var t = colors[band4]['tol'];
    return t != null ? "±$t%" : "";
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
                // HEADER
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back, color: Colors.grey), onPressed: () => Navigator.pop(context)),
                      const SizedBox(width: 10),
                      Text("İNDÜKTÖR HESAPLA", style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
                    ],
                  ),
                ),

                // MOD SEÇİCİ
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white10)),
                  child: Row(
                    children: [
                      _buildModeBtn("BOŞ DELİK (AXIAL)", 0),
                      _buildModeBtn("YONGA (SMD)", 1),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // SONUÇ
                Column(
                  children: [
                    Text(_calculate(), style: GoogleFonts.shareTechMono(fontSize: 60, color: Colors.white, fontWeight: FontWeight.bold, shadows: [const BoxShadow(color: Colors.greenAccent, blurRadius: 20)])),
                    Text(_getTolerance(), style: TextStyle(color: colors[band4]['color'], fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),

                const SizedBox(height: 20),

                // GÖRSEL ALAN
                Expanded(
                  flex: 4,
                  child: Center(
                    child: type == 0 ? _buildAxialInductor() : _buildSMDInductor(),
                  ),
                ),

                // KONTROL PANELİ
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                    decoration: const BoxDecoration(color: Color(0xFF22252A), borderRadius: BorderRadius.vertical(top: Radius.circular(30)), boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)]),
                    child: ListView(
                      children: [
                        _buildColorRow("1. BANT / NOKTA", band1, (v) => setState(() => band1 = v), limit: 9),
                        _buildColorRow("2. BANT / NOKTA", band2, (v) => setState(() => band2 = v), limit: 9),
                        _buildColorRow("ÇARPAN", band3, (v) => setState(() => band3 = v), limit: 11),
                        if (type == 0) 
                          _buildColorRow("TOLERANS", band4, (v) => setState(() => band4 = v), isTolerance: true),
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

  // --- YENİLENMİŞ GÖRSELLER ---

  // 1. AXIAL (Yeşil Direnç Tipi)
  Widget _buildAxialInductor() {
    return SizedBox(
      width: 320, height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(width: 320, height: 6, color: Colors.grey[600]),
          Container(
            width: 240, height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF43A047), // Mat Yeşil
              borderRadius: BorderRadius.circular(40),
              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5))],
              border: Border.all(color: Colors.green[800]!, width: 1),
              gradient: const LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0xFF81C784), Color(0xFF2E7D32)]
              )
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBand(colors[band1]['color']), const SizedBox(width: 15),
              _buildBand(colors[band2]['color']), const SizedBox(width: 15),
              _buildBand(colors[band3]['color']), const SizedBox(width: 30),
              _buildBand(colors[band4]['color']),
            ],
          )
        ],
      ),
    );
  }

  // 2. SMD İNDÜKTÖR (YENİ BOBİN TASARIMI)
  Widget _buildSMDInductor() {
    return Container(
      width: 240, height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // Seramik Beyazı
        borderRadius: BorderRadius.circular(12), // Hafif köşeli
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10))],
        border: Border.all(color: Colors.grey[300]!, width: 2)
      ),
      child: Stack(
        children: [
          // Sol ve Sağ Metal Terminaller
          Positioned(left: 0, top: 0, bottom: 0, child: Container(width: 40, decoration: const BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.horizontal(left: Radius.circular(10))))),
          Positioned(right: 0, top: 0, bottom: 0, child: Container(width: 40, decoration: const BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.horizontal(right: Radius.circular(10))))),
          
          // ORTA KISIM: BAKIR BOBİN GÖRÜNÜMÜ (Çizgilerle simülasyon)
          Center(
            child: Container(
              width: 140, height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFD7CCC8), // Açık zemin
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(5)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(8, (index) => 
                  Container(
                    width: 8, height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA1887F), // Bakır Rengi
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(1, 1), blurRadius: 2)]
                    ),
                  )
                ),
              ),
            ),
          ),

          // RENKLİ NOKTALAR (Bobinin Üzerinde)
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Noktaları belirginleştirmek için arka plana beyaz daire koydum
                _buildDotWithBorder(colors[band1]['color']),
                _buildDotWithBorder(colors[band2]['color']),
                _buildDotWithBorder(colors[band3]['color']),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBand(Color color) => Container(width: 20, height: 80, color: color);
  
  // Yeni: Kenarlıklı Nokta
  Widget _buildDotWithBorder(Color color) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)]
      ),
    );
  }

  Widget _buildModeBtn(String title, int modeVal) {
    bool isSelected = type == modeVal;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => type = modeVal),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: isSelected ? Colors.amber : Colors.transparent, borderRadius: BorderRadius.circular(25)),
          child: Text(title, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.black : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildColorRow(String title, int selectedIdx, Function(int) onSelect, {int limit = 12, bool isTolerance = false}) {
    List<int> validIndices = [];
    if (isTolerance) {
      validIndices = [0, 1, 2, 3, 4, 10, 11];
    } else {
      for (int i = 0; i <= limit; i++) validIndices.add(i);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(left: 10, bottom: 5), child: Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: validIndices.length,
              itemBuilder: (context, index) {
                int colorIdx = validIndices[index];
                bool isSelected = selectedIdx == colorIdx;
                bool isWhite = colors[colorIdx]['color'] == const Color(0xFFFFFFFF);
                return GestureDetector(
                  onTap: () => onSelect(colorIdx),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: isSelected ? 40 : 35,
                    decoration: BoxDecoration(
                      color: colors[colorIdx]['color'],
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.white, width: 3) : (isWhite ? Border.all(color: Colors.grey) : null),
                      boxShadow: isSelected ? [BoxShadow(color: colors[colorIdx]['color'].withValues(alpha: 0.6), blurRadius: 10)] : []
                    ),
                    child: isSelected ? const Icon(Icons.check, size: 20, color: Colors.grey) : null,
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