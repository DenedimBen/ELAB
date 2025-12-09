import 'package:flutter/material.dart';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';

class TestStep {
  final String title;
  final String description;
  final int? redPin;
  final int? blackPin;
  final String expectedValue;
  final bool isAction;

  TestStep({
    required this.title,
    required this.description,
    this.redPin,
    this.blackPin,
    required this.expectedValue,
    this.isAction = false,
  });
}

class TestScripts {
  
  // --- ANA YÖNLENDİRİCİ (ROUTER) ---
  static List<TestStep> getScript(BuildContext context, String scriptId, String pinout) {
    final l10n = AppLocalizations.of(context)!;
    if (pinout.isEmpty) pinout = "123";

    switch (scriptId) {
      // MOSFET
      case 'TEST_MOS_N': return _getMosfetN(l10n, pinout);
      case 'TEST_MOS_P': return _getMosfetP(l10n, pinout);
      
      // BJT TRANSİSTÖR
      case 'TEST_BJT_NPN': return _getBJT(l10n, pinout, isNPN: true);
      case 'TEST_BJT_PNP': return _getBJT(l10n, pinout, isNPN: false);
      case 'TEST_BJT_DARLINGTON_N': return _getDarlington(l10n, pinout, isNPN: true);
      
      // DİYOTLAR
      case 'TEST_DIODE': return _getDiode(l10n, pinout);
      case 'TEST_ZENER': return _getDiode(l10n, pinout);
      
      // REGÜLATÖRLER
      case 'TEST_REGULATOR_FIXED': return _getRegulatorFixed(l10n, pinout);
      case 'TEST_REGULATOR_ADJ': return _getRegulatorAdj(l10n, pinout);
      case 'TEST_REF_VOLT': return _getShuntRegulator(l10n, pinout);
      
      // ENTEGRELER & OPTO
      case 'TEST_OPTO': return _getOptocoupler(l10n, pinout);
      case 'TEST_IC_GEN': 
      case 'TEST_IC_555':
      case 'TEST_IC_OPAMP':
      case 'TEST_LOGIC':
        return _getICPowerCheck(l10n, pinout);
        
      default: return _getGeneric(l10n);
    }
  }

  // ===========================================================================
  // 1. MOSFET TESTLERİ (N-CHANNEL & P-CHANNEL)
  // ===========================================================================
  static List<TestStep> _getMosfetN(AppLocalizations l10n, String pinout) {
    int g = pinout.indexOf('G'); int d = pinout.indexOf('D'); int s = pinout.indexOf('S');
    if (g == -1) { g=0; d=1; s=2; }

    return [
      TestStep(title: l10n.testPrepTitle, description: l10n.testPrepDesc, expectedValue: "HAZIRLIK", redPin: null, blackPin: null),
      TestStep(title: l10n.testDiodeModeTitle, description: l10n.testDiodeModeDesc("SOURCE ($s)", "DRAIN ($d)"), expectedValue: "0.400V - 0.700V", redPin: s, blackPin: d),
      TestStep(title: l10n.testBlockingTitle, description: l10n.testBlockingDesc("DRAIN ($d)", "SOURCE ($s)"), expectedValue: "OL (Değer Yok)", redPin: d, blackPin: s),
      TestStep(title: l10n.testTriggerTitle, description: l10n.testTriggerDesc("SOURCE ($s)", "GATE ($g)", "DRAIN ($d)"), expectedValue: "ŞARJ EDİLİYOR...", redPin: g, blackPin: s, isAction: true),
      TestStep(title: l10n.testLatchingTitle, description: l10n.testLatchingDesc, expectedValue: "0.000V - 0.200V", redPin: d, blackPin: s),
    ];
  }

  static List<TestStep> _getMosfetP(AppLocalizations l10n, String pinout) {
    int g = pinout.indexOf('G'); int d = pinout.indexOf('D'); int s = pinout.indexOf('S');
    if (g == -1) { g=0; d=1; s=2; }

    return [
      TestStep(title: l10n.testPrepTitle, description: l10n.testPrepDesc, expectedValue: "HAZIRLIK", redPin: null, blackPin: null),
      TestStep(title: l10n.testDiodeModeTitle, description: l10n.testDiodeModeDesc("DRAIN ($d)", "SOURCE ($s)"), expectedValue: "0.400V - 0.700V", redPin: d, blackPin: s),
      TestStep(title: l10n.testBlockingTitle, description: l10n.testBlockingDesc("SOURCE ($s)", "DRAIN ($d)"), expectedValue: "OL (Değer Yok)", redPin: s, blackPin: d),
      TestStep(title: l10n.testTriggerTitle, description: l10n.testTriggerDesc("SOURCE ($s)", "GATE ($g)", "DRAIN ($d)"), expectedValue: "ŞARJ EDİLİYOR...", redPin: s, blackPin: g, isAction: true),
      TestStep(title: l10n.testLatchingTitle, description: l10n.testLatchingDesc, expectedValue: "0.000V - 0.200V", redPin: s, blackPin: d),
    ];
  }

