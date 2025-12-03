import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import removed to revert to previous prompt
import 'package:firebase_auth/firebase_auth.dart'; // Giriş kontrolü
import '../../models/component_model.dart';
import '../../services/firestore_service.dart'; // Veritabanı servisi

// ==============================================================================
// 1. ANA EKRAN: DATASHEET GÖRÜNTÜLEYİCİ
// ==============================================================================
class TestScreen extends StatefulWidget {
  final Component component;
  const TestScreen({super.key, required this.component});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final FirestoreService _dbService = FirestoreService(); // Servisi başlat

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

  // --- DATASHEET WIDGETLARI ---
  Widget _buildTableRow(String label, String value, String unit) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 13)), Row(children: [Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(width: 5), Text(unit, style: const TextStyle(color: Colors.amber, fontSize: 12))])]));
  }
  Widget _buildPageGeneral() { return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("GENEL BILGI", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)), const Divider(color: Colors.grey), Text("Bu ${widget.component.polarity} ${widget.component.category}, endustriyel uygulamalar icin tasarlanmistir.", style: const TextStyle(color: Colors.white70, height: 1.4)), const SizedBox(height: 10), _buildTableRow("Kategori", widget.component.category, ""), _buildTableRow("Kılıf", widget.component.packageId, "")])); }
  Widget _buildPageLimits() { return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("LIMIT DEGERLER", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)), const Divider(color: Colors.grey), _buildTableRow("Vds Max", "${widget.component.vMax}", "V"), _buildTableRow("Id Max", "${widget.component.iMax}", "A"), _buildTableRow("Guc", "94", "W")])); }
  Widget _buildPageMechanical() { return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("MEKANIK", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)), const Divider(color: Colors.grey), Expanded(child: Container(width: double.infinity, padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)), child: Image.asset('assets/packages/${widget.component.packageId.trim().toLowerCase()}_dim.png', fit: BoxFit.contain, errorBuilder: (c,e,s) => const Center(child: Text("Cizim Yok", style: TextStyle(color: Colors.black))))))]); }

  @override
  Widget build(BuildContext context) {
    final imagePath = 'assets/packages/${widget.component.packageId.trim().toLowerCase()}.png';
    final user = FirebaseAuth.instance.currentUser; // Kullanıcı var mı?
    
    return Scaffold(
      backgroundColor: const Color(0xFF202329),
      appBar: AppBar(
        title: Text(widget.component.id, style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2, shadows: [const BoxShadow(color: Colors.amber, blurRadius: 15)])),
        centerTitle: true, backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.grey), onPressed: () => Navigator.pop(context)),
        actions: [
          // --- FAVORİ İKONU (YENİ) ---
          StreamBuilder<bool>(
            // Eğer kullanıcı yoksa false dinle, varsa veritabanını dinle
            stream: user == null ? Stream.value(false) : _dbService.isFavorite(widget.component.id),
            builder: (context, snapshot) {
              final isFav = snapshot.data ?? false;
              
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.redAccent : Colors.grey,
                  shadows: isFav ? [const BoxShadow(color: Colors.red, blurRadius: 10)] : []
                ),
                onPressed: () async {
                  if (user == null) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Favorilere eklemek için giriş yapmalısın!")));
                     return;
                  }
                  
                  if (isFav) {
                    await _dbService.removeFavorite(widget.component.id);
                  } else {
                    await _dbService.addFavorite(widget.component.id, widget.component.category);
                    if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Favorilere Eklendi ❤️"), duration: Duration(seconds: 1), backgroundColor: Colors.green));
                    }
                  }
                },
              );
            },
          ),
          
          const Padding(padding: EdgeInsets.only(right: 20, left: 10), child: Icon(Icons.picture_as_pdf, color: Colors.redAccent))
        ],
      ),
      body: Column(
        children: [
          Expanded(flex: 4, child: Center(child: Hero(tag: widget.component.id, child: Image.asset(imagePath, height: 200, fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.memory, size: 100, color: Colors.grey))))),
          Expanded(flex: 6, child: Container(margin: const EdgeInsets.fromLTRB(15, 0, 15, 20), decoration: BoxDecoration(color: const Color(0xFF2E3239), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white10), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 1)]), child: Column(children: [
            Expanded(child: ScrollConfiguration(behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse}), child: PageView(controller: _pageController, onPageChanged: (i) => setState(() => _currentPage = i), children: [Padding(padding: const EdgeInsets.all(20), child: _buildPageGeneral()), Padding(padding: const EdgeInsets.all(20), child: _buildPageLimits()), Padding(padding: const EdgeInsets.all(20), child: _buildPageMechanical())]))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), decoration: const BoxDecoration(color: Color(0xFF1A1C20), borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))), child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) => AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 4), width: _currentPage == i ? 20 : 8, height: 8, decoration: BoxDecoration(color: _currentPage == i ? Colors.amber : Colors.grey[700], borderRadius: BorderRadius.circular(4))))),
              const SizedBox(height: 20),
              GestureDetector(onTap: _openTestDialog, child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 15), decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.3), blurRadius: 10)]), child: const Center(child: Text("TEST LABORATUVARINI AC", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black))))),
              GestureDetector(onTap: _openTestDialog, child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 15), decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.3), blurRadius: 10)]), child: const Center(child: Text("TEST LABORATUVARINI AC", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black))))),
            ])),
          ]))),
        ],
      ),
    );
  }
}

