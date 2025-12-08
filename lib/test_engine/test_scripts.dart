import 'package:flutter/material.dart';

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
  // Excel'deki 'test_script_id'ye göre doğru reçeteyi seçer.
  static List<TestStep> getScript(String scriptId, String pinout) {
    // Pinout boş gelirse varsayılan ata (Çökme önleyici)
    if (pinout.isEmpty) pinout = "123";

    switch (scriptId) {
      // MOSFET
      case 'TEST_MOS_N': return _getMosfetN(pinout);
      case 'TEST_MOS_P': return _getMosfetP(pinout);
      
      // BJT TRANSİSTÖR
      case 'TEST_BJT_NPN': return _getBJT(pinout, isNPN: true);
      case 'TEST_BJT_PNP': return _getBJT(pinout, isNPN: false);
      case 'TEST_BJT_DARLINGTON_N': return _getDarlington(pinout, isNPN: true); // Darlington Eklendi
      
      // DİYOTLAR
      case 'TEST_DIODE': return _getDiode(pinout);
      case 'TEST_ZENER': return _getDiode(pinout); // Zener de diyot gibi ölçülür
      
      // REGÜLATÖRLER
      case 'TEST_REGULATOR_FIXED': return _getRegulatorFixed(pinout); // 7805, 7905, AMS1117
      case 'TEST_REGULATOR_ADJ': return _getRegulatorAdj(pinout); // LM317
      case 'TEST_REF_VOLT': return _getShuntRegulator(pinout); // TL431
      
      // ENTEGRELER & OPTO
      case 'TEST_OPTO': return _getOptocoupler(pinout); // PC817
      case 'TEST_IC_GEN': 
      case 'TEST_IC_555':
      case 'TEST_IC_OPAMP':
      case 'TEST_LOGIC':
        return _getICPowerCheck(pinout); // Genel IC Kısa Devre Testi
        
      default: return _getGeneric();
    }
  }

  // ===========================================================================
  // 1. MOSFET TESTLERİ (N-CHANNEL & P-CHANNEL)
  // ===========================================================================
  static List<TestStep> _getMosfetN(String pinout) {
    int g = pinout.indexOf('G'); int d = pinout.indexOf('D'); int s = pinout.indexOf('S');
    if (g == -1) { g=0; d=1; s=2; }

    return [
      TestStep(title: "Hazırlık & Deşarj", description: "Testten önce MOSFET'in metal bacaklarına aynı anda dokunarak statik elektriği boşaltın.", expectedValue: "HAZIRLIK", redPin: null, blackPin: null),
      TestStep(title: "Dahili Diyot Testi", description: "Kırmızı: SOURCE ($s) | Siyah: DRAIN ($d)\nSağlam bir N-Kanal MOSFET'te burada diyot değeri okunmalıdır.", expectedValue: "0.400V - 0.700V", redPin: s, blackPin: d),
      TestStep(title: "Kesim (Blocking)", description: "Probları ters çevirin.\nKırmızı: DRAIN ($d) | Siyah: SOURCE ($s)", expectedValue: "OL (Değer Yok)", redPin: d, blackPin: s),
      TestStep(title: "Gate Tetikleme", description: "Siyah prob SOURCE ($s) üzerinde kalsın.\nKırmızı probu anlık olarak GATE ($g) bacağına değdirip çekin, sonra tekrar DRAIN ($d) bacağına getirin.", expectedValue: "ŞARJ EDİLİYOR...", redPin: g, blackPin: s, isAction: true),
      TestStep(title: "İletim Kontrolü", description: "Tetiklemeden sonra Drain-Source arası iletime geçmelidir. Değer 0'a yaklaştı mı?", expectedValue: "0.000V - 0.200V", redPin: d, blackPin: s),
    ];
  }

  static List<TestStep> _getMosfetP(String pinout) {
    int g = pinout.indexOf('G'); int d = pinout.indexOf('D'); int s = pinout.indexOf('S');
    if (g == -1) { g=0; d=1; s=2; }

    return [
      TestStep(title: "Hazırlık & Deşarj", description: "Bacakları kısa devre ederek deşarj edin.", expectedValue: "HAZIRLIK", redPin: null, blackPin: null),
      TestStep(title: "Dahili Diyot Testi", description: "Kırmızı: DRAIN ($d) | Siyah: SOURCE ($s)\nP-Kanalda diyot yönü terstir.", expectedValue: "0.400V - 0.700V", redPin: d, blackPin: s),
      TestStep(title: "Kesim (Blocking)", description: "Probları ters çevirin.\nKırmızı: SOURCE ($s) | Siyah: DRAIN ($d)", expectedValue: "OL (Değer Yok)", redPin: s, blackPin: d),
      TestStep(title: "Gate Tetikleme", description: "Kırmızı prob SOURCE ($s) üzerinde kalsın.\nSiyah probu anlık olarak GATE ($g) ucuna değdirip (Negatif şarj) geri DRAIN'e getirin.", expectedValue: "ŞARJ EDİLİYOR...", redPin: s, blackPin: g, isAction: true),
      TestStep(title: "İletim Kontrolü", description: "Drain-Source arası iletime geçti mi?", expectedValue: "0.000V - 0.200V", redPin: s, blackPin: d),
    ];
  }

  // ===========================================================================
  // 2. BJT TRANSİSTÖR TESTLERİ (NPN / PNP / DARLINGTON)
  // ===========================================================================
  static List<TestStep> _getBJT(String pinout, {required bool isNPN}) {
    int b = pinout.indexOf('B'); int c = pinout.indexOf('C'); int e = pinout.indexOf('E');
    if (b == -1) { b=0; c=1; e=2; }

    return [
      TestStep(
        title: "Base - Collector Testi",
        description: isNPN ? "Kırmızı: BASE ($b) | Siyah: COLLECTOR ($c)" : "Siyah: BASE ($b) | Kırmızı: COLLECTOR ($c)",
        expectedValue: "0.500V - 0.800V",
        redPin: isNPN ? b : c, blackPin: isNPN ? c : b,
      ),
      TestStep(
        title: "Base - Emitter Testi",
        description: isNPN ? "Kırmızı: BASE ($b) | Siyah: EMITTER ($e)" : "Siyah: BASE ($b) | Kırmızı: EMITTER ($e)",
        expectedValue: "0.550V - 0.850V", // Emitter genelde Collector'dan biraz yüksek çıkar
        redPin: isNPN ? b : e, blackPin: isNPN ? e : b,
      ),
      TestStep(title: "Sızıntı Kontrolü", description: "Base boşta. Collector-Emitter arası ölçüm yapın. Kısa devre olmamalı.", expectedValue: "OL (Değer Yok)", redPin: c, blackPin: e),
    ];
  }

  static List<TestStep> _getDarlington(String pinout, {required bool isNPN}) {
    // TIP120 gibi Darlingtonlar çift transistör olduğu için Vbe yüksektir (1.2V civarı)
    int b = pinout.indexOf('B'); int c = pinout.indexOf('C'); int e = pinout.indexOf('E');
    if (b == -1) { b=0; c=1; e=2; }

    return [
      TestStep(
        title: "Base - Collector Testi",
        description: "Darlington transistörlerde B-C arası normal diyot gibidir.",
        expectedValue: "0.500V - 0.800V",
        redPin: isNPN ? b : c, blackPin: isNPN ? c : b,
      ),
      TestStep(
        title: "Base - Emitter Testi (Yüksek V)",
        description: "Darlington içinde iki transistör olduğu için değer YÜKSEK çıkmalıdır.",
        expectedValue: "1.100V - 1.500V", // Normal transistörden farkı burası!
        redPin: isNPN ? b : e, blackPin: isNPN ? e : b,
      ),
    ];
  }

  // ===========================================================================
  // 3. DİYOT & ZENER
  // ===========================================================================
  static List<TestStep> _getDiode(String pinout) {
    // Görsel koordinatlarda (package_coordinates.dart):
    // Index 0 -> SAĞ Taraf (Bizim yeni ayarımıza göre Anot burada olsun istiyoruz)
    // Index 1 -> SOL Taraf (Katot)
    
    // Veritabanından "AK" gelirse: A=0, K=1
    // Ama biz görselde yerlerini değiştirdik.
    
    // Doğru eşleşme için:
    int a = pinout.indexOf('A'); 
    int k = pinout.indexOf('K');
    
    // Eğer veritabanında "AK" yazıyorsa ve biz görselde A'yı 2. sıraya (Index 1) koyduysak
    // burada manuel bir düzeltme yapmamız gerekebilir.
    
    // Ancak en temizi şudur:
    // Görseldeki sıralama neyse (Örn: 0. index Sağ, 1. index Sol), 
    // Test adımındaki indexler de ona uymalı.
    
    // Eğer A ve K harfleri bulunamazsa varsayılan ata
    if (a == -1) a = 0; 
    if (k == -1) k = 1;

    return [
      TestStep(
        title: "Doğru Polarizasyon",
        description: "Akım Anot'tan Katot'a akar.\nKırmızı: ANOT | Siyah: KATOT",
        expectedValue: "0.400V - 0.700V",
        redPin: a,   // Anot hangi indexteyse orası yansın
        blackPin: k, // Katot hangi indexteyse orası yansın
      ),
      TestStep(
        title: "Ters Polarizasyon",
        description: "Probları ters çevirin. Akım geçmemelidir.",
        expectedValue: "OL (Değer Yok)",
        redPin: k, 
        blackPin: a,
      ),
    ];
  }

  // ===========================================================================
  // 4. REGÜLATÖRLER (78xx / 79xx / AMS1117)
  // ===========================================================================
  static List<TestStep> _getRegulatorFixed(String pinout) {
    // Pinout IGO (78xx) veya GIO (79xx) olabilir. Kod harfleri bulur.
    int i = pinout.indexOf('I'); // Input
    int g = pinout.indexOf('G'); // Ground
    int o = pinout.indexOf('O'); // Output
    if (i == -1) { i=0; g=1; o=2; }

    return [
      TestStep(title: "Giriş Kısa Devre Kontrolü", description: "Giriş (I) ile Şase (G) arasını ölçün. Tam kısa devre (0.000V) olmamalıdır.", expectedValue: "Değer Var / OL", redPin: i, blackPin: g),
      TestStep(title: "Çıkış Kısa Devre Kontrolü", description: "Çıkış (O) ile Şase (G) arasını ölçün. 0.000V görüyorsanız regülatör yanmıştır.", expectedValue: "Değer Var / OL", redPin: o, blackPin: g),
      TestStep(title: "Giriş-Çıkış Sızıntı", description: "Giriş ve Çıkış arası doğrudan iletim olmamalıdır.", expectedValue: "OL (Genelde)", redPin: i, blackPin: o),
    ];
  }

  static List<TestStep> _getRegulatorAdj(String pinout) {
    // LM317: ADJ - OUT - IN
    int a = pinout.indexOf('A'); // Adjust
    int o = pinout.indexOf('O'); // Output
    int i = pinout.indexOf('I'); // Input
    if (a == -1) { a=0; o=1; i=2; }

    return [
      TestStep(title: "Referans Voltaj Kontrolü", description: "Adjust (A) ile Output (O) arasında yaklaşık 1.25V'a karşılık gelen bir direnç/diyot değeri okunur.", expectedValue: "Değer Var", redPin: a, blackPin: o),
      TestStep(title: "Kısa Devre Kontrolü", description: "Input (I) ve Output (O) arası kısa devre (0V) olmamalıdır.", expectedValue: "OL / Değer", redPin: i, blackPin: o),
    ];
  }

  static List<TestStep> _getShuntRegulator(String pinout) {
    // TL431: RKA (Ref, Cathode, Anode)
    int r = pinout.indexOf('R'); int k = pinout.indexOf('K'); int a = pinout.indexOf('A');
    if (r == -1) { r=0; k=1; a=2; }

    return [
      TestStep(title: "Diyot Modu Testi", description: "TL431 iç yapısında Anot-Katot arası diyot gibidir.\nKırmızı: ANOT ($a) | Siyah: KATOT ($k)", expectedValue: "0.500V - 0.800V", redPin: a, blackPin: k),
      TestStep(title: "Kısa Devre Kontrolü", description: "Referans ucu ile diğer uçlar kısa devre olmamalıdır.", expectedValue: "OL / Değer", redPin: r, blackPin: a),
    ];
  }

  // ===========================================================================
  // 5. OPTOKUPLÖRLER (PC817 vb.)
  // ===========================================================================
  static List<TestStep> _getOptocoupler(String pinout) {
    // Pinout genelde "AKEC" (1:Anot, 2:Katot, 3:Emitter, 4:Collector)
    // Eğer veritabanından "1234" gelirse manuel map yaparız.
    // PC817 için standart: 1:A, 2:K, 3:E, 4:C
    int a=0, k=1, e=2, c=3; 

    return [
      TestStep(title: "Giriş LED Testi", description: "Optokuplörün girişi bir IR LED'dir.\nKırmızı: Pin 1 (Anot) | Siyah: Pin 2 (Katot)", expectedValue: "1.000V - 1.200V", redPin: a, blackPin: k),
      TestStep(title: "Çıkış Transistör Testi", description: "Çıkış tarafı tetiklenmediği sürece açık devre olmalıdır.\nKırmızı: Pin 4 | Siyah: Pin 3", expectedValue: "OL (Açık Devre)", redPin: c, blackPin: e),
    ];
  }

  // ===========================================================================
  // 6. ENTEGRELER (GENEL GÜÇ KONTROLÜ)
  // ===========================================================================
  static List<TestStep> _getICPowerCheck(String pinout) {
    // Entegrelerde en yaygın arıza VCC ve GND'nin kısa devre olmasıdır.
    // DIP-8 için genelde: GND=4 (Index 3), VCC=8 (Index 7)
    // DIP-14 için genelde: GND=7 (Index 6), VCC=14 (Index 13)
    
    int gnd = 3; // Varsayılan DIP-8
    int vcc = 7;

    if (pinout.length > 10) { // DIP-14 veya 16 ise
       gnd = (pinout.length ~/ 2) - 1; // Yarısının son bacağı
       vcc = pinout.length - 1;        // En son bacak
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

  static List<TestStep> _getGeneric() {
    return [
      TestStep(title: "Genel Sağlamlık", description: "Bacaklar arasında kısa devre (0.000V) olup olmadığını kontrol edin.", expectedValue: "Kontrol Edin", redPin: null, blackPin: null)
    ];
  }
}