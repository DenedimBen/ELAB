class Component {
  final String id;
  final String category;
  final String polarity;
  final String packageId;
  final String pinoutCode;
  final double vMax;
  final double iMax;
  final double powerMax;
  final double vTrig; // Yeni: Tetikleme Voltajı
  final double rDs;   // Yeni: İç Direnç
  final double hFe;   // Yeni: Kazanç
  final double speed; // Yeni: Hız (ns)
  final String testScriptId;

  Component({
    required this.id,
    required this.category,
    required this.polarity,
    required this.packageId,
    required this.pinoutCode,
    required this.vMax,
    required this.iMax,
    required this.powerMax,
    required this.vTrig,
    required this.rDs,
    required this.hFe,
    required this.speed,
    required this.testScriptId,
  });

  factory Component.fromExcelRow(List<dynamic> row) {
    dynamic getSafe(int index) {
      if (index < row.length && row[index] != null) {
        return row[index];
      }
      return "";
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
      // Yeni Sütunlar (Excel sırasına dikkat!)
      vTrig: double.tryParse(getSafe(8).toString()) ?? 0.0,
      rDs: double.tryParse(getSafe(9).toString()) ?? 0.0,
      hFe: double.tryParse(getSafe(10).toString()) ?? 0.0,
      speed: double.tryParse(getSafe(11).toString()) ?? 0.0,
      testScriptId: getSafe(12).toString(),
    );
  }
}