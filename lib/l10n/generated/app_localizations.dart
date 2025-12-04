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

  /// No description provided for @appSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'ELEKTRONİK ASİSTANI'**
  String get appSubtitle;

  /// No description provided for @searchHint.
  ///
  /// In tr, this message translates to:
  /// **'Komponent Ara...'**
  String get searchHint;

  /// No description provided for @navHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get navHome;

  /// No description provided for @navTools.
  ///
  /// In tr, this message translates to:
  /// **'Araçlar'**
  String get navTools;

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

  /// No description provided for @catTransistors.
  ///
  /// In tr, this message translates to:
  /// **'TRANSİSTÖRLER'**
  String get catTransistors;

  /// No description provided for @catDiodes.
  ///
  /// In tr, this message translates to:
  /// **'DİYOTLAR'**
  String get catDiodes;

  /// No description provided for @catRegulators.
  ///
  /// In tr, this message translates to:
  /// **'REGÜLATÖRLER'**
  String get catRegulators;

  /// No description provided for @catCapacitors.
  ///
  /// In tr, this message translates to:
  /// **'KONDANSATÖRLER'**
  String get catCapacitors;

  /// No description provided for @catResistors.
  ///
  /// In tr, this message translates to:
  /// **'DİRENÇLER'**
  String get catResistors;

  /// No description provided for @catICs.
  ///
  /// In tr, this message translates to:
  /// **'ENTEGRELER'**
  String get catICs;

  /// No description provided for @toolResistorCalc.
  ///
  /// In tr, this message translates to:
  /// **'DİRENÇ\nRENK KODU'**
  String get toolResistorCalc;

  /// No description provided for @toolCapacitorDec.
  ///
  /// In tr, this message translates to:
  /// **'KONDANSATÖR\nÇÖZÜCÜ'**
  String get toolCapacitorDec;

  /// No description provided for @toolSmdSearch.
  ///
  /// In tr, this message translates to:
  /// **'SMD KOD\nDEDEKTİFİ'**
  String get toolSmdSearch;

  /// No description provided for @toolSmdCalc.
  ///
  /// In tr, this message translates to:
  /// **'SMD DİRENÇ\nHESAPLA'**
  String get toolSmdCalc;

  /// No description provided for @toolInductorColor.
  ///
  /// In tr, this message translates to:
  /// **'İNDÜKTÖR\nRENK KODU'**
  String get toolInductorColor;

  /// No description provided for @toolValueToCode.
  ///
  /// In tr, this message translates to:
  /// **'DEĞER -> KOD\nÇEVİRİCİ'**
  String get toolValueToCode;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'AYARLAR'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @community.
  ///
  /// In tr, this message translates to:
  /// **'TOPLULUK'**
  String get community;

  /// No description provided for @forumTitle.
  ///
  /// In tr, this message translates to:
  /// **'FORUM'**
  String get forumTitle;

  /// No description provided for @forumSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'TOPLULUK VİTRİNİ'**
  String get forumSubtitle;

  /// No description provided for @btnAddProject.
  ///
  /// In tr, this message translates to:
  /// **'PROJE EKLE'**
  String get btnAddProject;

  /// No description provided for @btnShare.
  ///
  /// In tr, this message translates to:
  /// **'PAYLAŞ'**
  String get btnShare;

  /// No description provided for @btnSharing.
  ///
  /// In tr, this message translates to:
  /// **'YÜKLENİYOR...'**
  String get btnSharing;

  /// No description provided for @noPostsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz gönderi yok.\nİlk sen paylaş!'**
  String get noPostsYet;

  /// No description provided for @postTitleHint.
  ///
  /// In tr, this message translates to:
  /// **'Başlık (Örn: IRF3205 Devresi)'**
  String get postTitleHint;

  /// No description provided for @postContentHint.
  ///
  /// In tr, this message translates to:
  /// **'Nasıl yaptın? Hangi malzemeleri kullandın?'**
  String get postContentHint;

  /// No description provided for @addPhoto.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf Ekle'**
  String get addPhoto;

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

  /// No description provided for @author.
  ///
  /// In tr, this message translates to:
  /// **'Yapan:'**
  String get author;

  /// No description provided for @comments.
  ///
  /// In tr, this message translates to:
  /// **'Yorumlar'**
  String get comments;

  /// No description provided for @reply.
  ///
  /// In tr, this message translates to:
  /// **'Yanıtla'**
  String get reply;

  /// No description provided for @edit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @promote.
  ///
  /// In tr, this message translates to:
  /// **'Boost'**
  String get promote;

  /// No description provided for @promoted.
  ///
  /// In tr, this message translates to:
  /// **'PRO'**
  String get promoted;

  /// No description provided for @errorOccurred.
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu!'**
  String get errorOccurred;

  /// No description provided for @myFavorites.
  ///
  /// In tr, this message translates to:
  /// **'FAVORİLERİM'**
  String get myFavorites;

  /// No description provided for @noFavoritesYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz favori eklemedin.'**
  String get noFavoritesYet;

  /// No description provided for @calculationTools.
  ///
  /// In tr, this message translates to:
  /// **'HESAPLAMA ARAÇLARI'**
  String get calculationTools;

  /// No description provided for @btnTestOpen.
  ///
  /// In tr, this message translates to:
  /// **'TEST LABORATUVARINI AÇ'**
  String get btnTestOpen;

  /// No description provided for @stepReady.
  ///
  /// In tr, this message translates to:
  /// **'HAZIRLIK'**
  String get stepReady;

  /// No description provided for @msgReady.
  ///
  /// In tr, this message translates to:
  /// **'Teste başlamak için butona bas.'**
  String get msgReady;

  /// No description provided for @btnStart.
  ///
  /// In tr, this message translates to:
  /// **'TESTİ BAŞLAT'**
  String get btnStart;

  /// No description provided for @btnYes.
  ///
  /// In tr, this message translates to:
  /// **'EVET'**
  String get btnYes;

  /// No description provided for @btnNo.
  ///
  /// In tr, this message translates to:
  /// **'HAYIR'**
  String get btnNo;

  /// No description provided for @resultGood.
  ///
  /// In tr, this message translates to:
  /// **'SAĞLAM'**
  String get resultGood;

  /// No description provided for @resultBad.
  ///
  /// In tr, this message translates to:
  /// **'ARIZALI'**
  String get resultBad;

  /// No description provided for @postDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'GÖNDER İ DETAYLARI'**
  String get postDetailTitle;

  /// No description provided for @writeComment.
  ///
  /// In tr, this message translates to:
  /// **'Yorum yaz...'**
  String get writeComment;

  /// No description provided for @send.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get send;
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
