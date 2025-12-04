import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class SeriesParallelScreen extends StatefulWidget {
  const SeriesParallelScreen({super.key});

  @override
  State<SeriesParallelScreen> createState() => _SeriesParallelScreenState();
}

class _SeriesParallelScreenState extends State<SeriesParallelScreen> with SingleTickerProviderStateMixin {
  // --- DURUM DEĞİŞKENLERİ ---
  bool isSeries = true; // true: Seri, false: Paralel
  
  // Direnç Listesi (Değer ve Birim)
  final List<ResistorItem> resistors = [];
  
  // Kontrolcüler
  final TextEditingController _valController = TextEditingController();
  String _currentUnit = "Ω"; // Varsayılan birim

  // Animasyon
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    
    // Başlangıç için örnek veriler
    _addResistor(100, "Ω");
    _addResistor(10, "kΩ");
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // --- MANTIK ---
  void _addResistor(double val, String unit) {
    setState(() {
      resistors.add(ResistorItem(value: val, unit: unit));
    });
  }

  void _addNewFromInput() {
    if (_valController.text.isEmpty) return;
    double? val = double.tryParse(_valController.text.replaceAll(',', '.'));
    if (val != null && val > 0) {
      _addResistor(val, _currentUnit);
      _valController.clear();
    }
  }

