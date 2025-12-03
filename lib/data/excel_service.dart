import 'package:flutter/services.dart' show rootBundle;
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import '../models/component_model.dart';

class ExcelService {
  // Tüm parçaların listesi
  List<Component> allComponents = [];
  
  // SMD Kod Sözlüğü: "1A" -> ["BC846", "MMBT3904"] (Bir kod birden fazla parça olabilir)
  Map<String, List<String>> smdDictionary = {};

  Future<void> loadDatabase() async {
    try {
      print("📂 Excel dosyası yükleniyor...");
      final bytes = await rootBundle.load('assets/db/electronic_components_db.xlsx');
      var decoder = SpreadsheetDecoder.decodeBytes(bytes.buffer.asUint8List());
      
      // 1. KOMPONENTLERİ YÜKLE
      var compTable = decoder.tables['Components'] ?? decoder.tables.values.first;
      allComponents.clear();
      
      for (var i = 1; i < compTable.rows.length; i++) {
        var row = compTable.rows[i];
        if (row.isEmpty || row[0] == null) continue;
        try {
          allComponents.add(Component.fromExcelRow(row));
        } catch (e) {
          print("⚠️ Komponent okuma hatası: $e");
        }
      }

      // 2. SMD KODLARINI YÜKLE
      var smdTable = decoder.tables['SMDCodes'];
      smdDictionary.clear();

      if (smdTable != null) {
        for (var i = 1; i < smdTable.rows.length; i++) {
          var row = smdTable.rows[i];
          // row[0] = Code (örn: 1A), row[1] = ComponentID (örn: BC846)
          if (row.length > 1 && row[0] != null && row[1] != null) {
            String code = row[0].toString().trim().toUpperCase();
            String compId = row[1].toString().trim();

            if (!smdDictionary.containsKey(code)) {
              smdDictionary[code] = [];
            }
            smdDictionary[code]!.add(compId);
          }
        }
        print("✅ SMD Kodları Yüklendi: ${smdDictionary.length} kod hafızada.");
      }

      print("✅ Veritabanı Hazır: ${allComponents.length} parça.");

    } catch (e) {
      print("❌ KRİTİK HATA: Veritabanı yüklenemedi -> $e");
    }
  }

  // ID'ye göre parça bulma (SMD sonuçları için lazım)
  Component? getComponentById(String id) {
    try {
      return allComponents.firstWhere((c) => c.id.toLowerCase() == id.toLowerCase());
    } catch (e) {
      return null;
    }
  }
}
