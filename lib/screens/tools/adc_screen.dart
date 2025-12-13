import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class AdcScreen extends StatefulWidget {
  const AdcScreen({super.key});

  @override
  State<AdcScreen> createState() => _AdcScreenState();
}

class _AdcScreenState extends State<AdcScreen> with SingleTickerProviderStateMixin {
  // --- DURUM DEĞİŞKENLERİ ---
  int calcMode = 0; // 0: Voltajdan ADC'ye, 1: ADC'den Voltaja
  
  // Varsayılanlar (Arduino Uno standardı)
  double vRef = 5.0;      // Referans Voltajı
  int bitDepth = 10;      // Bit Derinliği (8, 10, 12, 16...)
  
  final TextEditingController _inputController = TextEditingController(text: "2.5");
  
  // Sonuçlar
  String mainResult = "---";
  String hexResult = "0x00";
  String resLSB = "---";    // Çözünürlük (Volt/Step)
  String resSteps = "---";  // Toplam Seviye
  String resError = "---";  // Kuantalama Hatası
  
  // Animasyon
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _calculate();
  }

  @override
  void dispose() {
    _animController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  // --- HESAPLAMA MOTORU ---
  void _calculate() {
    double input = double.tryParse(_inputController.text) ?? 0;
    
    // 1. Temel Parametreler
    int maxSteps = pow(2, bitDepth).toInt() - 1; // Örn: 10bit -> 1023
    double lsb = vRef / maxSteps; // Step Size (Volt)
    
    double calculatedVal = 0;
    
    if (calcMode == 0) {
      // --- VOLTAJ -> ADC ---
      if (input > vRef) input = vRef; // Sınırla
      
      calculatedVal = (input / vRef) * maxSteps;
      int adcInt = calculatedVal.round();
      
      setState(() {
        mainResult = "$adcInt";
        hexResult = "0x${adcInt.toRadixString(16).toUpperCase()}";
      });
    } else {
      // --- ADC -> VOLTAJ ---
      if (input > maxSteps) input = maxSteps.toDouble();
      
      calculatedVal = (input / maxSteps) * vRef;
      
      setState(() {
        mainResult = "${calculatedVal.toStringAsFixed(4)} V";
        hexResult = "---";
      });
    }

    // Detaylar
    setState(() {
      resLSB = "${(lsb * 1000).toStringAsFixed(2)} mV";
      resSteps = "${maxSteps + 1} Seviye"; // 0 dahil
      resError = "± ${(lsb * 1000 / 2).toStringAsFixed(3)} mV"; // LSB/2
    });
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor = calcMode == 0 ? Colors.cyanAccent : Colors.orangeAccent;

    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      body: Stack(
        children: [
          // 1. CANLI ÖRNEKLEME ANİMASYONU
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: SamplingPainter(
                  animValue: _animController.value,
                  bitDepth: bitDepth,
                  color: themeColor,
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
                      Text("ADC ÇEVİRİCİ", style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 2. MOD SEÇİCİ
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white10)),
                    child: Row(
                      children: [
                        _buildModeBtn("VOLTAJ ➞ ADC", 0, Colors.cyanAccent),
                        _buildModeBtn("ADC ➞ VOLTAJ", 1, Colors.orangeAccent),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 3. BÜYÜK SONUÇ EKRANI
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF353A40),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: themeColor.withValues(alpha: 0.5)),
                      boxShadow: [BoxShadow(color: themeColor.withValues(alpha: 0.2), blurRadius: 20)]
                    ),
                    child: Column(
                      children: [
                        Text(calcMode == 0 ? "DİJİTAL ÇIKIŞ (DEC)" : "ANALOG VOLTAJ", style: TextStyle(color: Colors.grey[400], fontSize: 10, letterSpacing: 2)),
                        Text(
                          mainResult,
                          style: GoogleFonts.shareTechMono(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        if (calcMode == 0) // Sadece ADC modunda Hex göster
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(5)),
                            child: Text("HEX: $hexResult", style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          )
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 4. AYARLAR VE GİRİŞ
                  // Referans Voltajı ve Bit Derinliği
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown("Vref (Referans)", vRef, [3.3, 5.0, 12.0, 24.0], (val) { setState(() => vRef = val); _calculate(); }, "V"),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildDropdown("Bit (Çözünürlük)", bitDepth.toDouble(), [8, 10, 12, 16, 24], (val) { setState(() => bitDepth = val.toInt()); _calculate(); }, "Bit"),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),

                  // Giriş Değeri
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(color: const Color(0xFF22252A), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
                    child: TextField(
                      controller: _inputController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: calcMode == 0 ? "Giriş Voltajı (V)" : "ADC Değeri (0 - ${pow(2, bitDepth).toInt()-1})",
                        labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                        border: InputBorder.none
                      ),
                      onChanged: (v) => _calculate(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 5. DETAYLI BİLGİ TABLOSU
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
                    child: Column(
                      children: [
                        _buildDetailRow("Çözünürlük (LSB)", resLSB, Icons.straighten),
                        const Divider(color: Colors.white10),
                        _buildDetailRow("Kuantalama Seviyesi", resSteps, Icons.layers),
                        const Divider(color: Colors.white10),
                        _buildDetailRow("Teorik Hata", resError, Icons.error_outline),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text("LSB = Vref / (2^n - 1)", style: GoogleFonts.shareTechMono(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeBtn(String title, int val, Color color) {
    bool isSelected = calcMode == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { calcMode = val; _inputController.clear(); _calculate(); }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: isSelected ? color : Colors.transparent),
          ),
          child: Text(title, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? color : Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, double value, List<num> items, Function(double) onChanged, String unit) {
    // Listeyi açıkça double listesine çeviriyoruz
    List<double> doubleItems = items.map((e) => e.toDouble()).toList();
    
    // Değer listede yoksa ilk elemanı seç (Güvenlik)
    double safeValue = doubleItems.contains(value) ? value : doubleItems.first;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          DropdownButtonHideUnderline(
            child: DropdownButton<double>(
              value: safeValue, // Artık kesinlikle double
              dropdownColor: const Color(0xFF353A40),
              isDense: true,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              items: doubleItems.map((double item) => DropdownMenuItem<double>(
                value: item,
                child: Text("${item % 1 == 0 ? item.toInt() : item} $unit"), // Tam sayıysa küsuratsız göster
              )).toList(),
              onChanged: (v) => onChanged(v!),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 16),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}

// --- SİNYAL ÖRNEKLEME GÖRSELİ (SAMPLING) ---
class SamplingPainter extends CustomPainter {
  final double animValue;
  final int bitDepth;
  final Color color;
  SamplingPainter({required this.animValue, required this.bitDepth, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final analogPaint = Paint()..color = Colors.white10..strokeWidth = 2..style = PaintingStyle.stroke;
    final digitalPaint = Paint()..color = color.withValues(alpha: 0.3)..strokeWidth = 2..style = PaintingStyle.stroke;
    
    // Görsel basamak sayısı (Gerçek bit depth çok yüksek olduğu için görseli sınırlıyoruz)
    // 8-bit olsa bile ekranda 256 çizgi çizmek kötü görünür, o yüzden simüle ediyoruz.
    double visualSteps = bitDepth > 5 ? 16.0 : pow(2, bitDepth).toDouble();
    double stepHeight = size.height / visualSteps;

    Path analogPath = Path();
    Path digitalPath = Path();
    
    double centerY = size.height / 2;
    
    for (double x = 0; x <= size.width; x+=2) {
      // Analog Sinyal (Sinüs)
      double t = (x / size.width) * 4 * pi + (animValue * 2 * pi);
      double yAnalog = centerY + (sin(t) * size.height * 0.4);
      
      // Dijital Örnekleme (Merdiven Etkisi - Quantization)
      // Y değerini en yakın basamağa yuvarla
      double yDigital = (yAnalog / stepHeight).round() * stepHeight;

      if (x==0) {
        analogPath.moveTo(x, yAnalog);
        digitalPath.moveTo(x, yDigital);
      } else {
        analogPath.lineTo(x, yAnalog);
        digitalPath.lineTo(x, yDigital);
      }
    }
    
    canvas.drawPath(analogPath, analogPaint);
    canvas.drawPath(digitalPath, digitalPaint); // Basamaklı çizgi

    // Örnekleme Noktaları (Sampling Points)
    // Sinyal üzerinde belirli aralıklarla noktalar koyarak "Sample" alındığını gösterelim
    final dotPaint = Paint()..color = color..style = PaintingStyle.fill;
    for (double x = 0; x <= size.width; x += 40) {
       double t = (x / size.width) * 4 * pi + (animValue * 2 * pi);
       double y = centerY + (sin(t) * size.height * 0.4);
       double yDig = (y / stepHeight).round() * stepHeight;
       
       // Dikey örnekleme çizgisi
       canvas.drawLine(Offset(x, y), Offset(x, yDig), Paint()..color = color.withValues(alpha: 0.5)..strokeWidth=1);
       canvas.drawCircle(Offset(x, yDig), 3, dotPaint);
    }
  }
  @override
  bool shouldRepaint(covariant SamplingPainter oldDelegate) => true;
}
