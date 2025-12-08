import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import '../services/firestore_service.dart';
import '../test_engine/test_screen.dart';
import '../services/ad_service.dart';

class ComponentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> componentData;

  const ComponentDetailScreen({super.key, required this.componentData});

  @override
  Widget build(BuildContext context) {
    // Sayfaya her girildiğinde sayacı artırır
    // Eğer limit dolduysa reklamı gösterir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdService().showInterstitialAd(); 
    });

    // Verileri Güvenli Çek
    final String id = componentData['id'] ?? 'Unknown';
    final String package = componentData['package'] ?? 'N/A';
    final String category = componentData['category'] ?? 'General';
    final String pinout = componentData['pinout_code'] ?? '123';
    
    // Değerler
    final String vMax = "${componentData['vmax']}V";
    final String iMax = "${componentData['imax']}A";
    final String pMax = "${componentData['power_max'] ?? '0'}W";

    // --- BURASI DEĞİŞTİ ---
    // Artık açıklamayı fonksiyonumuz üretiyor
    final String desc = _generateSmartDescription(componentData);
    // ----------------------

    // Excel'den gelen veriyi güvenli çek
    // Eğer Excel boşsa varsayılan mühendislik metinleri uydur (Fake AI)
    String appsRaw = componentData['applications'] ?? '';
    if (appsRaw.isEmpty || appsRaw == 'nan') {
       // Kategoriye göre otomatik doldur (Yedek Plan)
       if (category.contains('MOSFET')) appsRaw = "Motor Control, SMPS, DC-DC Converter, Load Switch";
       else if (category.contains('BJT')) appsRaw = "Audio Amplifier, Signal Processing, Switching";
       else appsRaw = "General Purpose, Prototyping, PCB Design";
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121418), // Çok koyu gri (Cyberpunk Dark)
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 1. KAYAN BAŞLIK VE RESİM
              SliverAppBar(
                expandedHeight: 280.0,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF1E2126),
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(id, style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, shadows: [const Shadow(color: Colors.black, blurRadius: 10)])),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [const Color(0xFF2E3239), const Color(0xFF121418)],
                      ),
                    ),
                    child: Center(
                      child: Hero(
                        tag: id, // Animasyonlu geçiş için
                        child: Image.asset(
                          'assets/packages/${package.toLowerCase()}.png',
                          height: 180,
                          errorBuilder: (c, o, s) => const Icon(Icons.memory, size: 80, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 2. İÇERİK GÖVDESİ
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      // ETİKETLER VE AKSİYON BUTONLARI
                      Row(
                        children: [
                          _buildTag(category, Colors.blueAccent),
                          const SizedBox(width: 10),
                          _buildTag(package, Colors.amber),
                          
                          const Spacer(),
                          
                          // 1. FAVORİ BUTONU ❤️
                          StreamBuilder<bool>(
                            stream: FirestoreService().isFavorite(id),
                            builder: (context, snapshot) {
                              bool isFav = snapshot.data ?? false;
                              return IconButton(
                                icon: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? Colors.redAccent : Colors.grey,
                                ),
                                onPressed: () {
                                  if (isFav) {
                                    FirestoreService().removeFavorite(id);
                                  } else {
                                    // Kategori bilgisini de kaydediyoruz ki favorilerde filtreleyebilelim
                                    FirestoreService().addFavorite(id, category);
                                  }
                                },
                              );
                            },
                          ),

                          // 2. PAYLAŞ BUTONU 📤
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.grey),
                            onPressed: () {
                              Share.share(
                                "E-LAB Uygulamasında bu parçayı incele: $id\n"
                                "Özellikler: $vMax, $iMax\n"
                                "Hemen indir: https://play.google.com/store/apps/details?id=com.senin.uygulaman"
                              );
                            },
                          ),

                          // 3. HATA BİLDİR BUTONU 🐞 (YENİ)
                          IconButton(
                            icon: const Icon(Icons.report_problem_outlined, color: Colors.grey),
                            tooltip: "Hata Bildir",
                            onPressed: () => _showReportDialog(context, id),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 25),

                      // HUD İSTATİSTİKLERİ (VOLTAJ - AKIM - GÜÇ)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatCard("MAX VOLTAGE", vMax, Icons.flash_on, Colors.amber),
                          _buildStatCard("MAX CURRENT", iMax, Icons.bolt, Colors.cyan),
                          _buildStatCard("MAX POWER", pMax, Icons.local_fire_department, Colors.redAccent),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // AÇIKLAMA BAŞLIĞI
                      Text("COMPONENT OVERVIEW", style: GoogleFonts.teko(color: Colors.grey, fontSize: 16, letterSpacing: 2)),
                      const Divider(color: Colors.white12),
                      
                      // AÇIKLAMA METNİ
                      Text(
                        desc,
                        style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                      ),

                      const SizedBox(height: 20),

                      // UYGULAMA ALANLARI (Akıllı Devre Bulucu)
                      Text("TYPICAL APPLICATIONS (Click for Circuits)", style: GoogleFonts.teko(color: Colors.grey, fontSize: 16, letterSpacing: 2)),
                      const Divider(color: Colors.white12),
                      
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: appsRaw.split(',').map<Widget>((appText) {
                          final String app = appText.trim();
                          if (app.isEmpty) return const SizedBox();

                          return ActionChip(
                            // Görsel Ayarlar
                            avatar: const Icon(Icons.electrical_services, size: 14, color: Colors.black87),
                            label: Text(app),
                            backgroundColor: Colors.amber, 
                            labelStyle: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                            padding: const EdgeInsets.all(6),
                            elevation: 4,
                            pressElevation: 8,
                            shadowColor: Colors.amber.withOpacity(0.5),
                            
                            // TIKLAMA OLAYI: DEVRE ŞEMASI ARA 🔍
                            onPressed: () async {
                              // Arama Sorgusu: "IRF3205 Motor Control Circuit Schematic"
                              final query = "$id $app Circuit Schematic";
                              // Google Görseller Linki (tbm=isch görseller demektir)
                              final url = Uri.parse("https://www.google.com/search?q=$query&tbm=isch");

                              try {
                                if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                  throw 'Tarayıcı açılamadı';
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Arama başlatılamadı ❌"))
                                );
                              }
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 30),

                      // PINOUT BİLGİSİ
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Icon(Icons.settings_input_component, color: Colors.grey),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("PIN CONFIGURATION", style: GoogleFonts.teko(color: Colors.amber, fontSize: 14)),
                                Text(
                                  pinout.split('').join(' - '), // GDS -> G - D - S
                                  style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            // AKILLI PDF BUTONU 📄
                            OutlinedButton.icon(
                              onPressed: () async {
                                String urlStr = componentData['datasheet_url'] ?? '';
                                
                                // Eğer link yoksa veya bozuksa Google Araması oluştur
                                if (urlStr.isEmpty || urlStr == 'nan' || !urlStr.startsWith('http')) {
                                  urlStr = "https://www.google.com/search?q=$id+datasheet+filetype:pdf";
                                }

                                final Uri url = Uri.parse(urlStr);
                                try {
                                  // LaunchMode.externalApplication: Tarayıcıda açar (Önemli!)
                                  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                    throw 'Link açılamadı';
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent, 
                                side: const BorderSide(color: Colors.redAccent)
                              ),
                              icon: const Icon(Icons.picture_as_pdf, size: 18),
                              label: const Text("DATASHEET"),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 100), // Buton için boşluk
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 3. ALT ALAN (TEST BUTONU + REKLAM)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              // Arkaya siyah degrade atalım ki reklam net görünsün
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black, Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TEST BUTONU
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: SizedBox(
                      height: 55,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ComponentTestScreen(
                                componentName: id,
                                packageType: package,
                                pinout: pinout,
                                scriptId: componentData['test_script_id'] ?? 'TEST_GENERIC',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 10,
                          shadowColor: Colors.amber.withOpacity(0.5),
                        ),
                        icon: const Icon(Icons.health_and_safety, size: 28),
                        label: Text("START DIAGNOSTIC TEST", style: GoogleFonts.oswald(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    ),
                  ),
                  
                  // 💰 BANNER REKLAM ALANI 💰
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AdService().getBannerAdWidget(), 
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- YARDIMCI WIDGETLAR ---

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2126),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  // --- AKILLI AÇIKLAMA ÜRETİCİSİ (TÜRKÇE) ---
  String _generateSmartDescription(Map<String, dynamic> data) {
    String id = data['id'] ?? '';
    String cat = data['category'] ?? '';
    String pkg = data['package'] ?? '';
    String pol = data['polarity'] ?? ''; // N-Channel, NPN vs.
    String vmax = "${data['vmax']}V";
    String imax = "${data['imax']}A";
    
    // Eğer Excel'den gelen özel bir açıklama varsa onu kullan
    String dbDesc = data['description'] ?? '';
    if (dbDesc.length > 10 && dbDesc != 'nan') return dbDesc;

    // Kategoriye Göre Türkçe Şablonlar
    if (cat.contains('MOSFET')) {
      return "Bu, dayanıklı $pkg kılıfına sahip yüksek performanslı bir $pol Güç MOSFET'idir. "
             "$vmax gerilime ve $imax sürekli akıma dayanacak şekilde tasarlanmıştır. "
             "Yüksek hızlı anahtarlama uygulamaları, DC-DC dönüştürücüler ve motor sürücüleri için idealdir. "
             "Verimli güç yönetimi için düşük iletim direncine (RDS-on) sahiptir.";
    } 
    else if (cat.contains('BJT')) {
      return "$pkg kılıf yapısında, çok yönlü bir $pol Bipolar Jonksiyon Transistörü (BJT). "
             "$vmax kollektör-emiter gerilimi ve $imax kollektör akım kapasitesine sahiptir. "
             "Doğrusal sinyal yükseltme (amplifikasyon) ve genel amaçlı anahtarlama işlemleri için uygundur. "
             "Genellikle ses devrelerinde ve sinyal işleme uygulamalarında kullanılır.";
    }
    else if (cat.contains('DIODE')) {
      String type = id.contains('1N47') || id.contains('Zener') ? "Zener" : "Doğrultucu (Rectifier)";
      return "$pkg formatında güvenilirlik için tasarlanmış standart bir $type Diyodu. "
             "$vmax'a kadar ters gerilimi bloklayabilir ve $imax ileri akım taşıyabilir. "
             "Güç kaynağı doğrultma, voltaj sınırlama ve ters polarite koruma devreleri için vazgeçilmezdir.";
    }
    else if (cat.contains('IC')) {
      if (id.contains('78') || id.contains('79') || id.contains('1117') || id.contains('317')) {
        return "Kararlı bir çıkış voltajı sağlamak için tasarlanmış hassas Voltaj Regülatörü Entegresi. "
               "$pkg kılıfındadır ve $vmax'a kadar giriş voltajlarını yönetebilir. "
               "Dahili termal aşırı yük koruması ve kısa devre akım sınırlaması sayesinde standart uygulamalarda bozulması neredeyse imkansızdır.";
      }
      if (id.contains('555')) {
        return "Efsanevi 555 Zamanlayıcı Entegresi (Timer IC). Hassas zaman gecikmeleri veya osilasyon üretebilen son derece kararlı bir kontrolördür. "
               "$vmax gerilime kadar çalışabilir. Kullanım alanları arasında hassas zamanlama, darbe (pulse) üretimi ve zaman gecikmesi devreleri bulunur.";
      }
      if (id.contains('358') || id.contains('741') || id.contains('324')) {
        return "$pkg kılıfında genel amaçlı bir Operasyonel Amplifikatör (Op-Amp). "
               "Geniş bant genişliği ve yüksek DC voltaj kazancı sunar. Aktif filtreler, sensör arayüzleri ve analog sinyal koşullandırma devreleri için uygundur.";
      }
    }

    // Bilinmeyen Parçalar İçin Varsayılan Türkçe Metin
    return "$pkg form faktörüne sahip genel bir elektronik bileşen ($cat). "
           "$vmax ve $imax çalışma değerleri için derecelendirilmiştir. "
           "Ayrıntılı elektriksel karakteristikler ve termal veriler için lütfen teknik dokümana (datasheet) başvurun.";
  }

  // --- HATA BİLDİRİM PENCERESİ (GÜNCELLENDİ) ---
  void _showReportDialog(BuildContext context, String componentId) {
    final TextEditingController _controller = TextEditingController();
    String _selectedReason = "Yanlış Değer"; // Varsayılan

    showDialog(
      context: context,
      barrierDismissible: false, // Dışarı basınca kapanmasın
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF25282F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Row(
                children: [
                  Icon(Icons.bug_report, color: Colors.redAccent),
                  SizedBox(width: 10),
                  Text("Hata Bildir", style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
              content: Material( // GÜVENLİK İÇİN EKLENDİ
                color: Colors.transparent,
                child: SingleChildScrollView( // KLAVYE TAŞMASINI ÖNLER
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Bu bileşenle ilgili bir sorun mu var? Bize bildir, hemen düzeltelim.",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      
                      // Sebep Seçimi
                      DropdownButtonFormField<String>(
                        value: _selectedReason,
                        dropdownColor: const Color(0xFF353A40),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Sorun Nedir?",
                          labelStyle: TextStyle(color: Colors.amber),
                          prefixIcon: Icon(Icons.list, color: Colors.amber),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                          filled: true,
                          fillColor: Colors.black12,
                        ),
                        items: const [
                          DropdownMenuItem(value: "Yanlış Değer", child: Text("Yanlış Voltaj/Akım Değeri")),
                          DropdownMenuItem(value: "Hatalı Pinout", child: Text("Pin Sıralaması Yanlış")),
                          DropdownMenuItem(value: "Görsel Hatası", child: Text("Resim/Kılıf Yanlış")),
                          DropdownMenuItem(value: "Diğer", child: Text("Diğer")),
                        ],
                        onChanged: (val) => setState(() => _selectedReason = val!),
                      ),
                      
                      const SizedBox(height: 15),

                      // Açıklama
                      TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: "Detaylar (Opsiyonel)",
                          labelStyle: TextStyle(color: Colors.grey),
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.description, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.black12,
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("İptal", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                  ),
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text("GÖNDER"),
                  onPressed: () async {
                    Navigator.pop(ctx); 
                    
                    // Firebase'e kaydet
                    await FirestoreService().submitReport(
                      componentId, 
                      _selectedReason, 
                      _controller.text
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 10),
                          Text("Raporunuz bize ulaştı!"),
                        ]),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      )
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}