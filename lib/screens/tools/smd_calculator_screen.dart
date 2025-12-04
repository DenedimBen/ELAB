import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SmdCalculatorScreen extends StatefulWidget {
  const SmdCalculatorScreen({super.key});

  @override
  State<SmdCalculatorScreen> createState() => _SmdCalculatorScreenState();
}

class _SmdCalculatorScreenState extends State<SmdCalculatorScreen> {
  int mode = 3; // 3: 3-Digit, 4: 4-Digit, 96: EIA-96

  // Seçilen Değerler
  int val1Idx = 1;
  int val2Idx = 0;
  int val3Idx = 2;
  int val4Idx = 1;
  int eiaLetterIdx = 3;

  // --- VERİ TABLOLARI ---
  final List<Map<String, dynamic>> numberData = [
    {'text': '0', 'color': const Color(0xFF000000)},
    {'text': '1', 'color': const Color(0xFF795548)},
    {'text': '2', 'color': const Color(0xFFF44336)},
    {'text': '3', 'color': const Color(0xFFFF9800)},
    {'text': '4', 'color': const Color(0xFFFFEB3B), 'textColor': Colors.black},
    {'text': '5', 'color': const Color(0xFF4CAF50)},
    {'text': '6', 'color': const Color(0xFF2196F3)},
    {'text': '7', 'color': const Color(0xFF9C27B0)},
    {'text': '8', 'color': const Color(0xFF9E9E9E)},
    {'text': '9', 'color': const Color(0xFFFFFFFF), 'textColor': Colors.black},
  ];

  final List<Map<String, dynamic>> eiaLetterData = [
    {'text': 'Z', 'mult': 0.001, 'color': Colors.grey[800]},
    {'text': 'Y', 'mult': 0.01,  'color': Colors.grey[700]},
    {'text': 'X', 'mult': 0.1,   'color': Colors.grey[600]},
    {'text': 'A', 'mult': 1.0,   'color': Colors.blueGrey[400]},
    {'text': 'B', 'mult': 10.0,  'color': Colors.blueGrey[500]},
    {'text': 'C', 'mult': 100.0, 'color': Colors.blueGrey[600]},
    {'text': 'D', 'mult': 1000.0,'color': Colors.blueGrey[700]},
    {'text': 'E', 'mult': 10000.0,'color': Colors.blueGrey[800]},
    {'text': 'F', 'mult': 100000.0,'color': Colors.blueGrey[900]},
  ];

  final Map<int, int> eia96Table = {
    01: 100, 02: 102, 03: 105, 04: 107, 05: 110, 06: 113, 07: 115, 08: 118, 09: 121, 10: 124,
    11: 127, 12: 130, 13: 133, 14: 137, 15: 140, 16: 143, 17: 147, 18: 150, 19: 154, 20: 158,
    21: 162, 22: 165, 23: 169, 24: 174, 25: 178, 26: 182, 27: 187, 28: 191, 29: 196, 30: 200,
    31: 205, 32: 210, 33: 215, 34: 221, 35: 226, 36: 232, 37: 237, 38: 243, 39: 249, 40: 255,
    41: 261, 42: 267, 43: 274, 44: 280, 45: 287, 46: 294, 47: 301, 48: 309, 49: 316, 50: 324,
    51: 332, 52: 340, 53: 348, 54: 357, 55: 365, 56: 374, 57: 383, 58: 392, 59: 402, 60: 412,
    61: 422, 62: 432, 63: 442, 64: 453, 65: 464, 66: 475, 67: 487, 68: 499, 69: 511, 70: 523,
    71: 536, 72: 549, 73: 562, 74: 576, 75: 590, 76: 604, 77: 619, 78: 634, 79: 649, 80: 665,
    81: 681, 82: 698, 83: 715, 84: 732, 85: 750, 86: 768, 87: 787, 88: 806, 89: 825, 90: 845,
    91: 866, 92: 887, 93: 909, 94: 931, 95: 953, 96: 976
  };

  // --- HESAPLAMA MOTORU ---
  String _calculate() {
    double ohms = 0;
    int v1 = int.parse(numberData[val1Idx]['text']);
    int v2 = int.parse(numberData[val2Idx]['text']);

    if (mode == 96) {
      int code = (v1 * 10) + v2;
      if (code == 0) return "Geçersiz";
      int? baseVal = eia96Table[code];
      if (baseVal == null) return "Hata";
      double multiplier = eiaLetterData[eiaLetterIdx]['mult'];
      ohms = baseVal * multiplier;
    } else {
      double base = 0;
      int multiplierPower = 0;
      int v3 = int.parse(numberData[val3Idx]['text']);
      
      if (mode == 3) {
        base = (v1 * 10 + v2).toDouble();
        multiplierPower = v3;
      } else {
        int v4 = int.parse(numberData[val4Idx]['text']);
        base = (v1 * 100 + v2 * 10 + v3).toDouble();
        multiplierPower = v4;
      }
      ohms = base * _getPowerOfTen(multiplierPower);
    }
    return _formatOhms(ohms);
  }

