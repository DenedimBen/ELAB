import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('hi'),
    Locale('tr'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'E-LAB'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get navHome;

  /// No description provided for @navCommunity.
  ///
  /// In tr, this message translates to:
  /// **'Topluluk'**
  String get navCommunity;

  /// No description provided for @navFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favoriler'**
  String get navFavorites;

  /// No description provided for @navProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get navSettings;

  /// No description provided for @catComponents.
  ///
  /// In tr, this message translates to:
  /// **'BİLEŞENLER'**
  String get catComponents;

  /// No description provided for @calcDesc.
  ///
  /// In tr, this message translates to:
  /// **'Direnç, Güç, Bobin...'**
  String get calcDesc;

  /// No description provided for @knowledgeBase.
  ///
  /// In tr, this message translates to:
  /// **'BİLGİ BANKASI'**
  String get knowledgeBase;

  /// No description provided for @myFavorites.
  ///
  /// In tr, this message translates to:
  /// **'FAVORİLERİM'**
  String get myFavorites;

  /// No description provided for @noFavoritesYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz favori eklenmedi.'**
  String get noFavoritesYet;

  /// No description provided for @btnAddProject.
  ///
  /// In tr, this message translates to:
  /// **'PROJE EKLE'**
  String get btnAddProject;

  /// No description provided for @forumTitle.
  ///
  /// In tr, this message translates to:
  /// **'E-LAB TOPLULUĞU'**
  String get forumTitle;

  /// No description provided for @forumSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Mühendislerin Buluşma Noktası'**
  String get forumSubtitle;

  /// No description provided for @noPostsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz gönderi yok.'**
  String get noPostsYet;

  /// No description provided for @camera.
  ///
  /// In tr, this message translates to:
  /// **'Kamera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In tr, this message translates to:
  /// **'Galeri'**
  String get gallery;

  /// No description provided for @addPhoto.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf Ekle'**
  String get addPhoto;

  /// No description provided for @postTitleHint.
  ///
  /// In tr, this message translates to:
  /// **'Konu Başlığı'**
  String get postTitleHint;

  /// No description provided for @postContentHint.
  ///
  /// In tr, this message translates to:
  /// **'Detayları buraya yazın...'**
  String get postContentHint;

  /// No description provided for @btnShare.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get btnShare;

  /// No description provided for @btnSharing.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşılıyor...'**
  String get btnSharing;

  /// No description provided for @btnStartTest.
  ///
  /// In tr, this message translates to:
  /// **'TESTİ BAŞLAT'**
  String get btnStartTest;

  /// No description provided for @btnReport.
  ///
  /// In tr, this message translates to:
  /// **'Hata Bildir'**
  String get btnReport;

  /// No description provided for @btnSend.
  ///
  /// In tr, this message translates to:
  /// **'GÖNDER'**
  String get btnSend;

  /// No description provided for @btnCancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get btnCancel;

  /// No description provided for @btnYes.
  ///
  /// In tr, this message translates to:
  /// **'EVET / UYGUN'**
  String get btnYes;

  /// No description provided for @btnNo.
  ///
  /// In tr, this message translates to:
  /// **'HAYIR / FARKLI'**
  String get btnNo;

  /// No description provided for @lblStep.
  ///
  /// In tr, this message translates to:
  /// **'ADIM'**
  String get lblStep;

  /// No description provided for @lblTrigger.
  ///
  /// In tr, this message translates to:
  /// **'TETİKLEME'**
  String get lblTrigger;

  /// No description provided for @lblTypicalApps.
  ///
  /// In tr, this message translates to:
  /// **'TİPİK UYGULAMALAR'**
  String get lblTypicalApps;

  /// No description provided for @lblPinConfig.
  ///
  /// In tr, this message translates to:
  /// **'PIN YAPILANDIRMASI'**
  String get lblPinConfig;

  /// No description provided for @lblCompOverview.
  ///
  /// In tr, this message translates to:
  /// **'BİLEŞEN ÖZETİ'**
  String get lblCompOverview;

  /// No description provided for @msgReportSent.
  ///
  /// In tr, this message translates to:
  /// **'Teşekkürler! Raporun bize ulaştı.'**
  String get msgReportSent;

  /// No description provided for @msgTestRestarted.
  ///
  /// In tr, this message translates to:
  /// **'Test Yeniden Başlatıldı 🔄'**
  String get msgTestRestarted;

  /// No description provided for @msgTestFailed.
  ///
  /// In tr, this message translates to:
  /// **'Test Başarısız ❌'**
  String get msgTestFailed;

  /// No description provided for @msgTestCompleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'TEST TAMAMLANDI'**
  String get msgTestCompleteTitle;

  /// No description provided for @msgTestCompleteBody.
  ///
  /// In tr, this message translates to:
  /// **'Tüm adımlar başarılıysa komponent SAĞLAMDIR.\n\nEğer herhangi bir adımda \'HAYIR\' dediyseniz komponent ARIZALIDIR.'**
  String get msgTestCompleteBody;

  /// No description provided for @msgInfoBubble.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen ölçü aleti proplarını aşağıda yanıp sönen bacaklara temas ettirin.'**
  String get msgInfoBubble;

  /// No description provided for @btnBack.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get btnBack;

  /// No description provided for @btnApplied.
  ///
  /// In tr, this message translates to:
  /// **'UYGULADIM'**
  String get btnApplied;

  /// No description provided for @btnYesCorrect.
  ///
  /// In tr, this message translates to:
  /// **'EVET (Doğru)'**
  String get btnYesCorrect;

  /// No description provided for @specMaxVoltage.
  ///
  /// In tr, this message translates to:
  /// **'MAKS VOLTAJ'**
  String get specMaxVoltage;

  /// No description provided for @specMaxCurrent.
  ///
  /// In tr, this message translates to:
  /// **'MAKS AKIM'**
  String get specMaxCurrent;

  /// No description provided for @specMaxPower.
  ///
  /// In tr, this message translates to:
  /// **'MAKS GÜÇ'**
  String get specMaxPower;

  /// No description provided for @testPrepTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hazırlık & Deşarj'**
  String get testPrepTitle;

  /// No description provided for @testPrepDesc.
  ///
  /// In tr, this message translates to:
  /// **'Testten önce bileşenin metal bacaklarına aynı anda dokunarak statik elektriği boşaltın.'**
  String get testPrepDesc;

  /// No description provided for @testDiodeModeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Dahili Diyot Testi'**
  String get testDiodeModeTitle;

  /// No description provided for @testDiodeModeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Multimetre DİYOT modunda.\nKırmızı: {red} | Siyah: {black}'**
  String testDiodeModeDesc(Object red, Object black);

  /// No description provided for @testBlockingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kesim (Blocking) Kontrolü'**
  String get testBlockingTitle;

  /// No description provided for @testBlockingDesc.
  ///
  /// In tr, this message translates to:
  /// **'Probları ters çevirin.\nKırmızı: {red} | Siyah: {black}'**
  String testBlockingDesc(Object red, Object black);

  /// No description provided for @testTriggerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gate Tetikleme'**
  String get testTriggerTitle;

  /// No description provided for @testTriggerDesc.
  ///
  /// In tr, this message translates to:
  /// **'Siyah prob {fixed} üzerinde kalsın.\nKırmızı probu anlık olarak {trigger} bacağına değdirip çekin, sonra tekrar {returnPin} bacağına getirin.'**
  String testTriggerDesc(Object fixed, Object trigger, Object returnPin);

  /// No description provided for @testLatchingTitle.
  ///
  /// In tr, this message translates to:
  /// **'İletim Kontrolü'**
  String get testLatchingTitle;

  /// No description provided for @testLatchingDesc.
  ///
  /// In tr, this message translates to:
  /// **'Tetiklemeden sonra Drain-Source arası iletime geçmelidir. Değer 0\'a yaklaştı mı?'**
  String get testLatchingDesc;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @btnOk.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get btnOk;

  /// No description provided for @tooltipFlip.
  ///
  /// In tr, this message translates to:
  /// **'Parçayı Çevir'**
  String get tooltipFlip;

  /// No description provided for @descMosfetTemplate.
  ///
  /// In tr, this message translates to:
  /// **'Bu, {pkg} kılıfına sahip yüksek performanslı bir {pol} Güç MOSFET\'idir. {vmax} gerilime ve {imax} sürekli akıma dayanacak şekilde tasarlanmıştır.'**
  String descMosfetTemplate(Object pkg, Object pol, Object vmax, Object imax);

  /// No description provided for @descBjtTemplate.
  ///
  /// In tr, this message translates to:
  /// **'{pkg} kılıf yapısında, çok yönlü bir {pol} Bipolar Jonksiyon Transistörü (BJT). {vmax} gerilim ve {imax} akım kapasitesine sahiptir.'**
  String descBjtTemplate(Object pkg, Object pol, Object vmax, Object imax);

  /// No description provided for @descGenericTemplate.
  ///
  /// In tr, this message translates to:
  /// **'{pkg} form faktörüne sahip genel bir elektronik bileşen ({cat}). {vmax} ve {imax} çalışma değerleri için derecelendirilmiştir.'**
  String descGenericTemplate(Object pkg, Object cat, Object vmax, Object imax);

  /// No description provided for @toolResistorCalc.
  ///
  /// In tr, this message translates to:
  /// **'Direnç Renk Kodu'**
  String get toolResistorCalc;

  /// No description provided for @toolCapacitorDec.
  ///
  /// In tr, this message translates to:
  /// **'Kapasitör Çözücü'**
  String get toolCapacitorDec;

  /// No description provided for @toolSmdSearch.
  ///
  /// In tr, this message translates to:
  /// **'SMD Kod Arama'**
  String get toolSmdSearch;

  /// No description provided for @toolSmdCalc.
  ///
  /// In tr, this message translates to:
  /// **'SMD Direnç Hesapla'**
  String get toolSmdCalc;

  /// No description provided for @toolInductorColor.
  ///
  /// In tr, this message translates to:
  /// **'Bobin Renk Kodu'**
  String get toolInductorColor;

  /// No description provided for @toolValueToCode.
  ///
  /// In tr, this message translates to:
  /// **'Değer -> Kod'**
  String get toolValueToCode;

  /// No description provided for @catCalculators.
  ///
  /// In tr, this message translates to:
  /// **'HESAPLAYICILAR'**
  String get catCalculators;

  /// No description provided for @calculationTools.
  ///
  /// In tr, this message translates to:
  /// **'Mühendislik Araçları'**
  String get calculationTools;

  /// No description provided for @basicLaws.
  ///
  /// In tr, this message translates to:
  /// **'Temel Kanunlar'**
  String get basicLaws;

  /// No description provided for @acCircuits.
  ///
  /// In tr, this message translates to:
  /// **'AC Devreler'**
  String get acCircuits;

  /// No description provided for @catDiodes.
  ///
  /// In tr, this message translates to:
  /// **'Diyotlar'**
  String get catDiodes;

  /// No description provided for @digitalLogic.
  ///
  /// In tr, this message translates to:
  /// **'Dijital Mantık'**
  String get digitalLogic;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'AYARLAR'**
  String get settingsTitle;

  /// No description provided for @settingsGeneral.
  ///
  /// In tr, this message translates to:
  /// **'GENEL'**
  String get settingsGeneral;

  /// No description provided for @settingsSound.
  ///
  /// In tr, this message translates to:
  /// **'Ses Efektleri'**
  String get settingsSound;

  /// No description provided for @settingsLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil / Language'**
  String get settingsLanguage;

  /// No description provided for @profileTitle.
  ///
  /// In tr, this message translates to:
  /// **'PROFİL'**
  String get profileTitle;

  /// No description provided for @rankCurrent.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Rütbe'**
  String get rankCurrent;

  /// No description provided for @xpProgress.
  ///
  /// In tr, this message translates to:
  /// **'XP İlerlemesi'**
  String get xpProgress;

  /// No description provided for @quickTestTitle.
  ///
  /// In tr, this message translates to:
  /// **'HIZLI SAĞLAMLIK TESTİ'**
  String get quickTestTitle;

  /// No description provided for @quickTestDesc.
  ///
  /// In tr, this message translates to:
  /// **'Modeli yaz, testi başlat...'**
  String get quickTestDesc;

  /// No description provided for @searchComponentTitle.
  ///
  /// In tr, this message translates to:
  /// **'Komponent Ara'**
  String get searchComponentTitle;

  /// No description provided for @searchHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: IRF3205, 7805...'**
  String get searchHint;

  /// No description provided for @kbSmdCodes.
  ///
  /// In tr, this message translates to:
  /// **'SMD KODLARI'**
  String get kbSmdCodes;

  /// No description provided for @kbSmdDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kılıf üzerindeki kodların karşılığı...'**
  String get kbSmdDesc;

  /// No description provided for @commonCalculate.
  ///
  /// In tr, this message translates to:
  /// **'HESAPLA'**
  String get commonCalculate;

  /// No description provided for @commonResult.
  ///
  /// In tr, this message translates to:
  /// **'SONUÇ'**
  String get commonResult;

  /// No description provided for @commonClear.
  ///
  /// In tr, this message translates to:
  /// **'TEMİZLE'**
  String get commonClear;

  /// No description provided for @commonBands.
  ///
  /// In tr, this message translates to:
  /// **'Bantlar'**
  String get commonBands;

  /// No description provided for @commonValue.
  ///
  /// In tr, this message translates to:
  /// **'Değer'**
  String get commonValue;

  /// No description provided for @commonVoltage.
  ///
  /// In tr, this message translates to:
  /// **'Gerilim (V)'**
  String get commonVoltage;

  /// No description provided for @commonCurrent.
  ///
  /// In tr, this message translates to:
  /// **'Akım (I)'**
  String get commonCurrent;

  /// No description provided for @commonResistance.
  ///
  /// In tr, this message translates to:
  /// **'Direnç (R)'**
  String get commonResistance;

  /// No description provided for @commonPower.
  ///
  /// In tr, this message translates to:
  /// **'Güç (P)'**
  String get commonPower;

  /// No description provided for @postDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'GÖNDERİ DETAYI'**
  String get postDetailTitle;

  /// No description provided for @comments.
  ///
  /// In tr, this message translates to:
  /// **'Yorumlar'**
  String get comments;

  /// No description provided for @myProfile.
  ///
  /// In tr, this message translates to:
  /// **'PROFİLİM'**
  String get myProfile;

  /// No description provided for @searchStartTest.
  ///
  /// In tr, this message translates to:
  /// **'Testi Başlat'**
  String get searchStartTest;

  /// No description provided for @rank0.
  ///
  /// In tr, this message translates to:
  /// **'Lehim Dumanı'**
  String get rank0;

  /// No description provided for @rank1.
  ///
  /// In tr, this message translates to:
  /// **'Direnç Okuyucu'**
  String get rank1;

  /// No description provided for @rank2.
  ///
  /// In tr, this message translates to:
  /// **'Kapasitör Şarjı'**
  String get rank2;

  /// No description provided for @rank3.
  ///
  /// In tr, this message translates to:
  /// **'Devre Çırağı'**
  String get rank3;

  /// No description provided for @rank4.
  ///
  /// In tr, this message translates to:
  /// **'Transistör Terbiyecisi'**
  String get rank4;

  /// No description provided for @rank5.
  ///
  /// In tr, this message translates to:
  /// **'Mantık Kapısı'**
  String get rank5;

  /// No description provided for @rank6.
  ///
  /// In tr, this message translates to:
  /// **'Op-Amp Ustası'**
  String get rank6;

  /// No description provided for @rank7.
  ///
  /// In tr, this message translates to:
  /// **'PCB Mimarı'**
  String get rank7;

  /// No description provided for @rank8.
  ///
  /// In tr, this message translates to:
  /// **'Gömülü Sistemci'**
  String get rank8;

  /// No description provided for @rank9.
  ///
  /// In tr, this message translates to:
  /// **'Silikon Mühendisi'**
  String get rank9;

  /// No description provided for @rank10.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek Frekans'**
  String get rank10;

  /// No description provided for @rank11.
  ///
  /// In tr, this message translates to:
  /// **'Kuantum Mekaniği'**
  String get rank11;

  /// No description provided for @rank12.
  ///
  /// In tr, this message translates to:
  /// **'Yapay Zeka Çekirdeği'**
  String get rank12;

  /// No description provided for @rank13.
  ///
  /// In tr, this message translates to:
  /// **'Tekillik'**
  String get rank13;

  /// No description provided for @rank14.
  ///
  /// In tr, this message translates to:
  /// **'E-LAB EFSANESİ'**
  String get rank14;

  /// No description provided for @rank15.
  ///
  /// In tr, this message translates to:
  /// **'SİSTEM YÖNETİCİSİ'**
  String get rank15;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'es',
    'hi',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'hi':
      return AppLocalizationsHi();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
