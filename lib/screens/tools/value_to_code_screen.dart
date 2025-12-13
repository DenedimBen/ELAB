import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ValueToCodeScreen extends StatefulWidget {
  const ValueToCodeScreen({super.key});

  @override
  State<ValueToCodeScreen> createState() => _ValueToCodeScreenState();
}

class _ValueToCodeScreenState extends State<ValueToCodeScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedUnit = "Ω"; 
  
  // Sonuçlar
  String code3Digit = "---";
  String code4Digit = "---";
  String codeEIA96 = "---";
  
  // EIA-96 TERS TABLOSU
  final Map<int, String> eia96ReverseMap = {
    100: '01', 102: '02', 105: '03', 107: '04', 110: '05', 113: '06', 115: '07', 118: '08', 121: '09', 124: '10',
    127: '11', 130: '12', 133: '13', 137: '14', 140: '15', 143: '16', 147: '17', 150: '18', 154: '19', 158: '20',
    162: '21', 165: '22', 169: '23', 174: '24', 178: '25', 182: '26', 187: '27', 191: '28', 196: '29', 200: '30',
    205: '31', 210: '32', 215: '33', 221: '34', 226: '35', 232: '36', 237: '37', 243: '38', 249: '39', 255: '40',
    261: '41', 267: '42', 274: '43', 280: '44', 287: '45', 294: '46', 301: '47', 309: '48', 316: '49', 324: '50',
    332: '51', 340: '52', 348: '53', 357: '54', 365: '55', 374: '56', 383: '57', 392: '58', 402: '59', 412: '60',
    422: '61', 432: '62', 442: '63', 453: '64', 464: '65', 475: '66', 487: '67', 499: '68', 511: '69', 523: '70',
    536: '71', 549: '72', 562: '73', 576: '74', 590: '75', 604: '76', 619: '77', 634: '78', 649: '79', 665: '80',
    681: '81', 698: '82', 715: '83', 732: '84', 750: '85', 768: '86', 787: '87', 806: '88', 825: '89', 845: '90',
    866: '91', 887: '92', 909: '93', 931: '94', 953: '95', 976: '96'
  };
  
  final Map<int, String> eiaMultipliers = {
    -2: 'Y', -1: 'X', 0: 'A', 1: 'B', 2: 'C', 3: 'D', 4: 'E', 5: 'F'
  };

  void _calculate() {
    if (_controller.text.isEmpty) {
      setState(() { code3Digit = "---"; code4Digit = "---"; codeEIA96 = "---"; });
      return;
    }

    double val = double.tryParse(_controller.text.replaceAll(',', '.')) ?? 0;
    if (val <= 0) return;

    double ohms = val;
    if (_selectedUnit == "kΩ") ohms *= 1000;
    if (_selectedUnit == "MΩ") ohms *= 1000000;

    setState(() {
      code3Digit = _calc3Digit(ohms);
      code4Digit = _calc4Digit(ohms);
      codeEIA96 = _calcEIA96(ohms);
    });
  }

  String _calc3Digit(double ohms) {
    if (ohms < 10) return ohms.toStringAsFixed(1).replaceAll('.', 'R');
    String s = ohms.toStringAsFixed(0);
    int len = s.length;
    String firstTwo = s.substring(0, 2);
    int zeros = len - 2;
    if (zeros > 9) return "O.L";
    return "$firstTwo$zeros";
  }

  String _calc4Digit(double ohms) {
    if (ohms < 100) return ohms.toStringAsFixed(1).replaceAll('.', 'R');
    String s = ohms.toStringAsFixed(0);
    int len = s.length;
    String firstThree = s.substring(0, 3);
    int zeros = len - 3;
    if (zeros > 9) return "O.L";
    return "$firstThree$zeros";
  }

  String _calcEIA96(double ohms) {
    double temp = ohms;
    int multiplier = 0;
    while (temp >= 1000) { temp /= 10; multiplier++; }
    while (temp < 100 && temp > 0) { temp *= 10; multiplier--; }
    int significant = temp.round();
    if (eia96ReverseMap.containsKey(significant) && eiaMultipliers.containsKey(multiplier)) {
      return "${eia96ReverseMap[significant]}${eiaMultipliers[multiplier]}";
    } else {
      return "N/A";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      body: Stack(
        children: [
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
                        Text("DEĞER -> KOD", style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
                      ],
                    ),
                    
                    const SizedBox(height: 30),

                    // --- INPUT TERMİNALİ ---
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22252A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 5))]
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("DİRENÇ DEĞERİ GİRİN", style: GoogleFonts.orbitron(color: Colors.grey[400], fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black38,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.amber.withValues(alpha: 0.3))
                                  ),
                                  child: TextField(
                                    controller: _controller,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 32),
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      hintText: "000",
                                      hintStyle: TextStyle(color: Colors.white10),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)
                                    ),
                                    onChanged: (v) => _calculate(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              // BİRİM SEÇİCİ (BTN)
                              _buildUnitSelector(),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- SONUÇLAR (GÜNCELLENDİ: ORTALI VE KISA) ---
                    Column(
                      children: [
                         _buildSciFiResultCard("3 DIGIT KOD (Standart)", code3Digit, Colors.blueAccent),
                         const SizedBox(height: 25),
                         _buildSciFiResultCard("4 DIGIT KOD (Hassas)", code4Digit, Colors.greenAccent),
                         const SizedBox(height: 25),
                         _buildSciFiResultCard("EIA-96 KODU (1%)", codeEIA96, Colors.purpleAccent),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5))
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedUnit,
          dropdownColor: const Color(0xFF353A40),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
          style: GoogleFonts.orbitron(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18),
          onChanged: (String? newValue) {
            setState(() {
              _selectedUnit = newValue!;
              _calculate();
            });
          },
          items: <String>['Ω', 'kΩ', 'MΩ'].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }

  // YENİLENMİŞ SONUÇ KARTI
  Widget _buildSciFiResultCard(String title, String code, Color color) {
    bool isNA = code == "N/A" || code == "---" || code == "O.L";
    
    return Column(
      children: [
        // BAŞLIK (ARTIK NEON VE ORTALI)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3))
          ),
          child: Text(
            title, 
            style: GoogleFonts.orbitron(color: color, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)
          ),
        ),
        
        const SizedBox(height: 8),

        // DİRENÇ GÖVDESİ (KISA VE GERÇEKÇİ)
        Center(
          child: Container(
            height: 70, 
            width: 240, // Boyunu kısalttık (Daha gerçekçi SMD oranı)
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              borderRadius: BorderRadius.circular(4), 
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 15, offset: const Offset(0, 5))],
              border: Border.all(color: Colors.white.withValues(alpha: 0.05))
            ),
            child: Row(
              children: [
                // Sol Terminal
                Container(
                  width: 25, 
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.grey, Colors.white70, Colors.grey], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
                    border: Border.all(color: Colors.grey[800]!)
                  ),
                ),
                // Gövde ve Yazı
                Expanded(
                  child: Center(
                    child: Text(
                      code,
                      style: GoogleFonts.shareTechMono(
                        fontSize: 36, // Font boyutu ideal
                        color: isNA ? Colors.grey[700] : Colors.white.withValues(alpha: 0.9), 
                        letterSpacing: 3
                      ),
                    ),
                  ),
                ),
                // Sağ Terminal
                Container(
                  width: 25, 
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.grey, Colors.white70, Colors.grey], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                    border: Border.all(color: Colors.grey[800]!)
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.03)..strokeWidth = 1;
    const double step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