  double _getPowerOfTen(int power) {
    double res = 1;
    for(int i=0; i<power; i++) res *= 10;
    return res;
  }

  String _formatOhms(double ohms) {
    if (ohms >= 1000000) return "${(ohms / 1000000).toStringAsFixed(2).replaceAll('.00', '')} MΩ";
    if (ohms >= 1000) return "${(ohms / 1000).toStringAsFixed(2).replaceAll('.00', '')} kΩ";
    return "${ohms.toStringAsFixed(2).replaceAll('.00', '')} Ω";
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
                // 1. HEADER & MOD SEÇİCİ
                _buildHeader(),
                const SizedBox(height: 20),
                // 2. SONUÇ ALANI
                _buildResultDisplay(),
                const Spacer(),
                // 3. DİKEY SEÇİCİLER
                _buildWheelsContainer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back, color: Colors.grey), onPressed: () => Navigator.pop(context)),
              const SizedBox(width: 10),
              Text("SMD HESAPLAYICI", style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFF202329),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                _buildSciFiModeBtn("3 DIGIT", 3),
                Container(width: 1, color: Colors.white10),
                _buildSciFiModeBtn("4 DIGIT", 4),
                Container(width: 1, color: Colors.white10),
                _buildSciFiModeBtn("EIA-96", 96),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultDisplay() {
    List<Widget> bands = [];
    if (mode == 96) {
      bands = [
        _buildResultBand(numberData[val1Idx]),
        _buildResultBand(numberData[val2Idx]),
        _buildResultBand(eiaLetterData[eiaLetterIdx]),
      ];
    } else if (mode == 4) {
      bands = [
        _buildResultBand(numberData[val1Idx]),
        _buildResultBand(numberData[val2Idx]),
        _buildResultBand(numberData[val3Idx]),
        _buildResultBand(numberData[val4Idx]),
      ];
    } else {
      bands = [
        _buildResultBand(numberData[val1Idx]),
        _buildResultBand(numberData[val2Idx]),
        _buildResultBand(numberData[val3Idx]),
      ];
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF353A40),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Text(
            _calculate(),
            style: GoogleFonts.shareTechMono(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.5), blurRadius: 20)]
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: bands.map((b) => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: b)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultBand(Map<String, dynamic> data) {
    return Container(
      width: 50, height: 60,
      decoration: BoxDecoration(
        color: data['color'],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24, width: 2),
        boxShadow: [BoxShadow(color: (data['color'] as Color).withValues(alpha: 0.5), blurRadius: 8)]
      ),
      child: Center(
        child: Text(
          data['text'],
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: data['textColor'] ?? Colors.white
          ),
        ),
      ),
    );
  }

  Widget _buildWheelsContainer() {
    List<Widget> wheels = [];
    if (mode == 96) {
      wheels = [
        _buildWheel(numberData, val1Idx, (v) => setState(() => val1Idx = v)),
        _buildWheel(numberData, val2Idx, (v) => setState(() => val2Idx = v)),
        _buildWheel(eiaLetterData, eiaLetterIdx, (v) => setState(() => eiaLetterIdx = v)),
      ];
    } else if (mode == 4) {
      wheels = [
        _buildWheel(numberData, val1Idx, (v) => setState(() => val1Idx = v)),
        _buildWheel(numberData, val2Idx, (v) => setState(() => val2Idx = v)),
        _buildWheel(numberData, val3Idx, (v) => setState(() => val3Idx = v)),
        _buildWheel(numberData, val4Idx, (v) => setState(() => val4Idx = v)),
      ];
    } else {
      wheels = [
        _buildWheel(numberData, val1Idx, (v) => setState(() => val1Idx = v)),
        _buildWheel(numberData, val2Idx, (v) => setState(() => val2Idx = v)),
        _buildWheel(numberData, val3Idx, (v) => setState(() => val3Idx = v)),
      ];
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF22252A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, -5))]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: wheels,
      ),
    );
  }

  Widget _buildWheel(List<Map<String, dynamic>> dataList, int currentIdx, Function(int) onChanged) {
    return SizedBox(
      width: 70,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 70,
        perspective: 0.003,
        diameterRatio: 1.5,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: dataList.length,
          builder: (context, index) {
            final data = dataList[index];
            bool isSelected = index == currentIdx;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: data['color'],
                borderRadius: BorderRadius.circular(12),
                border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                boxShadow: isSelected ? [BoxShadow(color: (data['color'] as Color).withValues(alpha: 0.7), blurRadius: 15)] : []
              ),
              child: Center(
                child: Text(
                  data['text'],
                  style: TextStyle(
                    fontSize: isSelected ? 32 : 24,
                    fontWeight: FontWeight.bold,
                    color: data['textColor'] ?? Colors.white
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSciFiModeBtn(String title, int modeVal) {
    bool isSelected = mode == modeVal;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => mode = modeVal),
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(color: isSelected ? Colors.amber : Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12)),
              // HATALI KOD DÜZELTİLDİ: EdgeInsets.only(top: 4)
              if (isSelected) Container(margin: const EdgeInsets.only(top: 4), width: 4, height: 4, decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle))
            ],
          ),
        ),
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