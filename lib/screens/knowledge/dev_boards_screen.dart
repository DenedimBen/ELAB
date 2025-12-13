import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_1/screens/knowledge/hardware_detail_screen.dart';

class DevBoardsScreen extends StatefulWidget {
  const DevBoardsScreen({super.key});

  @override
  State<DevBoardsScreen> createState() => _DevBoardsScreenState();
}

class _DevBoardsScreenState extends State<DevBoardsScreen> {
  int _selectedCategoryIndex = 0;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // --- KART VERİTABANI (TÜM VERİLER VE ÖZELLİKLER DAHİL) ---
  final List<Map<String, dynamic>> allBoards = [
    
    // --- 1. ARDUINO NANO AILESİ ---
    {
      "name": "Arduino Nano",
      "category": "Arduino",
      "heroImage": "assets/images/nano_board.png",
      "desc": "ATmega328P tabanlı, breadboard dostu klasik kart.",
      "features": [
        {"type": "processor", "title": "ATmega328P", "desc": "16 MHz hızında çalışan klasik 8-bit AVR mikrodenetleyici."},
        {"type": "power", "title": "5V Çalışma Gerilimi", "desc": "USB veya Vin pini üzerinden 7-12V giriş ile beslenebilir."},
        {"type": "memory", "title": "Hafıza", "desc": "32 KB Flash (2KB bootloader), 2 KB SRAM, 1 KB EEPROM."},
        {"type": "default", "title": "Kompakt Tasarım", "desc": "Breadboard üzerinde kullanım için ideal küçük form faktörü."},
      ],
      "resources": [
        {"title": "Pinout", "path": "assets/pinouts/nano_pinouts.pdf"},
        {"title": "Datasheet", "path": "assets/pinouts/nano_datasheet.pdf"},
        {"title": "Schematics", "path": "assets/pinouts/nano_schematics.pdf"},
      ]
    },
    {
      "name": "Nano 33 BLE",
      "category": "Arduino",
      "heroImage": "assets/images/nano_33_ble.png",
      "desc": "Bluetooth Low Energy ve 9 eksenli IMU sensörü içeren 3.3V kart.",
      "features": [
        {"type": "bluetooth", "title": "Bluetooth® 5.0", "desc": "u-blox NINA-B306 modülü ile güçlü BLE bağlantısı."},
        {"type": "imu", "title": "9 Eksenli IMU", "desc": "LSM9DS1 (İvmeölçer, Jiroskop, Manyetometre) ile hareket algılama."},
        {"type": "processor", "title": "nRF52840 İşlemci", "desc": "64 MHz hızında 32-bit ARM® Cortex™-M4 işlemci."},
        {"type": "python", "title": "MicroPython", "desc": "Python programlama dili ile kodlanabilir."},
      ],
      "resources": [
        {"title": "Pinout", "path": "assets/pinouts/nano_33_ble_pinout.pdf"},
        {"title": "Datasheet", "path": "assets/pinouts/nano_33_ble_datasheet.pdf"},
        {"title": "Schematics", "path": "assets/pinouts/nano_33_ble_schematics.pdf"},
      ]
    },
    {
      "name": "Nano 33 IoT",
      "category": "Arduino",
      "heroImage": "assets/images/nano_33_iot.png",
      "desc": "Güvenli WiFi ve Bluetooth bağlantısı gerektiren IoT projeleri için.",
      "features": [
        {"type": "wifi", "title": "Wi-Fi & BT", "desc": "u-blox NINA-W102 modülü ile güvenli IoT bağlantısı."},
        {"type": "security", "title": "Kripto Çip", "desc": "ECC608A ile ultra güvenli veri depolama ve transferi."},
        {"type": "processor", "title": "SAMD21 İşlemci", "desc": "Düşük güç tüketen 32-bit ARM Cortex-M0+."},
        {"type": "power", "title": "3.3V Mantık", "desc": "Modern sensörlerle doğrudan uyumluluk."},
      ],
      "resources": [
        {"title": "Pinout", "path": "assets/pinouts/nano_33_iot_pinout.pdf"},
        {"title": "Datasheet", "path": "assets/pinouts/nano_33_iot_datasheet.pdf"},
      ]
    },
    {
      "name": "Nano ESP32",
      "category": "Arduino",
      "heroImage": "assets/images/nano_esp32.png",
      "desc": "Arduino ekosistemi ve MicroPython desteği ile güçlü ESP32-S3 işlemcisi.",
      "features": [
        {"type": "processor", "title": "ESP32-S3", "desc": "240 MHz çift çekirdekli güçlü Xtensa LX7 işlemci."},
        {"type": "wifi", "title": "Wi-Fi & BLE", "desc": "Tam entegre 2.4 GHz Wi-Fi ve Bluetooth 5 (LE)."},
        {"type": "memory", "title": "Geniş Hafıza", "desc": "16 MB Harici Flash ve 512 KB SRAM."},
        {"type": "python", "title": "MicroPython & Arduino", "desc": "Her iki platformda da kolayca programlanabilir."},
      ],
      "resources": [
        {"title": "Pinout", "path": "assets/pinouts/nano_esp32_pinout.pdf"},
        {"title": "Datasheet", "path": "assets/pinouts/nano_esp32_datasheet.pdf"},
        {"title": "Schematics", "path": "assets/pinouts/nano_esp32_schematics.pdf"},
      ]
    },
    {
      "name": "Nano Every",
      "category": "Arduino",
      "heroImage": "assets/images/nano_every.png",
      "desc": "Klasik Nano'nun daha güçlü ve ucuz halefi (5V).",
      "features": [
        {"type": "processor", "title": "ATMega4809", "desc": "20 MHz hızında, klasik Nano'dan daha güçlü AVR işlemci."},
        {"type": "memory", "title": "Artırılmış Hafıza", "desc": "48 KB Flash ve 6 KB SRAM ile daha büyük projeler."},
        {"type": "power", "title": "5V Uyumlu", "desc": "Mevcut 5V sensörler ve shield'lar ile çalışır."},
        {"type": "default", "title": "Pin Uyumlu", "desc": "Klasik Nano ile aynı pin dizilimine sahiptir."},
      ],
      "resources": [
        {"title": "Pinout", "path": "assets/pinouts/nano_every_pinout.pdf"},
        {"title": "Datasheet", "path": "assets/pinouts/nano_every_datasheet.pdf"},
        {"title": "Schematics", "path": "assets/pinouts/nano_every_schematics.pdf"},
      ]
    },
    {
      "name": "Nano Matter",
      "category": "Arduino",
      "heroImage": "assets/images/nano_matter.png",
      "desc": "Matter standardını destekleyen ilk Arduino kartı.",
      "features": [
        {"type": "bluetooth", "title": "Matter & Thread", "desc": "Akıllı ev cihazları için yeni nesil bağlantı standardı."},
        {"type": "processor", "title": "MGM240S", "desc": "Silicon Labs tarafından üretilen güçlü kablosuz SoC."},
        {"type": "security", "title": "Gelişmiş Güvenlik", "desc": "Donanım tabanlı güvenlik hızlandırıcıları içerir."},
      ],
      "resources": [
        {"title": "Pinout", "path": "assets/pinouts/nano_metter_pinout.pdf"},
        {"title": "Datasheet", "path": "assets/pinouts/nano_metter_datasheet.pdf"},
        {"title": "Schematics", "path": "assets/pinouts/nano_metter_schematics.pdf"},
      ]
    },
    {
      "name": "Nano RP2040 Connect",
      "category": "Arduino",
      "heroImage": "assets/images/nano_rp2040_connect.png",
      "desc": "Raspberry Pi işlemcisi, WiFi, BT, Mikrofon ve IMU sensörleri.",
      "features": [
        {"type": "processor", "title": "Raspberry Pi RP2040", "desc": "Çift çekirdekli 133 MHz ARM Cortex-M0+ işlemci."},
        {"type": "wifi", "title": "Tam Bağlantı", "desc": "u-blox NINA-W102 ile Wi-Fi ve Bluetooth bağlantısı."},
        {"type": "sensor", "title": "Dahili Sensörler", "desc": "6 eksenli IMU ve MEMS mikrofon içerir."},
        {"type": "memory", "title": "16MB Flash", "desc": "Kod ve veri depolama için ekstra geniş harici flash."},
      ],
      "resources": [
        {"title": "Pinout", "path": "assets/pinouts/nano_rp2040_connect_pinout.pdf"},
      ]
    },

    // --- 2. UNO AILESİ ---
    {
      "name": "Arduino Uno R3",
      "category": "Arduino",
      "heroImage": "assets/images/uno_board.png",
      "desc": "Dünyanın en popüler başlangıç kartı.",
      "features": [
        {"type": "processor", "title": "ATmega328P", "desc": "16 MHz hızında, değiştirilebilir DIP kılıf işlemci."},
        {"type": "power", "title": "5V Standart", "desc": "Geniş Arduino Shield ekosistemiyle tam uyumlu."},
        {"type": "default", "title": "Kolay Kullanım", "desc": "Yeni başlayanlar için en iyi belgelenmiş kart."},
        {"type": "default", "title": "Dayanıklı", "desc": "Hata yapmaya müsait, sağlam yapı."},
      ],
      "resources": [
        {"title": "Pinout (SMD)", "path": "assets/pinouts/uno_r3_smd_pinouts.pdf"},
        {"title": "Schematics (SMD)", "path": "assets/pinouts/uno_r3_smd_schematics.pdf"},
        {"title": "Standard Schematics", "path": "assets/pinouts/arduino_uno_schematics.pdf"},
      ]
    },
    {
      "name": "Uno WiFi Rev2",
      "category": "Arduino",
      "heroImage": "assets/images/uno_wifi_rev2.png",
      "desc": "Uno form faktöründe entegre WiFi ve IMU sensörü.",
      "features": [
        {"type": "wifi", "title": "Wi-Fi Bağlantısı", "desc": "Entegre u-blox NINA-W102 modülü."},
        {"type": "processor", "title": "ATmega4809", "desc": "Daha fazla hafızaya sahip 8-bit AVR işlemci."},
        {"type": "imu", "title": "Dahili IMU", "desc": "LSM6DS3TR ile hareket ve yönelim algılama."},
        {"type": "security", "title": "Kripto Çip", "desc": "ECC608A ile güvenli iletişim."},
      ],
      "resources": [
        {"title": "Pinout", "path": "assets/pinouts/uno_wifi_rev2_pinout.pdf"},
        {"title": "Schematics", "path": "assets/pinouts/uno_wifi_rev2_schematics.pdf"},
      ]
    },

    // --- 3. PORTENTA & NICLA (PRO) ---
    {
      "name": "Portenta H7",
      "category": "Pro",
      "heroImage": "assets/images/portenta_h7.png",
      "desc": "Çift çekirdekli endüstriyel güç merkezi (M7 + M4).",
      "features": [
        {"type": "processor", "title": "Çift Çekirdek", "desc": "STM32H747 (480 MHz M7 + 240 MHz M4) yüksek performans."},
        {"type": "default", "title": "AI/ML Hazır", "desc": "TensorFlow™ Lite ile uçta yapay zeka çalıştırabilir."},
        {"type": "wifi", "title": "Endüstriyel Bağlantı", "desc": "WiFi, BLE ve Ethernet (opsiyonel) desteği."},
        {"type": "default", "title": "Yüksek Yoğunluklu Konnektörler", "desc": "İki adet 80 pinli konnektör ile genişletilebilirlik."},
      ],
      "resources": [
        {"title": "Pinout", "path": "assets/pinouts/portenta_33_pinout.pdf"}, 
        {"title": "Datasheet", "path": "assets/pinouts/portenta_33_datasheet.pdf"},
        {"title": "Schematics", "path": "assets/pinouts/portenta_33_schematics.pdf"},
      ]
    },
    {
      "name": "Portenta C33",
      "category": "Pro",
      "heroImage": "assets/images/portenta_c33.png",
      "desc": "Uygun maliyetli endüstriyel IoT modülü.",
      "features": [
        {"type": "processor", "title": "Renesas RA6M5", "desc": "200 MHz hızında ARM® Cortex®-M33 işlemci."},
        {"type": "wifi", "title": "Tam Bağlantı", "desc": "Wi-Fi, BLE ve Ethernet bağlantı seçenekleri."},
        {"type": "security", "title": "Secure Element", "desc": "Endüstriyel seviyede güvenlik sertifikaları."},
      ],
      "resources": [
        {"title": "Schematics", "path": "assets/pinouts/Portenta_C33_schematics.pdf"},
      ]
    },
    {
      "name": "Nicla Sense ME",
      "category": "Pro",
      "heroImage": "assets/images/nicla_sense.png",
      "desc": "Yapay zeka ve hareket algılama odaklı minik sensör kartı.",
      "features": [
        {"type": "sensor", "title": "Bosch Sensörleri", "desc": "BHI260AP (AI), BMP390 (Basınç), BMM150 (Manyetometre), BME688 (Gaz)."},
        {"type": "default", "title": "Ultra Kompakt", "desc": "Sadece 22.86 x 22.86 mm boyutlarında."},
        {"type": "bluetooth", "title": "BLE Bağlantısı", "desc": "Düşük güç tüketimi ile kablosuz veri aktarımı."},
        {"type": "processor", "title": "NRF52832", "desc": "Sensör füzyonu ve BLE için ana işlemci."},
      ],
      "resources": [
        {"title": "Pinout", "path": "assets/pinouts/nicla_sense_env_pinout.pdf"},
        {"title": "Datasheet", "path": "assets/pinouts/nicla_sense_env_datasheet.pdf"},
        {"title": "Schematics", "path": "assets/pinouts/nicla_sense_env_schematics.pdf"},
      ]
    },
    {
      "name": "Nicla Vision",
      "category": "Pro",
      "heroImage": "assets/images/nicla_vision.png",
      "desc": "Görüntü işleme için 2MP kameralı akıllı sensör.",
      "features": [
        {"type": "default", "title": "2MP Renkli Kamera", "desc": "Gömülü görüntü işleme ve makine görüşü için."},
        {"type": "sensor", "title": "Akıllı Sensörler", "desc": "ToF (Mesafe), Mikrofon ve 6 eksenli IMU."},
        {"type": "processor", "title": "Çift Çekirdek STM32H7", "desc": "Görüntü işleme için yüksek performanslı işlemci."},
        {"type": "wifi", "title": "Kablosuz Bağlantı", "desc": "Entegre WiFi ve Bluetooth modülü."},
      ],
      "resources": [] 
    },

    // --- 4. DİĞERLERİ ---
    {
      "name": "Arduino Micro",
      "category": "Arduino",
      "heroImage": "assets/images/micro.png",
      "desc": "Leonardo'nun küçültülmüş versiyonu. USB HID destekler.",
      "features": [
        {"type": "processor", "title": "ATmega32U4", "desc": "Dahili USB desteğine sahip AVR işlemci."},
        {"type": "default", "title": "USB HID", "desc": "Bilgisayara klavye veya fare olarak tanıtılabilir."},
        {"type": "power", "title": "5V Çalışma", "desc": "Kompakt form faktöründe 5V mantık seviyesi."},
      ],
      "resources": [
         // PDF varsa ekle
      ]
    },
    {
      "name": "Arduino Yun Rev2",
      "category": "SBC",
      "heroImage": "assets/images/arduino_yun.png",
      "desc": "Linux işlemci ile Arduino'yu birleştiren hibrit kart.",
      "features": [
        {"type": "processor", "title": "Hibrit Mimari", "desc": "ATmega32U4 (Arduino) + Atheros AR9331 (Linux)."},
        {"type": "wifi", "title": "Güçlü Ağ", "desc": "Dahili Wi-Fi ve Ethernet portu."},
        {"type": "default", "title": "Linux OS", "desc": "OpenWrt tabanlı Linux dağıtımı çalıştırır."},
        {"type": "memory", "title": "SD Kart Yuvası", "desc": "Ekstra depolama için microSD desteği."},
      ],
      "resources": [
        {"title": "Pinout", "path": "assets/pinouts/yun_rev2_pinout.pdf"},
      ]
    },
    {
      "name": "MKR GSM 1400",
      "category": "SBC",
      "heroImage": "assets/images/mkr_gsm_1400.png",
      "desc": "GSM/3G şebekesi üzerinden IoT bağlantısı sağlar.",
      "features": [
        {"type": "default", "title": "Hücresel Bağlantı", "desc": "SARA-U201 modülü ile küresel GSM/3G kapsama alanı."},
        {"type": "processor", "title": "SAMD21", "desc": "Düşük güç tüketen 32-bit Cortex-M0+ işlemci."},
        {"type": "power", "title": "Li-Po Şarj Devresi", "desc": "Dahili batarya bağlantısı ve şarj yönetimi."},
        {"type": "security", "title": "Güvenli IoT", "desc": "ECC508 kripto çipi ile güvenli kimlik doğrulama."},
      ],
      "resources": [
        {"title": "Pinout", "path": "assets/pinouts/mkr_gsm_1400_pinout.pdf"},
      ]
    },
  ];

