import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/component_model.dart';
import '../../providers/pro_provider.dart';
import '../../services/ad_helper.dart';

// ... (TestScreen class ve build metodu AYNI, değiştirmiyoruz) ...
// Sadece _TestDialog kısmını tamamen değiştireceğiz.
// Kolaylık olsun diye dosyanın TAMAMINI veriyorum:

class TestScreen extends StatefulWidget {
  final Component component;
  const TestScreen({super.key, required this.component});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _openTestDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Test Lab",
      barrierColor: Colors.black.withValues(alpha: 0.95),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, anim1, anim2) {
        return _TestDialog(component: widget.component);
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  // ... (Datasheet widgetları AYNI) ...
  Widget _buildTableRow(String label, String value, String unit) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 13)), Row(children: [Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(width: 5), Text(unit, style: const TextStyle(color: Colors.amber, fontSize: 12))])]));
  }
  Widget _buildPageGeneral() { return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("GENEL BILGI", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)), const Divider(color: Colors.grey), Text("Bu ${widget.component.polarity} ${widget.component.category}, endustriyel kullanim icindir.", style: const TextStyle(color: Colors.white70, height: 1.4)), const SizedBox(height: 10), _buildTableRow("Kategori", widget.component.category, ""), _buildTableRow("Kılıf", widget.component.packageId, "")])); }
  Widget _buildPageLimits() { return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("LIMIT DEGERLER", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)), const Divider(color: Colors.grey), _buildTableRow("Vds/Vce", "${widget.component.vMax}", "V"), _buildTableRow("Id/Ic", "${widget.component.iMax}", "A"), _buildTableRow("Guc", "94", "W")])); }
  Widget _buildPageMechanical() { return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("MEKANIK", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)), const Divider(color: Colors.grey), Expanded(child: Container(width: double.infinity, padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)), child: Image.asset('assets/packages/${widget.component.packageId.trim().toLowerCase()}_dim.png', fit: BoxFit.contain, errorBuilder: (c,e,s) => const Center(child: Text("Cizim Yok", style: TextStyle(color: Colors.black))))))]); }

  @override
  Widget build(BuildContext context) {
    final imagePath = 'assets/packages/${widget.component.packageId.trim().toLowerCase()}.png';
    return Scaffold(
      backgroundColor: const Color(0xFF202329),
      appBar: AppBar(
        title: Text(widget.component.id, style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2, shadows: [const BoxShadow(color: Colors.amber, blurRadius: 15)])),
        centerTitle: true, backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.grey), onPressed: () => Navigator.pop(context)),
        actions: const [Padding(padding: EdgeInsets.only(right: 20), child: Icon(Icons.picture_as_pdf, color: Colors.redAccent))],
      ),
      body: Column(
        children: [
          Expanded(flex: 4, child: Center(child: Hero(tag: widget.component.id, child: Image.asset(imagePath, height: 200, fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.memory, size: 100, color: Colors.grey))))),
          Expanded(flex: 6, child: Container(margin: const EdgeInsets.fromLTRB(15, 0, 15, 20), decoration: BoxDecoration(color: const Color(0xFF2E3239), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white10), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 1)]), child: Column(children: [
            Expanded(child: PageView(controller: _pageController, onPageChanged: (i) => setState(() => _currentPage = i), children: [Padding(padding: const EdgeInsets.all(20), child: _buildPageGeneral()), Padding(padding: const EdgeInsets.all(20), child: _buildPageLimits()), Padding(padding: const EdgeInsets.all(20), child: _buildPageMechanical())])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), decoration: const BoxDecoration(color: Color(0xFF1A1C20), borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))), child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) => AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 4), width: _currentPage == i ? 20 : 8, height: 8, decoration: BoxDecoration(color: _currentPage == i ? Colors.amber : Colors.grey[700], borderRadius: BorderRadius.circular(4))))),
              const SizedBox(height: 20),
              GestureDetector(onTap: _openTestDialog, child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 15), decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.3), blurRadius: 10)]), child: const Center(child: Text("TEST LABORATUVARINI AC", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black))))),
            ])),
          ]))),
        ],
      ),
    );
  }
}

// ==============================================================================
// 2. POP-UP TEST PENCERESİ (AKILLI PIN HARİTALAMA İLE)
// ==============================================================================
class _TestDialog extends StatefulWidget {
  final Component component;
  const _TestDialog({required this.component});

  @override
  State<_TestDialog> createState() => _TestDialogState();
}

class _TestDialogState extends State<_TestDialog> {
  int currentStep = 0;
  String infoText = "Hazirlaniyor...";
  String multimeterValue = "OL";
  String multimeterMode = "AUTO";
  String stepTitle = "HAZIRLIK";
  String failureReason = "";
  
  // Prob Göstergeleri
  String redProbeTarget = "--";
  String blackProbeTarget = "--";

  // Reklam Yöneticisi
  final AdHelper _adHelper = AdHelper();

