// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'E-LAB';

  @override
  String get navHome => 'Home';

  @override
  String get navCommunity => 'Community';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String get catComponents => 'COMPONENTS';

  @override
  String get calcDesc => 'Resistor, Power, Inductor...';

  @override
  String get knowledgeBase => 'KNOWLEDGE BASE';

  @override
  String get myFavorites => 'MY FAVORITES';

  @override
  String get noFavoritesYet => 'No favorites yet.';

  @override
  String get btnAddProject => 'ADD PROJECT';

  @override
  String get forumTitle => 'E-LAB COMMUNITY';

  @override
  String get forumSubtitle => 'Meeting Point for Engineers';

  @override
  String get noPostsYet => 'No posts yet.';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get postTitleHint => 'Topic Title';

  @override
  String get postContentHint => 'Write details here...';

  @override
  String get btnShare => 'Share';

  @override
  String get btnSharing => 'Sharing...';

  @override
  String get btnStartTest => 'START TEST';

  @override
  String get btnReport => 'Report Issue';

  @override
  String get btnSend => 'SEND';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnYes => 'YES / PASS';

  @override
  String get btnNo => 'NO / FAIL';

  @override
  String get lblStep => 'STEP';

  @override
  String get lblTrigger => 'TRIGGER';

  @override
  String get lblTypicalApps => 'TYPICAL APPLICATIONS';

  @override
  String get lblPinConfig => 'PIN CONFIGURATION';

  @override
  String get lblCompOverview => 'COMPONENT OVERVIEW';

  @override
  String get msgReportSent => 'Thanks! Report received.';

  @override
  String get msgTestRestarted => 'Test Restarted 🔄';

  @override
  String get msgTestFailed => 'Test Failed ❌';

  @override
  String get msgTestCompleteTitle => 'TEST COMPLETE';

  @override
  String get msgTestCompleteBody =>
      'If all steps passed, component is GOOD.\n\nIf any step failed, component is BAD.';

  @override
  String get msgInfoBubble =>
      'Please touch the multimeter probes to the blinking pins below.';

  @override
  String get btnBack => 'Back';

  @override
  String get btnApplied => 'APPLIED';

  @override
  String get btnYesCorrect => 'YES (Correct)';

  @override
  String get specMaxVoltage => 'MAX VOLTAGE';

  @override
  String get specMaxCurrent => 'MAX CURRENT';

  @override
  String get specMaxPower => 'MAX POWER';

  @override
  String get testPrepTitle => 'Preparation & Discharge';

  @override
  String get testPrepDesc =>
      'Touch all metal pins simultaneously to discharge static electricity.';

  @override
  String get testDiodeModeTitle => 'Body Diode Test';

  @override
  String testDiodeModeDesc(Object red, Object black) {
    return 'Multimeter in DIODE mode.\nRed: $red | Black: $black';
  }

  @override
  String get testBlockingTitle => 'Blocking Control';

  @override
  String testBlockingDesc(Object red, Object black) {
    return 'Reverse probes.\nRed: $red | Black: $black';
  }

  @override
  String get testTriggerTitle => 'Gate Trigger';

  @override
  String testTriggerDesc(Object fixed, Object trigger, Object returnPin) {
    return 'Keep Black on $fixed.\nTouch Red momentarily to $trigger, then back to $returnPin.';
  }

  @override
  String get testLatchingTitle => 'Latching Check';

  @override
  String get testLatchingDesc => 'Did the value drop after triggering?';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get btnOk => 'OK';

  @override
  String get tooltipFlip => 'Flip Component';

  @override
  String descMosfetTemplate(Object pkg, Object pol, Object vmax, Object imax) {
    return 'This is a high-performance $pol Power MOSFET in a $pkg package. Rated for $vmax and $imax continuous current.';
  }

  @override
  String descBjtTemplate(Object pkg, Object pol, Object vmax, Object imax) {
    return 'A versatile $pol Bipolar Junction Transistor (BJT) in $pkg package. Rated for $vmax and $imax.';
  }

  @override
  String descGenericTemplate(Object pkg, Object cat, Object vmax, Object imax) {
    return 'Generic electronic component ($cat) with $pkg form factor. Rated at $vmax and $imax.';
  }

  @override
  String get toolResistorCalc => 'Resistor Color Code';

  @override
  String get toolCapacitorDec => 'Capacitor Decoder';

  @override
  String get toolSmdSearch => 'SMD Code Search';

  @override
  String get toolSmdCalc => 'SMD Resistor Calc';

  @override
  String get toolInductorColor => 'Inductor Color Code';

  @override
  String get toolValueToCode => 'Value -> Code';

  @override
  String get catCalculators => 'CALCULATORS';

  @override
  String get calculationTools => 'Engineering Tools';

  @override
  String get basicLaws => 'Basic Laws';

  @override
  String get acCircuits => 'AC Circuits';

  @override
  String get catDiodes => 'Diodes';

  @override
  String get digitalLogic => 'Digital Logic';

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get settingsGeneral => 'GENERAL';

  @override
  String get settingsSound => 'Sound Effects';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get profileTitle => 'PROFILE';

  @override
  String get rankCurrent => 'Current Rank';

  @override
  String get xpProgress => 'XP Progress';

  @override
  String get quickTestTitle => 'QUICK DIAGNOSTIC TEST';

  @override
  String get quickTestDesc => 'Type model, start testing...';

  @override
  String get searchComponentTitle => 'Search Component';

  @override
  String get searchHint => 'Ex: IRF3205, 7805...';

  @override
  String get kbSmdCodes => 'SMD CODES';

  @override
  String get kbSmdDesc => 'Decode package markings...';

  @override
  String get commonCalculate => 'CALCULATE';

  @override
  String get commonResult => 'RESULT';

  @override
  String get commonClear => 'RESET';

  @override
  String get commonBands => 'Bands';

  @override
  String get commonValue => 'Value';

  @override
  String get commonVoltage => 'Voltage (V)';

  @override
  String get commonCurrent => 'Current (I)';

  @override
  String get commonResistance => 'Resistance (R)';

  @override
  String get commonPower => 'Power (P)';

  @override
  String get postDetailTitle => 'POST DETAILS';

  @override
  String get comments => 'Comments';

  @override
  String get myProfile => 'MY PROFILE';

  @override
  String get searchStartTest => 'Start Test';

  @override
  String get rank0 => 'Solder Fumes';

  @override
  String get rank1 => 'Resistor Reader';

  @override
  String get rank2 => 'Capacitor Charge';

  @override
  String get rank3 => 'Circuit Apprentice';

  @override
  String get rank4 => 'Transistor Tamer';

  @override
  String get rank5 => 'Logic Gate';

  @override
  String get rank6 => 'Op-Amp Master';

  @override
  String get rank7 => 'PCB Architect';

  @override
  String get rank8 => 'Embedded Systemist';

  @override
  String get rank9 => 'Silicon Engineer';

  @override
  String get rank10 => 'High Frequency';

  @override
  String get rank11 => 'Quantum Mechanics';

  @override
  String get rank12 => 'AI Core';

  @override
  String get rank13 => 'Singularity';

  @override
  String get rank14 => 'E-LAB LEGEND';

  @override
  String get rank15 => 'SYSTEM ADMIN';
}
