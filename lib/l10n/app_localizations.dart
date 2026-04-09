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
    Locale('ru'),
    Locale('en'),
    Locale('tg')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'JUYO Mobile'**
  String get appTitle;

  /// No description provided for @languageName.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get languageName;

  /// No description provided for @commonContinue.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get commonContinue;

  /// No description provided for @commonSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get commonCancel;

  /// No description provided for @commonBack.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get commonBack;

  /// No description provided for @commonRetry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get commonRetry;

  /// No description provided for @commonLoading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка...'**
  String get commonLoading;

  /// No description provided for @commonSoon.
  ///
  /// In ru, this message translates to:
  /// **'Скоро будет доступно'**
  String get commonSoon;

  /// No description provided for @commonPremium.
  ///
  /// In ru, this message translates to:
  /// **'Premium'**
  String get commonPremium;

  /// No description provided for @commonShare.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться'**
  String get commonShare;

  /// No description provided for @commonCopied.
  ///
  /// In ru, this message translates to:
  /// **'Скопировано'**
  String get commonCopied;

  /// No description provided for @commonLogout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get commonLogout;

  /// No description provided for @commonProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get commonProfile;

  /// No description provided for @commonDashboard.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get commonDashboard;

  /// No description provided for @commonTests.
  ///
  /// In ru, this message translates to:
  /// **'Тесты'**
  String get commonTests;

  /// No description provided for @commonDuel.
  ///
  /// In ru, this message translates to:
  /// **'Дуэль'**
  String get commonDuel;

  /// No description provided for @commonLeague.
  ///
  /// In ru, this message translates to:
  /// **'Лига'**
  String get commonLeague;

  /// No description provided for @commonAnalytics.
  ///
  /// In ru, this message translates to:
  /// **'Аналитика'**
  String get commonAnalytics;

  /// No description provided for @commonPractice.
  ///
  /// In ru, this message translates to:
  /// **'Практика'**
  String get commonPractice;

  /// No description provided for @commonSchoolLeaderboard.
  ///
  /// In ru, this message translates to:
  /// **'Рейтинг школ'**
  String get commonSchoolLeaderboard;

  /// No description provided for @commonRedList.
  ///
  /// In ru, this message translates to:
  /// **'Красный список'**
  String get commonRedList;

  /// No description provided for @commonReferral.
  ///
  /// In ru, this message translates to:
  /// **'Рефералы'**
  String get commonReferral;

  /// No description provided for @commonSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get commonSettings;

  /// No description provided for @emptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет данных'**
  String get emptyTitle;

  /// No description provided for @emptySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Данные появятся после обновления.'**
  String get emptySubtitle;

  /// No description provided for @errorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Произошла ошибка'**
  String get errorTitle;

  /// No description provided for @lockedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Эта функция доступна только в Premium'**
  String get lockedTitle;

  /// No description provided for @lockedSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Перейдите на страницу Premium, чтобы открыть этот раздел.'**
  String get lockedSubtitle;

  /// No description provided for @splashTagline.
  ///
  /// In ru, this message translates to:
  /// **'Качественная подготовка к экзамену'**
  String get splashTagline;

  /// No description provided for @landingHeroTitle.
  ///
  /// In ru, this message translates to:
  /// **'Продолжайте подготовку к экзамену в мобильном приложении'**
  String get landingHeroTitle;

  /// No description provided for @landingHeroSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Тесты, дуэли, рейтинги и прогресс в одном приложении.'**
  String get landingHeroSubtitle;

  /// No description provided for @landingPrimaryCta.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get landingPrimaryCta;

  /// No description provided for @landingSecondaryCta.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get landingSecondaryCta;

  /// No description provided for @landingFeatureFast.
  ///
  /// In ru, this message translates to:
  /// **'Быстрый старт'**
  String get landingFeatureFast;

  /// No description provided for @landingFeatureFastSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Войдите и сразу переходите к обучению.'**
  String get landingFeatureFastSubtitle;

  /// No description provided for @landingFeatureAi.
  ///
  /// In ru, this message translates to:
  /// **'Умный путь обучения'**
  String get landingFeatureAi;

  /// No description provided for @landingFeatureAiSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Следите за прогрессом и слабыми местами.'**
  String get landingFeatureAiSubtitle;

  /// No description provided for @landingFeatureLeague.
  ///
  /// In ru, this message translates to:
  /// **'Лиги и дуэли'**
  String get landingFeatureLeague;

  /// No description provided for @landingFeatureLeagueSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Соревнуйтесь с другими и зарабатывайте XP.'**
  String get landingFeatureLeagueSubtitle;

  /// No description provided for @authLoginTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Продолжите свою подготовку'**
  String get authLoginSubtitle;

  /// No description provided for @authRegisterTitle.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Начните обучение уже сегодня'**
  String get authRegisterSubtitle;

  /// No description provided for @authForgotTitle.
  ///
  /// In ru, this message translates to:
  /// **'Восстановление пароля'**
  String get authForgotTitle;

  /// No description provided for @authPhoneLabel.
  ///
  /// In ru, this message translates to:
  /// **'Номер телефона'**
  String get authPhoneLabel;

  /// No description provided for @authPhoneHint.
  ///
  /// In ru, this message translates to:
  /// **'+992 900 00 00 00'**
  String get authPhoneHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get authPasswordLabel;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In ru, this message translates to:
  /// **'Повторите пароль'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authFirstNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get authFirstNameLabel;

  /// No description provided for @authLastNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Фамилия'**
  String get authLastNameLabel;

  /// No description provided for @authReferralCodeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Реферальный код'**
  String get authReferralCodeLabel;

  /// No description provided for @authForgotPassword.
  ///
  /// In ru, this message translates to:
  /// **'Забыли пароль?'**
  String get authForgotPassword;

  /// No description provided for @authNoAccount.
  ///
  /// In ru, this message translates to:
  /// **'Нет аккаунта?'**
  String get authNoAccount;

  /// No description provided for @authHasAccount.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт?'**
  String get authHasAccount;

  /// No description provided for @authSignIn.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get authSignIn;

  /// No description provided for @authSignUp.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get authSignUp;

  /// No description provided for @authSendCode.
  ///
  /// In ru, this message translates to:
  /// **'Отправить код'**
  String get authSendCode;

  /// No description provided for @authVerifyCode.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить'**
  String get authVerifyCode;

  /// No description provided for @authResetPassword.
  ///
  /// In ru, this message translates to:
  /// **'Обновить пароль'**
  String get authResetPassword;

  /// No description provided for @authOtpLabel.
  ///
  /// In ru, this message translates to:
  /// **'Код подтверждения'**
  String get authOtpLabel;

  /// No description provided for @authOtpHint.
  ///
  /// In ru, this message translates to:
  /// **'0000'**
  String get authOtpHint;

  /// No description provided for @authInvalidFields.
  ///
  /// In ru, this message translates to:
  /// **'Пожалуйста, заполните все поля корректно'**
  String get authInvalidFields;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In ru, this message translates to:
  /// **'Пароли не совпадают'**
  String get authPasswordMismatch;

  /// No description provided for @authBackToLogin.
  ///
  /// In ru, this message translates to:
  /// **'Ко входу'**
  String get authBackToLogin;

  /// No description provided for @authStepPhone.
  ///
  /// In ru, this message translates to:
  /// **'Шаг 1 из 3'**
  String get authStepPhone;

  /// No description provided for @authStepOtp.
  ///
  /// In ru, this message translates to:
  /// **'Шаг 2 из 3'**
  String get authStepOtp;

  /// No description provided for @authStepReset.
  ///
  /// In ru, this message translates to:
  /// **'Шаг 3 из 3'**
  String get authStepReset;

  /// No description provided for @authResendCode.
  ///
  /// In ru, this message translates to:
  /// **'Отправить повторно'**
  String get authResendCode;

  /// No description provided for @shellGreeting.
  ///
  /// In ru, this message translates to:
  /// **'Здравствуйте'**
  String get shellGreeting;

  /// No description provided for @shellPublicInvite.
  ///
  /// In ru, this message translates to:
  /// **'Приглашение на дуэль'**
  String get shellPublicInvite;

  /// No description provided for @dashboardTitle.
  ///
  /// In ru, this message translates to:
  /// **'Главная панель'**
  String get dashboardTitle;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Ваш прогресс, цели и активность'**
  String get dashboardSubtitle;

  /// No description provided for @dashboardOpenProfile.
  ///
  /// In ru, this message translates to:
  /// **'Открыть профиль'**
  String get dashboardOpenProfile;

  /// No description provided for @testsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Центр тестов'**
  String get testsTitle;

  /// No description provided for @testsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Выберите подходящий режим'**
  String get testsSubtitle;

  /// No description provided for @testsSubjectMode.
  ///
  /// In ru, this message translates to:
  /// **'Тест по предмету'**
  String get testsSubjectMode;

  /// No description provided for @testsExamMode.
  ///
  /// In ru, this message translates to:
  /// **'Экзамен'**
  String get testsExamMode;

  /// No description provided for @testsPracticeMode.
  ///
  /// In ru, this message translates to:
  /// **'Практика'**
  String get testsPracticeMode;

  /// No description provided for @testsDuelMode.
  ///
  /// In ru, this message translates to:
  /// **'Дуэль'**
  String get testsDuelMode;

  /// No description provided for @leagueTitle.
  ///
  /// In ru, this message translates to:
  /// **'Лиги'**
  String get leagueTitle;

  /// No description provided for @leagueSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Следите за местом и соревнованием'**
  String get leagueSubtitle;

  /// No description provided for @duelTitle.
  ///
  /// In ru, this message translates to:
  /// **'Дуэль'**
  String get duelTitle;

  /// No description provided for @duelSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Живое соревнование и приватные приглашения'**
  String get duelSubtitle;

  /// No description provided for @duelInviteCodeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Код приглашения'**
  String get duelInviteCodeLabel;

  /// No description provided for @duelJoinButton.
  ///
  /// In ru, this message translates to:
  /// **'Присоединиться'**
  String get duelJoinButton;

  /// No description provided for @duelCreateInvite.
  ///
  /// In ru, this message translates to:
  /// **'Создать приглашение'**
  String get duelCreateInvite;

  /// No description provided for @profileTitle.
  ///
  /// In ru, this message translates to:
  /// **'Мой профиль'**
  String get profileTitle;

  /// No description provided for @profileEdit.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать профиль'**
  String get profileEdit;

  /// No description provided for @referralTitle.
  ///
  /// In ru, this message translates to:
  /// **'Рефералы'**
  String get referralTitle;

  /// No description provided for @referralSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Приглашайте друзей и получайте XP'**
  String get referralSubtitle;

  /// No description provided for @premiumTitle.
  ///
  /// In ru, this message translates to:
  /// **'Premium'**
  String get premiumTitle;

  /// No description provided for @premiumSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Откройте все возможности'**
  String get premiumSubtitle;

  /// No description provided for @redListTitle.
  ///
  /// In ru, this message translates to:
  /// **'Красный список'**
  String get redListTitle;

  /// No description provided for @redListSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Повторяйте слабые вопросы'**
  String get redListSubtitle;

  /// No description provided for @schoolTitle.
  ///
  /// In ru, this message translates to:
  /// **'Рейтинг школ'**
  String get schoolTitle;

  /// No description provided for @schoolSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Смотрите позицию своей школы'**
  String get schoolSubtitle;

  /// No description provided for @inviteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вас пригласили на дуэль'**
  String get inviteTitle;

  /// No description provided for @inviteSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Войдите или зарегистрируйтесь, чтобы присоединиться к матчу.'**
  String get inviteSubtitle;

  /// No description provided for @premiumGoToPlans.
  ///
  /// In ru, this message translates to:
  /// **'Открыть планы'**
  String get premiumGoToPlans;

  /// No description provided for @appLocaleTg.
  ///
  /// In ru, this message translates to:
  /// **'TJ'**
  String get appLocaleTg;

  /// No description provided for @appLocaleRu.
  ///
  /// In ru, this message translates to:
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
