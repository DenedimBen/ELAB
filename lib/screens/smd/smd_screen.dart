import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/excel_service.dart';
import '../../models/component_model.dart';
import '../test_page/test_screen.dart';

class SmdScreen extends StatefulWidget {
  const SmdScreen({super.key});

  @override
  State<SmdScreen> createState() => _SmdScreenState();
}

class _SmdScreenState extends State<SmdScreen> {
  final ExcelService _service = ExcelService();
  final TextEditingController _codeController = TextEditingController();
  
  List<Component> _foundComponents = [];
  bool _hasSearched = false; // Arama yapıldı mı?

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _service.loadDatabase();
  }

  void _searchSMD(String input) {
    if (input.isEmpty) {
      setState(() {
        _foundComponents = [];
        _hasSearched = false;
      });
      return;
    }

    String code = input.trim().toUpperCase();
    List<Component> results = [];

    // Sözlükten bak: Bu kod var mı?
    if (_service.smdDictionary.containsKey(code)) {
      List<String> ids = _service.smdDictionary[code]!;
      
      // Bulunan ID'lerin detaylarını çek
      for (String id in ids) {
        Component? comp = _service.getComponentById(id);
        if (comp != null) {
          results.add(comp);
        }
      }
    }

    setState(() {
      _foundComponents = results;
      _hasSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      body: Stack(
        children: [
          // 1. GRID ARKA PLAN
          CustomPaint(
            size: Size.infinite,
            painter: GridPainter(),
          ),

          SafeArea(
            child: Column(
              children: [
                // 2. HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "SMD DEDEKTİFİ",
                            style: GoogleFonts.orbitron(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                              letterSpacing: 2,
                              shadows: [const BoxShadow(color: Colors.amber, blurRadius: 15)]
                            ),
                          ),
                          Text(
                            "KOD ÇÖZÜCÜ",
                            style: TextStyle(color: Colors.grey[400], fontSize: 10, letterSpacing: 4),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3. SANAL ÇİP (INPUT ALANI)
                Center(
                  child: Container(
                    width: 220,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFF151515), // Çip Siyahı
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[800]!, width: 2),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 10))
                      ]
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Sol Bacaklar
                        Positioned(left: -12, top: 20, child: _buildLeg()),
                        Positioned(left: -12, bottom: 20, child: _buildLeg()),
                        // Sağ Bacaklar
                        Positioned(right: -12, top: 20, child: _buildLeg()),
                        Positioned(right: -12, bottom: 20, child: _buildLeg()),
                        
                        // Çip Üzerindeki Yazı (Input)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 150,
                              child: TextField(
                                controller: _codeController,
                                onChanged: _searchSMD,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.shareTechMono( // Lazer baskı fontu
                                  fontSize: 45,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.bold
                                ),
                                decoration: InputDecoration(
                                  hintText: "1A",
                                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.1)),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            Text("KODU GİRİN", style: TextStyle(color: Colors.grey[600], fontSize: 8, letterSpacing: 2)),
                          ],
                        ),
                        
                        // Çip Noktası (Pin 1)
                        const Positioned(
                          top: 15, left: 15,
                          child: CircleAvatar(radius: 5, backgroundColor: Colors.white10),
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // 4. SONUÇLAR BAŞLIĞI
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    children: [
                      const Icon(Icons.manage_search, color: Colors.amber),
                      const SizedBox(width: 10),
                      Text(
                        _hasSearched ? "${_foundComponents.length} EŞLEŞME BULUNDU" : "BEKLENİYOR...",
                        style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 10),

                // 5. SONUÇ LİSTESİ
                Expanded(
                  child: _hasSearched && _foundComponents.isEmpty
                  ? Center( // Bulunamadıysa
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 50, color: Colors.white10),
                          const SizedBox(height: 10),
                          Text("Veritabanında Yok", style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: _foundComponents.length,
                      itemBuilder: (context, index) {
                        final comp = _foundComponents[index];
                        return _buildResultCard(context, comp);
                      },
                    ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Çip Bacağı Widget'ı
  Widget _buildLeg() {
    return Container(
      width: 12, height: 25,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.grey[400]!, Colors.grey[700]!]),
        borderRadius: BorderRadius.circular(2)
      ),
    );
  }

  // Sonuç Kartı
  Widget _buildResultCard(BuildContext context, Component comp) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TestScreen(component: comp)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF353A40),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            // Sol: Resim
            Container(
              width: 60, height: 60,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                'assets/packages/${comp.packageId.trim().toLowerCase()}.png',
                fit: BoxFit.contain,
                errorBuilder: (c,e,s) => const Icon(Icons.memory, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 15),
            // Orta: Bilgi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comp.id, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.blue.withValues(alpha: 0.5))),
                        child: Text(comp.category, style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.orange.withValues(alpha: 0.5))),
                        child: Text(comp.packageId, style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              ),
            ),
            // Sağ: Ok
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.amber),
          ],
        ),
      ),
    );
  }
}

// Izgara Çizici (Diğer sayfalardaki ile aynı)
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