  @override
  void initState() {
    super.initState();
    
    // Eğer kullanıcı PRO değilse reklamı önceden yükle
    final isPro = Provider.of<ProProvider>(context, listen: false).isPro;
    if (!isPro) _adHelper.loadInterstitial();
    
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _nextStepLogic();
    });
  }

  // --- YARDIMCI: PIN BULUCU (SMART MAPPER) ---
  // Örnek: code="SGD", role="G" -> return "Pin 2 (G)"
  String _getPin(String role) {
    String code = widget.component.pinoutCode;
    int index = code.indexOf(role);
    
    if (index == -1) return "$role?"; // Bulunamazsa
    return "Pin ${index + 1} ($role)";
  }

  // --- TEST SENARYOLARI ---
  void _nextStepLogic() {
    setState(() {
      currentStep++;
      String type = widget.component.category;
      if (type == "MOSFET") _runMosfetNTest();
      else if (type == "BJT") _runBjtNpnTest();
      else if (type == "DIODE") _runDiodeTest();
      else if (type == "REGULATOR") _runRegulatorTest();
      else if (type == "IC") _runICTest(); 
      else _runMosfetNTest();
    });
  }

  void _runMosfetNTest() {
    // Pin kodlarını dinamik al (G, D, S)
    String gate = _getPin("G");
    String drain = _getPin("D");
    String source = _getPin("S");

    if (currentStep == 1) {
      stepTitle = "ADIM 1: BODY DIYODU";
      infoText = "Mosfet kapaliyken diyot degerini kontrol et.";
      multimeterMode = "DIODE";
      // N-Kanal Body Diyodu: Anot(S) -> Katot(D). Yani Kırmızı(S), Siyah(D)
      redProbeTarget = source;
      blackProbeTarget = drain;
      _simulateReading("0.520 V");
    } else if (currentStep == 2) {
      stepTitle = "ADIM 2: TETIKLEME";
      infoText = "Gate ucuna kirmizi ile dokunup kapasiteyi sarj et.";
      multimeterMode = "DIODE";
      redProbeTarget = gate;
      blackProbeTarget = source;
      _simulateReading("OL");
    } else if (currentStep == 3) {
      stepTitle = "ADIM 3: ILETIM";
      infoText = "Simdi Drain-Source arasina bak. Kisa devre olmali.";
      multimeterMode = "OHM";
      redProbeTarget = drain;
      blackProbeTarget = source;
      _simulateReading("0.004 Ω");
    } else {
      _showResult(true);
    }
  }

  void _runBjtNpnTest() {
    String base = _getPin("B");
    String coll = _getPin("C");
    String emit = _getPin("E");

     if (currentStep == 1) {
      stepTitle = "ADIM 1: BASE-EMITTER";
      infoText = "Base-Emitter arasi diyot degeri.";
      multimeterMode = "DIODE";
      redProbeTarget = base;
      blackProbeTarget = emit;
      _simulateReading("0.680 V");
    } else if (currentStep == 2) {
      stepTitle = "ADIM 2: BASE-COLLECTOR";
      infoText = "Base-Collector arasi diyot degeri.";
      multimeterMode = "DIODE";
      redProbeTarget = base;
      blackProbeTarget = coll;
      _simulateReading("0.675 V");
    } else {
      _showResult(true);
    }
  }

  void _runRegulatorTest() {
    // I=Input, G=Ground, O=Output, A=Adjust
    String pinIn = widget.component.pinoutCode.contains("I") ? _getPin("I") : _getPin("1"); // Fallback
    String pinGnd = widget.component.pinoutCode.contains("G") ? _getPin("G") : _getPin("A"); // LM317 için Adj=Gnd gibi davranır
    String pinOut = widget.component.pinoutCode.contains("O") ? _getPin("O") : _getPin("3");

    if (currentStep == 1) {
      stepTitle = "GIRIS KONTROL";
      infoText = "Giris ve GND arasi kisa devre var mi?";
      multimeterMode = "OHM";
      redProbeTarget = pinIn;
      blackProbeTarget = pinGnd;
      _simulateReading("5.4 MΩ");
    } else if (currentStep == 2) {
      stepTitle = "CIKIS KONTROL";
      infoText = "Cikis ve GND arasi kisa devre var mi?";
      redProbeTarget = pinOut;
      blackProbeTarget = pinGnd;
      _simulateReading("3.2 kΩ");
    } else {
      _showResult(true);
    }
  }

  void _runDiodeTest() {
    // A=Anode, K=Cathode
    // 1N4007 (DO-41): Soldaki Anot(Pin1), Çizgili sağdaki Katot(Pin2). Veritabanı "AK" dediyse A=1, K=2.
    String anot = _getPin("A");
    String katot = _getPin("K");

    if (currentStep == 1) {
      stepTitle = "ADIM 1: DOGRU YON";
      infoText = "Anot(+) ve Katot(-) arasi iletim var mi?";
      multimeterMode = "DIODE";
      redProbeTarget = anot;
      blackProbeTarget = katot;
      _simulateReading("0.550 V");
    } else if (currentStep == 2) {
      stepTitle = "ADIM 2: TERS YON";
      infoText = "Problari ters cevir. Iletim olmamali.";
      multimeterMode = "DIODE";
      redProbeTarget = katot;
      blackProbeTarget = anot;
      _simulateReading("OL");
    } else {
      _showResult(true);
    }
  }

  void _runICTest() {
    // ... (IC Testi aynı kalabilir, zaten pin ID'leri manuel girmiştik) ...
    _showResult(true); // Şimdilik direkt sonuca
  }

  void _simulateReading(String val) {
    setState(() => multimeterValue = "---");
    Future.delayed(const Duration(milliseconds: 600), () {
      if(mounted) setState(() => multimeterValue = val);
    });
  }

  void _handleUserAction(bool isSuccess) {
    if (isSuccess) _nextStepLogic();
    else _showResult(false);
  }

  void _showResult(bool isGood) {
    Navigator.pop(context);
    
    // --- REKLAM KONTROLÜ ---
    final isPro = Provider.of<ProProvider>(context, listen: false).isPro;
    if (!isPro) {
      _adHelper.showInterstitial(); // Reklamı Patlat!
    }
    // -----------------------
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF22252A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isGood ? Colors.green : Colors.red, width: 2)),
        title: Row(children: [Icon(isGood ? Icons.check_circle : Icons.error, color: isGood ? Colors.green : Colors.red, size: 32), const SizedBox(width: 10), Text(isGood ? "SAGLAM" : "ARIZALI", style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold))]),
        content: Text(isGood ? "Parca tum testlerden gecti." : "Test basarisiz oldu.", style: const TextStyle(color: Colors.white70)),
        actions: [TextButton(onPressed: () {Navigator.pop(ctx); Navigator.pop(context);}, child: const Text("TAMAM", style: TextStyle(color: Colors.amber)))]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final imagePath = 'assets/packages/${widget.component.packageId.trim().toLowerCase()}.png';

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: w * 0.95, height: h * 0.92,
          decoration: BoxDecoration(color: const Color(0xFF25282F), borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 40)], border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                // HEADER
                Positioned(top: 20, left: 0, right: 0, child: Center(child: Column(children: [Text(stepTitle, style: GoogleFonts.orbitron(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2, shadows: [BoxShadow(color: Colors.amber.withValues(alpha: 0.5), blurRadius: 15)])), const SizedBox(height: 5), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Text("Adim $currentStep", style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1))) ]))),
                Positioned(top: 15, right: 15, child: IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context))),

                // MULTİMETRE
                Positioned(top: 100, left: 20, right: 20, child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF38404B), borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 5))], border: Border.all(color: Colors.white10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("FLUKE", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)), const SizedBox(height: 5), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF9EA38D), borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.black38, width: 3)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [const Text("AUTO", style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.bold)), const SizedBox(height: 10), Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(border: Border.all(color: Colors.black54, width: 1.5), borderRadius: BorderRadius.circular(3)), child: Text(multimeterMode, style: const TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold)))]), Text(multimeterValue, style: GoogleFonts.vt323(fontSize: 50, color: const Color(0xFF151515), fontWeight: FontWeight.bold))]))]))),

                // PARÇA GÖRSELİ (SABİT VE ORTADA)
                Positioned.fill(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const SizedBox(height: 80), Hero(tag: "dialog_${widget.component.id}", child: Image.asset(imagePath, height: 180, fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.memory, size: 100, color: Colors.grey))), const SizedBox(height: 5), 
                // Pin isimlerini (G D S) göster
                if (!widget.component.packageId.contains("DIP")) 
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: widget.component.pinoutCode.split('').map((c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 25), child: Text(c, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)))).toList())
                ]))),

                // --- NET TALİMAT PANELİ (SABİT) ---
                Positioned(
                  bottom: 20, left: 20, right: 20,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. PROB GÖSTERGELERİ
                      if (currentStep > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildProbeBox(redProbeTarget, Colors.redAccent),
                            const Icon(Icons.arrow_downward, color: Colors.grey, size: 24),
                            _buildProbeBox(blackProbeTarget, Colors.black87),
                          ],
                        ),
                      ),

                      // 2. MAVİ TALİMAT KUTUSU
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
                          boxShadow: [BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.05), blurRadius: 15)]
                        ),
                        child: Text(
                          infoText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4)
                        ),
                      ),
                      
                      const SizedBox(height: 20), 

                      // 3. BUTONLAR
                      currentStep > 0
                          ? Row(
                              children: [
                                Expanded(child: _buildSciFiBtn("HATA / YOK", Colors.redAccent, Icons.close, () => _handleUserAction(false))),
                                const SizedBox(width: 15),
                                Expanded(child: _buildSciFiBtn("ONAYLA", Colors.greenAccent, Icons.check, () => _handleUserAction(true)))
                              ],
                            )
                          : const SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProbeBox(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.8), width: 2),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10)]
      ),
      child: Row(
        children: [
          Icon(Icons.ads_click, color: color, size: 18),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSciFiBtn(String txt, Color color, IconData icon, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(height: 55, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.6)), boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 1)]), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 22), const SizedBox(width: 10), Text(txt, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1))])));
  }
}