  // ===========================================================================
  // 2. BJT TRANSİSTÖR TESTLERİ (NPN / PNP / DARLINGTON)
  // ===========================================================================
  static List<TestStep> _getBJT(AppLocalizations l10n, String pinout, {required bool isNPN}) {
    int b = pinout.indexOf('B'); int c = pinout.indexOf('C'); int e = pinout.indexOf('E');
    if (b == -1) { b=0; c=1; e=2; }

    return [
      TestStep(
        title: "Base - Collector Testi",
        description: l10n.testDiodeModeDesc(isNPN ? "BASE ($b)" : "COLLECTOR ($c)", isNPN ? "COLLECTOR ($c)" : "BASE ($b)"),
        expectedValue: "0.500V - 0.800V",
        redPin: isNPN ? b : c, blackPin: isNPN ? c : b,
      ),
      TestStep(
        title: "Base - Emitter Testi",
        description: l10n.testDiodeModeDesc(isNPN ? "BASE ($b)" : "EMITTER ($e)", isNPN ? "EMITTER ($e)" : "BASE ($b)"),
        expectedValue: "0.550V - 0.850V",
        redPin: isNPN ? b : e, blackPin: isNPN ? e : b,
      ),
      TestStep(title: "Sızıntı Kontrolü", description: "Base boşta. Collector-Emitter arası ölçüm yapın. Kısa devre olmamalı.", expectedValue: "OL (Değer Yok)", redPin: c, blackPin: e),
    ];
  }

  static List<TestStep> _getDarlington(AppLocalizations l10n, String pinout, {required bool isNPN}) {
    int b = pinout.indexOf('B'); int c = pinout.indexOf('C'); int e = pinout.indexOf('E');
    if (b == -1) { b=0; c=1; e=2; }

    return [
      TestStep(
        title: "Base - Collector Testi",
        description: l10n.testDiodeModeDesc(isNPN ? "BASE ($b)" : "COLLECTOR ($c)", isNPN ? "COLLECTOR ($c)" : "BASE ($b)"),
        expectedValue: "0.500V - 0.800V",
        redPin: isNPN ? b : c, blackPin: isNPN ? c : b,
      ),
      TestStep(
        title: "Base - Emitter Testi (Yüksek V)",
        description: "Darlington içinde iki transistör olduğu için değer YÜKSEK çıkmalıdır.",
        expectedValue: "1.100V - 1.500V",
        redPin: isNPN ? b : e, blackPin: isNPN ? e : b,
      ),
    ];
  }

  // ===========================================================================
  // 3. DİYOT & ZENER
  // ===========================================================================
  static List<TestStep> _getDiode(AppLocalizations l10n, String pinout) {
    int a = pinout.indexOf('A'); 
    int k = pinout.indexOf('K');
    if (a == -1) a = 0; 
    if (k == -1) k = 1;

    return [
      TestStep(
        title: l10n.testDiodeModeTitle,
        description: l10n.testDiodeModeDesc("ANOT", "KATOT"),
        expectedValue: "0.400V - 0.700V",
        redPin: a,
        blackPin: k,
      ),
      TestStep(
        title: l10n.testBlockingTitle,
        description: l10n.testBlockingDesc("KATOT", "ANOT"),
        expectedValue: "OL (Değer Yok)",
        redPin: k, 
        blackPin: a,
      ),
    ];
  }

