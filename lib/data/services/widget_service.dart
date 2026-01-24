import 'package:home_widget/home_widget.dart';
import 'dart:convert';
import '../models/activity_model.dart';
import 'local_storage_service.dart';
import '../../core/utils/wake_window_calculator.dart';
import '../../core/utils/feeding_interval_calculator.dart';

/// 🎨 Widget Service - Apple WidgetKit inspired
/// Manages home screen widget data with intelligent updates
class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  final LocalStorageService _storage = LocalStorageService();

  // Baby data (72 days old, born Nov 11, 2025, 2.46kg)
  static const int babyAgeInDays = 72;
  static final DateTime babyBirthDate = DateTime(2025, 11, 11);
  static const double birthWeightKg = 2.46;

  /// Update all widget variants with latest data
  Future<void> updateAllWidgets() async {
    try {
      final widgetData = await _getWidgetData();

      // Update small widget (2x2)
      await _updateSmallWidget(widgetData);

      // Update medium widget (4x2)
      await _updateMediumWidget(widgetData);

      // Update lock screen widget (iOS)
      await _updateLockScreenWidget(widgetData);

      // Trigger widget update
      await HomeWidget.updateWidget(
        iOSName: 'LuluWidgetProvider',
        androidName: 'LuluWidgetProvider',
      );
    } catch (e) {
      print('Widget update error: $e');
    }
  }

  /// Get comprehensive widget data
  Future<Map<String, dynamic>> _getWidgetData() async {
    final now = DateTime.now();

    // Get last wake time
    final lastWakeTime = await _storage.getLastWakeUpTime();

    // Get last feeding
    final feedingActivities = await _storage.getActivitiesByType(ActivityType.feeding);
    feedingActivities.sort((a, b) =>
      DateTime.parse(b.timestamp).compareTo(DateTime.parse(a.timestamp)));

    // Get today's activities
    final todayActivities = await _storage.getActivitiesByDate(now);
    final sleepActivities = todayActivities.where((a) => a.type == ActivityType.sleep).toList();
    final todayFeedings = todayActivities.where((a) => a.type == ActivityType.feeding).toList();
    final todayDiapers = todayActivities.where((a) => a.type == ActivityType.diaper).toList();

    // Calculate sleep prediction
    WakeWindowPrediction? sleepPrediction;
    if (lastWakeTime != null) {
      sleepPrediction = WakeWindowCalculator.calculateNextSleepTime(
        lastWakeTime: lastWakeTime,
        ageInDays: babyAgeInDays,
      );
    }

    // Calculate feeding prediction
    FeedingPrediction? feedingPrediction;
    if (feedingActivities.isNotEmpty) {
      final lastFeeding = feedingActivities.first;
      final lastFeedTime = DateTime.parse(lastFeeding.timestamp);
      final amountMl = lastFeeding.amountMl ?? 135.0;

      feedingPrediction = FeedingIntervalCalculator.calculateNextFeedingTime(
        lastFeedingTime: lastFeedTime,
        lastFeedingAmountMl: amountMl,
        ageInDays: babyAgeInDays,
      );
    }

    // Calculate total sleep today
    int totalSleepMinutes = 0;
    for (var sleep in sleepActivities) {
      if (sleep.durationMinutes != null) {
        totalSleepMinutes += sleep.durationMinutes!;
      }
    }

    // Calculate total feeding amount
    double totalFeedingMl = 0;
    for (var feeding in todayFeedings) {
      if (feeding.amountMl != null) {
        totalFeedingMl += feeding.amountMl!;
      }
    }

    return {
      'sleepPrediction': sleepPrediction,
      'feedingPrediction': feedingPrediction,
      'totalSleepMinutes': totalSleepMinutes,
      'totalFeedingMl': totalFeedingMl,
      'diaperCount': todayDiapers.length,
      'feedingCount': todayFeedings.length,
      'hasData': lastWakeTime != null || feedingActivities.isNotEmpty,
      'lastUpdateTime': now.toIso8601String(),
    };
  }

  /// Update small widget (2x2) - Next Sweet Spot focus
  Future<void> _updateSmallWidget(Map<String, dynamic> data) async {
    final sleepPrediction = data['sleepPrediction'] as WakeWindowPrediction?;

    if (sleepPrediction != null) {
      final minutesUntil = sleepPrediction.minutesUntilSweetSpot;
      final urgency = sleepPrediction.urgencyLevel.name;
      final confidence = (sleepPrediction.confidence * 100).toInt();

      await HomeWidget.saveWidgetData('widget_type', 'small');
      await HomeWidget.saveWidgetData('next_sleep_minutes', minutesUntil);
      await HomeWidget.saveWidgetData('next_sleep_time',
        '${sleepPrediction.nextSweetSpot.hour}:${sleepPrediction.nextSweetSpot.minute.toString().padLeft(2, '0')}');
      await HomeWidget.saveWidgetData('sleep_urgency', urgency);
      await HomeWidget.saveWidgetData('sleep_confidence', confidence);
      await HomeWidget.saveWidgetData('has_sleep_data', true);
    } else {
      await HomeWidget.saveWidgetData('has_sleep_data', false);
    }
  }

  /// Update medium widget (4x2) - Today's summary + next action
  Future<void> _updateMediumWidget(Map<String, dynamic> data) async {
    final sleepPrediction = data['sleepPrediction'] as WakeWindowPrediction?;
    final feedingPrediction = data['feedingPrediction'] as FeedingPrediction?;

    await HomeWidget.saveWidgetData('widget_type', 'medium');

    // Today's summary
    await HomeWidget.saveWidgetData('total_sleep_hours',
      ((data['totalSleepMinutes'] as int) / 60.0).toStringAsFixed(1));
    await HomeWidget.saveWidgetData('total_feeding_ml',
      (data['totalFeedingMl'] as double).toInt());
    await HomeWidget.saveWidgetData('diaper_count', data['diaperCount']);
    await HomeWidget.saveWidgetData('feeding_count', data['feedingCount']);

    // Next action (prioritize most urgent)
    String nextAction = 'No actions';
    int nextActionMinutes = 999;

    if (sleepPrediction != null && sleepPrediction.isUrgent) {
      nextAction = 'Sleep';
      nextActionMinutes = sleepPrediction.minutesUntilSweetSpot.abs();
    } else if (feedingPrediction != null && feedingPrediction.isUrgent) {
      nextAction = 'Feeding';
      nextActionMinutes = feedingPrediction.minutesUntilFeeding.abs();
    } else if (sleepPrediction != null) {
      nextAction = 'Sleep';
      nextActionMinutes = sleepPrediction.minutesUntilSweetSpot;
    } else if (feedingPrediction != null) {
      nextAction = 'Feeding';
      nextActionMinutes = feedingPrediction.minutesUntilFeeding;
    }

    await HomeWidget.saveWidgetData('next_action', nextAction);
    await HomeWidget.saveWidgetData('next_action_minutes', nextActionMinutes);
    await HomeWidget.saveWidgetData('has_medium_data', data['hasData']);
  }

  /// Update lock screen widget (iOS) - Minimal text-based
  Future<void> _updateLockScreenWidget(Map<String, dynamic> data) async {
    final feedingPrediction = data['feedingPrediction'] as FeedingPrediction?;

    if (feedingPrediction != null) {
      final nextFeedTime = feedingPrediction.nextFeedingTime;
      await HomeWidget.saveWidgetData('widget_type', 'lockscreen');
      await HomeWidget.saveWidgetData('next_feed_time',
        '${nextFeedTime.hour.toString().padLeft(2, '0')}:${nextFeedTime.minute.toString().padLeft(2, '0')}');
      await HomeWidget.saveWidgetData('feed_minutes_until',
        feedingPrediction.minutesUntilFeeding);
      await HomeWidget.saveWidgetData('has_lockscreen_data', true);
    } else {
      await HomeWidget.saveWidgetData('has_lockscreen_data', false);
    }
  }

  /// Schedule smart background updates
  /// Updates more frequently near sleep/feeding times
  Future<void> scheduleSmartUpdates() async {
    final widgetData = await _getWidgetData();
    final sleepPrediction = widgetData['sleepPrediction'] as WakeWindowPrediction?;
    final feedingPrediction = widgetData['feedingPrediction'] as FeedingPrediction?;

    // Determine update interval based on urgency
    Duration updateInterval = const Duration(minutes: 30); // Default

    if (sleepPrediction != null || feedingPrediction != null) {
      final sleepMinutes = sleepPrediction?.minutesUntilSweetSpot.abs() ?? 999;
      final feedMinutes = feedingPrediction?.minutesUntilFeeding.abs() ?? 999;
      final nearestMinutes = sleepMinutes < feedMinutes ? sleepMinutes : feedMinutes;

      if (nearestMinutes < 15) {
        updateInterval = const Duration(minutes: 5); // Very urgent
      } else if (nearestMinutes < 30) {
        updateInterval = const Duration(minutes: 10); // Urgent
      } else if (nearestMinutes < 60) {
        updateInterval = const Duration(minutes: 15); // Approaching
      }
    }

    // Note: Actual background scheduling needs platform-specific implementation
    // This is a placeholder for the logic
    print('Smart update interval: ${updateInterval.inMinutes} minutes');
  }

  /// Handle widget tap actions (deep linking)
  Future<void> handleWidgetAction(String action) async {
    // This will be called from main.dart when widget is tapped
    // Actions: 'sleep', 'feeding', 'diaper', 'open_app'
    print('Widget action received: $action');
  }

  /// Get next update time recommendation
  DateTime getNextUpdateTime() {
    return DateTime.now().add(const Duration(minutes: 15));
  }
}
