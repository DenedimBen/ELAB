class Component {
  final String id;
  final String category;
  final String polarity;
  final String packageId;
  final String pinoutCode;
  final double vMax;
  final double iMax;
  final double powerMax;
  final String testScriptId;
  final String description;
  final String datasheetUrl;
  
  // YENİ: PIN İSİMLERİ LİSTESİ
  final List<String> pinNames; 

  Component({
    required this.id,
    required this.category,
    required this.polarity,
    required this.packageId,
    required this.pinoutCode,
    required this.vMax,
    required this.iMax,
    required this.powerMax,
    required this.testScriptId,
    required this.description,
    required this.datasheetUrl,
    required this.pinNames,
  });

  factory Component.fromExcelRow(List<dynamic> row) {
    dynamic getSafe(int index) {
      if (index < row.length && row[index] != null) return row[index];
      return "";
    }

    // Pin isimlerini virgül ile ayırıp listeye çeviriyoruz
    String rawPins = getSafe(11).toString(); // Excel'deki sıraya göre (11. sütun pin_names ise)
    // Python kodunda pin_names en sonda değil, aralarda olabilir.
    // Güvenli okuma için Excel dosyasındaki sütun sırasını kontrol etmek en iyisidir.
    // Bizim Python kodunda pin_names sonlarda. Tahmini index ayarlıyorum:
    
    // Components Data Sırası:
    // 0:id, 1:cat, 2:pol, 3:pack, 4:pin_code, 5:v, 6:i, 7:p, 8:script, 9:desc, 10:man, 11:url, 12:PIN_NAMES
    // (Python kodundaki sözlük sırasına göre Excel yazar, genelde alfabetik DEĞİLDİR, ekleme sırasıdır)
    
    // Düzeltme: Python'da 'pin_names' en sona eklendi. 
    // Ama 'test_script_id' arada. 
    // O yüzden String tabanlı map'leme yapmak daha güvenli olurdu ama şu an index ile gidiyoruz.
    // description -> 9, manufacturer (yoksa) -> atla, pin_names -> 10 olabilir.
    
    // Basitlik için: Eğer pin_names alanı boş gelirse varsayılanları kullan.
    List<String> pNames = [];
    if (rawPins.contains(',')) {
      pNames = rawPins.split(',').map((e) => e.trim()).toList();
    } else {
      pNames = ["1", "2", "3", "4", "5", "6", "7", "8"]; // Varsayılan
    }

    return Component(
      id: getSafe(0).toString(),
      category: getSafe(1).toString(),
      polarity: getSafe(2).toString(),
      packageId: getSafe(3).toString(),
      pinoutCode: getSafe(4).toString(),
      vMax: double.tryParse(getSafe(5).toString()) ?? 0.0,
      iMax: double.tryParse(getSafe(6).toString()) ?? 0.0,
      powerMax: double.tryParse(getSafe(7).toString()) ?? 0.0,
      testScriptId: getSafe(8).toString(), // Sıra kaymış olabilir, kontrol et
      description: getSafe(9).toString(),
      datasheetUrl: "", // Şimdilik boş
      pinNames: pNames,
    );
  }
}