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
  /// **'Consider talking to your pediatrician'**
  String get criticalAlertTitle;

  /// No description provided for @criticalAlertMessage.
  ///
  /// In en, this message translates to:
  /// **'If you\'re concerned, your pediatrician can provide personalized guidance. We can generate a report to share with your doctor.'**
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

  /// No description provided for @actionZoneCardTitle.
  ///
  /// In en, this message translates to:
  /// **'What should I do now?'**
  String get actionZoneCardTitle;

  /// No description provided for @actionZoneNoDataMessage.
  ///
  /// In en, this message translates to:
  /// **'Record sleep to get recommendations'**
  String get actionZoneNoDataMessage;

  /// No description provided for @actionZoneSweetSpotPassedMessage.
  ///
  /// In en, this message translates to:
  /// **'Sweet spot passed - put baby to sleep now!'**
  String get actionZoneSweetSpotPassedMessage;

  /// No description provided for @actionZoneSweetSpotNowMessage.
  ///
  /// In en, this message translates to:
  /// **'Perfect time to put baby to sleep!'**
  String get actionZoneSweetSpotNowMessage;

  /// No description provided for @actionZoneSweetSpotUpcomingMessage.
  ///
  /// In en, this message translates to:
  /// **'Put to sleep by this time'**
  String get actionZoneSweetSpotUpcomingMessage;

  /// No description provided for @actionZoneSleepNowButton.
  ///
  /// In en, this message translates to:
  /// **'Sleep Now'**
  String get actionZoneSleepNowButton;

  /// No description provided for @actionZoneSetAlarmButton.
  ///
  /// In en, this message translates to:
  /// **'Set Alarm'**
  String get actionZoneSetAlarmButton;

  /// No description provided for @todaysSnapshotTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Snapshot'**
  String get todaysSnapshotTitle;

  /// No description provided for @todaysSnapshotSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get todaysSnapshotSleep;

  /// No description provided for @todaysSnapshotTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get todaysSnapshotTotalTime;

  /// No description provided for @todaysSnapshotFeeding.
  ///
  /// In en, this message translates to:
  /// **'Feeding'**
  String get todaysSnapshotFeeding;

  /// No description provided for @smartAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Alerts'**
  String get smartAlertsTitle;

  /// No description provided for @smartAlertsViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get smartAlertsViewAll;

  /// No description provided for @alertSleepUrgentTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for a sleep break'**
  String get alertSleepUrgentTitle;

  /// No description provided for @alertSleepUrgentMessage.
  ///
  /// In en, this message translates to:
  /// **'Baby might be getting sleepy. Consider putting down soon.'**
  String alertSleepUrgentMessage(int minutes);

  /// No description provided for @alertSleepWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Almost time for sleep'**
  String get alertSleepWarningTitle;

  /// No description provided for @alertSleepWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Consider putting to sleep in {minutes}min.'**
  String alertSleepWarningMessage(int minutes);

  /// No description provided for @alertFeedingUrgentTitle.
  ///
  /// In en, this message translates to:
  /// **'Feeding time is here'**
  String get alertFeedingUrgentTitle;

  /// No description provided for @alertFeedingUrgentMessage.
  ///
  /// In en, this message translates to:
  /// **'Baby might be hungry soon.'**
  String alertFeedingUrgentMessage(int minutes);

  /// No description provided for @alertFeedingWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Feeding time soon'**
  String get alertFeedingWarningTitle;

  /// No description provided for @alertFeedingWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Baby might be ready to eat in {minutes}min.'**
  String alertFeedingWarningMessage(int minutes);

  /// No description provided for @alertDiaperWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Diaper check'**
  String get alertDiaperWarningTitle;

  /// No description provided for @alertDiaperWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Might be time for a diaper change.'**
  String alertDiaperWarningMessage(int hours);

  /// No description provided for @recordsFilterAllPeriod.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get recordsFilterAllPeriod;

  /// No description provided for @recordsFilterSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get recordsFilterSearch;

  /// No description provided for @insightPositive.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get insightPositive;

  /// No description provided for @insightWarning.
  ///
  /// In en, this message translates to:
  /// **'Heads up'**
  String get insightWarning;

  /// No description provided for @insightConcern.
  ///
  /// In en, this message translates to:
  /// **'Worth noting'**
  String get insightConcern;

  /// No description provided for @insightNeutral.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get insightNeutral;

  /// No description provided for @weeklyInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'This Week\'s Insights'**
  String get weeklyInsightsTitle;

  /// No description provided for @weeklyInsightsNoData.
  ///
  /// In en, this message translates to:
  /// **'Record data to see weekly insights'**
  String get weeklyInsightsNoData;

  /// No description provided for @trendImproving.
  ///
  /// In en, this message translates to:
  /// **'Improving'**
  String get trendImproving;

  /// No description provided for @trendDeclining.
  ///
  /// In en, this message translates to:
  /// **'A bit lower'**
  String get trendDeclining;

  /// No description provided for @trendStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get trendStable;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @averageSleep.
  ///
  /// In en, this message translates to:
  /// **'Average Sleep'**
  String get averageSleep;

  /// No description provided for @sleepCount.
  ///
  /// In en, this message translates to:
  /// **'Sleep Count'**
  String get sleepCount;

  /// No description provided for @averageFeeding.
  ///
  /// In en, this message translates to:
  /// **'Average Feeding'**
  String get averageFeeding;

  /// No description provided for @dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily Average'**
  String get dailyAverage;

  /// No description provided for @log_sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep Log'**
  String get log_sleep;

  /// No description provided for @track_sleep_patterns.
  ///
  /// In en, this message translates to:
  /// **'Track sleep patterns'**
  String get track_sleep_patterns;

  /// No description provided for @start_sleep_timer.
  ///
  /// In en, this message translates to:
  /// **'Start Sleep Timer'**
  String get start_sleep_timer;

  /// No description provided for @save_sleep_record.
  ///
  /// In en, this message translates to:
  /// **'Save Sleep Record'**
  String get save_sleep_record;

  /// No description provided for @sleep_last_sleep.
  ///
  /// In en, this message translates to:
  /// **'Last sleep: {time} ({duration} min)'**
  String sleep_last_sleep(String time, int duration);

  /// No description provided for @sleep_recommended_wake_time.
  ///
  /// In en, this message translates to:
  /// **'Recommended wake time: 1 hour 30 min'**
  String get sleep_recommended_wake_time;

  /// No description provided for @sleep_first_record.
  ///
  /// In en, this message translates to:
  /// **'First sleep record! Please select the start time.'**
  String get sleep_first_record;

  /// No description provided for @sleep_time_ago_minutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String sleep_time_ago_minutes(int minutes);

  /// No description provided for @sleep_time_ago_hours.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr {minutes} min ago'**
  String sleep_time_ago_hours(int hours, int minutes);

  /// No description provided for @sleep_status.
  ///
  /// In en, this message translates to:
  /// **'Sleep Status'**
  String get sleep_status;

  /// No description provided for @record_past_sleep.
  ///
  /// In en, this message translates to:
  /// **'Record Past Sleep'**
  String get record_past_sleep;

  /// No description provided for @sleep_in_progress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get sleep_in_progress;

  /// No description provided for @start_time.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get start_time;

  /// No description provided for @end_time_wake_up.
  ///
  /// In en, this message translates to:
  /// **'End Time (Wake Up)'**
  String get end_time_wake_up;

  /// No description provided for @sleep_location.
  ///
  /// In en, this message translates to:
  /// **'Sleep Location'**
  String get sleep_location;

  /// No description provided for @sleep_crib.
  ///
  /// In en, this message translates to:
  /// **'Crib'**
  String get sleep_crib;

  /// No description provided for @sleep_bed.
  ///
  /// In en, this message translates to:
  /// **'Bed'**
  String get sleep_bed;

  /// No description provided for @sleep_stroller.
  ///
  /// In en, this message translates to:
  /// **'Stroller'**
  String get sleep_stroller;

  /// No description provided for @sleep_car.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get sleep_car;

  /// No description provided for @sleep_arms.
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get sleep_arms;

  /// No description provided for @sleep_quality.
  ///
  /// In en, this message translates to:
  /// **'Sleep Quality'**
  String get sleep_quality;

  /// No description provided for @sleep_quality_good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get sleep_quality_good;

  /// No description provided for @sleep_quality_fair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get sleep_quality_fair;

  /// No description provided for @sleep_quality_poor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get sleep_quality_poor;

  /// No description provided for @notes_optional.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notes_optional;

  /// No description provided for @observations_hint_sleep.
  ///
  /// In en, this message translates to:
  /// **'Any observations? (e.g., woke up crying, slept soundly)'**
  String get observations_hint_sleep;

  /// No description provided for @sleep_total_duration.
  ///
  /// In en, this message translates to:
  /// **'Total sleep time: {hours} hr {minutes} min'**
  String sleep_total_duration(int hours, int minutes);

  /// No description provided for @sleep_record_complete.
  ///
  /// In en, this message translates to:
  /// **'Sleep Record Complete! 😴'**
  String get sleep_record_complete;

  /// No description provided for @sleep_save_failed.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String sleep_save_failed(String error);

  /// No description provided for @sleep_today_total.
  ///
  /// In en, this message translates to:
  /// **'⏱️ Total sleep today: {hours} hr {minutes} min'**
  String sleep_today_total(int hours, int minutes);

  /// No description provided for @sleep_yesterday_diff_plus.
  ///
  /// In en, this message translates to:
  /// **'📈 +{diff} min from yesterday'**
  String sleep_yesterday_diff_plus(int diff);

  /// No description provided for @sleep_yesterday_diff_minus.
  ///
  /// In en, this message translates to:
  /// **'📉 {diff} min from yesterday'**
  String sleep_yesterday_diff_minus(int diff);

  /// No description provided for @sleep_this_record.
  ///
  /// In en, this message translates to:
  /// **'🎯 This record: {minutes} min'**
  String sleep_this_record(int minutes);

  /// No description provided for @sleep_in_progress_label.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get sleep_in_progress_label;

  /// No description provided for @log_feeding.
  ///
  /// In en, this message translates to:
  /// **'Feeding Log'**
  String get log_feeding;

  /// No description provided for @track_feeding_types.
  ///
  /// In en, this message translates to:
  /// **'Track different feeding types'**
  String get track_feeding_types;

  /// No description provided for @save_feeding_record.
  ///
  /// In en, this message translates to:
  /// **'Save Feeding Record'**
  String get save_feeding_record;

  /// No description provided for @feeding_last_time.
  ///
  /// In en, this message translates to:
  /// **'Last feeding: {time} ago'**
  String feeding_last_time(String time);

  /// No description provided for @feeding_recommended_interval.
  ///
  /// In en, this message translates to:
  /// **'Recommended interval: 2-3 hours'**
  String get feeding_recommended_interval;

  /// No description provided for @feeding_first_record.
  ///
  /// In en, this message translates to:
  /// **'First feeding record! Please enter feeding information.'**
  String get feeding_first_record;

  /// No description provided for @feeding_time.
  ///
  /// In en, this message translates to:
  /// **'Feeding Time'**
  String get feeding_time;

  /// No description provided for @feeding_type.
  ///
  /// In en, this message translates to:
  /// **'Feeding Type'**
  String get feeding_type;

  /// No description provided for @bottle.
  ///
  /// In en, this message translates to:
  /// **'Bottle'**
  String get bottle;

  /// No description provided for @breast.
  ///
  /// In en, this message translates to:
  /// **'Breast'**
  String get breast;

  /// No description provided for @solid_food.
  ///
  /// In en, this message translates to:
  /// **'Solid Food'**
  String get solid_food;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @breast_side.
  ///
  /// In en, this message translates to:
  /// **'Breast Side'**
  String get breast_side;

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get left;

  /// No description provided for @right.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get right;

  /// No description provided for @both.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get both;

  /// No description provided for @observations_hint_feeding.
  ///
  /// In en, this message translates to:
  /// **'Any observations? (e.g., good appetite, refused milk)'**
  String get observations_hint_feeding;

  /// No description provided for @feeding_record_complete.
  ///
  /// In en, this message translates to:
  /// **'Feeding Record Complete! 🍼'**
  String get feeding_record_complete;

  /// No description provided for @feeding_today_count.
  ///
  /// In en, this message translates to:
  /// **'🍼 Today\'s feedings: {count}'**
  String feeding_today_count(int count);

  /// No description provided for @feeding_bottle_amount.
  ///
  /// In en, this message translates to:
  /// **'📊 {ml} ml ({oz} oz)'**
  String feeding_bottle_amount(int ml, String oz);

  /// No description provided for @feeding_breast_both.
  ///
  /// In en, this message translates to:
  /// **'🤱 Both sides'**
  String get feeding_breast_both;

  /// No description provided for @feeding_breast_left.
  ///
  /// In en, this message translates to:
  /// **'🤱 Left'**
  String get feeding_breast_left;

  /// No description provided for @feeding_breast_right.
  ///
  /// In en, this message translates to:
  /// **'🤱 Right'**
  String get feeding_breast_right;

  /// No description provided for @log_diaper.
  ///
  /// In en, this message translates to:
  /// **'Diaper Log'**
  String get log_diaper;

  /// No description provided for @track_diaper_types.
  ///
  /// In en, this message translates to:
  /// **'Track diaper types'**
  String get track_diaper_types;

  /// No description provided for @save_diaper_record.
  ///
  /// In en, this message translates to:
  /// **'Save Diaper Record'**
  String get save_diaper_record;

  /// No description provided for @diaper_last_change.
  ///
  /// In en, this message translates to:
  /// **'Last diaper change: {time} ago'**
  String diaper_last_change(String time);

  /// No description provided for @diaper_recommended_interval.
  ///
  /// In en, this message translates to:
  /// **'Recommended change interval: 2-3 hours'**
  String get diaper_recommended_interval;

  /// No description provided for @diaper_first_record.
  ///
  /// In en, this message translates to:
  /// **'First diaper record! Please select the diaper status.'**
  String get diaper_first_record;

  /// No description provided for @diaper_change_time.
  ///
  /// In en, this message translates to:
  /// **'Diaper Change Time'**
  String get diaper_change_time;

  /// No description provided for @diaper_type.
  ///
  /// In en, this message translates to:
  /// **'Diaper Type'**
  String get diaper_type;

  /// No description provided for @wet_desc.
  ///
  /// In en, this message translates to:
  /// **'Wet'**
  String get wet_desc;

  /// No description provided for @urineOnly.
  ///
  /// In en, this message translates to:
  /// **'Urine only'**
  String get urineOnly;

  /// No description provided for @dirty_desc.
  ///
  /// In en, this message translates to:
  /// **'Dirty'**
  String get dirty_desc;

  /// No description provided for @bowelMovement.
  ///
  /// In en, this message translates to:
  /// **'Bowel movement'**
  String get bowelMovement;

  /// No description provided for @both_desc.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get both_desc;

  /// No description provided for @wet_and_dirty.
  ///
  /// In en, this message translates to:
  /// **'Wet and dirty'**
  String get wet_and_dirty;

  /// No description provided for @observations_hint_diaper.
  ///
  /// In en, this message translates to:
  /// **'Any observations? (e.g., color, consistency)'**
  String get observations_hint_diaper;

  /// No description provided for @diaper_record_complete.
  ///
  /// In en, this message translates to:
  /// **'Diaper Record Complete!'**
  String get diaper_record_complete;

  /// No description provided for @diaper_today_count.
  ///
  /// In en, this message translates to:
  /// **'🧷 Today\'s changes: {count}'**
  String diaper_today_count(int count);

  /// No description provided for @diaper_wet_only.
  ///
  /// In en, this message translates to:
  /// **'💧 Wet only'**
  String get diaper_wet_only;

  /// No description provided for @diaper_dirty_only.
  ///
  /// In en, this message translates to:
  /// **'💩 Dirty'**
  String get diaper_dirty_only;

  /// No description provided for @diaper_both.
  ///
  /// In en, this message translates to:
  /// **'💧💩 Wet and dirty'**
  String get diaper_both;

  /// No description provided for @health_record.
  ///
  /// In en, this message translates to:
  /// **'Health Record'**
  String get health_record;

  /// No description provided for @medication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medication;

  /// No description provided for @temperature_unit.
  ///
  /// In en, this message translates to:
  /// **'Temperature Unit'**
  String get temperature_unit;

  /// No description provided for @celsius.
  ///
  /// In en, this message translates to:
  /// **'Celsius (°C)'**
  String get celsius;

  /// No description provided for @fahrenheit.
  ///
  /// In en, this message translates to:
  /// **'Fahrenheit (°F)'**
  String get fahrenheit;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @highFever.
  ///
  /// In en, this message translates to:
  /// **'⚠️ High fever - consider contacting your pediatrician'**
  String get highFever;

  /// No description provided for @additionalObservationsHint.
  ///
  /// In en, this message translates to:
  /// **'Any additional observations?'**
  String get additionalObservationsHint;

  /// No description provided for @saveTemperature.
  ///
  /// In en, this message translates to:
  /// **'Save Temperature'**
  String get saveTemperature;

  /// No description provided for @enterValidTemperature.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid temperature'**
  String get enterValidTemperature;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @temperature_record_baby.
  ///
  /// In en, this message translates to:
  /// **'Record baby\'s temperature'**
  String get temperature_record_baby;

  /// No description provided for @temperature_normal_range.
  ///
  /// In en, this message translates to:
  /// **'Normal range: 36.5-37.5°C (97.7-99.5°F)\n38°C or higher is considered fever.'**
  String get temperature_normal_range;

  /// No description provided for @temperature_fever_status.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Fever detected'**
  String get temperature_fever_status;

  /// No description provided for @temperature_normal_status.
  ///
  /// In en, this message translates to:
  /// **'✅ Normal temperature'**
  String get temperature_normal_status;

  /// No description provided for @temperature_record_complete.
  ///
  /// In en, this message translates to:
  /// **'Temperature Record Complete!'**
  String get temperature_record_complete;

  /// No description provided for @medication_type.
  ///
  /// In en, this message translates to:
  /// **'Medication Type'**
  String get medication_type;

  /// No description provided for @feverReducer.
  ///
  /// In en, this message translates to:
  /// **'Fever Reducer'**
  String get feverReducer;

  /// No description provided for @antibiotic.
  ///
  /// In en, this message translates to:
  /// **'Antibiotic'**
  String get antibiotic;

  /// No description provided for @medicationOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get medicationOther;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @reasonForMedicationHint.
  ///
  /// In en, this message translates to:
  /// **'Reason for medication?'**
  String get reasonForMedicationHint;

  /// No description provided for @saveMedication.
  ///
  /// In en, this message translates to:
  /// **'Save Medication'**
  String get saveMedication;

  /// No description provided for @medication_record_info.
  ///
  /// In en, this message translates to:
  /// **'Record medication information'**
  String get medication_record_info;

  /// No description provided for @medication_record_complete.
  ///
  /// In en, this message translates to:
  /// **'Medication Record Complete!'**
  String get medication_record_complete;

  /// No description provided for @growth_record_title.
  ///
  /// In en, this message translates to:
  /// **'Growth Record'**
  String get growth_record_title;

  /// No description provided for @growth_record_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Record baby\'s height, weight, and head circumference'**
  String get growth_record_subtitle;

  /// No description provided for @growth_track_progress.
  ///
  /// In en, this message translates to:
  /// **'Track regularly to monitor growth trends'**
  String get growth_track_progress;

  /// No description provided for @growth_weight_kg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get growth_weight_kg;

  /// No description provided for @growth_height_cm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get growth_height_cm;

  /// No description provided for @growth_head_cm.
  ///
  /// In en, this message translates to:
  /// **'Head Circumference (cm)'**
  String get growth_head_cm;

  /// No description provided for @growth_save_record.
  ///
  /// In en, this message translates to:
  /// **'Save Growth Record'**
  String get growth_save_record;

  /// No description provided for @growth_min_one_value.
  ///
  /// In en, this message translates to:
  /// **'Please enter at least one measurement'**
  String get growth_min_one_value;

  /// No description provided for @growth_record_complete.
  ///
  /// In en, this message translates to:
  /// **'Growth Record Complete!'**
  String get growth_record_complete;

  /// No description provided for @log_play_activity.
  ///
  /// In en, this message translates to:
  /// **'Play Activity'**
  String get log_play_activity;

  /// No description provided for @play_track_developmental.
  ///
  /// In en, this message translates to:
  /// **'Track developmental play activities'**
  String get play_track_developmental;

  /// No description provided for @save_activity.
  ///
  /// In en, this message translates to:
  /// **'Save Activity'**
  String get save_activity;

  /// No description provided for @play_context_hint.
  ///
  /// In en, this message translates to:
  /// **'Select age-appropriate play activities.\nRegular play helps baby\'s physical and cognitive development.'**
  String get play_context_hint;

  /// No description provided for @select_activity.
  ///
  /// In en, this message translates to:
  /// **'Select Activity'**
  String get select_activity;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @activity_notes_hint.
  ///
  /// In en, this message translates to:
  /// **'Add activity notes...'**
  String get activity_notes_hint;

  /// No description provided for @development_benefits.
  ///
  /// In en, this message translates to:
  /// **'Development Benefits:'**
  String get development_benefits;

  /// No description provided for @play_select_time.
  ///
  /// In en, this message translates to:
  /// **'Please select activity and duration'**
  String get play_select_time;

  /// No description provided for @play_record_complete.
  ///
  /// In en, this message translates to:
  /// **'Play Activity Complete! 🎉'**
  String get play_record_complete;

  /// No description provided for @play_today_count.
  ///
  /// In en, this message translates to:
  /// **'🎯 Today\'s activities: {count}'**
  String play_today_count(int count);

  /// No description provided for @play_duration_minutes.
  ///
  /// In en, this message translates to:
  /// **'⏱️ {minutes} min'**
  String play_duration_minutes(int minutes);
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
