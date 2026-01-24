// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Lulu';

  @override
  String get appTagline => 'AI-Powered Baby Sleep Companion';

  @override
  String get tabHome => 'Home';

  @override
  String get tabSleep => 'Sleep';

  @override
  String get tabAnalytics => 'Analytics';

  @override
  String get tabChat => 'AI Chat';

  @override
  String get tabSettings => 'Settings';

  @override
  String get navHome => 'Home';

  @override
  String get navRecords => 'Records';

  @override
  String get navInsights => 'Insights';

  @override
  String get navSettings => 'Settings';

  @override
  String get navStats => 'Stats';

  @override
  String get homeTitle => 'Welcome back!';

  @override
  String get homeSubtitle => 'Track your baby\'s daily activities';

  @override
  String get todaySummary => 'Today\'s Summary';

  @override
  String get sleepsToday => 'Sleeps';

  @override
  String get feedingsToday => 'Feedings';

  @override
  String get diapersToday => 'Diapers';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get recentActivities => 'Recent Activities';

  @override
  String get seeAll => 'See All';

  @override
  String get sleep => 'Sleep';

  @override
  String get feeding => 'Feeding';

  @override
  String get diaper => 'Diaper';

  @override
  String get health => 'Health';

  @override
  String get play => 'Play';

  @override
  String get noRecords => 'No records yet';

  @override
  String get activityHistory => 'Activity History';

  @override
  String get viewAllRecordedActivities => 'View all recorded activities';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageEnglishUS => 'English (US)';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageKoreanKR => 'Korean';

  @override
  String get units => 'Units';

  @override
  String get temperature => 'Temperature';

  @override
  String get weight => 'Weight';

  @override
  String get volume => 'Volume';

  @override
  String get unitCelsius => '℃';

  @override
  String get unitFahrenheit => '℉';

  @override
  String get unitKg => 'kg';

  @override
  String get unitLb => 'lb';

  @override
  String get unitMl => 'ml';

  @override
  String get unitOz => 'oz';

  @override
  String get notifications => 'Notifications';

  @override
  String get sweetSpotAlerts => 'Sweet Spot Alerts';

  @override
  String notifyMeMinutesBefore(int minutes) {
    return 'Notify me $minutes min before optimal sleep time';
  }

  @override
  String get appUpdatesAndTips => 'App Updates & Tips';

  @override
  String get receiveHelpfulTips =>
      'Receive helpful parenting tips and feature updates';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get allNotificationsMarkedAsRead => 'All notifications marked as read';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get exportData => 'Export Data';

  @override
  String get importData => 'Import Data';

  @override
  String get exportToCSV => 'Export data to CSV file';

  @override
  String get importFromCSV => 'Import data from CSV file';

  @override
  String get sweetSpotDemo => 'Sweet Spot Demo';

  @override
  String get tryAISleepPredictionDemo => 'Try the AI sleep prediction demo';

  @override
  String get insights => 'Insights';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String error(String message) {
    return 'Error: $message';
  }

  @override
  String get aiCoachingTitle => 'AI Coaching Insight';

  @override
  String get aiCoachingAnalyzing => 'AI is analyzing...';

  @override
  String get aiCoachingEmpathy => 'Empathy';

  @override
  String get aiCoachingInsight => 'Data Insight';

  @override
  String get aiCoachingAction => 'Action Plan';

  @override
  String get aiCoachingExpert => 'Expert Advice';

  @override
  String get aiCoachingFeedbackQuestion => 'Was this helpful?';

  @override
  String get aiCoachingFeedbackPositive => 'Helpful';

  @override
  String get aiCoachingFeedbackNegative => 'Not helpful';

  @override
  String get aiCoachingFeedbackThanks =>
      'Thank you for your feedback! We\'ll use it to improve our advice.';

  @override
  String get aiAnalysisAvailable => 'AI Analysis Available';

  @override
  String get tapChartForAnalysis =>
      'Tap on the chart to have AI analyze that time period';

  @override
  String get criticalAlertTitle => 'Expert Consultation Recommended';

  @override
  String get criticalAlertMessage =>
      'Your baby\'s condition requires careful observation. We recommend consulting with a pediatrician and can generate a report to share with your doctor.';

  @override
  String get generatePDFReport => 'Generate PDF Report';

  @override
  String get longestSleepStretch => 'Longest Sleep Stretch';

  @override
  String get hours => 'hours';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get actionZoneCardTitle => 'What should I do now?';

  @override
  String get actionZoneNoDataMessage => 'Record sleep to get recommendations';

  @override
  String get actionZoneSweetSpotPassedMessage =>
      'Sweet spot passed - put baby to sleep now!';

  @override
  String get actionZoneSweetSpotNowMessage =>
      'Perfect time to put baby to sleep!';

  @override
  String get actionZoneSweetSpotUpcomingMessage => 'Put to sleep by this time';

  @override
  String get actionZoneSleepNowButton => 'Sleep Now';

  @override
  String get actionZoneSetAlarmButton => 'Set Alarm';

  @override
  String get todaysSnapshotTitle => 'Today\'s Snapshot';

  @override
  String get todaysSnapshotSleep => 'Sleep';

  @override
  String get todaysSnapshotTotalTime => 'Total Time';

  @override
  String get todaysSnapshotFeeding => 'Feeding';

  @override
  String get smartAlertsTitle => 'Smart Alerts';

  @override
  String get smartAlertsViewAll => 'View All';

  @override
  String get alertSleepUrgentTitle => 'Baby has been awake too long!';

  @override
  String alertSleepUrgentMessage(int minutes) {
    return '${minutes}min over recommended. Put to sleep now.';
  }

  @override
  String get alertSleepWarningTitle => 'Almost time for sleep';

  @override
  String alertSleepWarningMessage(int minutes) {
    return 'Put to sleep in ${minutes}min.';
  }

  @override
  String get alertFeedingUrgentTitle => 'Feeding time overdue!';

  @override
  String alertFeedingUrgentMessage(int minutes) {
    return '${minutes}min delayed.';
  }

  @override
  String get alertFeedingWarningTitle => 'Feeding time soon';

  @override
  String alertFeedingWarningMessage(int minutes) {
    return 'Feed in ${minutes}min.';
  }

  @override
  String get alertDiaperWarningTitle => 'Check diaper';

  @override
  String alertDiaperWarningMessage(int hours) {
    return '${hours}h since last change.';
  }

  @override
  String get recordsFilterAllPeriod => 'All Time';

  @override
  String get recordsFilterSearch => 'Search';

  @override
  String get insightPositive => 'Good';

  @override
  String get insightWarning => 'Warning';

  @override
  String get insightConcern => 'Concern';

  @override
  String get insightNeutral => 'Info';

  @override
  String get weeklyInsightsTitle => 'This Week\'s Insights';

  @override
  String get weeklyInsightsNoData => 'Record data to see weekly insights';

  @override
  String get trendImproving => 'Improving';

  @override
  String get trendDeclining => 'Declining';

  @override
  String get trendStable => 'Stable';

  @override
  String get viewDetails => 'View Details';

  @override
  String get averageSleep => 'Average Sleep';

  @override
  String get sleepCount => 'Sleep Count';

  @override
  String get averageFeeding => 'Average Feeding';

  @override
  String get dailyAverage => 'Daily Average';
}