  String _calculateTotal() {
    if (resistors.isEmpty) return "0.00 Ω";

    double total = 0;
    
    // Tüm değerleri Ohm cinsine çevirerek hesapla
    List<double> ohmValues = resistors.map((r) {
      if (r.unit == "kΩ") return r.value * 1000;
      if (r.unit == "MΩ") return r.value * 1000000;
      return r.value;
    }).toList();

    if (isSeries) {
      // SERİ: R_t = R1 + R2 + ...
      for (var r in ohmValues) total += r;
    } else {
      // PARALEL: 1/R_t = 1/R1 + 1/R2 + ...
      double denominator = 0;
      for (var r in ohmValues) {
        if (r != 0) denominator += (1 / r);
      }
      if (denominator != 0) total = 1 / denominator;
    }

    // Sonucu formatla
    if (total >= 1000000) return "${(total / 1000000).toStringAsFixed(3)} MΩ";
    if (total >= 1000) return "${(total / 1000).toStringAsFixed(3)} kΩ";
    return "${total.toStringAsFixed(2)} Ω";
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor = isSeries ? Colors.orangeAccent : Colors.cyanAccent;

    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      body: Stack(
        children: [
          // 1. CANLI ARKA PLAN (AKIŞKAN)
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: FlowBackgroundPainter(_animController.value, isSeries, themeColor),
              );
            },
          ),

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
                      Text("SERİ / PARALEL", style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
                    ],
                  ),
                ),

                // 2. MOD SEÇİCİ
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white10)),
                  child: Row(
                    children: [
                      Expanded(child: _buildModeBtn("SERİ DEVRE", true, Colors.orangeAccent)),
                      Expanded(child: _buildModeBtn("PARALEL DEVRE", false, Colors.cyanAccent)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3. SONUÇ EKRANI (BÜYÜK)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF353A40),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: themeColor.withValues(alpha: 0.5)),
                    boxShadow: [BoxShadow(color: themeColor.withValues(alpha: 0.2), blurRadius: 20)]
                  ),
                  child: Column(
                    children: [
                      Text("TOPLAM EŞDEĞER DİRENÇ (Req)", style: TextStyle(color: Colors.grey[400], fontSize: 10, letterSpacing: 2)),
                      const SizedBox(height: 5),
                      Text(
                        _calculateTotal(),
                        style: GoogleFonts.shareTechMono(fontSize: 45, color: Colors.white, fontWeight: FontWeight.bold, shadows: [BoxShadow(color: themeColor.withValues(alpha: 0.5), blurRadius: 15)]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 4. EKLEME PANELİ
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(color: const Color(0xFF22252A), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white24)),
                          child: TextField(
                            controller: _valController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                            decoration: const InputDecoration(hintText: "Değer Gir...", hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Birim Seçici
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(15)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _currentUnit,
                            dropdownColor: const Color(0xFF353A40),
                            icon: Icon(Icons.arrow_drop_down, color: themeColor),
                            style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
                            items: ['Ω', 'kΩ', 'MΩ'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                            onChanged: (v) => setState(() => _currentUnit = v!),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Ekle Butonu
                      FloatingActionButton(
                        onPressed: _addNewFromInput,
                        mini: true,
                        backgroundColor: themeColor,
                        child: const Icon(Icons.add, color: Colors.black),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                
                // Liste Başlığı
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("EKLENEN DİRENÇLER (${resistors.length})", style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold)),
                      if (resistors.isNotEmpty)
                        GestureDetector(
                          onTap: () => setState(() => resistors.clear()),
                          child: const Text("Tümünü Sil", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                        )
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 5. SÜRÜKLE BIRAK LİSTE (REORDERABLE LIST)
                Expanded(
                  child: ReorderableListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) newIndex -= 1;
                        final item = resistors.removeAt(oldIndex);
                        resistors.insert(newIndex, item);
                      });
                    },
                    children: [
                      for (int index = 0; index < resistors.length; index++)
                        Dismissible( // Kaydırıp silme özelliği
                          key: ValueKey(resistors[index]),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            setState(() {
                              resistors.removeAt(index);
                            });
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.redAccent.withValues(alpha: 0.2),
                            child: const Icon(Icons.delete, color: Colors.redAccent),
                          ),
                          child: Container(
                            key: ValueKey(resistors[index]),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white10)
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.drag_handle, color: Colors.grey), // Tutamaç
                                const SizedBox(width: 15),
                                Container( // Direnç İkonu
                                  width: 40, height: 15,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0C9A6),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.grey)
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  "${resistors[index].value} ${resistors[index].unit}",
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // 6. BİLGİ KUTUSU
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  color: Colors.black26,
                  child: Text(
                    isSeries 
                      ? "BİLGİ: Seri devrede dirençler toplanır (R1+R2...). Akım her yerde aynıdır."
                      : "BİLGİ: Paralel devrede eşdeğer direnç düşer (1/Rt...). Voltaj her kolda aynıdır.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeBtn(String title, bool modeVal, Color color) {
    bool isSelected = isSeries == modeVal;
    return GestureDetector(
      onTap: () => setState(() => isSeries = modeVal),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(title, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.black : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }
}

// Veri Modeli
class ResistorItem {
  final double value;
  final String unit;
  ResistorItem({required this.value, required this.unit});
}

// Arka Plan Animasyonu (Seri vs Paralel Akış)
class FlowBackgroundPainter extends CustomPainter {
  final double animationValue;
  final bool isSeries;
  final Color color;
  
  FlowBackgroundPainter(this.animationValue, this.isSeries, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double step = 60.0;
    double offset = animationValue * step;

    if (isSeries) {
      // SERİ: Tek çizgi halinde aşağı akan dalga
      double center = size.width / 2;
      for (double y = -step; y < size.height; y += step) {
        double drawY = y + offset;
        canvas.drawCircle(Offset(center, drawY), 10, paint); // Enerji paketleri
        canvas.drawLine(Offset(center, 0), Offset(center, size.height), paint..strokeWidth=1);
      }
    } else {
      // PARALEL: Yan yana inen çizgiler
      for (double x = step; x < size.width; x += step) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint..strokeWidth=1);
        
        for (double y = -step; y < size.height; y += step * 2) {
          double drawY = y + offset;
          canvas.drawCircle(Offset(x, drawY), 5, paint);
        }
      }
    }
  }
  @override
  bool shouldRepaint(covariant FlowBackgroundPainter oldDelegate) => true;
}