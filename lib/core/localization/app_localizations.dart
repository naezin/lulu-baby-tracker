import 'package:flutter/material.dart';

/// 앱 다국어 지원 클래스
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App Name
      'app_name': 'Lulu',
      'app_tagline': 'AI-Powered Sleep Coach for Your Baby',

      // Bottom Navigation
      'nav_home': 'Home',
      'nav_sleep': 'Sleep',
      'nav_records': 'Records',
      'nav_insights': 'Insights',
      'nav_lulu': 'Lulu',
      'nav_more': 'More',

      // Home Screen
      'home_welcome': 'Welcome back!',
      'home_today_summary': 'Today\'s Summary',
      'home_quick_actions': 'Quick Actions',
      'home_recent_activities': 'Recent Activities',
      'home_ai_tips': 'AI Tips',

      // Action Zone Card
      'action_zone_title': 'What to do now?',
      'action_zone_no_data': 'Log sleep to get recommendations',
      'action_zone_past_window': 'Sweet spot passed - sleep now!',
      'action_zone_in_window': 'Perfect time to sleep!',
      'action_zone_before_window': 'Best time to sleep by',
      'action_sleep_now': 'Sleep Now',
      'action_set_alarm': 'Set Alarm',
      'minutes_remaining': ' min left',

      // Smart Alerts
      'smart_alerts_title': 'Smart Alerts',
      'view_all': 'View All',

      // Sleep Tracking
      'sleep_title': 'Sleep Tracking',
      'sleep_start': 'Start Sleep',
      'sleep_stop': 'Stop Sleep',
      'sleep_log': 'Log Sleep',
      'sleep_quality': 'Sleep Quality',
      'sleep_duration': 'Duration',
      'sleep_location': 'Location',
      'sleep_crib': 'Crib',
      'sleep_bed': 'Bed',
      'sleep_stroller': 'Stroller',
      'sleep_car': 'Car Seat',
      'sleep_arms': 'In Arms',
      'sleep_quality_excellent': 'Excellent',
      'sleep_quality_good': 'Good',
      'sleep_quality_fair': 'Fair',
      'sleep_quality_poor': 'Poor',

      // Feeding
      'feeding_title': 'Feeding',
      'feeding_log': 'Log Feeding',
      'feeding_type': 'Type',
      'feeding_breast_left': 'Left Breast',
      'feeding_breast_right': 'Right Breast',
      'feeding_bottle': 'Bottle',
      'feeding_solid': 'Solid Food',
      'feeding_amount': 'Amount',
      'feeding_duration': 'Duration',
      'feeding_side': 'Side',

      // Diaper
      'diaper_title': 'Diaper Change',
      'diaper_log': 'Log Change',
      'diaper_type': 'Type',
      'diaper_wet': 'Wet',
      'diaper_dirty': 'Dirty',
      'diaper_mixed': 'Mixed',
      'diaper_clean': 'Clean',

      // Records
      'records_title': 'Records',
      'records_all': 'All Records',
      'records_sleep': 'Sleep',
      'records_feeding': 'Feeding',
      'records_diaper': 'Diaper',
      'records_health': 'Health',
      'records_play': 'Play',
      'records_empty': 'No records yet',
      'records_empty_subtitle': 'Start tracking your baby\'s activities',

      // Records V2 - Quick Record
      'quick_record': 'Quick Record',
      'quick_record_hint': 'Tap to record instantly, long press for details',
      'now_feeding': 'Feed Now',
      'now_diaper': 'Diaper Now',
      'start_sleep': 'Start Sleep',
      'end_sleep': 'End Sleep',
      'play_record': 'Play',
      'health_record': 'Health',
      'todays_timeline': "Today's Timeline",
      'no_records_today': 'No records today',
      'start_first_record_hint': 'Tap the buttons above to start',
      'today_summary': 'Today\'s Summary',

      // Insights
      'insights_title': 'Insights',
      'insights_sleep_patterns': 'Sleep Patterns',
      'insights_feeding_schedule': 'Feeding Schedule',
      'insights_growth': 'Growth',
      'insights_weekly': 'Weekly',
      'insights_monthly': 'Monthly',
      'insights_custom': 'Custom Range',

      // Analysis Screen
      'analysis': 'Analysis',
      'this_week': 'This Week',
      'this_month': 'This Month',
      'q_sleeping_well': 'Is my baby sleeping well?',
      'q_night_wakeups': 'Are night wakings normal?',
      'q_feeding_amount': 'Is feeding amount enough?',
      'q_eat_play_sleep': 'How is the eat-play-sleep pattern?',
      'sleeping_well': 'Yes, sleeping well!',
      'needs_attention': 'Needs some attention',
      'normal': 'Normal range',
      'normal_wakeups': 'Normal range',
      'slightly_high': 'Slightly high',
      'adequate': 'Adequate',
      'check_needed': 'Check needed',
      'good_pattern': 'Good pattern!',
      'needs_improvement': 'Needs improvement',
      'avg_night_sleep': 'Avg night sleep',
      'avg_wakeups': 'This week avg',
      'daily_avg': 'Daily avg',
      'tip_reduce_wakeups': 'Tip: Try increasing last feeding by 10-20ml',
      'view_sleep_chart': '📈 View sleep chart',
      'view_24h_rhythm': '🕐 View 24h rhythm',
      'pediatric_report': 'Pediatric Visit Report',
      'report_description': 'Generate a PDF summary to show your doctor',
      'generate_pdf': 'Generate PDF',

      // Analytics
      'analytics_title': 'Analytics',
      'analytics_export': 'Export Data',
      'analytics_import': 'Import Data',
      'analytics_total_sleep': 'Total Sleep',
      'analytics_avg_sleep': 'Average Sleep',
      'analytics_total_feedings': 'Total Feedings',
      'analytics_total_diapers': 'Diapers Changed',

      // Today's Summary - Predictive Cards
      'today_summary': 'Today\'s Summary',
      'next_sweet_spot': 'Next Sweet Spot',
      'next_feeding_in': 'Next feeding in',
      'last_fed': 'Last fed',
      'feeding_overdue': 'Feeding overdue',
      'activity_goal': 'Activity Goal',
      'tummy_time_goal': 'Tummy Time',
      'play_time_goal': 'Play Time',
      'achieved': 'achieved',
      'status_stable': 'Stable',
      'status_attention': 'Attention',
      'ai_coaching_sleepy': 'Baby might be getting sleepy. Lower the lights.',
      'ai_coaching_feeding_soon': 'Feeding time approaching. Prepare bottle/breast.',
      'ai_coaching_awake_too_long': 'Baby has been awake for a while. Watch for sleep cues.',
      'ai_coaching_active': 'Great time for tummy time or play!',
      'ai_coaching_all_good': 'Everything looks good! Keep up the great work.',

      // Empty State
      'first_record_prompt': 'Record your baby\'s first activity',
      'first_record_description': 'Track sleep, feeding, and play\nto let AI analyze your baby\'s patterns',
      'start_first_record': 'Start First Record',
      'quick_log': 'Quick Log',
      'sleep_prediction': 'Sleep Prediction',
      'start_sleep_now': 'Start Sleep Now',

      // AI Chat
      'chat_title': 'AI Sleep Coach',
      'chat_placeholder': 'Ask about sleep, feeding, or any concerns...',
      'chat_send': 'Send',
      'chat_thinking': 'Thinking...',
      'chat_welcome': 'Hi! I\'m your AI sleep coach. How can I help you today?',
      'chat_welcome_greeting': 'Hi! I\'m Lulu, your AI sleep consultant. 👶✨',
      'chat_welcome_description': 'I\'m here to help you navigate your baby\'s sleep journey with warmth, evidence-based guidance, and plenty of empathy.',
      'chat_welcome_question': 'What\'s on your mind today?',

      // Settings
      'settings_title': 'Settings',
      'settings_profile': 'Baby Profile',
      'settings_notifications': 'Notifications',
      'settings_language': 'Language',
      'settings_theme': 'Theme',
      'settings_data': 'Data Management',
      'settings_export': 'Export Data',
      'settings_import': 'Import Data',
      'settings_privacy': 'Privacy Policy',
      'settings_terms': 'Terms of Service',
      'settings_about': 'About',
      'settings_version': 'Version',

      // Export/Import
      'export_title': 'Export Data',
      'export_description': 'Export your baby\'s data as CSV',
      'export_success': 'Data exported successfully!',
      'export_error': 'Failed to export data',
      'import_title': 'Import Data',
      'import_description': 'Import data from CSV file',
      'import_success': 'Data imported successfully!',
      'import_error': 'Failed to import data',
      'import_choose_file': 'Choose File',
      'import_file_selected': 'File Selected',
      'import_start': 'Start Import',

      // Import Data Screen
      'import_your_baby_log': 'Import Your Baby Log',
      'import_upload_csv_description': 'Upload CSV file to restore your data',
      'import_select_csv_file': 'Select CSV File',
      'import_choose_csv_description': 'Choose a CSV file exported from Lulu\nor any compatible baby tracking app.',
      'import_progress_percentage': '{percentage}%',
      'import_summary': 'Import Summary',
      'import_total_records': 'Total Records Imported',
      'import_sleep_records': 'Sleep Records',
      'import_feeding_records': 'Feeding Records',
      'import_diaper_records': 'Diaper Records',
      'import_duplicates_skipped': 'Duplicates Skipped',
      'import_errors': 'Errors',
      'import_another_file': 'Import Another File',
      'import_complete': 'Import Complete!',
      'import_failed': 'Import Failed',
      'import_complete_message': 'Successfully imported {count} records:',
      'import_failed_message': 'Failed to import data:\n{error}',
      'import_sleep_emoji': '😴 {count} sleep records',
      'import_feeding_emoji': '🍼 {count} feeding records',
      'import_diaper_emoji': '🧷 {count} diaper records',
      'import_duplicates_warning': '⚠️ {count} duplicates skipped',
      'import_errors_warning': '❌ {count} errors encountered',
      'import_starting': 'Starting import...',
      'import_csv_format_guide': 'CSV Format Guide',
      'import_csv_format_details': '• CSV file should have headers in the first row\n• Lulu automatically detects Sleep, Feeding, and Diaper records\n• Duplicate records (same timestamp) are automatically skipped\n• Supported date formats: YYYY-MM-DD HH:mm, MM/DD/YYYY HH:mm\n• Compatible with exports from Lulu and other baby tracking apps',
      'import_recognized_headers': 'Recognized Headers',
      'import_headers_details': 'Type: type, activity, record type\nDate/Time: date, time, start time, timestamp\nDuration: duration, duration (min)\nSleep: quality, location\nFeeding: feeding type, amount (ml), side\nDiaper: diaper type, change type',
      'import_failed_to_pick': 'Failed to pick file: {error}',

      // Common
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'done': 'Done',
      'close': 'Close',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'confirm': 'Confirm',
      'undo': 'Undo',
      'notes': 'Notes',
      'time': 'Time',
      'date': 'Date',
      'today': 'Today',
      'yesterday': 'Yesterday',
      'tomorrow': 'Tomorrow',
      'time_now': 'Now',
      'time_minutes_ago': 'min ago',
      'time_hours_ago': 'hr ago',
      'time_days_ago': 'days ago',
      'time_minutes_later': 'min later',
      'time_hours_later': 'hr later',
      'time_today': 'Today',
      'time_yesterday': 'Yesterday',
      'time_tomorrow': 'Tomorrow',
      'this_week': 'This Week',
      'this_month': 'This Month',
      'minutes': 'minutes',
      'hours': 'hours',
      'ml': 'ml',
      'minutes_short': 'min',
      'hours_short': 'hr',

      // Errors
      'error_title': 'Error',
      'error_network': 'Network error. Please check your connection.',
      'error_unknown': 'An unexpected error occurred.',
      'error_invalid_input': 'Please enter valid information.',

      // Log Sleep Screen
      'log_sleep': 'Log Sleep',
      'sleep_in_progress': 'Sleep In Progress',
      'record_past_sleep': 'Record Past Sleep',
      'sleep_timer_running': 'Sleep timer is running',
      'log_completed_sleep': 'Log a completed sleep session',
      'start_time': 'Start Time',
      'end_time': 'End Time',
      'end_time_wake_up': 'End Time (Wake Up)',
      'car_seat': 'Car Seat',
      'sleep_quality': 'Sleep Quality',
      'notes_optional': 'Notes (Optional)',
      'observations_hint_sleep': 'Any observations? (e.g., woke up twice, slept soundly)',
      'start_sleep_timer': 'Start Sleep Timer',
      'save_sleep_record': 'Save Sleep Record',
      'duration': 'Duration',
      'duration_format': 'Duration: {hours}h {minutes}m',
      'sleep_recorded_success': '✅ Sleep recorded successfully!',

      // Log Feeding Screen
      'log_feeding': 'Log Feeding',
      'record_feeding': 'Record Feeding',
      'track_feeding_types': 'Track bottle, breast, or solid food',
      'feeding_time': 'Feeding Time',
      'feeding_type': 'Feeding Type',
      'bottle': 'Bottle',
      'breast': 'Breast',
      'solid_food': 'Solid Food',
      'amount': 'Amount',
      'breast_side': 'Breast Side',
      'left': 'Left',
      'right': 'Right',
      'both': 'Both',
      'observations_hint_feeding': 'Any observations? (e.g., fed well, fussy)',
      'save_feeding_record': 'Save Feeding Record',
      'feeding_recorded_success': '✅ Feeding recorded successfully!',

      // Log Diaper Screen
      'log_diaper': 'Log Diaper',
      'record_diaper_change': 'Record Diaper Change',
      'track_diaper_types': 'Track wet, dirty, or both',
      'diaper_change_time': 'Diaper Change Time',
      'diaper_type': 'Diaper Type',
      'urineOnly': 'Urine Only',
      'bowelMovement': 'Bowel Movement',
      'wet_and_dirty': 'Both',
      'wet_desc': 'Wet',
      'dirty_desc': 'Dirty',
      'both_desc': 'Both',
      'observations_hint_diaper': 'Any observations? (e.g., color, consistency)',
      'save_diaper_record': 'Save Diaper Record',
      'diaper_recorded_success': '✅ Diaper change recorded successfully!',

      // Log Health Screen
      'health_record': 'Health Record',
      'temperature': 'Temperature',
      'medication': 'Medication',
      'temperature_unit': 'Temperature Unit',
      'celsius': 'Celsius (℃)',
      'fahrenheit': 'Fahrenheit (℉)',
      'high_fever_detected': '⚠️ High Fever Detected!\\nConsider medication if needed.',
      'fever_advice': 'Fever Advice ({months} months old)',
      'tips': 'Tips:',
      'urgent_medical_attention': '🚨 URGENT MEDICAL ATTENTION NEEDED',
      'fever_urgent_message': 'Your baby is under 3 months old with a fever of {temp}°{unit}.',
      'immediate_evaluation': '⚠️ This requires IMMEDIATE evaluation by a pediatrician.',
      'actions_now': 'Actions to take NOW:',
      'call_pediatrician': 'Call Pediatrician',
      'go_to_er': 'Go to ER',
      'time': 'Time',
      'change': 'Change',
      'notes_optional_short': 'Notes (optional)',
      'additional_observations': 'Any additional observations...',
      'save_temperature': 'Save Temperature',
      'saving': 'Saving...',
      'temperature_recorded': 'Temperature recorded!',
      'enter_valid_temperature': 'Please enter a valid temperature',
      'medication_type': 'Medication Type',
      'fever_reducer': 'Fever Reducer',
      'antibiotic': 'Antibiotic',
      'other': 'Other',
      'medication_name': 'Medication Name',
      'dosage': 'Dosage',
      'safety_timer': 'Safety Timer',
      'next_dose_available': 'Next dose available in:',
      'next_dose': 'Next dose: {time}',
      'time_given': 'Time Given',
      'reason_for_medication': 'Reason for medication...',
      'save_medication': 'Save Medication',
      'select_medication': 'Please select a medication',
      'medication_recorded': 'Medication recorded!',
      'medication_recorded_next': 'Medication recorded! Next dose in {hours} hours',
      'ibuprofen_warning': '⚠️ Ibuprofen is NOT recommended for infants under 6 months. Please consult your pediatrician.',
      'dosage_calculator': '💊 Dosage Calculator',
      'medication_name_label': 'Medication: {name}',
      'baby_weight': 'Baby\'s Weight: {weight} kg',
      'recommended_dosage': 'Recommended Dosage:',
      'frequency': 'Frequency: Every {hours} hours',
      'max_daily': 'Max Daily: {mg} mg',
      'concentration': 'Concentration: {conc}',
      'safety_warnings': 'Safety Warnings:',
      'guideline_disclaimer': 'ℹ️ This is a guideline only. Always consult your pediatrician or pharmacist.',

      // Activity History Screen
      'activity_history': 'Activity History',
      'refresh': 'Refresh',
      'all': 'All',
      'todays_snapshot_title': "Today's Snapshot",
      'sleep': 'Sleep',
      'feed': 'Feed',
      'feeding': 'Feeding',
      'diaper': 'Diaper',
      'play': 'Play',
      'health': 'Health',
      'no_activities_yet': 'No activities yet',
      'no_activities_type': 'No {type} activities',
      'start_logging': 'Start logging to see your history',
      'today': 'Today',
      'delete': 'Delete',
      'delete_activity': 'Delete Activity?',
      'confirm_delete_activity': 'Are you sure you want to delete this {type} activity?',
      'cancel': 'Cancel',
      'activity_deleted': 'Activity deleted',

      // Statistics Screen
      'statistics': 'Statistics',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'key_metrics': 'Key Metrics',
      'avg_sleep': 'Avg Sleep',
      'per_day': 'per day',
      'last_diaper': 'Last Diaper',
      'elapsed': 'elapsed',
      'today_feedings': 'Today Feedings',
      'times': 'times',
      'today_sleeps': 'Today Sleeps',
      'daily_sleep_hours': 'Daily Sleep Hours',
      'no_sleep_data': 'No sleep data',
      'daily_feeding_amount': 'Daily Feeding Amount',
      'no_feeding_data': 'No feeding data',
      'hours_ago': '{hours}h ago',
      'minutes_ago': '{minutes}m ago',

      // Records Screen
      'add_record': 'Add Record',
      'health': 'Health',
      'error_loading_records': 'Error loading records',
      'sleep_record': 'Sleep',
      'feeding_record': 'Feeding',
      'diaper_record': 'Diaper',
      'temperature_record': 'Temperature',
      'medication_record': 'Medication',
      'health_record': 'Health',
      'activity': 'Activity',
      'delete_record': 'Delete Record',
      'confirm_delete_record': 'Are you sure you want to delete this record?',
      'record_deleted': 'Record deleted',
      'failed_to_delete': 'Failed to delete: {error}',
      'high_fever': '🔥 HIGH',

      // Insights Screen
      'insights': 'Insights',
      'daily_rhythm_24h': '24-Hour Daily Rhythm',
      'weekly_sleep_trends': 'Weekly Sleep Trends',
      'sleep_trends': 'Sleep Trends',
      'last_7_days': 'Last 7 Days',
      'great_progress': 'Great Progress!',
      'baby_slept_more_this_week': 'Baby slept {minutes} min more on average this week',
      'hours_sleep': '{hours} hours sleep',
      'wake_ups_count': '{count} wake-ups',
      'mon': 'Mon',
      'tue': 'Tue',
      'wed': 'Wed',
      'thu': 'Thu',
      'fri': 'Fri',
      'sat': 'Sat',
      'sun': 'Sun',
      'eat_play_sleep_cycle': 'Eat-Play-Sleep Cycle',
      'pattern_analysis': 'Pattern Analysis',
      'ai_sleep_insight': 'AI Sleep Insight',
      'sleep_longer_this_week': 'This week, your baby slept 30 minutes longer on average! 🎉',
      'nap_deepest_time': 'Your baby tends to nap deepest between 2-4 PM. At 72 days old (about 2 months), babies are learning to distinguish day from night. Try dimming lights after 7 PM to support this development.',
      'developmental_stage': 'Developmental Stage: 2 months',
      'consistency_score': 'Consistency Score',
      'eat': 'Eat',
      'play': 'Play',
      'sleep': 'Sleep',
      'times_per_day': '{count} times/day',
      'avg_minutes': 'Avg {minutes} min',
      'hours_per_day': '{hours} hrs/day',
      'feed_to_sleep_warning': 'Feed-to-sleep detected 4 times this week. Try a gentle wake after feeding.',
      'your_baby_patterns': 'Your Baby\'s Patterns',
      'longest_sleep_stretch': 'Longest Sleep Stretch',
      'usually_time_range': 'Usually {start} - {end}',
      'morning_wake_time': 'Morning Wake Time',
      'consistent_variance': 'Consistent ±{minutes} minutes',
      'preferred_nap_time': 'Preferred Nap Time',
      'deepest_afternoon_nap': 'Deepest afternoon nap',
      'feeding_interval': 'Feeding Interval',
      'every_hours': 'Every {hours} hours',
      'well_spaced': 'Well-spaced throughout day',

      // Sweet Spot Demo Screen
      'sweet_spot_demo_title': 'Sweet Spot Demo',
      'demo_try_sweet_spot_prediction': 'Try Sweet Spot Prediction',
      'demo_description': 'See when your baby should nap based on their age and last wake time',
      'demo_baby_age': 'Baby Age',
      'demo_months_old': '{months} months old',
      'demo_last_wake_up_time': 'Last Wake Up Time',
      'demo_calculate_sweet_spot': 'Calculate Sweet Spot',
      'demo_what_is_sweet_spot': 'What is Sweet Spot?',
      'demo_sweet_spot_explanation': 'Sweet Spot is the optimal time window for your baby to fall asleep easily, based on their age and wake windows.',
      'demo_custom_time': 'Custom Time: {time}',
      'demo_time_ago_minutes': '{minutes}m ago',
      'demo_time_ago_hours': '{hours}h ago',
      'demo_time_ago_hours_minutes': '{hours}h {minutes}m ago',
      'demo_time_format_am': 'AM',
      'demo_time_format_pm': 'PM',
      'demo_error_calculate': 'Could not calculate Sweet Spot',
      'demo_sweet_spot_result': 'Sweet Spot Result',
      'demo_view_on_home': 'View on Home',
      'demo_wake_window': 'Wake Window',
      'demo_age': 'Age',
      'demo_recommended_naps': 'Recommended Naps',
      'demo_naps_per_day': '{naps}/day',
      'demo_months': '{months} months',

      // Medication names
      'acetaminophen_tylenol': 'Acetaminophen (Tylenol)',
      'ibuprofen_advil': 'Ibuprofen (Advil)',
      'amoxicillin': 'Amoxicillin',
      'azithromycin': 'Azithromycin',
      'cefdinir': 'Cefdinir',

      // Sweet Spot Widget (sweet_spot_gauge.dart, sweet_spot_card.dart)
      'empty_state_track_sleep_sweet_spot': 'Track Sleep to See Sweet Spot',
      'empty_state_log_wake_up_hint': 'Log wake-up time for nap predictions',
      'empty_state_wake_up_hint_detailed': 'Log your baby\'s wake-up time to get personalized nap predictions',
      'sweet_spot_label_until': 'Until Sweet Spot',
      'sweet_spot_label_remaining': 'Sweet Spot Remaining',
      'sweet_spot_label_time_awake': 'Time Awake',
      'sweet_spot_stat_wake_window': 'Wake Window',
      'sweet_spot_stat_baby_age': 'Baby Age',
      'sweet_spot_stat_nap_today': 'Nap Today',
      'sweet_spot_title_window': 'Sweet Spot Window',
      'sweet_spot_label_wake_window_value': 'Wake Window: {range}',
      'sweet_spot_progress_awake_minutes': 'Awake: {minutes} min',
      'sweet_spot_progress_in_minutes': 'In {minutes} min',
      'sweet_spot_progress_minutes_left': '{minutes} min left',
      'sweet_spot_info_age': 'Age',
      'sweet_spot_info_nap': 'Nap',
      'sweet_spot_info_daily_naps': 'Daily Naps',

      // Sweet Spot Recommendation Card States
      'sweet_spot_state_no_data': 'Need sleep record',
      'sweet_spot_state_play_time': 'Play time',
      'sweet_spot_state_sleep_soon': 'Sleep soon',
      'sweet_spot_state_optimal_time': 'Optimal sleep time',
      'sweet_spot_state_sleep_now': 'Sleep now',
      'sweet_spot_msg_no_data': 'Log sleep to get\npersonalized recommendations',
      'sweet_spot_msg_too_early': 'Still play time\nKeep baby awake a bit longer',
      'sweet_spot_msg_approaching': 'Sleep time is coming\nStart preparing',
      'sweet_spot_msg_active_window': 'Perfect time to\nput baby to sleep!',
      'sweet_spot_msg_overtired': 'Missed the sweet spot\nPut baby to sleep now',
      'sweet_spot_action_log_sleep': 'Log Sleep',
      'sweet_spot_action_sleep_now': 'Sleep Now',
      'sweet_spot_action_set_reminder': 'Get Reminder',

      // Chat Interface (chat_bubble.dart, chat_input.dart)
      'timestamp_just_now': 'Just now',
      'chat_button_tooltip_add_context': 'Add context',
      'chat_hint_ask_lulu_about_sleep': 'Ask Lulu about sleep...',
      'chat_hint_lulu_typing': 'Lulu is typing...',
      'chat_button_tooltip_send': 'Send',

      // Dashboard Screen (dashboard_screen.dart, daily_summary_card.dart)
      'greeting_good_morning': 'Good Morning',
      'greeting_good_afternoon': 'Good Afternoon',
      'greeting_good_evening': 'Good Evening',
      'dashboard_title_babys_journey': 'Baby\'s Journey',
      'dashboard_section_daily_briefing': 'Daily Briefing',
      'briefing_card_title_sleep_score': 'Sleep Score',
      'briefing_card_subtitle_great': 'Great!',
      'briefing_card_title_feeding': 'Feeding',
      'briefing_card_subtitle_today': 'Today',
      'briefing_card_title_diaper': 'Diaper',
      'briefing_card_subtitle_changes': 'Changes',
      'briefing_card_title_temperature': 'Temperature',
      'briefing_card_subtitle_normal': 'Normal',
      'dashboard_section_sweet_spot_timer': 'Sweet Spot Timer',
      'dashboard_section_recent_activities': 'Recent Activities',
      'button_see_all': 'See All',
      'activity_title_nap_time': 'Nap Time',
      'activity_title_feeding': 'Feeding',
      'activity_title_diaper_change': 'Diaper Change',
      'activity_subtitle_wet_diaper': 'Wet',
      'summary_label_today': 'Today',

      // Insights Screen (insights_screen_old.dart)
      'empty_state_no_data_yet': 'No Data Yet',
      'empty_state_start_tracking_insights': 'Start tracking activities to see insights',
      'insights_card_title_avg_sleep': 'Avg Sleep',
      'insights_card_title_feedings': 'Feedings',
      'insights_card_title_diapers': 'Diapers',
      'chart_no_sleep_data_available': 'No sleep data available',
      'chart_title_sleep_pattern': 'Sleep Pattern',
      'chart_title_temperature_trend': 'Temperature Trend',
      'alert_fever_detected_period': 'Fever detected in this period',
      'insights_section_activity_breakdown': 'Activity Breakdown',
      'pie_chart_label_sleep': 'Sleep',
      'pie_chart_label_feeding': 'Feeding',
      'pie_chart_label_diaper': 'Diaper',

      // Settings Screen (settings_screen.dart)
      'error_permission_denied': 'Permission denied',
      'notification_sweet_spot_disabled': 'Sweet Spot notifications disabled',
      'notification_alert_time_format': 'Alert time: {minutes} minutes before',
      'slider_label_5_minutes': '5 min',
      'slider_label_30_minutes': '30 min',
      'notification_updates_enabled': 'Updates enabled!',
      'notification_updates_disabled': 'Updates disabled',

      // Health Screen Placeholders (log_health_screen.dart)
      'health_hint_temperature_celsius': '36.5',
      'health_hint_temperature_fahrenheit': '97.7',
      'health_hint_medication_amount': '5.0',

      // Demo Data (demo_setup_screen.dart, chat_example.dart)
      'demo_baby_name': 'Demo Baby',
      'example_baby_name_emma': 'Emma',
      'example_baby_name_oliver': 'Oliver',
      'example_sleep_pattern': 'Waking 3-4 times per night',
      'example_sweet_spot_time': '10:30 AM - 11:15 AM',
      'app_title': 'Lulu - AI Sleep Consultant',

      // CSV Export Service (csv_export_service.dart)
      'export_progress_fetching_sleep': 'Fetching sleep records...',
      'export_progress_fetching_feeding': 'Fetching feeding records...',
      'export_progress_fetching_diaper': 'Fetching diaper records...',
      'export_progress_creating_csv': 'Creating CSV file...',
      'export_progress_completed': 'Export completed!',
      'csv_type_sleep': 'Sleep',
      'csv_type_feeding': 'Feeding',
      'csv_type_diaper': 'Diaper',
      'csv_header_type': 'Type',
      'csv_header_date': 'Date',
      'csv_header_time': 'Time',
      'csv_header_start_time': 'Start Time',
      'csv_header_end_time': 'End Time',
      'csv_header_duration': 'Duration',
      'csv_header_location': 'Location',
      'csv_header_quality': 'Quality',
      'csv_header_feeding_type': 'Feeding Type',
      'csv_header_amount': 'Amount',
      'csv_header_side': 'Side',
      'csv_header_diaper_type': 'Diaper Type',
      'csv_header_notes': 'Notes',
      'export_email_subject': 'Lulu Baby Log Export',
      'export_email_body': 'Here is your baby\'s activity log exported from Lulu app.',
      'feeding_type_breastfeeding': 'Breastfeeding',
      'feeding_type_bottle': 'Bottle',

      // Notification Service (notification_service.dart)
      'notification_channel_name_sweet_spot': 'Sweet Spot Alerts',
      'notification_channel_desc_sweet_spot': 'Notifications for optimal sleep times',

      // Daily Summary Service (daily_summary_service.dart)
      'summary_no_data_available': 'No data',

      // Quick Log Bar
      'activity_sleep': 'Sleep',
      'activity_feeding': 'Feed',
      'activity_play': 'Play',
      'activity_diaper': 'Diaper',
      'activity_health': 'Health',

      // Log Play Activity Screen
      'log_play_activity': 'Log Play',
      'select_activity': 'Select Activity',
      'development_benefits': 'Development Benefits:',
      'activity_notes_hint': 'Add notes...',
      'save_activity': 'Save Activity',

      // Play Activity Types
      'activity_tummyTime': 'Tummy Time',
      'activity_reading': 'Reading',
      'activity_rattlePlaying': 'Rattle Play',
      'activity_massage': 'Massage',
      'activity_walk': 'Walk',
      'activity_bath': 'Bath',
      'activity_music': 'Music',
      'activity_singing': 'Singing',
      'activity_exercise': 'Exercise',
      'activity_sensoryPlay': 'Sensory Play',
      'activity_other': 'Other',

      // Development Tags
      'dev_tag_motor': 'Motor',
      'dev_tag_cognitive': 'Cognitive',
      'dev_tag_sensory': 'Sensory',
      'dev_tag_bonding': 'Bonding',
      'dev_tag_language': 'Language',
      'dev_tag_emotional': 'Emotional',

      // Widgets
      'widget_next_sweet_spot': 'Next Sweet Spot',
      'widget_daily_summary': 'Daily Summary',
      'widget_next_feed': 'Next Feed',
      'widget_next_sleep': 'Next Sleep',
      'widget_in_minutes': 'in {minutes}m',
      'widget_today': 'Today',
      'widget_sleep_hours': '{hours}h',
      'widget_feeding_count': '{count}×',
      'widget_diaper_count': '{count}×',
      'widget_description': 'Track your baby\'s next sweet spot and daily activities',
      'widget_settings': 'Widget Settings',
      'widget_settings_description': 'Configure your home screen widgets',
      'widget_preview': 'Widget Preview',
      'widget_small_preview': 'Small Widget (2×2)',
      'widget_medium_preview': 'Medium Widget (4×2)',
      'widget_lock_screen_preview': 'Lock Screen Widget',
      'widget_update_now': 'Update Widgets',
      'widget_updating': 'Updating widgets...',
      'widget_updated_success': 'Widgets updated successfully!',
      'widget_add_instructions': 'How to Add Widgets',
      'widget_add_ios_step1': '1. Long press on your home screen',
      'widget_add_ios_step2': '2. Tap the + button in the top left',
      'widget_add_ios_step3': '3. Search for "Lulu"',
      'widget_add_ios_step4': '4. Choose your preferred widget size',
      'widget_add_android_step1': '1. Long press on your home screen',
      'widget_add_android_step2': '2. Tap "Widgets"',
      'widget_add_android_step3': '3. Find and select "Lulu"',
      'widget_add_android_step4': '4. Drag to your home screen',

      // Widget States - Empty
      'widget_empty_header': '🌙 Find your baby\'s golden time',
      'widget_empty_body': 'Tell us when your baby woke up, and we\'ll predict the best time to sleep',
      'widget_empty_cta': '🌅 Log wake-up time',

      // Widget States - Active
      'widget_active_header': 'Next Sweet Spot',
      'widget_active_remaining': '{n} min left',
      'widget_hint_green': '💡 Baby will get sleepy soon',
      'widget_hint_yellow': '💡 Sweet Spot is coming up',
      'widget_hint_red': '💡 Now is a good time!',

      // Widget States - Urgent
      'widget_urgent_header': '💤 It\'s Sweet Spot time!',
      'widget_urgent_body': 'This is when your baby falls asleep most easily',
      'widget_urgent_cta': '😴 Log sleep start',

      // Authentication
      'welcome_to_lulu': 'Welcome to Lulu',
      'tagline_peaceful_nights': 'For peaceful nights and happy days',
      'email': 'Email',
      'enter_email': 'Enter your email',
      'password': 'Password',
      'enter_password': 'Enter your password',
      'forgot_password': 'Forgot password?',
      'sign_in': 'Sign In',
      'sign_up': 'Sign Up',
      'or_continue_with': 'Or continue with',
      'dont_have_account': "Don't have an account?",
      'already_have_account': 'Already have an account?',
      'create_account': 'Create Account',
      'signup_subtitle': 'Join the Lulu family and start tracking',
      'name': 'Name',
      'enter_name': 'Enter your name',
      'confirm_password': 'Confirm Password',
      'confirm_password_hint': 'Re-enter your password',
      'agree_to': 'I agree to the ',
      'terms_of_service': 'Terms of Service',
      'and': ' and ',
      'privacy_policy': 'Privacy Policy',

      // Validation
      'email_required': 'Email is required',
      'email_invalid': 'Invalid email address',
      'password_required': 'Password is required',
      'password_too_short': 'Password must be at least 6 characters',
      'name_required': 'Name is required',
      'confirm_password_required': 'Please confirm your password',
      'passwords_dont_match': 'Passwords do not match',
      'weight_required': 'Weight is required',
      'weight_invalid': 'Invalid weight',

      // Onboarding
      'onboarding_intro': "Let's get to know your precious baby.\\nThis helps us provide personalized care recommendations.",
      'feature_ai_insights': 'AI-Powered Insights',
      'feature_sweet_spot': 'Sweet Spot Predictions',
      'feature_personalized': 'Personalized Care',
      'tell_us_about_baby': "Tell us about your baby",
      'baby_name': "Baby's name",
      'enter_baby_name': 'Enter name',
      'birth_date': 'Date of birth',
      'gender': 'Gender',
      'girl': 'Girl',
      'boy': 'Boy',
      'birth_weight': 'Birth weight (kg)',
      'enter_weight': 'e.g., 2.46',
      'back': 'Back',
      'next': 'Next',
      'finish': 'Finish',

      // Special Care
      'low_birth_weight_notice': 'We noticed your baby was born with a lower birth weight. We can provide specialized care recommendations.',
      'special_care_title': 'Special Care for Your Precious Baby',
      'special_care_message': 'Babies born with lower birth weights need extra care and attention. Would you like us to enable specialized growth monitoring and personalized feeding recommendations?',
      'no_thanks': 'No, thanks',
      'enable_special_care': 'Yes, enable',

      // === Post Record Feedback - Sleep ===
      'sleep_record_complete': 'Sleep Record Complete! 😴',
      'sleep_today_total': '⏱️ Total sleep today: {hours}h {minutes}m',
      'sleep_yesterday_diff_plus': '📈 +{diff} min from yesterday',
      'sleep_yesterday_diff_minus': '📉 {diff} min from yesterday',
      'sleep_this_record': '🎯 This record: {minutes} min',

      // === Post Record Feedback - Feeding ===
      'feeding_record_complete': 'Feeding Record Complete! 🍼',
      'feeding_today_count': '🍼 Today\'s feedings: {count}',
      'feeding_bottle_amount': '📊 {ml}ml ({oz}oz)',
      'feeding_breast_both': '🤱 Both sides',
      'feeding_breast_left': '🤱 Left side',
      'feeding_breast_right': '🤱 Right side',

      // === Post Record Feedback - Diaper ===
      'diaper_record_complete': 'Diaper Record Complete! 🧷',
      'diaper_today_count': '🧷 Today\'s changes: {count}',
      'diaper_wet_only': '💧 Wet only',
      'diaper_dirty_only': '💩 Dirty only',
      'diaper_both': '💧💩 Both',

      // === Growth Record Screen ===
      'growth_record': 'Growth',
      'growth_record_title': 'Growth Record',
      'growth_record_subtitle': 'Record baby\'s height, weight, and head circumference',
      'growth_track_progress': 'Track regularly to monitor growth trends',
      'growth_weight_kg': 'Weight (kg)',
      'growth_height_cm': 'Height (cm)',
      'growth_head_cm': 'Head Circumference (cm)',
      'growth_save_record': 'Save Growth Record',
      'growth_min_one_value': 'Please enter at least one measurement',
      'growth_record_complete': 'Growth Record Complete! 📈',

      // === Play Activity Screen ===
      'play_select_time': 'Please select activity and duration',
      'play_record_complete': 'Play Record Complete! 🎮',
      'play_track_developmental': 'Track developmental play activities',

      // === Health Record Screen ===
      'health_record_complete': 'Health Record Complete! 🏥',
      'health_fever_warning': '🔥 High fever detected! Please consult a doctor.',

      // === Common ===
      'great_job': 'Great job! 👏',
      'keep_it_up': 'Keep tracking!',

      // === Multi-Baby Onboarding (Step 4) ===
      'have_another_baby': 'Do you have another baby?',
      'multi_baby_description': 'You can manage twins or siblings together!',
      'add_another_baby': 'Add Another Baby',
      'skip_for_now': 'Skip for now →',
      'add_baby_later_hint': 'You can also add babies later in settings',

      // === Baby Switcher ===
      'select_baby': 'Select Baby',
      'add_baby': 'Add Baby',

      // === Add Baby Screen ===
      'baby_name': 'Baby Name',
      'baby_name_hint': 'Enter baby name',
      'baby_name_required': 'Please enter baby name',
      'birth_date': 'Birth Date',
      'birth_weight': 'Birth Weight (kg)',
      'gender': 'Gender',
      'female': 'Girl',
      'male': 'Boy',
      'is_premature': 'Premature Baby',
      'is_premature_hint': 'Born before 37 weeks',
      'due_date': 'Due Date',
      'save': 'Save',
    },
    'ko': {
      // App Name
      'app_name': 'Lulu',
      'app_tagline': 'AI 기반 우리 아기 수면 코치',

      // Bottom Navigation
      'nav_home': '홈',
      'nav_sleep': '수면',
      'nav_records': '기록',
      'nav_insights': '분석',
      'nav_lulu': '루루',
      'nav_more': '더보기',

      // Home Screen
      'home_welcome': '다시 오신 것을 환영합니다!',
      'home_today_summary': '오늘의 요약',
      'home_quick_actions': '빠른 기록',
      'home_recent_activities': '최근 활동',
      'home_ai_tips': 'AI 팁',

      // Action Zone Card
      'action_zone_title': '지금 뭘 하면 좋을까요?',
      'action_zone_no_data': '수면을 기록하면 추천을 받을 수 있어요',
      'action_zone_past_window': '스위트 스팟 지났어요 - 지금 재우세요!',
      'action_zone_in_window': '지금이 재우기 딱 좋은 시간이에요!',
      'action_zone_before_window': '이 시간까지 재우면 좋아요',
      'action_sleep_now': '지금 재우기',
      'action_set_alarm': '알림 설정',
      'minutes_remaining': '분 남음',

      // Smart Alerts
      'smart_alerts_title': '스마트 알림',
      'view_all': '전체 보기',

      // Sleep Tracking
      'sleep_title': '수면 기록',
      'sleep_start': '수면 시작',
      'sleep_stop': '수면 종료',
      'sleep_log': '수면 기록하기',
      'sleep_quality': '수면 품질',
      'sleep_duration': '수면 시간',
      'sleep_location': '수면 장소',
      'sleep_crib': '아기침대',
      'sleep_bed': '침대',
      'sleep_stroller': '유모차',
      'sleep_car': '카시트',
      'sleep_arms': '안아서',
      'sleep_quality_excellent': '매우 좋음',
      'sleep_quality_good': '좋음',
      'sleep_quality_fair': '보통',
      'sleep_quality_poor': '나쁨',

      // Feeding
      'feeding_title': '수유',
      'feeding_log': '수유 기록하기',
      'feeding_type': '수유 방법',
      'feeding_breast_left': '왼쪽 모유',
      'feeding_breast_right': '오른쪽 모유',
      'feeding_bottle': '분유',
      'feeding_solid': '이유식',
      'feeding_amount': '수유량',
      'feeding_duration': '수유 시간',
      'feeding_side': '쪽',

      // Diaper
      'diaper_title': '기저귀',
      'diaper_log': '기저귀 기록하기',
      'diaper_type': '종류',
      'diaper_wet': '소변',
      'diaper_dirty': '대변',
      'diaper_mixed': '대소변',
      'diaper_clean': '깨끗함',

      // Records
      'records_title': '기록',
      'records_all': '전체 기록',
      'records_sleep': '수면',
      'records_feeding': '수유',
      'records_diaper': '기저귀',
      'records_health': '건강',
      'records_play': '놀이',
      'records_empty': '아직 기록이 없습니다',
      'records_empty_subtitle': '아기의 활동을 기록해보세요',

      // Records V2 - Quick Record
      'quick_record': '원탭 기록',
      'quick_record_hint': '탭하면 즉시 기록, 길게 누르면 상세 입력',
      'now_feeding': '지금 수유',
      'now_diaper': '지금 기저귀',
      'start_sleep': '지금 재움',
      'end_sleep': '수면 종료',
      'play_record': '놀이 기록',
      'health_record': '건강 기록',
      'todays_timeline': '오늘의 타임라인',
      'no_records_today': '오늘 기록이 없어요',
      'start_first_record_hint': '위 버튼을 눌러 첫 기록을 시작하세요',
      'today_summary': '오늘 요약',

      // Insights
      'insights_title': '분석',
      'insights_sleep_patterns': '수면 패턴',
      'insights_feeding_schedule': '수유 스케줄',
      'insights_growth': '성장',
      'insights_weekly': '주간',
      'insights_monthly': '월간',
      'insights_custom': '기간 설정',

      // Analysis Screen
      'analysis': '분석',
      'this_week': '이번 주',
      'this_month': '이번 달',
      'q_sleeping_well': '우리 아기 요즘 잘 자고 있나요?',
      'q_night_wakeups': '밤에 깨는 횟수는 정상인가요?',
      'q_feeding_amount': '수유량은 충분한가요?',
      'q_eat_play_sleep': '먹-놀-잠 패턴은 어떤가요?',
      'sleeping_well': '네, 잘 자고 있어요!',
      'needs_attention': '조금 관심이 필요해요',
      'normal': '정상 범위입니다',
      'normal_wakeups': '정상 범위예요',
      'slightly_high': '조금 많은 편이에요',
      'adequate': '적절합니다',
      'check_needed': '확인이 필요해요',
      'good_pattern': '좋은 패턴이에요!',
      'needs_improvement': '개선이 필요해요',
      'avg_night_sleep': '평균 밤잠',
      'avg_wakeups': '이번 주 평균',
      'daily_avg': '일 평균',
      'tip_reduce_wakeups': 'Tip: 마지막 수유량을 10-20ml 늘려보세요',
      'view_sleep_chart': '📈 수면 차트 보기',
      'view_24h_rhythm': '🕐 24시간 리듬 보기',
      'pediatric_report': '소아과 방문용 리포트',
      'report_description': '이번 주 데이터를 PDF로 정리해서 의사 선생님께 보여드리세요',
      'generate_pdf': 'PDF 생성하기',

      // Analytics
      'analytics_title': '통계',
      'analytics_export': '데이터 내보내기',
      'analytics_import': '데이터 가져오기',
      'analytics_total_sleep': '총 수면 시간',
      'analytics_avg_sleep': '평균 수면 시간',
      'analytics_total_feedings': '총 수유 횟수',
      'analytics_total_diapers': '기저귀 교체 횟수',

      // Today's Summary - Predictive Cards
      'today_summary': '오늘의 요약',
      'next_sweet_spot': '다음 스위트 스팟',
      'next_feeding_in': '다음 수유까지',
      'last_fed': '마지막 수유',
      'feeding_overdue': '수유 시간 경과',
      'activity_goal': '활동 목표',
      'tummy_time_goal': '배밀이',
      'play_time_goal': '놀이 시간',
      'achieved': '달성',
      'status_stable': '안정',
      'status_attention': '주의',
      'ai_coaching_sleepy': '아기가 졸려 할 수 있어요. 조명을 낮춰주세요.',
      'ai_coaching_feeding_soon': '곧 수유 시간이에요. 분유나 수유 준비를 해주세요.',
      'ai_coaching_awake_too_long': '아기가 오래 깨어있었어요. 수면 신호를 주시하세요.',
      'ai_coaching_active': '지금은 배밀이나 놀이하기 좋은 시간이에요!',
      'ai_coaching_all_good': '모든 것이 순조로워요! 잘하고 계세요.',

      // Empty State
      'first_record_prompt': '아기의 첫 기록을 남겨주세요',
      'first_record_description': '수면, 수유, 활동을 기록하면\nAI가 아기의 패턴을 분석해드려요',
      'start_first_record': '첫 기록 시작하기',
      'quick_log': '빠른 기록',
      'sleep_prediction': '수면 예측',
      'start_sleep_now': '지금 수면 시작',

      // AI Chat
      'chat_title': 'AI 수면 코치',
      'chat_placeholder': '수면, 수유, 또는 궁금한 점을 물어보세요...',
      'chat_send': '전송',
      'chat_thinking': '생각 중...',
      'chat_welcome': '안녕하세요! 저는 AI 수면 코치입니다. 무엇을 도와드릴까요?',
      'chat_welcome_greeting': '안녕하세요! 저는 룰루, 당신의 AI 수면 컨설턴트입니다. 👶✨',
      'chat_welcome_description': '따뜻함과 과학적 근거, 그리고 충분한 공감을 바탕으로 아기의 수면 여정을 함께 해드립니다.',
      'chat_welcome_question': '오늘은 무엇이 궁금하신가요?',

      // Settings
      'settings_title': '설정',
      'settings_profile': '아기 프로필',
      'settings_notifications': '알림',
      'settings_language': '언어',
      'settings_theme': '테마',
      'settings_data': '데이터 관리',
      'settings_export': '데이터 내보내기',
      'settings_import': '데이터 가져오기',
      'settings_privacy': '개인정보 처리방침',
      'settings_terms': '서비스 이용약관',
      'settings_about': '앱 정보',
      'settings_version': '버전',

      // Export/Import
      'export_title': '데이터 내보내기',
      'export_description': '아기의 데이터를 CSV로 내보내기',
      'export_success': '데이터를 성공적으로 내보냈습니다!',
      'export_error': '데이터 내보내기에 실패했습니다',
      'import_title': '데이터 가져오기',
      'import_description': 'CSV 파일에서 데이터 가져오기',
      'import_success': '데이터를 성공적으로 가져왔습니다!',
      'import_error': '데이터 가져오기에 실패했습니다',
      'import_choose_file': '파일 선택',
      'import_file_selected': '파일 선택됨',
      'import_start': '가져오기 시작',

      // Import Data Screen
      'import_your_baby_log': '아기 기록 가져오기',
      'import_upload_csv_description': 'CSV 파일을 업로드하여 데이터 복원',
      'import_select_csv_file': 'CSV 파일 선택',
      'import_choose_csv_description': 'Lulu에서 내보낸 CSV 파일 또는\n호환 가능한 육아 앱 파일을 선택하세요.',
      'import_progress_percentage': '{percentage}%',
      'import_summary': '가져오기 요약',
      'import_total_records': '총 가져온 기록',
      'import_sleep_records': '수면 기록',
      'import_feeding_records': '수유 기록',
      'import_diaper_records': '기저귀 기록',
      'import_duplicates_skipped': '중복 건너뜀',
      'import_errors': '오류',
      'import_another_file': '다른 파일 가져오기',
      'import_complete': '가져오기 완료!',
      'import_failed': '가져오기 실패',
      'import_complete_message': '{count}개 기록을 성공적으로 가져왔습니다:',
      'import_failed_message': '데이터 가져오기 실패:\n{error}',
      'import_sleep_emoji': '😴 {count}개 수면 기록',
      'import_feeding_emoji': '🍼 {count}개 수유 기록',
      'import_diaper_emoji': '🧷 {count}개 기저귀 기록',
      'import_duplicates_warning': '⚠️ {count}개 중복 건너뜀',
      'import_errors_warning': '❌ {count}개 오류 발생',
      'import_starting': '가져오기 시작 중...',
      'import_csv_format_guide': 'CSV 형식 가이드',
      'import_csv_format_details': '• CSV 파일의 첫 행에 헤더가 있어야 합니다\n• Lulu는 수면, 수유, 기저귀 기록을 자동으로 감지합니다\n• 중복 기록(동일한 타임스탬프)은 자동으로 건너뜁니다\n• 지원되는 날짜 형식: YYYY-MM-DD HH:mm, MM/DD/YYYY HH:mm\n• Lulu 및 기타 육아 앱에서 내보낸 파일과 호환됩니다',
      'import_recognized_headers': '인식되는 헤더',
      'import_headers_details': '유형: type, activity, record type\n날짜/시간: date, time, start time, timestamp\n지속시간: duration, duration (min)\n수면: quality, location\n수유: feeding type, amount (ml), side\n기저귀: diaper type, change type',
      'import_failed_to_pick': '파일 선택 실패: {error}',

      // Common
      'save': '저장',
      'cancel': '취소',
      'delete': '삭제',
      'edit': '수정',
      'done': '완료',
      'close': '닫기',
      'ok': '확인',
      'yes': '예',
      'no': '아니오',
      'confirm': '확인',
      'undo': '실행 취소',
      'notes': '메모',
      'time': '시간',
      'date': '날짜',
      'today': '오늘',
      'yesterday': '어제',
      'tomorrow': '내일',
      'time_now': '방금',
      'time_minutes_ago': '분 전',
      'time_hours_ago': '시간 전',
      'time_days_ago': '일 전',
      'time_minutes_later': '분 후',
      'time_hours_later': '시간 후',
      'time_today': '오늘',
      'time_yesterday': '어제',
      'time_tomorrow': '내일',
      'this_week': '이번 주',
      'this_month': '이번 달',
      'minutes': '분',
      'hours': '시간',
      'ml': 'ml',
      'minutes_short': '분',
      'hours_short': '시간',

      // Errors
      'error_title': '오류',
      'error_network': '네트워크 오류가 발생했습니다. 연결을 확인해주세요.',
      'error_unknown': '예상치 못한 오류가 발생했습니다.',
      'error_invalid_input': '올바른 정보를 입력해주세요.',

      // Log Sleep Screen
      'log_sleep': '수면 기록',
      'sleep_in_progress': '수면 진행 중',
      'record_past_sleep': '과거 수면 기록',
      'sleep_timer_running': '수면 타이머 실행 중',
      'log_completed_sleep': '완료된 수면 세션 기록',
      'start_time': '시작 시간',
      'end_time': '종료 시간',
      'end_time_wake_up': '종료 시간 (기상)',
      'car_seat': '카시트',
      'sleep_quality': '수면 품질',
      'notes_optional': '메모 (선택사항)',
      'observations_hint_sleep': '관찰 사항이 있나요? (예: 두 번 깼음, 푹 잤음)',
      'start_sleep_timer': '수면 타이머 시작',
      'save_sleep_record': '수면 기록 저장',
      'duration': '지속 시간',
      'duration_format': '지속 시간: {hours}시간 {minutes}분',
      'sleep_recorded_success': '✅ 수면이 성공적으로 기록되었습니다!',

      // Log Feeding Screen
      'log_feeding': '수유 기록',
      'record_feeding': '수유 기록',
      'track_feeding_types': '분유, 모유 또는 이유식 추적',
      'feeding_time': '수유 시간',
      'feeding_type': '수유 유형',
      'bottle': '분유',
      'breast': '모유',
      'solid_food': '이유식',
      'amount': '양',
      'breast_side': '수유한 쪽',
      'left': '왼쪽',
      'right': '오른쪽',
      'both': '양쪽',
      'observations_hint_feeding': '관찰 사항이 있나요? (예: 잘 먹음, 까다로움)',
      'save_feeding_record': '수유 기록 저장',
      'feeding_recorded_success': '✅ 수유가 성공적으로 기록되었습니다!',

      // Log Diaper Screen
      'log_diaper': '기저귀 기록',
      'record_diaper_change': '기저귀 교체 기록',
      'track_diaper_types': '소변, 대변 또는 둘 다 추적',
      'diaper_change_time': '기저귀 교체 시간',
      'diaper_type': '기저귀 유형',
      'urineOnly': '소변만',
      'bowelMovement': '대변',
      'wet_and_dirty': '둘 다',
      'wet_desc': '소변',
      'dirty_desc': '대변',
      'both_desc': '둘 다',
      'observations_hint_diaper': '관찰 사항이 있나요? (예: 색상, 농도)',
      'save_diaper_record': '기저귀 기록 저장',
      'diaper_recorded_success': '✅ 기저귀 교체가 성공적으로 기록되었습니다!',

      // Log Health Screen
      'health_record': '건강 기록',
      'temperature': '체온',
      'medication': '투약',
      'temperature_unit': '체온 단위',
      'celsius': '섭씨 (℃)',
      'fahrenheit': '화씨 (℉)',
      'high_fever_detected': '⚠️ 고열 감지!\\n필요시 약 복용을 고려하세요.',
      'fever_advice': '발열 조언 ({months}개월)',
      'tips': '팁:',
      'urgent_medical_attention': '🚨 긴급 의료 조치 필요',
      'fever_urgent_message': '생후 3개월 미만 아기의 체온이 {temp}°{unit}입니다.',
      'immediate_evaluation': '⚠️ 소아과 의사의 즉각적인 진찰이 필요합니다.',
      'actions_now': '지금 취해야 할 조치:',
      'call_pediatrician': '소아과 전화',
      'go_to_er': '응급실 방문',
      'time': '시간',
      'change': '변경',
      'notes_optional_short': '메모 (선택사항)',
      'additional_observations': '추가 관찰 사항...',
      'save_temperature': '체온 저장',
      'saving': '저장 중...',
      'temperature_recorded': '체온이 기록되었습니다!',
      'enter_valid_temperature': '유효한 체온을 입력하세요',
      'medication_type': '약물 유형',
      'fever_reducer': '해열제',
      'antibiotic': '항생제',
      'other': '기타',
      'medication_name': '약물 이름',
      'dosage': '복용량',
      'safety_timer': '안전 타이머',
      'next_dose_available': '다음 복용 가능 시간:',
      'next_dose': '다음 복용: {time}',
      'time_given': '투약 시간',
      'reason_for_medication': '투약 이유...',
      'save_medication': '투약 저장',
      'select_medication': '약물을 선택하세요',
      'medication_recorded': '투약이 기록되었습니다!',
      'medication_recorded_next': '투약이 기록되었습니다! {hours}시간 후 다음 복용',
      'ibuprofen_warning': '⚠️ 이부프로펜은 생후 6개월 미만 영아에게 권장되지 않습니다. 소아과 의사와 상담하세요.',
      'dosage_calculator': '💊 복용량 계산기',
      'medication_name_label': '약물: {name}',
      'baby_weight': '아기 체중: {weight} kg',
      'recommended_dosage': '권장 복용량:',
      'frequency': '빈도: {hours}시간마다',
      'max_daily': '일일 최대: {mg} mg',
      'concentration': '농도: {conc}',
      'safety_warnings': '안전 경고:',
      'guideline_disclaimer': 'ℹ️ 이것은 가이드라인일 뿐입니다. 항상 소아과 의사나 약사와 상담하세요.',

      // Activity History Screen
      'activity_history': '활동 기록',
      'refresh': '새로고침',
      'all': '전체',
      'todays_snapshot_title': '오늘의 스냅샷',
      'sleep': '수면',
      'feed': '수유',
      'feeding': '수유',
      'diaper': '기저귀',
      'play': '놀이',
      'health': '건강',
      'no_activities_yet': '아직 활동이 없습니다',
      'no_activities_type': '{type} 활동이 없습니다',
      'start_logging': '기록을 시작하여 히스토리를 확인하세요',
      'today': '오늘',
      'delete': '삭제',
      'delete_activity': '활동 삭제?',
      'confirm_delete_activity': '이 {type} 활동을 삭제하시겠습니까?',
      'cancel': '취소',
      'activity_deleted': '활동이 삭제되었습니다',

      // Statistics Screen
      'statistics': '통계',
      'weekly': '주간',
      'monthly': '월간',
      'key_metrics': '주요 지표',
      'avg_sleep': '평균 수면',
      'per_day': '하루',
      'last_diaper': '마지막 기저귀',
      'elapsed': '경과',
      'today_feedings': '오늘 수유',
      'times': '회',
      'today_sleeps': '오늘 수면',
      'daily_sleep_hours': '일일 수면 시간',
      'no_sleep_data': '수면 데이터 없음',
      'daily_feeding_amount': '일일 수유량',
      'no_feeding_data': '수유 데이터 없음',
      'hours_ago': '{hours}시간 전',
      'minutes_ago': '{minutes}분 전',

      // Records Screen
      'add_record': '기록 추가',
      'health': '건강',
      'error_loading_records': '기록 로딩 오류',
      'sleep_record': '수면',
      'feeding_record': '수유',
      'diaper_record': '기저귀',
      'temperature_record': '체온',
      'medication_record': '투약',
      'health_record': '건강',
      'activity': '활동',
      'delete_record': '기록 삭제',
      'confirm_delete_record': '이 기록을 삭제하시겠습니까?',
      'record_deleted': '기록이 삭제되었습니다',
      'failed_to_delete': '삭제 실패: {error}',
      'high_fever': '🔥 고열',

      // Insights Screen
      'insights': '인사이트',
      'daily_rhythm_24h': '24시간 일일 리듬',
      'weekly_sleep_trends': '주간 수면 추세',
      'sleep_trends': '수면 추세',
      'last_7_days': '최근 7일',
      'great_progress': '훌륭한 진전!',
      'baby_slept_more_this_week': '이번 주 아기가 평균 {minutes}분 더 잤어요',
      'hours_sleep': '{hours}시간 수면',
      'wake_ups_count': '{count}번 깸',
      'mon': '월',
      'tue': '화',
      'wed': '수',
      'thu': '목',
      'fri': '금',
      'sat': '토',
      'sun': '일',
      'eat_play_sleep_cycle': '먹기-놀기-자기 사이클',
      'pattern_analysis': '패턴 분석',
      'ai_sleep_insight': 'AI 수면 인사이트',
      'sleep_longer_this_week': '이번 주, 아기가 평균 30분 더 오래 잤어요! 🎉',
      'nap_deepest_time': '아기는 오후 2-4시 사이에 가장 깊게 낮잠을 자는 경향이 있습니다. 생후 72일(약 2개월)이 되면 아기들은 낮과 밤을 구분하는 법을 배웁니다. 오후 7시 이후 조명을 어둡게 하여 이 발달을 지원하세요.',
      'developmental_stage': '발달 단계: 2개월',
      'consistency_score': '일관성 점수',
      'eat': '먹기',
      'play': '놀기',
      'sleep': '자기',
      'times_per_day': '하루 {count}회',
      'avg_minutes': '평균 {minutes}분',
      'hours_per_day': '하루 {hours}시간',
      'feed_to_sleep_warning': '이번 주 4번 수유 후 바로 잠들었습니다. 수유 후 부드럽게 깨워보세요.',
      'your_baby_patterns': '우리 아기 패턴',
      'longest_sleep_stretch': '가장 긴 수면 시간',
      'usually_time_range': '보통 {start} - {end}',
      'morning_wake_time': '아침 기상 시간',
      'consistent_variance': '일정함 ±{minutes}분',
      'preferred_nap_time': '선호 낮잠 시간',
      'deepest_afternoon_nap': '가장 깊은 오후 낮잠',
      'feeding_interval': '수유 간격',
      'every_hours': '{hours}시간마다',
      'well_spaced': '하루 종일 잘 배분됨',

      // Sweet Spot Demo Screen
      'sweet_spot_demo_title': '스위트 스팟 데모',
      'demo_try_sweet_spot_prediction': '스위트 스팟 예측 체험하기',
      'demo_description': '아기의 나이와 마지막 기상 시간을 기반으로 낮잠 시간을 확인하세요',
      'demo_baby_age': '아기 나이',
      'demo_months_old': '{months}개월',
      'demo_last_wake_up_time': '마지막 기상 시간',
      'demo_calculate_sweet_spot': '스위트 스팟 계산하기',
      'demo_what_is_sweet_spot': '스위트 스팟이란?',
      'demo_sweet_spot_explanation': '스위트 스팟은 아기의 나이와 각성 시간을 기반으로 아기가 쉽게 잠들 수 있는 최적의 시간대입니다.',
      'demo_custom_time': '사용자 지정 시간: {time}',
      'demo_time_ago_minutes': '{minutes}분 전',
      'demo_time_ago_hours': '{hours}시간 전',
      'demo_time_ago_hours_minutes': '{hours}시간 {minutes}분 전',
      'demo_time_format_am': '오전',
      'demo_time_format_pm': '오후',
      'demo_error_calculate': '스위트 스팟을 계산할 수 없습니다',
      'demo_sweet_spot_result': '스위트 스팟 결과',
      'demo_view_on_home': '홈에서 보기',
      'demo_wake_window': '각성 시간',
      'demo_age': '나이',
      'demo_recommended_naps': '권장 낮잠 횟수',
      'demo_naps_per_day': '{naps}회/일',
      'demo_months': '{months}개월',

      // Medication names
      'acetaminophen_tylenol': '아세트아미노펜 (타이레놀)',
      'ibuprofen_advil': '이부프로펜 (애드빌)',
      'amoxicillin': '아목시실린',
      'azithromycin': '아지트로마이신',
      'cefdinir': '세프디니르',

      // Sweet Spot Widget (sweet_spot_gauge.dart, sweet_spot_card.dart)
      'empty_state_track_sleep_sweet_spot': '스위트 스팟을 보려면 수면을 기록하세요',
      'empty_state_log_wake_up_hint': '낮잠 예측을 위해 기상 시간을 기록하세요',
      'empty_state_wake_up_hint_detailed': '맞춤 낮잠 예측을 받으려면 아기의 기상 시간을 기록하세요',
      'sweet_spot_label_until': '스위트 스팟까지',
      'sweet_spot_label_remaining': '스위트 스팟 남은 시간',
      'sweet_spot_label_time_awake': '깨어있는 시간',
      'sweet_spot_stat_wake_window': '깨어있는 시간',
      'sweet_spot_stat_baby_age': '아기 나이',
      'sweet_spot_stat_nap_today': '오늘 낮잠',
      'sweet_spot_title_window': '스위트 스팟 시간대',
      'sweet_spot_label_wake_window_value': '깨어있는 시간: {range}',
      'sweet_spot_progress_awake_minutes': '깨어있음: {minutes}분',
      'sweet_spot_progress_in_minutes': '{minutes}분 후',
      'sweet_spot_progress_minutes_left': '{minutes}분 남음',
      'sweet_spot_info_age': '나이',
      'sweet_spot_info_nap': '낮잠',
      'sweet_spot_info_daily_naps': '일일 낮잠',

      // Sweet Spot Recommendation Card States
      'sweet_spot_state_no_data': '수면 기록 필요',
      'sweet_spot_state_play_time': '놀이 시간',
      'sweet_spot_state_sleep_soon': '곧 재울 시간',
      'sweet_spot_state_optimal_time': '최적 수면 시간',
      'sweet_spot_state_sleep_now': '즉시 재우기',
      'sweet_spot_msg_no_data': '수면을 기록하면\n맞춤 추천을 받을 수 있어요',
      'sweet_spot_msg_too_early': '아직 놀 시간이에요\n조금 더 깨어있게 해주세요',
      'sweet_spot_msg_approaching': '곧 재울 시간이에요\n준비를 시작하세요',
      'sweet_spot_msg_active_window': '지금이 재우기\n딱 좋은 시간이에요!',
      'sweet_spot_msg_overtired': '스위트 스팟을 놓쳤어요\n지금 바로 재워주세요',
      'sweet_spot_action_log_sleep': '수면 기록하기',
      'sweet_spot_action_sleep_now': '지금 재우기',
      'sweet_spot_action_set_reminder': '알림 받기',

      // Chat Interface (chat_bubble.dart, chat_input.dart)
      'timestamp_just_now': '방금 전',
      'chat_button_tooltip_add_context': '컨텍스트 추가',
      'chat_hint_ask_lulu_about_sleep': '룰루에게 수면에 대해 물어보세요...',
      'chat_hint_lulu_typing': '룰루가 입력 중...',
      'chat_button_tooltip_send': '전송',

      // Dashboard Screen (dashboard_screen.dart, daily_summary_card.dart)
      'greeting_good_morning': '좋은 아침입니다',
      'greeting_good_afternoon': '좋은 오후입니다',
      'greeting_good_evening': '좋은 저녁입니다',
      'dashboard_title_babys_journey': '아기의 하루',
      'dashboard_section_daily_briefing': '오늘의 브리핑',
      'briefing_card_title_sleep_score': '수면 점수',
      'briefing_card_subtitle_great': '훌륭해요!',
      'briefing_card_title_feeding': '수유',
      'briefing_card_subtitle_today': '오늘',
      'briefing_card_title_diaper': '기저귀',
      'briefing_card_subtitle_changes': '교체',
      'briefing_card_title_temperature': '체온',
      'briefing_card_subtitle_normal': '정상',
      'dashboard_section_sweet_spot_timer': '스위트 스팟 타이머',
      'dashboard_section_recent_activities': '최근 활동',
      'button_see_all': '전체 보기',
      'activity_title_nap_time': '낮잠 시간',
      'activity_title_feeding': '수유',
      'activity_title_diaper_change': '기저귀 교체',
      'activity_subtitle_wet_diaper': '소변',
      'summary_label_today': '오늘',

      // Insights Screen (insights_screen_old.dart)
      'empty_state_no_data_yet': '아직 데이터 없음',
      'empty_state_start_tracking_insights': '활동을 기록하여 인사이트를 확인하세요',
      'insights_card_title_avg_sleep': '평균 수면',
      'insights_card_title_feedings': '수유',
      'insights_card_title_diapers': '기저귀',
      'chart_no_sleep_data_available': '수면 데이터가 없습니다',
      'chart_title_sleep_pattern': '수면 패턴',
      'chart_title_temperature_trend': '체온 추이',
      'alert_fever_detected_period': '이 기간 동안 열이 감지되었습니다',
      'insights_section_activity_breakdown': '활동 분석',
      'pie_chart_label_sleep': '수면',
      'pie_chart_label_feeding': '수유',
      'pie_chart_label_diaper': '기저귀',

      // Settings Screen (settings_screen.dart)
      'error_permission_denied': '권한이 거부되었습니다',
      'notification_sweet_spot_disabled': '스위트 스팟 알림이 비활성화되었습니다',
      'notification_alert_time_format': '알림 시간: {minutes}분 전',
      'slider_label_5_minutes': '5분',
      'slider_label_30_minutes': '30분',
      'notification_updates_enabled': '업데이트가 활성화되었습니다!',
      'notification_updates_disabled': '업데이트가 비활성화되었습니다',

      // Health Screen Placeholders (log_health_screen.dart)
      'health_hint_temperature_celsius': '36.5',
      'health_hint_temperature_fahrenheit': '97.7',
      'health_hint_medication_amount': '5.0',

      // Demo Data (demo_setup_screen.dart, chat_example.dart)
      'demo_baby_name': '데모 아기',
      'example_baby_name_emma': 'Emma',
      'example_baby_name_oliver': 'Oliver',
      'example_sleep_pattern': '밤에 3-4회 깨어남',
      'example_sweet_spot_time': '오전 10:30 - 오전 11:15',
      'app_title': 'Lulu - AI 수면 컨설턴트',

      // CSV Export Service (csv_export_service.dart)
      'export_progress_fetching_sleep': '수면 기록 가져오는 중...',
      'export_progress_fetching_feeding': '수유 기록 가져오는 중...',
      'export_progress_fetching_diaper': '기저귀 기록 가져오는 중...',
      'export_progress_creating_csv': 'CSV 파일 생성 중...',
      'export_progress_completed': '내보내기 완료!',
      'csv_type_sleep': '수면',
      'csv_type_feeding': '수유',
      'csv_type_diaper': '기저귀',
      'csv_header_type': '유형',
      'csv_header_date': '날짜',
      'csv_header_time': '시간',
      'csv_header_start_time': '시작 시간',
      'csv_header_end_time': '종료 시간',
      'csv_header_duration': '기간',
      'csv_header_location': '장소',
      'csv_header_quality': '품질',
      'csv_header_feeding_type': '수유 유형',
      'csv_header_amount': '양',
      'csv_header_side': '측면',
      'csv_header_diaper_type': '기저귀 유형',
      'csv_header_notes': '메모',
      'export_email_subject': 'Lulu 아기 로그 내보내기',
      'export_email_body': 'Lulu 앱에서 내보낸 아기의 활동 로그입니다.',
      'feeding_type_breastfeeding': '모유 수유',
      'feeding_type_bottle': '분유',

      // Notification Service (notification_service.dart)
      'notification_channel_name_sweet_spot': '스위트 스팟 알림',
      'notification_channel_desc_sweet_spot': '최적의 수면 시간 알림',

      // Daily Summary Service (daily_summary_service.dart)
      'summary_no_data_available': '데이터 없음',

      // Quick Log Bar
      'activity_sleep': '수면',
      'activity_feeding': '수유',
      'activity_play': '놀이',
      'activity_diaper': '기저귀',
      'activity_health': '건강',

      // Log Play Activity Screen
      'log_play_activity': '놀이 기록',
      'select_activity': '활동 선택',
      'development_benefits': '발달 효과:',
      'activity_notes_hint': '메모 추가...',
      'save_activity': '활동 저장',

      // Play Activity Types
      'activity_tummyTime': '배밀이',
      'activity_reading': '책 읽기',
      'activity_rattlePlaying': '딸랑이',
      'activity_massage': '마사지',
      'activity_walk': '산책',
      'activity_bath': '목욕',
      'activity_music': '음악',
      'activity_singing': '노래',
      'activity_exercise': '운동',
      'activity_sensoryPlay': '감각 놀이',
      'activity_other': '기타',

      // Development Tags
      'dev_tag_motor': '운동',
      'dev_tag_cognitive': '인지',
      'dev_tag_sensory': '감각',
      'dev_tag_bonding': '애착',
      'dev_tag_language': '언어',
      'dev_tag_emotional': '정서',

      // Widgets
      'widget_next_sweet_spot': '다음 스위트 스팟',
      'widget_daily_summary': '오늘 요약',
      'widget_next_feed': '다음 수유',
      'widget_next_sleep': '다음 수면',
      'widget_in_minutes': '{minutes}분 후',
      'widget_today': '오늘',
      'widget_sleep_hours': '{hours}시간',
      'widget_feeding_count': '{count}회',
      'widget_diaper_count': '{count}회',
      'widget_description': '아기의 다음 스위트 스팟과 일일 활동을 추적하세요',
      'widget_settings': '위젯 설정',
      'widget_settings_description': '홈 화면 위젯 구성',
      'widget_preview': '위젯 미리보기',
      'widget_small_preview': '작은 위젯 (2×2)',
      'widget_medium_preview': '중간 위젯 (4×2)',
      'widget_lock_screen_preview': '잠금화면 위젯',
      'widget_update_now': '위젯 업데이트',
      'widget_updating': '위젯 업데이트 중...',
      'widget_updated_success': '위젯이 성공적으로 업데이트되었습니다!',
      'widget_add_instructions': '위젯 추가 방법',
      'widget_add_ios_step1': '1. 홈 화면을 길게 누르세요',
      'widget_add_ios_step2': '2. 왼쪽 상단의 + 버튼을 탭하세요',
      'widget_add_ios_step3': '3. "Lulu"를 검색하세요',
      'widget_add_ios_step4': '4. 원하는 위젯 크기를 선택하세요',
      'widget_add_android_step1': '1. 홈 화면을 길게 누르세요',
      'widget_add_android_step2': '2. "위젯"을 탭하세요',
      'widget_add_android_step3': '3. "Lulu"를 찾아 선택하세요',
      'widget_add_android_step4': '4. 홈 화면으로 드래그하세요',

      // Widget States - Empty
      'widget_empty_header': '🌙 아기의 골든타임을 찾아요',
      'widget_empty_body': '기상 시간을 알려주시면 아기가 가장 쉽게 잠들 시간을 예측해드릴게요',
      'widget_empty_cta': '🌅 기상 시간 기록하기',

      // Widget States - Active
      'widget_active_header': '다음 Sweet Spot',
      'widget_active_remaining': '{n}분 남음',
      'widget_hint_green': '💡 아기가 졸려할 시간이에요',
      'widget_hint_yellow': '💡 곧 잠들기 좋은 시간이에요',
      'widget_hint_red': '💡 지금 재우면 좋아요!',

      // Widget States - Urgent
      'widget_urgent_header': '💤 지금이 Sweet Spot!',
      'widget_urgent_body': '아기가 가장 편하게 잠들 수 있는 시간이에요',
      'widget_urgent_cta': '😴 수면 시작 기록',

      // Authentication
      'welcome_to_lulu': 'Lulu에 오신 것을 환영합니다',
      'tagline_peaceful_nights': '평화로운 밤과 행복한 낮을 위해',
      'email': '이메일',
      'enter_email': '이메일을 입력하세요',
      'password': '비밀번호',
      'enter_password': '비밀번호를 입력하세요',
      'forgot_password': '비밀번호를 잊으셨나요?',
      'sign_in': '로그인',
      'sign_up': '회원가입',
      'or_continue_with': '또는 다음으로 계속',
      'dont_have_account': '계정이 없으신가요?',
      'already_have_account': '이미 계정이 있으신가요?',
      'create_account': '계정 만들기',
      'signup_subtitle': 'Lulu 가족이 되어 아기 기록을 시작하세요',
      'name': '이름',
      'enter_name': '이름을 입력하세요',
      'confirm_password': '비밀번호 확인',
      'confirm_password_hint': '비밀번호를 다시 입력하세요',
      'agree_to': '동의합니다 ',
      'terms_of_service': '서비스 이용약관',
      'and': ' 및 ',
      'privacy_policy': '개인정보 처리방침',

      // Validation
      'email_required': '이메일을 입력해주세요',
      'email_invalid': '올바른 이메일 주소를 입력해주세요',
      'password_required': '비밀번호를 입력해주세요',
      'password_too_short': '비밀번호는 최소 6자 이상이어야 합니다',
      'name_required': '이름을 입력해주세요',
      'confirm_password_required': '비밀번호를 다시 입력해주세요',
      'passwords_dont_match': '비밀번호가 일치하지 않습니다',
      'weight_required': '몸무게를 입력해주세요',
      'weight_invalid': '올바른 몸무게를 입력해주세요',

      // Onboarding
      'onboarding_intro': "소중한 아기에 대해 알려주세요.\\n맞춤형 케어 추천을 제공하는 데 도움이 됩니다.",
      'feature_ai_insights': 'AI 기반 인사이트',
      'feature_sweet_spot': '스위트 스팟 예측',
      'feature_personalized': '맞춤형 케어',
      'tell_us_about_baby': '아기에 대해 알려주세요',
      'baby_name': '아기 이름',
      'enter_baby_name': '이름 입력',
      'birth_date': '생년월일',
      'gender': '성별',
      'girl': '여아',
      'boy': '남아',
      'birth_weight': '출생 체중 (kg)',
      'enter_weight': '예: 2.46',
      'back': '이전',
      'next': '다음',
      'finish': '완료',

      // Special Care
      'low_birth_weight_notice': '아기가 낮은 출생 체중으로 태어났네요. 특별한 케어 추천을 제공해드릴 수 있습니다.',
      'special_care_title': '소중한 우리 아기를 위한 특별 케어',
      'special_care_message': '낮은 출생 체중으로 태어난 아기들은 조금 더 세심한 관심과 케어가 필요합니다. 특화된 성장 모니터링과 맞춤형 수유 추천을 활성화하시겠어요?',
      'no_thanks': '괜찮아요',
      'enable_special_care': '네, 활성화할게요',

      // === Post Record Feedback - Sleep ===
      'sleep_record_complete': '수면 기록 완료! 😴',
      'sleep_today_total': '⏱️ 오늘 총 수면: {hours}시간 {minutes}분',
      'sleep_yesterday_diff_plus': '📈 어제보다 +{diff}분',
      'sleep_yesterday_diff_minus': '📉 어제보다 {diff}분',
      'sleep_this_record': '🎯 이번 기록: {minutes}분',

      // === Post Record Feedback - Feeding ===
      'feeding_record_complete': '수유 기록 완료! 🍼',
      'feeding_today_count': '🍼 오늘 수유: {count}회',
      'feeding_bottle_amount': '📊 {ml}ml ({oz}oz)',
      'feeding_breast_both': '🤱 양쪽',
      'feeding_breast_left': '🤱 왼쪽',
      'feeding_breast_right': '🤱 오른쪽',

      // === Post Record Feedback - Diaper ===
      'diaper_record_complete': '기저귀 기록 완료! 🧷',
      'diaper_today_count': '🧷 오늘 교체: {count}회',
      'diaper_wet_only': '💧 소변만',
      'diaper_dirty_only': '💩 대변만',
      'diaper_both': '💧💩 둘 다',

      // === Growth Record Screen ===
      'growth_record': '성장',
      'growth_record_title': '성장 기록',
      'growth_record_subtitle': '아기의 키, 몸무게, 머리둘레를 기록하세요',
      'growth_track_progress': '정기적으로 기록하여 성장 추이를 확인하세요',
      'growth_weight_kg': '체중 (kg)',
      'growth_height_cm': '키 (cm)',
      'growth_head_cm': '머리둘레 (cm)',
      'growth_save_record': '성장 기록 저장',
      'growth_min_one_value': '최소 하나의 측정값을 입력해주세요',
      'growth_record_complete': '성장 기록 완료! 📈',

      // === Play Activity Screen ===
      'play_select_time': '활동과 시간을 선택해주세요',
      'play_record_complete': '놀이 기록 완료! 🎮',
      'play_track_developmental': '발달 놀이 활동을 기록하세요',

      // === Health Record Screen ===
      'health_record_complete': '건강 기록 완료! 🏥',
      'health_fever_warning': '🔥 고열이 감지되었습니다! 의사와 상담하세요.',

      // === Common ===
      'great_job': '잘했어요! 👏',
      'keep_it_up': '계속 기록해요!',

      // === Multi-Baby Onboarding (Step 4) ===
      'have_another_baby': '혹시 다른 아기도 있으신가요?',
      'multi_baby_description': '쌍둥이나 형제자매를 함께 관리할 수 있어요!',
      'add_another_baby': '아기 추가하기',
      'skip_for_now': '지금은 넘어갈게요 →',
      'add_baby_later_hint': '나중에 설정에서도 추가할 수 있어요',

      // === Baby Switcher ===
      'select_baby': '아기 선택',
      'add_baby': '아기 추가',

      // === Add Baby Screen ===
      'baby_name': '아기 이름',
      'baby_name_hint': '아기 이름을 입력하세요',
      'baby_name_required': '아기 이름을 입력해주세요',
      'birth_date': '생년월일',
      'birth_weight': '출생 시 체중 (kg)',
      'gender': '성별',
      'female': '여아',
      'male': '남아',
      'is_premature': '조산아',
      'is_premature_hint': '37주 이전 출생',
      'due_date': '출산 예정일',
      'save': '저장',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  String translateWithArgs(String key, Map<String, dynamic> args) {
    String result = _localizedValues[locale.languageCode]?[key] ?? key;
    args.forEach((argKey, value) {
      result = result.replaceAll('{$argKey}', value.toString());
    });
    return result;
  }

  // Alias for translate method (used by some screens)
  String getString(String key) {
    return translate(key);
  }

  // Convenience getters
  String get appName => translate('app_name');
  String get appTagline => translate('app_tagline');

  // Navigation
  String get navHome => translate('nav_home');
  String get navSleep => translate('nav_sleep');
  String get navRecords => translate('nav_records');
  String get navInsights => translate('nav_insights');
  String get navLulu => translate('nav_lulu');
  String get navMore => translate('nav_more');
  String get navSettings => translate('settings_title');
  String get navChat => translate('chat_title');
  String get navStats => translate('analytics_title');

  // Common
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get done => translate('done');
  String get close => translate('close');
  String get ok => translate('ok');
  String get today => translate('today');
  String get sleep => translate('records_sleep');
  String get feeding => translate('feeding_title');
  String get diaper => translate('diaper_title');
  String get health => locale.languageCode == 'ko' ? '건강' : 'Health';
  String get play => locale.languageCode == 'ko' ? '놀이' : 'Play';

  // Settings
  String get exportData => translate('settings_export');
  String get importData => translate('settings_import');
  String get language => translate('settings_language');
  String get languageEnglish => 'English';
  String get languageEnglishUS => locale.languageCode == 'ko' ? '영어 (미국)' : 'English (US)';
  String get languageKorean => '한국어';
  String get languageKoreanKR => locale.languageCode == 'ko' ? '한국어' : 'Korean';
  String get units => locale.languageCode == 'ko' ? '단위' : 'Units';
  String get temperature => locale.languageCode == 'ko' ? '온도' : 'Temperature';
  String get weight => locale.languageCode == 'ko' ? '무게' : 'Weight';
  String get volume => locale.languageCode == 'ko' ? '용량' : 'Volume';
  String get unitCelsius => '℃';
  String get unitFahrenheit => '℉';
  String get unitKg => 'kg';
  String get unitLb => 'lb';
  String get unitMl => 'ml';
  String get unitOz => 'oz';
  String get notifications => locale.languageCode == 'ko' ? '알림' : 'Notifications';
  String get sweetSpotAlerts => locale.languageCode == 'ko' ? '스위트 스팟 알림' : 'Sweet Spot Alerts';
  String notifyMeMinutesBefore(int minutes) => locale.languageCode == 'ko'
    ? '최적 수면 시간 $minutes분 전에 알림'
    : 'Notify me $minutes min before optimal sleep time';
  String get appUpdatesAndTips => locale.languageCode == 'ko' ? '앱 업데이트 & 팁' : 'App Updates & Tips';
  String get receiveHelpfulTips => locale.languageCode == 'ko'
    ? '유용한 육아 팁과 기능 업데이트 받기'
    : 'Receive helpful parenting tips and feature updates';
  String get dataManagement => locale.languageCode == 'ko' ? '데이터 관리' : 'Data Management';
  String get activityHistory => locale.languageCode == 'ko' ? '활동 기록' : 'Activity History';
  String get viewAllRecordedActivities => locale.languageCode == 'ko'
    ? '모든 기록된 활동 보기'
    : 'View all recorded activities';
  String get exportToCSV => locale.languageCode == 'ko'
    ? 'CSV 파일로 데이터 내보내기'
    : 'Export data to CSV file';
  String get importFromCSV => locale.languageCode == 'ko'
    ? 'CSV 파일에서 데이터 가져오기'
    : 'Import data from CSV file';
  String get sweetSpotDemo => locale.languageCode == 'ko' ? '스위트 스팟 데모' : 'Sweet Spot Demo';
  String get tryAISleepPredictionDemo => locale.languageCode == 'ko'
    ? 'AI 수면 예측 데모 사용해보기'
    : 'Try the AI sleep prediction demo';
  String get insights => locale.languageCode == 'ko' ? '인사이트' : 'Insights';
  String get aiCoachingTitle => locale.languageCode == 'ko' ? 'AI 코칭 인사이트' : 'AI Coaching Insight';
  String get aiCoachingAnalyzing => locale.languageCode == 'ko' ? 'AI가 분석 중입니다...' : 'AI is analyzing...';
  String get aiCoachingEmpathy => locale.languageCode == 'ko' ? '공감 메시지' : 'Empathy';
  String get aiCoachingInsight => locale.languageCode == 'ko' ? '데이터 통찰' : 'Data Insight';
  String get aiCoachingAction => locale.languageCode == 'ko' ? '행동 지침' : 'Action Plan';
  String get aiCoachingExpert => locale.languageCode == 'ko' ? '전문가 조언' : 'Expert Advice';
  String get aiCoachingFeedbackQuestion => locale.languageCode == 'ko' ? '도움이 되었나요?' : 'Was this helpful?';
  String get aiCoachingFeedbackPositive => locale.languageCode == 'ko' ? '도움됨' : 'Helpful';
  String get aiCoachingFeedbackNegative => locale.languageCode == 'ko' ? '별로' : 'Not helpful';
  String get aiCoachingFeedbackThanks => locale.languageCode == 'ko'
    ? '피드백 감사합니다! 더 나은 조언을 위해 활용하겠습니다.'
    : 'Thank you for your feedback! We\'ll use it to improve our advice.';
  String get tapChartForAnalysis => locale.languageCode == 'ko'
    ? '차트를 탭하면 AI가 그 시간의 패턴을 분석해줍니다'
    : 'Tap on the chart to have AI analyze that time period';
  String get criticalAlertTitle => locale.languageCode == 'ko' ? '전문가 상담 권고' : 'Expert Consultation Recommended';
  String get criticalAlertMessage => locale.languageCode == 'ko'
    ? '아기의 상태가 면밀한 관찰이 필요해 보입니다. 소아과 방문을 권장하며, 의사에게 보여줄 오늘의 리포트를 생성할 수 있습니다.'
    : 'Your baby\'s condition requires careful observation. We recommend consulting with a pediatrician and can generate a report to share with your doctor.';
  String get generatePDFReport => locale.languageCode == 'ko' ? 'PDF 리포트 생성' : 'Generate PDF Report';
  String get longestSleepStretch => locale.languageCode == 'ko' ? '가장 긴 수면 시간' : 'Longest Sleep Stretch';
  String get hours => locale.languageCode == 'ko' ? '시간' : 'hours';
  String get markAllRead => locale.languageCode == 'ko' ? '모두 읽음으로 표시' : 'Mark all read';
  String get allNotificationsMarkedAsRead => locale.languageCode == 'ko'
    ? '모든 알림을 읽음으로 표시했습니다'
    : 'All notifications marked as read';
  String get noNotificationsYet => locale.languageCode == 'ko' ? '알림이 없습니다' : 'No notifications yet';
  String get youllSeeSweetSpotAlerts => locale.languageCode == 'ko'
    ? '스위트 스팟 알림과 업데이트가 여기에 표시됩니다'
    : 'You\'ll see Sweet Spot alerts and updates here';
  String get minutesAgo => locale.languageCode == 'ko' ? '분 전' : 'minutes ago';
  String get hoursAgo => locale.languageCode == 'ko' ? '시간 전' : 'hours ago';
  String get daysAgo => locale.languageCode == 'ko' ? '일 전' : 'days ago';

  // Home Screen
  String get goodMorning => locale.languageCode == 'ko' ? '좋은 아침이에요' : 'Good Morning';
  String get goodAfternoon => locale.languageCode == 'ko' ? '좋은 오후에요' : 'Good Afternoon';
  String get goodEvening => locale.languageCode == 'ko' ? '좋은 저녁이에요' : 'Good Evening';
  String get quickActions => locale.languageCode == 'ko' ? '빠른 작업' : 'Quick Actions';
  String get logSleep => locale.languageCode == 'ko' ? '수면 기록' : 'Log Sleep';
  String get logFeeding => locale.languageCode == 'ko' ? '수유 기록' : 'Log Feeding';
  String get logDiaper => locale.languageCode == 'ko' ? '기저귀 기록' : 'Log Diaper';
  String get logHealth => locale.languageCode == 'ko' ? '건강 기록' : 'Log Health';

  // Chat Screen
  String get aiSleepConsultant => locale.languageCode == 'ko' ? 'AI 수면 컨설턴트' : 'AI Sleep Consultant';
  String get newConversation => locale.languageCode == 'ko' ? '새 대화' : 'New conversation';
  String get startConversation => locale.languageCode == 'ko' ? 'Lulu와 대화를 시작하세요' : 'Start a conversation with Lulu';
  String get chatError => locale.languageCode == 'ko' ? '죄송합니다. 문제가 발생했습니다. 다시 시도해주세요.' : 'Sorry, something went wrong. Please try again.';

  // Quick Questions
  String get quickQuestionBabyWaking => locale.languageCode == 'ko' ? '밤에 자주 깨요' : 'Baby keeps waking at night';
  String get quickQuestionWontSleep => locale.languageCode == 'ko' ? '잠을 안 자요' : 'Won\'t fall asleep';
  String get quickQuestionShortNaps => locale.languageCode == 'ko' ? '짧은 낮잠' : 'Short naps';
  String get quickQuestionEarlyWaking => locale.languageCode == 'ko' ? '새벽에 일찍 깨요' : 'Early morning waking';
  String get quickQuestionSleepEnvironment => locale.languageCode == 'ko' ? '수면 환경 확인' : 'Sleep environment check';
  String get quickQuestionAnalyzePatterns => locale.languageCode == 'ko' ? '수면 패턴 분석' : 'Analyze sleep patterns';

  // Activity Types & Labels
  String get all => locale.languageCode == 'ko' ? '전체' : 'All';
  String get refresh => locale.languageCode == 'ko' ? '새로고침' : 'Refresh';
  String get bottle => locale.languageCode == 'ko' ? '분유' : 'Bottle';
  String get breast => locale.languageCode == 'ko' ? '모유' : 'Breast';
  String get amount => locale.languageCode == 'ko' ? '양' : 'Amount';
  String get left => locale.languageCode == 'ko' ? '왼쪽' : 'Left';
  String get right => locale.languageCode == 'ko' ? '오른쪽' : 'Right';
  String get both => locale.languageCode == 'ko' ? '양쪽' : 'Both';
  String get crib => locale.languageCode == 'ko' ? '아기침대' : 'Crib';
  String get bed => locale.languageCode == 'ko' ? '침대' : 'Bed';
  String get stroller => locale.languageCode == 'ko' ? '유모차' : 'Stroller';
  String get good => locale.languageCode == 'ko' ? '좋음' : 'Good';
  String get fair => locale.languageCode == 'ko' ? '보통' : 'Fair';
  String get poor => locale.languageCode == 'ko' ? '나쁨' : 'Poor';
  String get wet => locale.languageCode == 'ko' ? '소변' : 'Wet';
  String get dirty => locale.languageCode == 'ko' ? '대변' : 'Dirty';
  String get urineOnly => locale.languageCode == 'ko' ? '소변만' : 'Urine only';
  String get bowelMovement => locale.languageCode == 'ko' ? '대변' : 'Bowel movement';
  String get eat => locale.languageCode == 'ko' ? '먹기' : 'Eat';
  String get settings => locale.languageCode == 'ko' ? '설정' : 'Settings';

  // Health Screen - Additional keys
  String get highFever => locale.languageCode == 'ko' ? '⚠️ 고열이 감지되었습니다!\n필요시 해열제를 고려하세요.' : '⚠️ High Fever Detected!\nConsider medication if needed.';
  String get feverAdviceWithMonths => locale.languageCode == 'ko' ? '발열 조언' : 'Fever Advice';
  String get additionalObservationsHint => locale.languageCode == 'ko' ? '추가 관찰 사항...' : 'Any additional observations...';
  String get saveTemperature => locale.languageCode == 'ko' ? '체온 저장' : 'Save Temperature';
  String get saving => locale.languageCode == 'ko' ? '저장 중...' : 'Saving...';
  String get tips => locale.languageCode == 'ko' ? '팁:' : 'Tips:';
  String get actionsToTakeNow => locale.languageCode == 'ko' ? '지금 취해야 할 조치:' : 'Actions to take NOW:';
  String get callPediatrician => locale.languageCode == 'ko' ? '소아과에 전화' : 'Call Pediatrician';
  String get goToER => locale.languageCode == 'ko' ? '응급실로 가기' : 'Go to ER';
  String get enterValidTemperature => locale.languageCode == 'ko' ? '유효한 체온을 입력하세요' : 'Please enter a valid temperature';
  String get temperatureRecorded => locale.languageCode == 'ko' ? '체온이 기록되었습니다!' : 'Temperature recorded!';
  String errorWithMessage(String error) => locale.languageCode == 'ko' ? '오류: $error' : 'Error: $error';

  // Medication keys
  String get feverReducer => locale.languageCode == 'ko' ? '해열제' : 'Fever Reducer';
  String get antibiotic => locale.languageCode == 'ko' ? '항생제' : 'Antibiotic';
  String get medicationOther => locale.languageCode == 'ko' ? '기타' : 'Other';
  String get medicationName => locale.languageCode == 'ko' ? '약물 이름' : 'Medication Name';
  String get dosage => locale.languageCode == 'ko' ? '투여량' : 'Dosage';
  String get safetyTimer => locale.languageCode == 'ko' ? '안전 타이머' : 'Safety Timer';
  String get nextDoseAvailableIn => locale.languageCode == 'ko' ? '다음 투여 가능 시간:' : 'Next dose available in:';
  String get fourHours => locale.languageCode == 'ko' ? '4시간' : '4 hours';
  String get sixHours => locale.languageCode == 'ko' ? '6시간' : '6 hours';
  String get eightHours => locale.languageCode == 'ko' ? '8시간' : '8 hours';
  String get timeGiven => locale.languageCode == 'ko' ? '투여 시간' : 'Time Given';
  String get reasonForMedicationHint => locale.languageCode == 'ko' ? '투약 사유...' : 'Reason for medication...';
  String get saveMedication => locale.languageCode == 'ko' ? '투약 저장' : 'Save Medication';
  String get ibuprofenWarning => locale.languageCode == 'ko' ? '⚠️ 이부프로펜은 6개월 미만 영아에게 권장되지 않습니다. 소아과 의사와 상담하세요.' : '⚠️ Ibuprofen is NOT recommended for infants under 6 months. Please consult your pediatrician.';
  String get dosageCalculator => locale.languageCode == 'ko' ? '💊 투여량 계산기' : '💊 Dosage Calculator';
  String medicationLabel(String name) => locale.languageCode == 'ko' ? '약물: $name' : 'Medication: $name';
  String babyWeightLabel(String weight) => locale.languageCode == 'ko' ? '아기 체중: $weight kg' : 'Baby\'s Weight: $weight kg';
  String get recommendedDosage => locale.languageCode == 'ko' ? '권장 투여량:' : 'Recommended Dosage:';
  String frequencyEveryHours(int hours) => locale.languageCode == 'ko' ? '빈도: $hours시간마다' : 'Frequency: Every $hours hours';
  String maxDailyMg(String mg) => locale.languageCode == 'ko' ? '일일 최대: $mg mg' : 'Max Daily: $mg mg';
  String concentrationLabel(String concentration) => locale.languageCode == 'ko' ? '농도: $concentration' : 'Concentration: $concentration';
  String get safetyWarnings => locale.languageCode == 'ko' ? '안전 경고:' : 'Safety Warnings:';
  String get guidelineDisclaimer => locale.languageCode == 'ko' ? 'ℹ️ 이것은 가이드일 뿐입니다. 항상 소아과 의사나 약사와 상담하세요.' : 'ℹ️ This is a guideline only. Always consult your pediatrician or pharmacist.';
  String get selectMedication => locale.languageCode == 'ko' ? '약물을 선택하세요' : 'Please select a medication';
  String get medicationRecorded => locale.languageCode == 'ko' ? '투약이 기록되었습니다!' : 'Medication recorded!';
  String medicationRecordedNextDose(int hours) => locale.languageCode == 'ko' ? '투약이 기록되었습니다! 다음 투여는 $hours시간 후' : 'Medication recorded! Next dose in $hours hours';
  String get emergencyWarning => locale.languageCode == 'ko' ? '🚨 긴급 의료 조치 필요' : '🚨 URGENT MEDICAL ATTENTION NEEDED';
  String emergencyFeverMessage(String temp, String unit) => locale.languageCode == 'ko' ? '아기가 3개월 미만이며 체온이 $temp°$unit입니다.' : 'Your baby is under 3 months old with a fever of $temp°$unit.';
  String get immediateEvaluation => locale.languageCode == 'ko' ? '⚠️ 소아과 의사의 즉각적인 진찰이 필요합니다.' : '⚠️ This requires IMMEDIATE evaluation by a pediatrician.';
  String get monthsOld => locale.languageCode == 'ko' ? '개월' : ' months old';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ko'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
