import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

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
    Locale('en'),
    Locale('ko')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Lulu'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Baby Sleep Companion'**
  String get appTagline;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get tabSleep;

  /// No description provided for @tabAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get tabAnalytics;

  /// No description provided for @tabChat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get tabChat;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get navRecords;

  /// No description provided for @navInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get navInsights;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get homeTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your baby\'s daily activities'**
  String get homeSubtitle;

  /// No description provided for @todaySummary.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Summary'**
  String get todaySummary;

  /// No description provided for @sleepsToday.
  ///
  /// In en, this message translates to:
  /// **'Sleeps'**
  String get sleepsToday;

  /// No description provided for @feedingsToday.
  ///
  /// In en, this message translates to:
  /// **'Feedings'**
  String get feedingsToday;

  /// No description provided for @diapersToday.
  ///
  /// In en, this message translates to:
  /// **'Diapers'**
  String get diapersToday;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @recentActivities.
  ///
  /// In en, this message translates to:
  /// **'Recent Activities'**
  String get recentActivities;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @feeding.
  ///
  /// In en, this message translates to:
  /// **'Feeding'**
  String get feeding;

  /// No description provided for @diaper.
  ///
  /// In en, this message translates to:
  /// **'Diaper'**
  String get diaper;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @noRecords.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get noRecords;

  /// No description provided for @activityHistory.
  ///
  /// In en, this message translates to:
  /// **'Activity History'**
  String get activityHistory;

  /// No description provided for @viewAllRecordedActivities.
  ///
  /// In en, this message translates to:
  /// **'View all recorded activities'**
  String get viewAllRecordedActivities;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageEnglishUS.
  ///
  /// In en, this message translates to:
  /// **'English (US)'**
  String get languageEnglishUS;

  /// No description provided for @languageKorean.
  ///
  /// In en, this message translates to:
  /// **'한국어'**
  String get languageKorean;

  /// No description provided for @languageKoreanKR.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get languageKoreanKR;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @unitCelsius.
  ///
  /// In en, this message translates to:
  /// **'℃'**
  String get unitCelsius;

  /// No description provided for @unitFahrenheit.
  ///
  /// In en, this message translates to:
  /// **'℉'**
  String get unitFahrenheit;

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitLb.
  ///
  /// In en, this message translates to:
  /// **'lb'**
  String get unitLb;

  /// No description provided for @unitMl.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unitMl;

  /// No description provided for @unitOz.
  ///
  /// In en, this message translates to:
  /// **'oz'**
  String get unitOz;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @sweetSpotAlerts.
  ///
  /// In en, this message translates to:
  /// **'Sweet Spot Alerts'**
  String get sweetSpotAlerts;

  /// No description provided for @notifyMeMinutesBefore.
  ///
  /// In en, this message translates to:
  /// **'Notify me {minutes} min before optimal sleep time'**
  String notifyMeMinutesBefore(int minutes);

  /// No description provided for @appUpdatesAndTips.
  ///
  /// In en, this message translates to:
  /// **'App Updates & Tips'**
  String get appUpdatesAndTips;

  /// No description provided for @receiveHelpfulTips.
  ///
  /// In en, this message translates to:
  /// **'Receive helpful parenting tips and feature updates'**
  String get receiveHelpfulTips;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @allNotificationsMarkedAsRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allNotificationsMarkedAsRead;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @exportToCSV.
  ///
  /// In en, this message translates to:
  /// **'Export data to CSV file'**
  String get exportToCSV;

  /// No description provided for @importFromCSV.
  ///
  /// In en, this message translates to:
  /// **'Import data from CSV file'**
  String get importFromCSV;

  /// No description provided for @sweetSpotDemo.
  ///
  /// In en, this message translates to:
  /// **'Sweet Spot Demo'**
  String get sweetSpotDemo;

  /// No description provided for @tryAISleepPredictionDemo.
  ///
  /// In en, this message translates to:
  /// **'Try the AI sleep prediction demo'**
  String get tryAISleepPredictionDemo;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String error(String message);

  /// No description provided for @aiCoachingTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Coaching Insight'**
  String get aiCoachingTitle;

  /// No description provided for @aiCoachingAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'AI is analyzing...'**
  String get aiCoachingAnalyzing;

  /// No description provided for @aiCoachingEmpathy.
  ///
  /// In en, this message translates to:
  /// **'Empathy'**
  String get aiCoachingEmpathy;

  /// No description provided for @aiCoachingInsight.
  ///
  /// In en, this message translates to:
  /// **'Data Insight'**
  String get aiCoachingInsight;

  /// No description provided for @aiCoachingAction.
  ///
  /// In en, this message translates to:
  /// **'Action Plan'**
  String get aiCoachingAction;

  /// No description provided for @aiCoachingExpert.
  ///
  /// In en, this message translates to:
  /// **'Expert Advice'**
  String get aiCoachingExpert;

  /// No description provided for @aiCoachingFeedbackQuestion.
  ///
  /// In en, this message translates to:
  /// **'Was this helpful?'**
  String get aiCoachingFeedbackQuestion;

  /// No description provided for @aiCoachingFeedbackPositive.
  ///
  /// In en, this message translates to:
  /// **'Helpful'**
  String get aiCoachingFeedbackPositive;

  /// No description provided for @aiCoachingFeedbackNegative.
  ///
  /// In en, this message translates to:
  /// **'Not helpful'**
  String get aiCoachingFeedbackNegative;

  /// No description provided for @aiCoachingFeedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback! We\'ll use it to improve our advice.'**
  String get aiCoachingFeedbackThanks;

  /// No description provided for @aiAnalysisAvailable.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis Available'**
  String get aiAnalysisAvailable;

  /// No description provided for @tapChartForAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Tap on the chart to have AI analyze that time period'**
  String get tapChartForAnalysis;

  /// No description provided for @criticalAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Expert Consultation Recommended'**
  String get criticalAlertTitle;

  /// No description provided for @criticalAlertMessage.
  ///
  /// In en, this message translates to:
  /// **'Your baby\'s condition requires careful observation. We recommend consulting with a pediatrician and can generate a report to share with your doctor.'**
  String get criticalAlertMessage;

  /// No description provided for @generatePDFReport.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF Report'**
  String get generatePDFReport;

  /// No description provided for @longestSleepStretch.
  ///
  /// In en, this message translates to:
  /// **'Longest Sleep Stretch'**
  String get longestSleepStretch;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;
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
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
