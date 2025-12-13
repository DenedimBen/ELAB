import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';

class ResistorScreen extends StatefulWidget {
  const ResistorScreen({super.key});

  @override
  State<ResistorScreen> createState() => _ResistorScreenState();
}

class _ResistorScreenState extends State<ResistorScreen> {
  // --- DURUM DEĞİŞKENLERİ ---
  int _bandCount = 4;
  int _selectedBandIndex = 0; // Şu an hangi bandı boyuyoruz?

  // Renk Kodları (Varsayılan: 1k Ohm %5)
  // 4 Bant: [Digit1, Digit2, Multiplier, Tolerance]
  List<int> _bands = [1, 0, 2, 10]; 

  // --- RENK VERİTABANI ---
  final List<Map<String, dynamic>> _colorData = [
    {'color': Colors.black, 'name': 'Siyah', 'val': 0, 'mult': 1.0},
    {'color': const Color(0xFF795548), 'name': 'Kahve', 'val': 1, 'mult': 10.0},
    {'color': const Color(0xFFD32F2F), 'name': 'Kırmızı', 'val': 2, 'mult': 100.0},
    {'color': const Color(0xFFF57C00), 'name': 'Turuncu', 'val': 3, 'mult': 1000.0},
    {'color': const Color(0xFFFBC02D), 'name': 'Sarı', 'val': 4, 'mult': 10000.0},
    {'color': const Color(0xFF388E3C), 'name': 'Yeşil', 'val': 5, 'mult': 100000.0},
    {'color': const Color(0xFF1976D2), 'name': 'Mavi', 'val': 6, 'mult': 1000000.0},
    {'color': const Color(0xFF7B1FA2), 'name': 'Mor', 'val': 7, 'mult': 10000000.0},
    {'color': const Color(0xFF616161), 'name': 'Gri', 'val': 8, 'mult': 0.0},
    {'color': Colors.white, 'name': 'Beyaz', 'val': 9, 'mult': 0.0},
    {'color': const Color(0xFFFFD700), 'name': 'Altın', 'val': -1, 'mult': 0.1},
    {'color': const Color(0xFFC0C0C0), 'name': 'Gümüş', 'val': -2, 'mult': 0.01},
  ];

  // --- HESAPLAMA ---
  String _calculate() {
    double value = 0;
    double multiplier = 0;

    if (_bandCount == 4) {
      value = (_bands[0] * 10 + _bands[1]).toDouble();
      multiplier = _getMult(_bands[2]);
    } else {
      value = (_bands[0] * 100 + _bands[1] * 10 + _bands[2]).toDouble();
      multiplier = _getMult(_bands[3]);
    }
    return _formatOhms(value * multiplier);
  }

  double _getMult(int colorIdx) => _colorData[colorIdx]['mult'];

  String _getTolerance() {
    int idx = _bands.last;
    if (idx == 1) return "±1%";
    if (idx == 2) return "±2%";
    if (idx == 10) return "±5%";
    if (idx == 11) return "±10%";
    return "±20%";
  }

  String _formatOhms(double ohms) {
    if (ohms >= 1e9) return "${(ohms / 1e9).toStringAsFixed(2)} GΩ";
    if (ohms >= 1e6) return "${(ohms / 1e6).toStringAsFixed(2)} MΩ";
    if (ohms >= 1e3) return "${(ohms / 1e3).toStringAsFixed(2)} kΩ";
    return "${ohms.toStringAsFixed(2)} Ω";
  }

  // --- ETKİLEŞİM ---
  void _setBand(int colorIdx) {
    setState(() {
      _bands[_selectedBandIndex] = colorIdx;
      // Otomatik bir sonraki banda geç (Kullanıcı dostu)
      if (_selectedBandIndex < _bands.length - 2) {
        _selectedBandIndex++;
      }
    });
  }