// ==============================================================================
// 2. POP-UP TEST PENCERESİ (AYNI KALDI)
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
  
  double dialogW = 0;
  double dialogH = 0;
  double redProbeX = -100;
  double redProbeY = 1000;
  double blackProbeX = -100;
  double blackProbeY = 1000;
  Map<String, Offset> pinLocs = {};

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _nextStepLogic();
    });
  }

  void _calculatePinLocations() {
    final double centerX = dialogW / 2;
    final double legsY = dialogH * 0.55; 

    double legSpacing = 60.0;
    if (widget.component.packageId.contains("TO-220")) legSpacing = 70.0;

    if (widget.component.category == "DIODE" || widget.component.packageId.contains("DO")) {
       pinLocs = {
        '1': Offset(centerX - legSpacing, legsY),
        '2': Offset(centerX + legSpacing, legsY),
        '3': Offset(centerX + legSpacing, legsY),
      };
    } else {
      pinLocs = {
        '1': Offset(centerX - legSpacing, legsY),
        '2': Offset(centerX, legsY),
        '3': Offset(centerX + legSpacing, legsY),
      };
    }
  }

  void moveProbes({String? redTo, String? blackTo}) {
    setState(() {
      const double tipOffsetX = 15.0; 
      const double tipOffsetY = 200.0; 

      if (redTo != null && pinLocs.containsKey(redTo)) {
        redProbeX = pinLocs[redTo]!.dx - tipOffsetX;
        redProbeY = pinLocs[redTo]!.dy - tipOffsetY;
      }
      if (blackTo != null && pinLocs.containsKey(blackTo)) {
        blackProbeX = pinLocs[blackTo]!.dx - tipOffsetX;
        blackProbeY = pinLocs[blackTo]!.dy - tipOffsetY;
      }
    });
  }

  void _handleUserAction(bool isSuccess) {
    if (isSuccess) _nextStepLogic();
    else _showResult(false);
  }

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

  void _runICTest() {
    String id = widget.component.id;
    String vccPin = (id == "NE555") ? "8" : (id == "LM741") ? "7" : (id == "UC3843") ? "7" : "8";
    String gndPin = (id == "NE555") ? "1" : (id == "LM741") ? "4" : (id == "UC3843") ? "5" : "4";

    if (currentStep == 1) {
      stepTitle = "BESLEME KONTROL";
      infoText = "VCC ($vccPin) ve GND ($gndPin) arasi kisa devre var mi?";
      multimeterMode = "OHM";
      moveProbes(redTo: vccPin, blackTo: gndPin);
      _simulateReading("2.5 kΩ"); 
    } else if (currentStep == 2) {
      stepTitle = "CIKIS KONTROL";
      infoText = "Cikis bacagi ile GND arasi kisa devre var mi?";
      String outPin = (id == "NE555") ? "3" : "6";
      moveProbes(redTo: outPin, blackTo: gndPin);
      _simulateReading("OL");
    } else {
      _showResult(true);
    }
  }

  void _runRegulatorTest() {
    if (currentStep == 1) {
      stepTitle = "GIRIS KONTROL";
      infoText = "Giris (1) ve GND (2) arasi kisa devre (0.00) var mi?";
      multimeterMode = "OHM";
      moveProbes(redTo: '1', blackTo: '2');
      _simulateReading("5.4 MΩ");
    } else if (currentStep == 2) {
      stepTitle = "CIKIS KONTROL";
      infoText = "Cikis (3) ve GND (2) arasi kisa devre var mi?";
      multimeterMode = "OHM";
      moveProbes(redTo: '3', blackTo: '2');
      _simulateReading("3.2 kΩ");
    } else {
      _showResult(true);
    }
  }

  void _runMosfetNTest() {
    if (currentStep == 1) {
      stepTitle = "ADIM 1: Body Diyodu";
      infoText = "Multimetrede diyot degeri (0.4V - 0.7V) goruyor musun?";
      multimeterMode = "DIODE";
      moveProbes(redTo: '3', blackTo: '2');
      _simulateReading("0.520 V");
    } else if (currentStep == 2) {
      stepTitle = "ADIM 2: Tetikleme";
      infoText = "Kirmizi probu Gate bacagina dokundur. Deger 'OL' mu?";
      multimeterMode = "DC V";
      moveProbes(redTo: '1', blackTo: '3');
      _simulateReading("OL");
    } else if (currentStep == 3) {
      stepTitle = "ADIM 3: Iletim";
      infoText = "Tekrar D-S olc. Deger sifira yakin (Kisa Devre) mi?";
      multimeterMode = "OHM";
      moveProbes(redTo: '2', blackTo: '3');
      _simulateReading("0.004 Ω");
    } else {
      _showResult(true);
    }
  }

  void _runBjtNpnTest() {
     if (currentStep == 1) {
      stepTitle = "ADIM 1: Base-Emitter";
      infoText = "B-E arasi diyot degeri (0.6V) okunuyor mu?";
      multimeterMode = "DIODE";
      moveProbes(redTo: '2', blackTo: '3'); 
      _simulateReading("0.680 V");
    } else if (currentStep == 2) {
      stepTitle = "ADIM 2: Base-Collector";
      infoText = "B-C arasi diyot degeri (0.6V) okunuyor mu?";
      multimeterMode = "DIODE";
      moveProbes(redTo: '2', blackTo: '1');
      _simulateReading("0.675 V");
    } else {
      _showResult(true);
    }
  }

  void _runDiodeTest() {
    if (currentStep == 1) {
      stepTitle = "ADIM 1: Dogru Yon";
      infoText = "Diyot degeri (0.5V - 0.7V) okunuyor mu?";
      multimeterMode = "DIODE";
      moveProbes(redTo: '1', blackTo: '2');
      _simulateReading("0.550 V");
    } else if (currentStep == 2) {
      stepTitle = "ADIM 2: Ters Yon";
      infoText = "Deger 'OL' (Sonsuz) mu?";
      multimeterMode = "DIODE";
      moveProbes(redTo: '2', blackTo: '1');
      _simulateReading("OL");
    } else {
      _showResult(true);
    }
  }

  void _simulateReading(String val) {
    setState(() => multimeterValue = "---");
    Future.delayed(const Duration(milliseconds: 600), () {
      if(mounted) setState(() => multimeterValue = val);
    });
  }

  void _showResult(bool isGood) {
    Navigator.pop(context); 
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF22252A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isGood ? Colors.green : Colors.red, width: 2)),
        title: Row(children: [Icon(isGood ? Icons.check_circle : Icons.error, color: isGood ? Colors.green : Colors.red, size: 32), const SizedBox(width: 10), Text(isGood ? "SAGLAM" : "ARIZALI", style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold))]),
        content: Text(isGood ? "Parca tum testlerden gecti ve kullanima uygundur." : "Test basarisiz oldu.\n\nOlasi Neden:\n$failureReason", style: const TextStyle(color: Colors.white70)),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              dialogW = constraints.maxWidth;
              dialogH = constraints.maxHeight;
              
              if (redProbeY == 1000) {
                 redProbeX = 10; redProbeY = dialogH; 
                 blackProbeX = dialogW - 60; blackProbeY = dialogH;
                 _calculatePinLocations();
              }

              return ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Stack(
                  children: [
                    Positioned(top: 20, left: 0, right: 0, child: Center(child: Column(children: [Text(stepTitle, style: GoogleFonts.orbitron(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2, shadows: [BoxShadow(color: Colors.amber.withValues(alpha: 0.5), blurRadius: 15)])), const SizedBox(height: 5), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Text("Adim $currentStep / 3", style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1))) ]))),
                    Positioned(top: 15, right: 15, child: IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context))),
                    Positioned(top: 100, left: 20, right: 20, child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF38404B), borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 5))], border: Border.all(color: Colors.white10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("FLUKE", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)), const SizedBox(height: 5), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF9EA38D), borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.black38, width: 3)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [const Text("AUTO", style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.bold)), const SizedBox(height: 10), Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(border: Border.all(color: Colors.black54, width: 1.5), borderRadius: BorderRadius.circular(3)), child: Text(multimeterMode, style: const TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold)))]), Text(multimeterValue, style: GoogleFonts.vt323(fontSize: 50, color: const Color(0xFF151515), fontWeight: FontWeight.bold))]))]))),
                    Positioned.fill(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const SizedBox(height: 80), Hero(tag: "dialog_${widget.component.id}", child: Image.asset(imagePath, height: 180, fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.memory, size: 100, color: Colors.grey))), const SizedBox(height: 5), Row(mainAxisAlignment: MainAxisAlignment.center, children: widget.component.pinoutCode.split('').map((c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 25), child: Text(c, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)))).toList())]))),
                    Positioned(bottom: 20, left: 20, right: 20, child: Column(children: [Container(width: double.infinity, padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)), boxShadow: [BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.05), blurRadius: 15)]), child: Text(infoText, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 15))), const SizedBox(height: 20), currentStep > 0 ? Row(children: [Expanded(child: _buildSciFiBtn("HATA / YOK", Colors.redAccent, Icons.close, () => _handleUserAction(false))), const SizedBox(width: 15), Expanded(child: _buildSciFiBtn("ONAYLA", Colors.greenAccent, Icons.check, () => _handleUserAction(true)))]) : const SizedBox(height: 60)])),
                    IgnorePointer(child: Stack(children: [AnimatedPositioned(duration: const Duration(seconds: 1), curve: Curves.easeInOutBack, left: redProbeX, top: redProbeY, child: Image.asset('assets/images/probe_red.png', height: 200)), AnimatedPositioned(duration: const Duration(seconds: 1), curve: Curves.easeInOutBack, left: blackProbeX, top: blackProbeY, child: Image.asset('assets/images/probe_black.png', height: 200))])),
                  ],
                ),
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _buildSciFiBtn(String txt, Color color, IconData icon, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(height: 55, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.6)), boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 1)]), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 22), const SizedBox(width: 10), Text(txt, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1))])));
  }
}