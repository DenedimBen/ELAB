// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'E-LAB';

  @override
  String get navHome => 'Ana Sayfa';

  @override
  String get navCommunity => 'Topluluk';

  @override
  String get navFavorites => 'Favoriler';

  @override
  String get navProfile => 'Profil';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get catComponents => 'BİLEŞENLER';

  @override
  String get calcDesc => 'Direnç, Güç, Bobin...';

  @override
  String get knowledgeBase => 'BİLGİ BANKASI';

  @override
  String get myFavorites => 'مفضلاتي';

  @override
  String get noFavoritesYet => 'لم تتم إضافة أي مفضلة بعد.';

  @override
  String get btnAddProject => 'PROJE EKLE';

  @override
  String get forumTitle => 'E-LAB TOPLULUĞU';

  @override
  String get forumSubtitle => 'Mühendislerin Buluşma Noktası';

  @override
  String get noPostsYet => 'لا توجد منشورات بعد.\nكن أول من ينشر!';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galeri';

  @override
  String get addPhoto => 'Fotoğraf Ekle';

  @override
  String get postTitleHint => 'Konu Başlığı';

  @override
  String get postContentHint => 'Detayları buraya yazın...';

  @override
  String get btnShare => 'Paylaş';

  @override
  String get btnSharing => 'Paylaşılıyor...';

  @override
  String get btnStartTest => 'TESTİ BAŞLAT';

  @override
  String get btnReport => 'Hata Bildir';

  @override
  String get btnSend => 'GÖNDER';

  @override
  String get btnCancel => 'İptal';

  @override
  String get btnYes => 'EVET / UYGUN';

  @override
  String get btnNo => 'HAYIR / FARKLI';

  @override
  String get lblStep => 'ADIM';

  @override
  String get lblTrigger => 'TETİKLEME';

  @override
  String get lblTypicalApps => 'TİPİK UYGULAMALAR';

  @override
  String get lblPinConfig => 'PIN YAPILANDIRMASI';

  @override
  String get lblCompOverview => 'BİLEŞEN ÖZETİ';

  @override
  String get msgReportSent => 'Teşekkürler! Raporun bize ulaştı.';

  @override
  String get msgTestRestarted => 'Test Yeniden Başlatıldı 🔄';

  @override
  String get msgTestFailed => 'Test Başarısız ❌';

  @override
  String get msgTestCompleteTitle => 'TEST TAMAMLANDI';

  @override
  String get msgTestCompleteBody =>
      'Tüm adımlar başarılıysa komponent SAĞLAMDIR.\n\nEğer herhangi bir adımda \'HAYIR\' dediyseniz komponent ARIZALIDIR.';

  @override
  String get msgInfoBubble =>
      'Lütfen ölçü aleti proplarını aşağıda yanıp sönen bacaklara temas ettirin.';

  @override
  String get btnBack => 'Geri';

  @override
  String get btnApplied => 'UYGULADIM';

  @override
  String get btnYesCorrect => 'EVET (Doğru)';

  @override
  String get specMaxVoltage => 'MAKS VOLTAJ';

  @override
  String get specMaxCurrent => 'MAKS AKIM';

  @override
  String get specMaxPower => 'MAKS GÜÇ';

  @override
  String get testPrepTitle => 'Hazırlık & Deşarj';

  @override
  String get testPrepDesc =>
      'Testten önce bileşenin metal bacaklarına aynı anda dokunarak statik elektriği boşaltın.';

  @override
  String get testDiodeModeTitle => 'Dahili Diyot Testi';

  @override
  String testDiodeModeDesc(Object red, Object black) {
    return 'Multimetre DİYOT modunda.\nKırmızı: $red | Siyah: $black';
  }

  @override
  String get testBlockingTitle => 'Kesim (Blocking) Kontrolü';

  @override
  String testBlockingDesc(Object red, Object black) {
    return 'Probları ters çevirin.\nKırmızı: $red | Siyah: $black';
  }

  @override
  String get testTriggerTitle => 'Gate Tetikleme';

  @override
  String testTriggerDesc(Object fixed, Object trigger, Object returnPin) {
    return 'Siyah prob $fixed üzerinde kalsın.\nKırmızı probu anlık olarak $trigger bacağına değdirip çekin, sonra tekrar $returnPin bacağına getirin.';
  }

  @override
  String get testLatchingTitle => 'İletim Kontrolü';

  @override
  String get testLatchingDesc =>
      'Tetiklemeden sonra Drain-Source arası iletime geçmelidir. Değer 0\'a yaklaştı mı?';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'لغة';

  @override
  String get btnOk => 'Tamam';

  @override
  String get tooltipFlip => 'Parçayı Çevir';

  @override
  String descMosfetTemplate(Object pkg, Object pol, Object vmax, Object imax) {
    return 'Bu, $pkg kılıfına sahip yüksek performanslı bir $pol Güç MOSFET\'idir. $vmax gerilime ve $imax sürekli akıma dayanacak şekilde tasarlanmıştır.';
  }

  @override
  String descBjtTemplate(Object pkg, Object pol, Object vmax, Object imax) {
    return '$pkg kılıf yapısında, çok yönlü bir $pol Bipolar Jonksiyon Transistörü (BJT). $vmax gerilim ve $imax akım kapasitesine sahiptir.';
  }

  @override
  String descGenericTemplate(Object pkg, Object cat, Object vmax, Object imax) {
    return '$pkg form faktörüne sahip genel bir elektronik bileşen ($cat). $vmax ve $imax çalışma değerleri için derecelendirilmiştir.';
  }

  @override
  String get toolResistorCalc => 'Direnç Renk Kodu';

  @override
  String get toolCapacitorDec => 'Kapasitör Çözücü';

  @override
  String get toolSmdSearch => 'SMD Kod Arama';

  @override
  String get toolSmdCalc => 'SMD Direnç Hesapla';

  @override
  String get toolInductorColor => 'Bobin Renk Kodu';

  @override
  String get toolValueToCode => 'Değer -> Kod';

  @override
  String get catCalculators => 'HESAPLAYICILAR';

  @override
  String get calculationTools => 'أدوات الحساب';

  @override
  String get basicLaws => 'Temel Kanunlar';

  @override
  String get acCircuits => 'AC Devreler';

  @override
  String get catDiodes => 'Diyotlar';

  @override
  String get digitalLogic => 'Dijital Mantık';

  @override
  String get settingsTitle => 'AYARLAR';

  @override
  String get settingsGeneral => 'GENEL';

  @override
  String get settingsSound => 'Ses Efektleri';

  @override
  String get settingsLanguage => 'Dil / Language';

  @override
  String get profileTitle => 'PROFİL';

  @override
  String get rankCurrent => 'Mevcut Rütbe';

  @override
  String get xpProgress => 'XP İlerlemesi';

  @override
  String get quickTestTitle => 'HIZLI SAĞLAMLIK TESTİ';

  @override
  String get quickTestDesc => 'Modeli yaz, testi başlat...';

  @override
  String get searchComponentTitle => 'Komponent Ara';

  @override
  String get searchHint => 'بحث عن مكون';

  @override
  String get kbSmdCodes => 'SMD KODLARI';

  @override
  String get kbSmdDesc => 'Kılıf üzerindeki kodların karşılığı...';

  @override
  String get commonCalculate => 'HESAPLA';

  @override
  String get commonResult => 'SONUÇ';

  @override
  String get commonClear => 'TEMİZLE';

  @override
  String get commonBands => 'Bantlar';

  @override
  String get commonValue => 'Değer';

  @override
  String get commonVoltage => 'Gerilim (V)';

  @override
  String get commonCurrent => 'Akım (I)';

  @override
  String get commonResistance => 'Direnç (R)';

  @override
  String get commonPower => 'Güç (P)';

  @override
  String get postDetailTitle => 'GÖNDERİ DETAYI';

  @override
  String get comments => 'Yorumlar';

  @override
  String get myProfile => 'PROFİLİM';

  @override
  String get searchStartTest => 'Testi Başlat';

  @override
  String get rank0 => 'Lehim Dumanı';

  @override
  String get rank1 => 'Direnç Okuyucu';

  @override
  String get rank2 => 'Kapasitör Şarjı';

  @override
  String get rank3 => 'Devre Çırağı';

  @override
  String get rank4 => 'Transistör Terbiyecisi';

  @override
  String get rank5 => 'Mantık Kapısı';

  @override
  String get rank6 => 'Op-Amp Ustası';

  @override
  String get rank7 => 'PCB Mimarı';

  @override
  String get rank8 => 'Gömülü Sistemci';

  @override
  String get rank9 => 'Silikon Mühendisi';

  @override
  String get rank10 => 'Yüksek Frekans';

  @override
  String get rank11 => 'Kuantum Mekaniği';

  @override
  String get rank12 => 'Yapay Zeka Çekirdeği';

  @override
  String get rank13 => 'Tekillik';

  @override
  String get rank14 => 'E-LAB EFSANESİ';

  @override
  String get rank15 => 'SİSTEM YÖNETİCİSİ';
}
