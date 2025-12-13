class ComponentModel {
  final String id;
  final String category;
  final String polarity;
  final String packageId;
  final String pinoutCode; // YENİ
  final double vMax;
  final double iMax;
  final double powerMax;
  final String testScriptId; // YENİ
  final String description;
  final String datasheetUrl;
  final List<String> pinNames;
  final String applications; // YENİ ALAN

  ComponentModel({
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
    required this.applications,
  });

  // Excel Satırından Model Üretme
  factory ComponentModel.fromExcelRow(List<dynamic> row) {
    // Güvenli veri okuma (Boş gelirse hata vermesin)
    String getSafe(int index) {
      if (index < row.length && row[index] != null) return row[index].toString();
      return "";
    }

    double getSafeDouble(int index) {
      if (index < row.length && row[index] != null) {
        return double.tryParse(row[index].toString()) ?? 0.0;
      }
      return 0.0;
    }

    // Excel Sütun Sırasına Göre Okuma (Python kodumuzdaki sıraya sadık kalıyoruz)
    // 0:id, 1:category, 2:polarity, 3:package_id, 4:pinout_code, 
    // 5:v_max, 6:i_max, 7:power_max, 8:test_script_id, 9:description, 10:url, 11:pin_names, 12:applications
    
    return ComponentModel(
      id: getSafe(0),
      category: getSafe(1),
      polarity: getSafe(2),
      packageId: getSafe(3),
      pinoutCode: getSafe(4).isEmpty ? "123" : getSafe(4), // Boşsa varsayılan
      vMax: getSafeDouble(5),
      iMax: getSafeDouble(6),
      powerMax: getSafeDouble(7),
      testScriptId: getSafe(8).isEmpty ? "TEST_GENERIC" : getSafe(8), // Boşsa varsayılan
      description: getSafe(9),
      datasheetUrl: getSafe(10),
      pinNames: getSafe(11).split(','), // "G,D,S" -> ["G", "D", "S"]
      applications: getSafe(12), // YENİ SÜTUNU OKU
    );
  }
}
