import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OhmsLawScreen extends StatefulWidget {
  const OhmsLawScreen({super.key});

  @override
  State<OhmsLawScreen> createState() => _OhmsLawScreenState();
}

class _OhmsLawScreenState extends State<OhmsLawScreen> {
  // Modlar: 0=Voltaj(V), 1=Akım(I), 2=Direnç(R), 3=Güç(P)
  int selectedMode = 0; 
  
  final TextEditingController _input1Controller = TextEditingController();
  final TextEditingController _input2Controller = TextEditingController();
  
  String resultValue = "0.00";
  String resultUnit = "V";

  // Hesaplama Fonksiyonu
  void _calculate() {
    double v1 = double.tryParse(_input1Controller.text.replaceAll(',', '.')) ?? 0;
    double v2 = double.tryParse(_input2Controller.text.replaceAll(',', '.')) ?? 0;
    
    double res = 0;

    setState(() {
      switch (selectedMode) {
        case 0: // Voltaj (V = I * R)
          res = v1 * v2;
          resultUnit = "V";
          break;
        case 1: // Akım (I = V / R)
          if (v2 != 0) res = v1 / v2;
          resultUnit = "A";
          break;
        case 2: // Direnç (R = V / I)
          if (v2 != 0) res = v1 / v2;
          resultUnit = "Ω";
          break;
        case 3: // Güç (P = V * I)
          res = v1 * v2;
          resultUnit = "W";
          break;
      }
      
      // Sonucu formatla (Çok büyük/küçük sayılar için)
      if (res >= 1000) {
         resultValue = "${(res / 1000).toStringAsFixed(2)} k$resultUnit";
      } else if (res < 1 && res > 0) {
         resultValue = "${(res * 1000).toStringAsFixed(1)} m$resultUnit";
      } else {
         resultValue = "${res.toStringAsFixed(2)} $resultUnit";
      }
    });
  }

  // Giriş Etiketlerini Belirle
  String getLabel1() {
    switch (selectedMode) {
      case 0: return "AKIM (I)"; // V hesaplamak için I lazım
      case 1: return "VOLTAJ (V)"; // I hesaplamak için V lazım
      case 2: return "VOLTAJ (V)"; // R hesaplamak için V lazım
      case 3: return "VOLTAJ (V)"; // P hesaplamak için V lazım
      default: return "";
    }
  }

  String getLabel2() {
    switch (selectedMode) {
      case 0: return "DİRENÇ (R)";
      case 1: return "DİRENÇ (R)";
      case 2: return "AKIM (I)";
      case 3: return "AKIM (I)";
      default: return "";
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
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // HEADER
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back, color: Colors.grey), onPressed: () => Navigator.pop(context)),
                      const SizedBox(width: 10),
                      Text("OHM KANUNU", style: GoogleFonts.orbitron(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 1. SEÇİM ALANI (NEON BUTONLAR)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildModeBtn("VOLTAJ (V)", 0, Colors.redAccent),
                      _buildModeBtn("AKIM (I)", 1, Colors.greenAccent),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildModeBtn("DİRENÇ (R)", 2, Colors.blueAccent),
                      _buildModeBtn("GÜÇ (P)", 3, Colors.purpleAccent),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // 2. GÖRSEL ÜÇGEN (OHM PİRAMİDİ)
                  SizedBox(
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Dış Halka
                        Container(
                          width: 180, height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white10, width: 2),
                            boxShadow: [BoxShadow(color: _getModeColor().withValues(alpha: 0.2), blurRadius: 30, spreadRadius: 5)]
                          ),
                        ),
                        // Formül Gösterimi
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Üst Değer
                            Text(
                              selectedMode == 0 ? "V = I x R" : 
                              selectedMode == 1 ? "I = V / R" :
                              selectedMode == 2 ? "R = V / I" : "P = V x I",
                              style: GoogleFonts.shareTechMono(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            // Alt Çizgi
                            Container(width: 100, height: 2, color: _getModeColor()),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 3. GİRİŞ ALANLARI
                  _buildInputField(getLabel1(), _input1Controller),
                  const SizedBox(height: 15),
                  _buildInputField(getLabel2(), _input2Controller),

                  const SizedBox(height: 30),

                  // 4. SONUÇ KARTI
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF353A40),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getModeColor().withValues(alpha: 0.5)),
                      boxShadow: [BoxShadow(color: _getModeColor().withValues(alpha: 0.2), blurRadius: 15)]
                    ),
                    child: Column(
                      children: [
                        Text("SONUÇ", style: TextStyle(color: Colors.grey[400], letterSpacing: 2, fontSize: 12)),
                        const SizedBox(height: 5),
                        Text(
                          resultValue,
                          style: GoogleFonts.orbitron(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
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

  Color _getModeColor() {
    switch (selectedMode) {
      case 0: return Colors.redAccent;
      case 1: return Colors.greenAccent;
      case 2: return Colors.blueAccent;
      case 3: return Colors.purpleAccent;
      default: return Colors.amber;
    }
  }

  Widget _buildModeBtn(String title, int index, Color color) {
    bool isSelected = selectedMode == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMode = index;
          _input1Controller.clear();
          _input2Controller.clear();
          resultValue = "0.00";
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? color : Colors.grey.withValues(alpha: 0.3)),
          boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10)] : []
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(color: isSelected ? color : Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white10)
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              suffixIcon: Icon(Icons.edit, color: Colors.grey, size: 18)
            ),
            onChanged: (val) => _calculate(),
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
    for (double x = 0; x < size.width; x += step) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += step) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}