  final List<String> categories = ["TÜMÜ", "ARDUINO", "ESP", "SBC", "PRO"];

  @override
  Widget build(BuildContext context) {
    // 1. Filtreleme Mantığı
    List<Map<String, dynamic>> filteredList = _selectedCategoryIndex == 0
        ? allBoards
        : allBoards.where((b) => _matchesCategory(b['category'], categories[_selectedCategoryIndex])).toList();

    // 2. Arama Mantığı
    if (_searchQuery.isNotEmpty) {
      filteredList = filteredList
          .where((board) => board['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E2126), // Orijinal Koyu Arka Plan
      appBar: AppBar(
        title: Text("GELİŞTİRME KARTLARI", style: GoogleFonts.orbitron(color: Colors.amber, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          // --- ARAMA ÇUBUĞU ---
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: const Color(0xFF2B2E36),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.amber,
              decoration: const InputDecoration(
                hintText: "Kart Ara...",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.amber),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // --- KATEGORİLER ---
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedCategoryIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategoryIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.amber : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? Colors.amber : Colors.white10),
                    ),
                    child: Text(
                      categories[index],
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // --- GRID LİSTE (ORİJİNAL TASARIM) ---
          Expanded(
            child: filteredList.isEmpty
                ? Center(child: Text("Sonuç bulunamadı...", style: TextStyle(color: Colors.grey[600])))
                : GridView.builder(
                    padding: const EdgeInsets.all(15),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.70, 
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return _buildOriginalCard(context, filteredList[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool _matchesCategory(String boardCat, String selectedCat) {
    if (selectedCat == "TÜMÜ") return true;
    if (selectedCat == "ARDUINO" && boardCat == "Arduino") return true;
    if (selectedCat == "ESP" && boardCat == "ESP") return true;
    if (selectedCat == "SBC" && boardCat == "SBC") return true;
    if (selectedCat == "PRO" && boardCat == "Pro") return true;
    return false;
  }

  Widget _buildOriginalCard(BuildContext context, Map<String, dynamic> board) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HardwareDetailScreen(itemData: board)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2B2E36),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RESİM
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Hero(
                  tag: board['name'],
                  child: board['heroImage'] != null
                    ? Image.asset(board['heroImage'], fit: BoxFit.contain, errorBuilder: (c,o,s) => const Icon(Icons.developer_board, size: 50, color: Colors.grey))
                    : const Icon(Icons.developer_board, size: 50, color: Colors.grey),
                ),
              ),
            ),
            
            // BİLGİ
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      board['name'],
                      style: GoogleFonts.teko(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.0),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      board['desc'],
                      style: const TextStyle(color: Colors.grey, fontSize: 10, height: 1.2),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text("İNCELE", style: GoogleFonts.orbitron(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 5),
                        const Icon(Icons.arrow_forward, size: 12, color: Colors.amber),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}