  void _changeMode(int count) {
    setState(() {
      _bandCount = count;
      if (count == 5 && _bands.length == 4) _bands.insert(2, 0); // Araya siyah ekle
      else if (count == 4 && _bands.length == 5) _bands.removeAt(2);
      _selectedBandIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context)!;
    String result = _calculate();
    String tol = _getTolerance();

    return Scaffold(
      backgroundColor: const Color(0xFF1E2126), // Ana Tema Rengi
      appBar: AppBar(
        title: Text(text.toolResistorCalc, style: GoogleFonts.orbitron(color: Colors.amber, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [
          // MOD SEÇİCİ (4/5 Bant)
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                _buildModeChip(4, "4 BANT"),
                _buildModeChip(5, "5 BANT"),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // 1. DİRENÇ GÖRSELİ (BÜYÜK VE NET)
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF25282F),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // DİRENÇ ÇİZİMİ
                  SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: CleanResistorPainter(bands: _bands, colors: _colorData.map((e) => e['color'] as Color).toList()),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // SONUÇ METNİ
                  Column(
                    children: [
                      Text(text.commonResult, style: const TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 2)),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(result, style: GoogleFonts.robotoMono(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 10),
                          Text(tol, style: GoogleFonts.robotoMono(fontSize: 24, color: Colors.amber)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 2. BANT SEÇİM SEKMELERİ (TABS)
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _bands.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedBandIndex == index;
                String label = "${index + 1}. Bant";
                if (index == _bands.length - 1) label = "Tolerans";
                else if (index == _bands.length - 2) label = "Çarpan";

                return GestureDetector(
                  onTap: () => setState(() => _selectedBandIndex = index),
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(right: 15),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.amber : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: isSelected ? Colors.amber : Colors.grey, width: 1.5),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // 3. RENK KLAVYESİ (İSİMLİ VE BÜYÜK)
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: Color(0xFF181A1F),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // Yan yana 4 tane
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8, // Kutuyu biraz uzattık ki yazı sığsın
                ),
                itemCount: _colorData.length,
                itemBuilder: (context, index) {
                  final colorInfo = _colorData[index];
                  bool isDisabled = _isColorDisabled(index);
                  bool isSelected = _bands[_selectedBandIndex] == index;
                  
                  return GestureDetector(
                    onTap: isDisabled ? null : () => _setBand(index),
                    child: Opacity(
                      opacity: isDisabled ? 0.3 : 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF25282F), // Her kutunun kendi arka planı olsun
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isSelected ? Colors.amber : Colors.transparent, 
                            width: 2
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // RENK DAİRESİ
                            Container(
                              width: 35, 
                              height: 35,
                              decoration: BoxDecoration(
                                color: colorInfo['color'],
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24, width: 1),
                                boxShadow: [
                                  if (!isDisabled) 
                                    BoxShadow(color: (colorInfo['color'] as Color).withValues(alpha: 0.5), blurRadius: 8)
                                ]
                              ),
                              child: isSelected 
                                ? const Icon(Icons.check, color: Colors.white, size: 20) // Renk koyuysa ikon beyaz
                                : null,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // RENK İSMİ
                            Text(
                              colorInfo['name'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey,
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip(int count, String label) {
    bool active = _bandCount == count;
    return GestureDetector(
      onTap: () => _changeMode(count),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.amber : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: active ? Colors.black : Colors.white)),
      ),
    );
  }

  bool _isColorDisabled(int idx) {
    // Tolerans bandında sadece belirli renkler olur
    if (_selectedBandIndex == _bands.length - 1) {
      return ![1, 2, 5, 6, 7, 8, 10, 11].contains(idx);
    }
    // 1. Bant Siyah olamaz
    if (_selectedBandIndex == 0 && idx == 0) return true;
    
    // Altın/Gümüş sadece çarpan ve toleransta olur
    if (_selectedBandIndex < _bands.length - 2 && idx >= 10) return true;
    
    return false;
  }
}

// --- TEMİZ VE NET DİRENÇ RESSAMI (DÜZELTİLMİŞ) ---
class CleanResistorPainter extends CustomPainter {
  final List<int> bands;
  final List<Color> colors;
  CleanResistorPainter({required this.bands, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    double w = size.width;
    double h = size.height;
    
    // 1. TEL (Wire) - En alta çiziyoruz
    paint.color = Colors.grey;
    paint.strokeWidth = 8;
    canvas.drawLine(Offset(0, h/2), Offset(w, h/2), paint);

    // 2. GÖVDE (Body)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w/2, h/2), width: w * 0.8, height: h * 0.65), // Gövdeyi biraz genişlettim
      const Radius.circular(25), // Köşeleri biraz daha yumuşattım
    );
    
    // 3D Bej Efekti
    paint.shader = const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFFE0C097), Color(0xFFBCAAA4), Color(0xFF8D6E63)] 
    ).createShader(bodyRect.outerRect);
    
    canvas.drawRRect(bodyRect, paint);
    paint.shader = null; 

    // --- MASKELEME (CLIPPING) ---
    // Burası çok önemli: Bantları çizmeden önce alanı gövdeyle sınırlıyoruz.
    // Böylece bantlar asla gövdeden dışarı taşamaz.
    canvas.save(); 
    canvas.clipRRect(bodyRect); 

    // 3. BANTLAR
    // Hesaplama: Gövdenin solundan başla, sağa doğru git
    double bodyWidth = bodyRect.width;
    double startX = (w - bodyWidth) / 2; // Gövdenin sol kenarı
    
    // Bantları gövdenin içine orantılı dağıt
    // (bodyWidth * 0.2) diyerek kenarlardan %20 boşluk bıraktık
    double drawingArea = bodyWidth * 0.7; 
    double marginLeft = bodyWidth * 0.15; 
    double spacing = drawingArea / (bands.length - 1); 

    for (int i = 0; i < bands.length; i++) {
      paint.color = colors[bands[i]];
      
      double x = startX + marginLeft + (i * spacing);
      
      // Tolerans bandı (Son bant) her zaman biraz daha ayrık ve sağda durmalı
      if (i == bands.length - 1) {
         x = startX + bodyWidth - (bodyWidth * 0.15); // Sağ kenardan %15 içeride
      }

      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, h/2), width: 12, height: h * 0.8), // Yükseklik gövdeden büyük olsa bile clip sayesinde kesilir
        paint
      );
    }
    
    canvas.restore(); // Maskelemeyi bitir
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}