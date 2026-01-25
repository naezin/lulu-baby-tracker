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
  String get criticalAlertTitle => 'Consider talking to your pediatrician';

  @override
  String get criticalAlertMessage =>
      'If you\'re concerned, your pediatrician can provide personalized guidance. We can generate a report to share with your doctor.';

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
  String get alertSleepUrgentTitle => 'Time for a sleep break';

  @override
  String alertSleepUrgentMessage(int minutes) {
    return 'Baby might be getting sleepy. Consider putting down soon.';
  }

  @override
  String get alertSleepWarningTitle => 'Almost time for sleep';

  @override
  String alertSleepWarningMessage(int minutes) {
    return 'Consider putting to sleep in ${minutes}min.';
  }

  @override
  String get alertFeedingUrgentTitle => 'Feeding time is here';

  @override
  String alertFeedingUrgentMessage(int minutes) {
    return 'Baby might be hungry soon.';
  }

  @override
  String get alertFeedingWarningTitle => 'Feeding time soon';

  @override
  String alertFeedingWarningMessage(int minutes) {
    return 'Baby might be ready to eat in ${minutes}min.';
  }

  @override
  String get alertDiaperWarningTitle => 'Diaper check';

  @override
  String alertDiaperWarningMessage(int hours) {
    return 'Might be time for a diaper change.';
  }

  @override
  String get recordsFilterAllPeriod => 'All Time';

  @override
  String get recordsFilterSearch => 'Search';

  @override
  String get insightPositive => 'Good';

  @override
  String get insightWarning => 'Heads up';

  @override
  String get insightConcern => 'Worth noting';

  @override
  String get insightNeutral => 'Info';

  @override
  String get weeklyInsightsTitle => 'This Week\'s Insights';

  @override
  String get weeklyInsightsNoData => 'Record data to see weekly insights';

  @override
  String get trendImproving => 'Improving';

  @override
  String get trendDeclining => 'A bit lower';

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

  @override
  String get log_sleep => 'Sleep Log';

  @override
  String get track_sleep_patterns => 'Track sleep patterns';

  @override
  String get start_sleep_timer => 'Start Sleep Timer';

  @override
  String get save_sleep_record => 'Save Sleep Record';

  @override
  String sleep_last_sleep(String time, int duration) {
    return 'Last sleep: $time ($duration min)';
  }

  @override
  String get sleep_recommended_wake_time =>
      'Recommended wake time: 1 hour 30 min';

  @override
  String get sleep_first_record =>
      'First sleep record! Please select the start time.';

  @override
  String sleep_time_ago_minutes(int minutes) {
    return '$minutes min ago';
  }

  @override
  String sleep_time_ago_hours(int hours, int minutes) {
    return '$hours hr $minutes min ago';
  }

  @override
  String get sleep_status => 'Sleep Status';

  @override
  String get record_past_sleep => 'Record Past Sleep';

  @override
  String get sleep_in_progress => 'In Progress';

  @override
  String get start_time => 'Start Time';

  @override
  String get end_time_wake_up => 'End Time (Wake Up)';

  @override
  String get sleep_location => 'Sleep Location';

  @override
  String get sleep_crib => 'Crib';

  @override
  String get sleep_bed => 'Bed';

  @override
  String get sleep_stroller => 'Stroller';

  @override
  String get sleep_car => 'Car';

  @override
  String get sleep_arms => 'Arms';

  @override
  String get sleep_quality => 'Sleep Quality';

  @override
  String get sleep_quality_good => 'Good';

  @override
  String get sleep_quality_fair => 'Fair';

  @override
  String get sleep_quality_poor => 'Poor';

  @override
  String get notes_optional => 'Notes (Optional)';

  @override
  String get observations_hint_sleep =>
      'Any observations? (e.g., woke up crying, slept soundly)';

  @override
  String sleep_total_duration(int hours, int minutes) {
    return 'Total sleep time: $hours hr $minutes min';
  }

  @override
  String get sleep_record_complete => 'Sleep Record Complete! 😴';

  @override
  String sleep_save_failed(String error) {
    return 'Save failed: $error';
  }

  @override
  String sleep_today_total(int hours, int minutes) {
    return '⏱️ Total sleep today: $hours hr $minutes min';
  }

  @override
  String sleep_yesterday_diff_plus(int diff) {
    return '📈 +$diff min from yesterday';
  }

  @override
  String sleep_yesterday_diff_minus(int diff) {
    return '📉 $diff min from yesterday';
  }

  @override
  String sleep_this_record(int minutes) {
    return '🎯 This record: $minutes min';
  }

  @override
  String get sleep_in_progress_label => 'In progress';

  @override
  String get log_feeding => 'Feeding Log';

  @override
  String get track_feeding_types => 'Track different feeding types';

  @override
  String get save_feeding_record => 'Save Feeding Record';

  @override
  String feeding_last_time(String time) {
    return 'Last feeding: $time ago';
  }

  @override
  String get feeding_recommended_interval => 'Recommended interval: 2-3 hours';

  @override
  String get feeding_first_record =>
      'First feeding record! Please enter feeding information.';

  @override
  String get feeding_time => 'Feeding Time';

  @override
  String get feeding_type => 'Feeding Type';

  @override
  String get bottle => 'Bottle';

  @override
  String get breast => 'Breast';

  @override
  String get solid_food => 'Solid Food';

  @override
  String get amount => 'Amount';

  @override
  String get breast_side => 'Breast Side';

  @override
  String get left => 'Left';

  @override
  String get right => 'Right';

  @override
  String get both => 'Both';

  @override
  String get observations_hint_feeding =>
      'Any observations? (e.g., good appetite, refused milk)';

  @override
  String get feeding_record_complete => 'Feeding Record Complete! 🍼';

  @override
  String feeding_today_count(int count) {
    return '🍼 Today\'s feedings: $count';
  }

  @override
  String feeding_bottle_amount(int ml, String oz) {
    return '📊 $ml ml ($oz oz)';
  }

  @override
  String get feeding_breast_both => '🤱 Both sides';

  @override
  String get feeding_breast_left => '🤱 Left';

  @override
  String get feeding_breast_right => '🤱 Right';

  @override
  String get log_diaper => 'Diaper Log';

  @override
  String get track_diaper_types => 'Track diaper types';

  @override
  String get save_diaper_record => 'Save Diaper Record';

  @override
  String diaper_last_change(String time) {
    return 'Last diaper change: $time ago';
  }

  @override
  String get diaper_recommended_interval =>
      'Recommended change interval: 2-3 hours';

  @override
  String get diaper_first_record =>
      'First diaper record! Please select the diaper status.';

  @override
  String get diaper_change_time => 'Diaper Change Time';

  @override
  String get diaper_type => 'Diaper Type';

  @override
  String get wet_desc => 'Wet';

  @override
  String get urineOnly => 'Urine only';

  @override
  String get dirty_desc => 'Dirty';

  @override
  String get bowelMovement => 'Bowel movement';

  @override
  String get both_desc => 'Both';

  @override
  String get wet_and_dirty => 'Wet and dirty';

  @override
  String get observations_hint_diaper =>
      'Any observations? (e.g., color, consistency)';

  @override
  String get diaper_record_complete => 'Diaper Record Complete!';

  @override
  String diaper_today_count(int count) {
    return '🧷 Today\'s changes: $count';
  }

  @override
  String get diaper_wet_only => '💧 Wet only';

  @override
  String get diaper_dirty_only => '💩 Dirty';

  @override
  String get diaper_both => '💧💩 Wet and dirty';

  @override
  String get health_record => 'Health Record';

  @override
  String get medication => 'Medication';

  @override
  String get temperature_unit => 'Temperature Unit';

  @override
  String get celsius => 'Celsius (°C)';

  @override
  String get fahrenheit => 'Fahrenheit (°F)';

  @override
  String get time => 'Time';

  @override
  String get highFever =>
      '⚠️ High fever - consider contacting your pediatrician';

  @override
  String get additionalObservationsHint => 'Any additional observations?';

  @override
  String get saveTemperature => 'Save Temperature';

  @override
  String get enterValidTemperature => 'Please enter a valid temperature';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get temperature_record_baby => 'Record baby\'s temperature';

  @override
  String get temperature_normal_range =>
      'Normal range: 36.5-37.5°C (97.7-99.5°F)\n38°C or higher is considered fever.';

  @override
  String get temperature_fever_status => '⚠️ Fever detected';

  @override
  String get temperature_normal_status => '✅ Normal temperature';

  @override
  String get temperature_record_complete => 'Temperature Record Complete!';

  @override
  String get medication_type => 'Medication Type';

  @override
  String get feverReducer => 'Fever Reducer';

  @override
  String get antibiotic => 'Antibiotic';

  @override
  String get medicationOther => 'Other';

  @override
  String get dosage => 'Dosage';

  @override
  String get reasonForMedicationHint => 'Reason for medication?';

  @override
  String get saveMedication => 'Save Medication';

  @override
  String get medication_record_info => 'Record medication information';

  @override
  String get medication_record_complete => 'Medication Record Complete!';

  @override
  String get growth_record_title => 'Growth Record';

  @override
  String get growth_record_subtitle =>
      'Record baby\'s height, weight, and head circumference';

  @override
  String get growth_track_progress =>
      'Track regularly to monitor growth trends';

  @override
  String get growth_weight_kg => 'Weight (kg)';

  @override
  String get growth_height_cm => 'Height (cm)';

  @override
  String get growth_head_cm => 'Head Circumference (cm)';

  @override
  String get growth_save_record => 'Save Growth Record';

  @override
  String get growth_min_one_value => 'Please enter at least one measurement';

  @override
  String get growth_record_complete => 'Growth Record Complete!';

  @override
  String get log_play_activity => 'Play Activity';

  @override
  String get play_track_developmental => 'Track developmental play activities';

  @override
  String get save_activity => 'Save Activity';

  @override
  String get play_context_hint =>
      'Select age-appropriate play activities.\nRegular play helps baby\'s physical and cognitive development.';

  @override
  String get select_activity => 'Select Activity';

  @override
  String get duration => 'Duration';

  @override
  String get activity_notes_hint => 'Add activity notes...';

  @override
  String get development_benefits => 'Development Benefits:';

  @override
  String get play_select_time => 'Please select activity and duration';

  @override
  String get play_record_complete => 'Play Activity Complete! 🎉';

  @override
  String play_today_count(int count) {
    return '🎯 Today\'s activities: $count';
  }

  @override
  String play_duration_minutes(int minutes) {
    return '⏱️ $minutes min';
  }
}
