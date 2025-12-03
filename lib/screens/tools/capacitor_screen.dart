import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CapacitorScreen extends StatefulWidget {
  const CapacitorScreen({super.key});

  @override
  State<CapacitorScreen> createState() => _CapacitorScreenState();
}

class _CapacitorScreenState extends State<CapacitorScreen> {
  final TextEditingController _controller = TextEditingController();
  String _capacitance = "---";
  String _tolerance = "";
  String _voltage = "";

  // VOLTAJ KODLARI (Yaygın Olanlar)
  final Map<String, String> voltageMap = {
    '1H': '50V', '2A': '100V', '2E': '250V', '2G': '400V', '2J': '630V',
    '3A': '1kV', '1E': '25V',  '1C': '16V'
  };

  // TOLERANS KODLARI
  final Map<String, String> toleranceMap = {
    'J': '±5%', 'K': '±10%', 'M': '±20%', 'F': '±1%', 'G': '±2%'
  };

  void _calculate(String input) {
    if (input.length < 3) {
      setState(() {
        _capacitance = "---";
        _tolerance = "";
        _voltage = "";
      });
      return;
    }

    String code = input.toUpperCase();
    
    // 1. KAPASİTE HESABI (İlk 3 rakam önemli: örn 104 -> 10 * 10^4 pF)
    try {
      // Input içindeki rakamları bul (Regex)
      RegExp digitReg = RegExp(r'(\d{3})');
      Match? match = digitReg.firstMatch(code);
      
      if (match != null) {
        String digits = match.group(0)!;
        int firstTwo = int.parse(digits.substring(0, 2));
        int multiplier = int.parse(digits.substring(2, 3));
        
        // Hesap (pF cinsinden)
        double pF = firstTwo * (multiplier == 0 ? 1 : 
                               multiplier == 1 ? 10 : 
                               multiplier == 2 ? 100 : 
                               multiplier == 3 ? 1000 : 
                               multiplier == 4 ? 10000 : 
                               multiplier == 5 ? 100000 : 
                               multiplier == 6 ? 1000000 : 0.0); // 8-9 genelde kullanılmaz

        // Birim Dönüştürme
        String result = "";
        if (pF >= 1000000) {
          result = "${(pF / 1000000).toStringAsFixed(2).replaceAll('.00', '')} µF";
        } else if (pF >= 1000) {
          result = "${(pF / 1000).toStringAsFixed(2).replaceAll('.00', '')} nF";
        } else {
          result = "${pF.toStringAsFixed(0)} pF";
        }
        
        setState(() => _capacitance = result);
      }
    } catch (e) {
      setState(() => _capacitance = "HATA");
    }

    // 2. TOLERANS BULMA (J, K, M...)
    String foundTol = "";
    toleranceMap.forEach((key, value) {
      if (code.contains(key)) foundTol = value;
    });
    setState(() => _tolerance = foundTol);

    // 3. VOLTAJ BULMA (2A, 1H...)
    String foundVolt = "";
    voltageMap.forEach((key, value) {
      if (code.startsWith(key)) foundVolt = value;
    });
    setState(() => _voltage = foundVolt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      body: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: GridPainter()),

          SafeArea(
            child: SingleChildScrollView( // Klavye açılınca taşmasın
              child: Column(
                children: [
                  // HEADER
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Row(
                      children: [
                        IconButton(icon: const Icon(Icons.arrow_back, color: Colors.grey), onPressed: () => Navigator.pop(context)),
                        const SizedBox(width: 10),
                        Text("KONDANSATOR COZUCU", style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
                      ],
                    ),
                  ),
            
                  const SizedBox(height: 20),
            
                  // GÖRSEL ALAN (Seramik Kondansatör)
                  Center(
                    child: SizedBox(
                      width: 250, height: 250,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Bacaklar
                          Positioned(bottom: 0, left: 80, child: Container(width: 6, height: 100, color: Colors.grey[400])),
                          Positioned(bottom: 0, right: 80, child: Container(width: 6, height: 100, color: Colors.grey[400])),
                          
                          // Gövde (Turuncu Disk)
                          Container(
                            width: 220, height: 180,
                            margin: const EdgeInsets.only(bottom: 50),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97D54), // Seramik Turuncusu
                              shape: BoxShape.circle,
                              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 15, offset: Offset(0, 8))],
                              border: Border.all(color: const Color(0xFFA65D3B), width: 4)
                            ),
                          ),
                          
                          // Üzerindeki Yazı (Dinamik)
                          Positioned(
                            top: 80,
                            child: Column(
                              children: [
                                Text(
                                  _controller.text.isEmpty ? "104" : _controller.text.toUpperCase(),
                                  style: GoogleFonts.shareTechMono(
                                    fontSize: 40, 
                                    color: Colors.black.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                // Altına çizgi (klasik seramik görüntüsü)
                                Container(width: 50, height: 2, color: Colors.black54, margin: const EdgeInsets.symmetric(vertical: 5)),
                                Text(
                                  _voltage.isEmpty ? "KV" : _voltage,
                                  style: GoogleFonts.shareTechMono(fontSize: 20, color: Colors.black54),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
            
                  const SizedBox(height: 30),
            
                  // INPUT ALANI
                  Container(
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white10)
                    ),
                    child: TextField(
                      controller: _controller,
                      onChanged: (val) {
                        setState(() {}); // Görseli güncelle
                        _calculate(val);
                      },
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                      decoration: const InputDecoration(
                        hintText: "KOD (Örn: 104J)",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(15)
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(6), // Max 6 karakter
                      ],
                    ),
                  ),
            
                  const SizedBox(height: 30),
            
                  // SONUÇ KARTLARI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildResultCard("KAPASİTE", _capacitance, Colors.blue),
                      _buildResultCard("TOLERANS", _tolerance.isEmpty ? "--" : _tolerance, Colors.green),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Voltaj Kartı (Varsa Göster)
                  if (_voltage.isNotEmpty)
                    _buildResultCard("MAX VOLTAJ", _voltage, Colors.redAccent),
            
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      decoration: BoxDecoration(
        color: const Color(0xFF353A40),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)]
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 10, letterSpacing: 1)),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Grid Arka Plan
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