  // ===========================================================================
  // 4. REGÜLATÖRLER (78xx / 79xx / AMS1117)
  // ===========================================================================
  static List<TestStep> _getRegulatorFixed(AppLocalizations l10n, String pinout) {
    int i = pinout.indexOf('I'); int g = pinout.indexOf('G'); int o = pinout.indexOf('O');
    if (i == -1) { i=0; g=1; o=2; }

    return [
      TestStep(title: "Giriş Kısa Devre Kontrolü", description: "Giriş (I) ile Şase (G) arasını ölçün. Tam kısa devre (0.000V) olmamalıdır.", expectedValue: "Değer Var / OL", redPin: i, blackPin: g),
      TestStep(title: "Çıkış Kısa Devre Kontrolü", description: "Çıkış (O) ile Şase (G) arasını ölçün. 0.000V görüyorsanız regülatör yanmıştır.", expectedValue: "Değer Var / OL", redPin: o, blackPin: g),
      TestStep(title: "Giriş-Çıkış Sızıntı", description: "Giriş ve Çıkış arası doğrudan iletim olmamalıdır.", expectedValue: "OL (Genelde)", redPin: i, blackPin: o),
    ];
  }

  static List<TestStep> _getRegulatorAdj(AppLocalizations l10n, String pinout) {
    int a = pinout.indexOf('A'); int o = pinout.indexOf('O'); int i = pinout.indexOf('I');
    if (a == -1) { a=0; o=1; i=2; }

    return [
      TestStep(title: "Referans Voltaj Kontrolü", description: "Adjust (A) ile Output (O) arasında yaklaşık 1.25V'a karşılık gelen bir direnç/diyot değeri okunur.", expectedValue: "Değer Var", redPin: a, blackPin: o),
      TestStep(title: "Kısa Devre Kontrolü", description: "Input (I) ve Output (O) arası kısa devre (0V) olmamalıdır.", expectedValue: "OL / Değer", redPin: i, blackPin: o),
    ];
  }

  static List<TestStep> _getShuntRegulator(AppLocalizations l10n, String pinout) {
    int r = pinout.indexOf('R'); int k = pinout.indexOf('K'); int a = pinout.indexOf('A');
    if (r == -1) { r=0; k=1; a=2; }

    return [
      TestStep(title: l10n.testDiodeModeTitle, description: l10n.testDiodeModeDesc("ANOT ($a)", "KATOT ($k)"), expectedValue: "0.500V - 0.800V", redPin: a, blackPin: k),
      TestStep(title: "Kısa Devre Kontrolü", description: "Referans ucu ile diğer uçlar kısa devre olmamalıdır.", expectedValue: "OL / Değer", redPin: r, blackPin: a),
    ];
  }

  // ===========================================================================
  // 5. OPTOKUPLÖRLER (PC817 vb.)
  // ===========================================================================
  static List<TestStep> _getOptocoupler(AppLocalizations l10n, String pinout) {
    int a=0, k=1, e=2, c=3; 

    return [
      TestStep(title: "Giriş LED Testi", description: l10n.testDiodeModeDesc("Pin 1 (Anot)", "Pin 2 (Katot)"), expectedValue: "1.000V - 1.200V", redPin: a, blackPin: k),
      TestStep(title: "Çıkış Transistör Testi", description: "Çıkış tarafı tetiklenmediği sürece açık devre olmalıdır.\nKırmızı: Pin 4 | Siyah: Pin 3", expectedValue: "OL (Açık Devre)", redPin: c, blackPin: e),
    ];
  }

  // ===========================================================================
  // 6. ENTEGRELER (GENEL GÜÇ KONTROLÜ)
  // ===========================================================================
  static List<TestStep> _getICPowerCheck(AppLocalizations l10n, String pinout) {
    int gnd = 3; 
    int vcc = 7;

    if (pinout.length > 10) { 
       gnd = (pinout.length ~/ 2) - 1; 
       vcc = pinout.length - 1;        
    }

    return [
      TestStep(
        title: "VCC - GND Kısa Devre Testi",
        description: "Entegrenin besleme bacakları (Pin ${vcc+1} ve Pin ${gnd+1}) arasını ölçün.\nEğer 0.000V (Kısa Devre) okursanız entegre yanmıştır.",
        expectedValue: "Değer Var / OL",
        redPin: vcc, blackPin: gnd,
      ),
      TestStep(
        title: "Fiziksel Kontrol",
        description: "Entegre üzerinde çatlak, delik veya aşırı ısınma belirtisi var mı?",
        expectedValue: "Gözle Kontrol",
        redPin: null, blackPin: null,
      ),
    ];
  }

  static List<TestStep> _getGeneric(AppLocalizations l10n) {
    return [
      TestStep(title: "Genel Sağlamlık", description: "Bacaklar arasında kısa devre (0.000V) olup olmadığını kontrol edin.", expectedValue: "Kontrol Edin", redPin: null, blackPin: null)
    ];
  }
}