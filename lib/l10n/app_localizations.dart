import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tg.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('tg'),
    Locale('ru'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In tg, this message translates to:
  /// **'JUYO Mobile'**
  String get appTitle;

  /// No description provided for @languageName.
  ///
  /// In tg, this message translates to:
  /// **'Тоҷикӣ'**
  String get languageName;

  /// No description provided for @commonContinue.
  ///
  /// In tg, this message translates to:
  /// **'Давом додан'**
  String get commonContinue;

  /// No description provided for @commonSave.
  ///
  /// In tg, this message translates to:
  /// **'Сабт кардан'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In tg, this message translates to:
  /// **'Бекор кардан'**
  String get commonCancel;

  /// No description provided for @commonBack.
  ///
  /// In tg, this message translates to:
  /// **'Бозгашт'**
  String get commonBack;

  /// No description provided for @commonRetry.
  ///
  /// In tg, this message translates to:
  /// **'Аз нав'**
  String get commonRetry;

  /// No description provided for @commonLoading.
  ///
  /// In tg, this message translates to:
  /// **'Боргирӣ...'**
  String get commonLoading;

  /// No description provided for @commonSoon.
  ///
  /// In tg, this message translates to:
  /// **'Ба зудӣ дастрас мешавад'**
  String get commonSoon;

  /// No description provided for @commonPremium.
  ///
  /// In tg, this message translates to:
  /// **'Premium'**
  String get commonPremium;

  /// No description provided for @commonShare.
  ///
  /// In tg, this message translates to:
  /// **'Мубодила'**
  String get commonShare;

  /// No description provided for @commonCopied.
  ///
  /// In tg, this message translates to:
  /// **'Нусхабардорӣ шуд'**
  String get commonCopied;

  /// No description provided for @commonLogout.
  ///
  /// In tg, this message translates to:
  /// **'Баромадан'**
  String get commonLogout;

  /// No description provided for @commonProfile.
  ///
  /// In tg, this message translates to:
  /// **'Профил'**
  String get commonProfile;

  /// No description provided for @commonDashboard.
  ///
  /// In tg, this message translates to:
  /// **'Асосӣ'**
  String get commonDashboard;

  /// No description provided for @commonTests.
  ///
  /// In tg, this message translates to:
  /// **'Тестҳо'**
  String get commonTests;

  /// No description provided for @commonDuel.
  ///
  /// In tg, this message translates to:
  /// **'Дуэл'**
  String get commonDuel;

  /// No description provided for @commonLeague.
  ///
  /// In tg, this message translates to:
  /// **'Лига'**
  String get commonLeague;

  /// No description provided for @commonAnalytics.
  ///
  /// In tg, this message translates to:
  /// **'Аналитика'**
  String get commonAnalytics;

  /// No description provided for @commonPractice.
  ///
  /// In tg, this message translates to:
  /// **'Практика'**
  String get commonPractice;

  /// No description provided for @commonSchoolLeaderboard.
  ///
  /// In tg, this message translates to:
  /// **'Рейтинги мактабҳо'**
  String get commonSchoolLeaderboard;

  /// No description provided for @commonRedList.
  ///
  /// In tg, this message translates to:
  /// **'Рӯйхати сурх'**
  String get commonRedList;

  /// No description provided for @commonReferral.
  ///
  /// In tg, this message translates to:
  /// **'Реферал'**
  String get commonReferral;

  /// No description provided for @commonSettings.
  ///
  /// In tg, this message translates to:
  /// **'Танзимот'**
  String get commonSettings;

  /// No description provided for @emptyTitle.
  ///
  /// In tg, this message translates to:
  /// **'Ҳоло маълумот нест'**
  String get emptyTitle;

  /// No description provided for @emptySubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Маълумот баъд аз навсозӣ пайдо мешавад.'**
  String get emptySubtitle;

  /// No description provided for @errorTitle.
  ///
  /// In tg, this message translates to:
  /// **'Хато рӯй дод'**
  String get errorTitle;

  /// No description provided for @lockedTitle.
  ///
  /// In tg, this message translates to:
  /// **'Ин имконият танҳо дар Premium аст'**
  String get lockedTitle;

  /// No description provided for @lockedSubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Барои кушодани ин қисм ба саҳифаи Premium гузаред.'**
  String get lockedSubtitle;

  /// No description provided for @splashTagline.
  ///
  /// In tg, this message translates to:
  /// **'Омодагии босифат ба имтиҳон'**
  String get splashTagline;

  /// No description provided for @landingHeroTitle.
  ///
  /// In tg, this message translates to:
  /// **'Омодагӣ ба имтиҳонро дар мобил идома деҳ'**
  String get landingHeroTitle;

  /// No description provided for @landingHeroSubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Тестҳо, дуэл, рейтинг ва пешрафт дар як барномаи ягона.'**
  String get landingHeroSubtitle;

  /// No description provided for @landingPrimaryCta.
  ///
  /// In tg, this message translates to:
  /// **'Ворид шудан'**
  String get landingPrimaryCta;

  /// No description provided for @landingSecondaryCta.
  ///
  /// In tg, this message translates to:
  /// **'Эҷоди аккаунт'**
  String get landingSecondaryCta;

  /// No description provided for @landingFeatureFast.
  ///
  /// In tg, this message translates to:
  /// **'Оғози зуд'**
  String get landingFeatureFast;

  /// No description provided for @landingFeatureFastSubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Ворид шавед ва фавран ба омӯзиш гузаред.'**
  String get landingFeatureFastSubtitle;

  /// No description provided for @landingFeatureAi.
  ///
  /// In tg, this message translates to:
  /// **'Роҳи омӯзиши оқилона'**
  String get landingFeatureAi;

  /// No description provided for @landingFeatureAiSubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Пешрафт ва заъфҳоро бинед.'**
  String get landingFeatureAiSubtitle;

  /// No description provided for @landingFeatureLeague.
  ///
  /// In tg, this message translates to:
  /// **'Лига ва дуэл'**
  String get landingFeatureLeague;

  /// No description provided for @landingFeatureLeagueSubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Бо дигарон рақобат кунед ва XP гиред.'**
  String get landingFeatureLeagueSubtitle;

  /// No description provided for @authLoginTitle.
  ///
  /// In tg, this message translates to:
  /// **'Ворид шудан'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Омодагии худро идома диҳед'**
  String get authLoginSubtitle;

  /// No description provided for @authRegisterTitle.
  ///
  /// In tg, this message translates to:
  /// **'Эҷоди аккаунт'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Омӯзишро имрӯз оғоз кунед'**
  String get authRegisterSubtitle;

  /// No description provided for @authForgotTitle.
  ///
  /// In tg, this message translates to:
  /// **'Барқарорсозии рамз'**
  String get authForgotTitle;

  /// No description provided for @authPhoneLabel.
  ///
  /// In tg, this message translates to:
  /// **'Рақами телефон'**
  String get authPhoneLabel;

  /// No description provided for @authPhoneHint.
  ///
  /// In tg, this message translates to:
  /// **'+992 900 00 00 00'**
  String get authPhoneHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In tg, this message translates to:
  /// **'Рамз'**
  String get authPasswordLabel;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In tg, this message translates to:
  /// **'Такрори рамз'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authFirstNameLabel.
  ///
  /// In tg, this message translates to:
  /// **'Ном'**
  String get authFirstNameLabel;

  /// No description provided for @authLastNameLabel.
  ///
  /// In tg, this message translates to:
  /// **'Насаб'**
  String get authLastNameLabel;

  /// No description provided for @authReferralCodeLabel.
  ///
  /// In tg, this message translates to:
  /// **'Коди рефералӣ'**
  String get authReferralCodeLabel;

  /// No description provided for @authForgotPassword.
  ///
  /// In tg, this message translates to:
  /// **'Рамзро фаромӯш кардед?'**
  String get authForgotPassword;

  /// No description provided for @authNoAccount.
  ///
  /// In tg, this message translates to:
  /// **'Аккаунт надоред?'**
  String get authNoAccount;

  /// No description provided for @authHasAccount.
  ///
  /// In tg, this message translates to:
  /// **'Аккаунт доред?'**
  String get authHasAccount;

  /// No description provided for @authSignIn.
  ///
  /// In tg, this message translates to:
  /// **'Ворид шудан'**
  String get authSignIn;

  /// No description provided for @authSignUp.
  ///
  /// In tg, this message translates to:
  /// **'Сабти ном'**
  String get authSignUp;

  /// No description provided for @authSendCode.
  ///
  /// In tg, this message translates to:
  /// **'Фиристодани код'**
  String get authSendCode;

  /// No description provided for @authVerifyCode.
  ///
  /// In tg, this message translates to:
  /// **'Тасдиқ'**
  String get authVerifyCode;

  /// No description provided for @authResetPassword.
  ///
  /// In tg, this message translates to:
  /// **'Нав кардани рамз'**
  String get authResetPassword;

  /// No description provided for @authOtpLabel.
  ///
  /// In tg, this message translates to:
  /// **'Коди тасдиқ'**
  String get authOtpLabel;

  /// No description provided for @authOtpHint.
  ///
  /// In tg, this message translates to:
  /// **'0000'**
  String get authOtpHint;

  /// No description provided for @authInvalidFields.
  ///
  /// In tg, this message translates to:
  /// **'Лутфан ҳамаи майдонҳоро дуруст пур кунед'**
  String get authInvalidFields;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In tg, this message translates to:
  /// **'Рамзҳо мувофиқат намекунанд'**
  String get authPasswordMismatch;

  /// No description provided for @authBackToLogin.
  ///
  /// In tg, this message translates to:
  /// **'Ба саҳифаи воридшавӣ'**
  String get authBackToLogin;

  /// No description provided for @authStepPhone.
  ///
  /// In tg, this message translates to:
  /// **'Қадами 1 аз 3'**
  String get authStepPhone;

  /// No description provided for @authStepOtp.
  ///
  /// In tg, this message translates to:
  /// **'Қадами 2 аз 3'**
  String get authStepOtp;

  /// No description provided for @authStepReset.
  ///
  /// In tg, this message translates to:
  /// **'Қадами 3 аз 3'**
  String get authStepReset;

  /// No description provided for @authResendCode.
  ///
  /// In tg, this message translates to:
  /// **'Бозфиристодани код'**
  String get authResendCode;

  /// No description provided for @shellGreeting.
  ///
  /// In tg, this message translates to:
  /// **'Салом'**
  String get shellGreeting;

  /// No description provided for @shellPublicInvite.
  ///
  /// In tg, this message translates to:
  /// **'Даъвати дуэл'**
  String get shellPublicInvite;

  /// No description provided for @dashboardTitle.
  ///
  /// In tg, this message translates to:
  /// **'Панели асосӣ'**
  String get dashboardTitle;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Пешрафт, ҳадафҳо ва фаъолияти шумо'**
  String get dashboardSubtitle;

  /// No description provided for @dashboardOpenProfile.
  ///
  /// In tg, this message translates to:
  /// **'Кушодани профил'**
  String get dashboardOpenProfile;

  /// No description provided for @testsTitle.
  ///
  /// In tg, this message translates to:
  /// **'Маркази тестҳо'**
  String get testsTitle;

  /// No description provided for @testsSubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Режими мувофиқро интихоб кунед'**
  String get testsSubtitle;

  /// No description provided for @testsSubjectMode.
  ///
  /// In tg, this message translates to:
  /// **'Тест аз рӯйи фан'**
  String get testsSubjectMode;

  /// No description provided for @testsExamMode.
  ///
  /// In tg, this message translates to:
  /// **'Имтиҳон'**
  String get testsExamMode;

  /// No description provided for @testsPracticeMode.
  ///
  /// In tg, this message translates to:
  /// **'Практика'**
  String get testsPracticeMode;

  /// No description provided for @testsDuelMode.
  ///
  /// In tg, this message translates to:
  /// **'Дуэл'**
  String get testsDuelMode;

  /// No description provided for @leagueTitle.
  ///
  /// In tg, this message translates to:
  /// **'Лигаҳо'**
  String get leagueTitle;

  /// No description provided for @leagueSubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Ҷойгоҳ ва рақобати худро пайгирӣ кунед'**
  String get leagueSubtitle;

  /// No description provided for @duelTitle.
  ///
  /// In tg, this message translates to:
  /// **'Дуэл'**
  String get duelTitle;

  /// No description provided for @duelSubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Рақобати зинда ва даъватҳои хусусӣ'**
  String get duelSubtitle;

  /// No description provided for @duelInviteCodeLabel.
  ///
  /// In tg, this message translates to:
  /// **'Коди даъват'**
  String get duelInviteCodeLabel;

  /// No description provided for @duelJoinButton.
  ///
  /// In tg, this message translates to:
  /// **'Пайваст шудан'**
  String get duelJoinButton;

  /// No description provided for @duelCreateInvite.
  ///
  /// In tg, this message translates to:
  /// **'Сохтани даъват'**
  String get duelCreateInvite;

  /// No description provided for @profileTitle.
  ///
  /// In tg, this message translates to:
  /// **'Профили ман'**
  String get profileTitle;

  /// No description provided for @profileEdit.
  ///
  /// In tg, this message translates to:
  /// **'Таҳрири профил'**
  String get profileEdit;

  /// No description provided for @referralTitle.
  ///
  /// In tg, this message translates to:
  /// **'Реферал'**
  String get referralTitle;

  /// No description provided for @referralSubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Дӯст даъват кунед ва XP гиред'**
  String get referralSubtitle;

  /// No description provided for @premiumTitle.
  ///
  /// In tg, this message translates to:
  /// **'Premium'**
  String get premiumTitle;

  /// No description provided for @premiumSubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Ҳамаи имкониятҳоро боз кунед'**
  String get premiumSubtitle;

  /// No description provided for @redListTitle.
  ///
  /// In tg, this message translates to:
  /// **'Рӯйхати сурх'**
  String get redListTitle;

  /// No description provided for @redListSubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Саволҳои заифро такрор кунед'**
  String get redListSubtitle;

  /// No description provided for @schoolTitle.
  ///
  /// In tg, this message translates to:
  /// **'Рейтинги мактабҳо'**
  String get schoolTitle;

  /// No description provided for @schoolSubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Мавқеи мактаби худро бинед'**
  String get schoolSubtitle;

  /// No description provided for @inviteTitle.
  ///
  /// In tg, this message translates to:
  /// **'Шумо ба дуэл даъват шудед'**
  String get inviteTitle;

  /// No description provided for @inviteSubtitle.
  ///
  /// In tg, this message translates to:
  /// **'Ба аккаунт дароед ё сабти ном кунед, то ба дуэл пайваст шавед.'**
  String get inviteSubtitle;

  /// No description provided for @premiumGoToPlans.
  ///
  /// In tg, this message translates to:
  /// **'Кушодани нақшаҳо'**
  String get premiumGoToPlans;

  /// No description provided for @appLocaleTg.
  ///
  /// In tg, this message translates to:
  /// **'TJ'**
  String get appLocaleTg;

  /// No description provided for @appLocaleRu.
  ///
  /// In tg, this message translates to:
  /// **'RU'**
  String get appLocaleRu;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'tg'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'tg':
      return AppLocalizationsTg();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
