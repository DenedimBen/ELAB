import 'package:flutter/material.dart';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'test_scripts.dart';
import 'component_visualizer.dart';
import '../services/ad_service.dart';

class ComponentTestScreen extends StatefulWidget {
  final String componentName; // "IRF3205"
  final String packageType;   // "TO-220"
  final String pinout;        // "GDS"
  final String scriptId;      // "TEST_MOS_N"

  const ComponentTestScreen({
    super.key, 
    required this.componentName, 
    required this.packageType,
    required this.pinout,
    required this.scriptId,
  });

  @override
  State<ComponentTestScreen> createState() => _ComponentTestScreenState();
}

class _ComponentTestScreenState extends State<ComponentTestScreen> {
  int _currentStep = 0;
  bool _isFlipped = false;
  
  late List<TestStep> _steps;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Excel'den gelen "test_script_id" (Örn: TEST_MOS_N) ve "pinout" (GDS) 
    // bilgisini vererek doğru testi alıyoruz.
    _steps = TestScripts.getScript(context, widget.scriptId, widget.pinout);
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _showResultDialog();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  void _restartTest() {
    setState(() {
      _currentStep = 0;
      _isFlipped = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.msgTestRestarted), duration: const Duration(seconds: 1)));
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Reklamı atlamasın diye
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF25282F),
        title: Text(AppLocalizations.of(context)!.msgTestCompleteTitle, style: const TextStyle(color: Colors.greenAccent)),
        content: Text(AppLocalizations.of(context)!.msgTestCompleteBody, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Diyaloğu kapat
              Navigator.pop(context); // Test ekranından çık
              
              // 💰 REKLAM GÖSTER (Zorla/Force) 💰
              // Test bittiği için sayaca bakma, direkt göster
              AdService().showInterstitialAd(force: true); 
            },
            child: Text(AppLocalizations.of(context)!.btnOk),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];

    return Scaffold(
      backgroundColor: const Color(0xFF1E2126),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.componentName, style: GoogleFonts.orbitron(color: Colors.amber)),
        actions: [
          IconButton(
            icon: Icon(_isFlipped ? Icons.flip_to_front : Icons.flip_to_back, color: Colors.white),
            tooltip: AppLocalizations.of(context)!.tooltipFlip,
            onPressed: () => setState(() => _isFlipped = !_isFlipped),
          )
        ],
      ),
      body: Column(
        children: [
          
          // --- YENİ: MAVİ BİLGİLENDİRME BALONU ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            color: Colors.blueAccent.withOpacity(0.1), // Hafif mavi zemin
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blueAccent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.msgInfoBubble,
                    style: GoogleFonts.roboto(
                      color: Colors.blueAccent[100], 
                      fontSize: 13,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- BÖLÜM 1: GÖRSELLEŞTİRİCİ ---
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Stack(
                children: [
                  // Görselleştirici
                  ComponentVisualizer(
                    packageType: widget.packageType,
                    redPinIndex: step.redPin,
                    blackPinIndex: step.blackPin,
                    isFlipped: _isFlipped,
                    pinLabels: widget.pinout.split(''), 
                  ),

                  // Kontrol Menüsü (Sadece Yenileme Kaldı)
                  Positioned(
                    top: 10, right: 10,
                    child: FloatingActionButton.small(
                      heroTag: "btn2",
                      backgroundColor: Colors.blueGrey.withOpacity(0.5),
                      child: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _restartTest,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- BÖLÜM 2: GERÇEKÇİ MULTİMETRE EKRANI ---
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF2B3A42), 
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF455A64), width: 4),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5))
                ],
              ),
              child: Stack(
                children: [
                  // LCD Arkaplan
                  Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8FA382), Color(0xFF7E9473)], 
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black38, blurRadius: 4)
                      ],
                    ),
                  ),

                  // Ekran İçeriği
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Row(
                               children: [
                                 const Icon(Icons.flash_on, size: 14, color: Colors.black54),
                                 const SizedBox(width: 4),
                                 Text("AUTO", style: GoogleFonts.robotoMono(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold)),
                               ],
                             ),
                             const Icon(Icons.battery_full, size: 14, color: Colors.black54),
                          ],
                        ),
                        
                        // ANA DEĞER (FittedBox ile sarmalandı)
                        Expanded( // Expanded ekledik ki boşluğu doldursun
                          child: FittedBox(
                            fit: BoxFit.scaleDown, // Sığmazsa küçült
                            alignment: Alignment.centerRight,
                            child: Text(
                              step.expectedValue,
                              style: GoogleFonts.vt323(
                                fontSize: 50, // Başlangıç boyutu
                                color: Colors.black.withOpacity(0.85),
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  const Shadow(color: Colors.black12, offset: Offset(2, 2), blurRadius: 1)
                                ],
                              ),
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(4)
                          ),
                          child: Text(
                            "DIODE MODE", 
                            style: GoogleFonts.roboto(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)
                          ),
                        )
                      ],
                    ),
                  ),
                  
                  // Parlama Efekti
                  Positioned(
                    top: 15, right: 15,
                    child: Container(
                      width: 50, height: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft
                        )
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          // --- BÖLÜM 3: ADIM KONTROLLERİ ---
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF25282F),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Text(
                    "ADIM ${_currentStep + 1} / ${_steps.length}",
                    style: GoogleFonts.robotoMono(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    step.title,
                    style: GoogleFonts.oswald(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    step.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (_currentStep > 0)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                          onPressed: _prevStep,
                          child: Text(AppLocalizations.of(context)!.btnBack, style: const TextStyle(color: Colors.white)),
                        ),
                      
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: step.isAction ? Colors.orange : Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)
                        ),
                        onPressed: _nextStep,
                        icon: Icon(step.isAction ? Icons.touch_app : Icons.check),
                        label: Text(step.isAction ? AppLocalizations.of(context)!.btnApplied : AppLocalizations.of(context)!.btnYesCorrect, style: const TextStyle(fontSize: 16)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
