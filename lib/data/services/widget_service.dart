import 'package:home_widget/home_widget.dart';
import '../models/activity_model.dart';
import '../models/baby_model.dart';
import '../models/widget_data_model.dart';
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

  /// Update all widget variants with latest data
  Future<void> updateAllWidgets() async {
    try {
      print('🔄 [WidgetService] Starting widget update...');

      // ✅ NEW: Get widget state using new State model
      final widgetState = await getWidgetState();
      await _saveWidgetState(widgetState);
      print('✅ [WidgetService] Widget state saved: ${widgetState.state.name}');

      // ✅ 동적으로 아기 데이터 가져오기 (기존 로직 유지)
      final baby = await _storage.getBaby();

      if (baby == null) {
        print('❌ [WidgetService] No baby data found - using empty state');
        // Trigger widget update even with empty state
        await HomeWidget.updateWidget(
          iOSName: 'LuluWidgetProvider',
          androidName: 'LuluWidgetProvider',
        );
        return;
      }
      print('✅ [WidgetService] Baby data loaded: ${baby.name}');

      final widgetData = await _getWidgetData(baby: baby);
      print('✅ [WidgetService] Widget data calculated');

      // Update small widget (2x2)
      await _updateSmallWidget(widgetData);
      print('✅ [WidgetService] Small widget data saved');

      // Update medium widget (4x2)
      await _updateMediumWidget(widgetData);
      print('✅ [WidgetService] Medium widget data saved');

      // Update lock screen widget (iOS)
      await _updateLockScreenWidget(widgetData);
      print('✅ [WidgetService] Lock screen widget data saved');

      // Trigger widget update
      final updateResult = await HomeWidget.updateWidget(
        iOSName: 'LuluWidgetProvider',
        androidName: 'LuluWidgetProvider',
      );
      print('✅ [WidgetService] Widget update triggered. Result: $updateResult');

      print('🎉 [WidgetService] Widget update completed successfully!');
    } catch (e, stackTrace) {
      print('❌ [WidgetService] Widget update error: $e');
      print('📍 [WidgetService] Stack trace: $stackTrace');
    }
  }

  /// Get comprehensive widget data
  Future<Map<String, dynamic>> _getWidgetData({required BabyModel baby}) async {
    final now = DateTime.now();

    // ✅ Calculate baby age from actual data
    final birthDate = DateTime.parse(baby.birthDate);
    final ageInDays = now.difference(birthDate).inDays;
    final ageInMonths = (ageInDays / 30).floor();

    // Get last wake time
    DateTime? lastWakeTime = await _storage.getLastWakeUpTime();

    // 🔧 FIX: 끝난 수면이 없으면, 가장 최근 수면 활동을 확인
    if (lastWakeTime == null) {
      final allSleepActivities = await _storage.getActivitiesByType(ActivityType.sleep);
      if (allSleepActivities.isNotEmpty) {
        // 최근 수면 활동 정렬
        allSleepActivities.sort((a, b) =>
          DateTime.parse(b.timestamp).compareTo(DateTime.parse(a.timestamp))
        );

        final latestSleep = allSleepActivities.first;

        // 진행 중인 수면이면 시작 시간 사용, 끝난 수면이면 endTime 사용
        if (latestSleep.endTime != null) {
          lastWakeTime = DateTime.parse(latestSleep.endTime!);
        } else {
          // 진행 중인 수면: 수면 시작 시간을 마지막 "활동" 시간으로 간주
          // Sweet Spot은 계산하지 않고 null로 유지
          lastWakeTime = null;
        }
      }
    }

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
        ageInDays: ageInDays,
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
        ageInDays: ageInDays,
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
      // Calculate progress: how much of the wake window has passed
      final minutesAwake = sleepPrediction.standardWakeWindow - minutesUntil;
      final progress = (minutesAwake / sleepPrediction.standardWakeWindow).clamp(0.0, 1.0);
      final isUrgent = sleepPrediction.isUrgent;

      // Keys must match Swift widget expectations
      await HomeWidget.saveWidgetData('widget_type', 'small');
      await HomeWidget.saveWidgetData('widget_next_sweet_spot_time',
        '${sleepPrediction.nextSweetSpot.hour}:${sleepPrediction.nextSweetSpot.minute.toString().padLeft(2, '0')}');
      await HomeWidget.saveWidgetData('widget_minutes_until_sweet_spot', minutesUntil);
      await HomeWidget.saveWidgetData('widget_sweet_spot_progress', progress);
      await HomeWidget.saveWidgetData('widget_is_urgent', isUrgent);
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

    // Today's summary - Keys must match Swift widget expectations
    final totalSleepHours = (data['totalSleepMinutes'] as int) / 60.0;
    await HomeWidget.saveWidgetData('widget_total_sleep_hours', totalSleepHours);
    await HomeWidget.saveWidgetData('widget_total_feeding_count', data['feedingCount']);
    await HomeWidget.saveWidgetData('widget_total_diaper_count', data['diaperCount']);

    // Legacy keys for compatibility
    await HomeWidget.saveWidgetData('total_sleep_hours', totalSleepHours.toStringAsFixed(1));
    await HomeWidget.saveWidgetData('total_feeding_ml', (data['totalFeedingMl'] as double).toInt());
    await HomeWidget.saveWidgetData('diaper_count', data['diaperCount']);
    await HomeWidget.saveWidgetData('feeding_count', data['feedingCount']);

    // Next action (prioritize most urgent)
    String nextActionType = 'sleep';
    String nextActionTime = '00:00';
    int nextActionMinutes = 999;
    bool isUrgent = false;

    if (sleepPrediction != null && sleepPrediction.isUrgent) {
      nextActionType = 'sleep';
      nextActionMinutes = sleepPrediction.minutesUntilSweetSpot.abs();
      final nextTime = sleepPrediction.nextSweetSpot;
      nextActionTime = '${nextTime.hour}:${nextTime.minute.toString().padLeft(2, '0')}';
      isUrgent = true;
    } else if (feedingPrediction != null && feedingPrediction.isUrgent) {
      nextActionType = 'feeding';
      nextActionMinutes = feedingPrediction.minutesUntilFeeding.abs();
      final nextTime = feedingPrediction.nextFeedingTime;
      nextActionTime = '${nextTime.hour}:${nextTime.minute.toString().padLeft(2, '0')}';
      isUrgent = true;
    } else if (sleepPrediction != null) {
      nextActionType = 'sleep';
      nextActionMinutes = sleepPrediction.minutesUntilSweetSpot;
      final nextTime = sleepPrediction.nextSweetSpot;
      nextActionTime = '${nextTime.hour}:${nextTime.minute.toString().padLeft(2, '0')}';
    } else if (feedingPrediction != null) {
      nextActionType = 'feeding';
      nextActionMinutes = feedingPrediction.minutesUntilFeeding;
      final nextTime = feedingPrediction.nextFeedingTime;
      nextActionTime = '${nextTime.hour}:${nextTime.minute.toString().padLeft(2, '0')}';
    }

    // Keys must match Swift widget expectations
    await HomeWidget.saveWidgetData('widget_next_action_type', nextActionType);
    await HomeWidget.saveWidgetData('widget_next_action_time', nextActionTime);
    await HomeWidget.saveWidgetData('widget_next_action_minutes', nextActionMinutes);
    await HomeWidget.saveWidgetData('widget_is_urgent', isUrgent);
    await HomeWidget.saveWidgetData('has_medium_data', data['hasData']);
  }

  /// Update lock screen widget (iOS) - Minimal text-based
  Future<void> _updateLockScreenWidget(Map<String, dynamic> data) async {
    final feedingPrediction = data['feedingPrediction'] as FeedingPrediction?;

    if (feedingPrediction != null) {
      final nextFeedTime = feedingPrediction.nextFeedingTime;
      final formattedTime = '${nextFeedTime.hour.toString().padLeft(2, '0')}:${nextFeedTime.minute.toString().padLeft(2, '0')}';

      await HomeWidget.saveWidgetData('widget_type', 'lockscreen');
      // Key must match Swift widget expectation
      await HomeWidget.saveWidgetData('widget_next_feeding_time', formattedTime);
      // Legacy keys for compatibility
      await HomeWidget.saveWidgetData('next_feed_time', formattedTime);
      await HomeWidget.saveWidgetData('feed_minutes_until', feedingPrediction.minutesUntilFeeding);
      await HomeWidget.saveWidgetData('has_lockscreen_data', true);
    } else {
      await HomeWidget.saveWidgetData('has_lockscreen_data', false);
    }
  }

  /// Schedule smart background updates
  /// Updates more frequently near sleep/feeding times
  Future<void> scheduleSmartUpdates() async {
    // ✅ 동적으로 아기 데이터 가져오기
    final baby = await _storage.getBaby();

    if (baby == null) {
      print('No baby data found - skipping smart update scheduling');
      return;
    }

    final widgetData = await _getWidgetData(baby: baby);
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

  /// Get WidgetData with proper state classification
  Future<WidgetData> getWidgetState() async {
    final baby = await _storage.getBaby();
    if (baby == null) {
      return WidgetData.empty();
    }

    final now = DateTime.now();
    final birthDate = DateTime.parse(baby.birthDate);
    final ageInDays = now.difference(birthDate).inDays;

    // Get last wake time
    DateTime? lastWakeTime = await _storage.getLastWakeUpTime();

    if (lastWakeTime == null) {
      final allSleepActivities = await _storage.getActivitiesByType(ActivityType.sleep);
      if (allSleepActivities.isNotEmpty) {
        allSleepActivities.sort((a, b) =>
          DateTime.parse(b.timestamp).compareTo(DateTime.parse(a.timestamp))
        );

        final latestSleep = allSleepActivities.first;

        if (latestSleep.endTime != null) {
          lastWakeTime = DateTime.parse(latestSleep.endTime!);
        }
      }
    }

    // If still no wake time, return empty state
    if (lastWakeTime == null) {
      return WidgetData.empty();
    }

    // Calculate Sweet Spot prediction
    final sleepPrediction = WakeWindowCalculator.calculateNextSleepTime(
      lastWakeTime: lastWakeTime,
      ageInDays: ageInDays,
    );

    if (sleepPrediction == null) {
      return WidgetData.empty();
    }

    final minutesRemaining = sleepPrediction.minutesUntilSweetSpot;
    final urgency = WidgetData.calculateUrgency(
      sweetSpotStart: sleepPrediction.nextSweetSpot,
      now: now,
    );

    // Determine state
    if (minutesRemaining <= 0 || (urgency == UrgencyLevel.red && minutesRemaining <= 5)) {
      // Urgent State: Sweet Spot 진입 또는 지남
      return WidgetData.urgent(
        sweetSpotTime: sleepPrediction.nextSweetSpot,
        confidence: sleepPrediction.confidence,
      );
    } else {
      // Active State: Sweet Spot 계산됨
      return WidgetData.active(
        sweetSpotTime: sleepPrediction.nextSweetSpot,
        minutesRemaining: minutesRemaining,
        urgency: urgency,
        confidence: sleepPrediction.confidence,
      );
    }
  }

  /// Save widget state to native storage
  Future<void> _saveWidgetState(WidgetData widgetData) async {
    // Save state
    await HomeWidget.saveWidgetData('widget_state', widgetData.state.name);

    // Save common data
    if (widgetData.nextSweetSpotTime != null) {
      final time = widgetData.nextSweetSpotTime!;
      final formattedTime = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
      await HomeWidget.saveWidgetData('widget_next_sweet_spot_time', formattedTime);

      // Save hour and minute separately for easier native access
      await HomeWidget.saveWidgetData('widget_sweet_spot_hour', time.hour);
      await HomeWidget.saveWidgetData('widget_sweet_spot_minute', time.minute);
    }

    if (widgetData.minutesRemaining != null) {
      await HomeWidget.saveWidgetData('widget_minutes_remaining', widgetData.minutesRemaining);
    }

    if (widgetData.urgencyLevel != null) {
      await HomeWidget.saveWidgetData('widget_urgency_level', widgetData.urgencyLevel!.name);
    }

    if (widgetData.confidenceScore != null) {
      await HomeWidget.saveWidgetData('widget_confidence_score', (widgetData.confidenceScore! * 100).toInt());
    }

    // Save hint message key
    if (widgetData.state == WidgetState.active && widgetData.urgencyLevel != null) {
      await HomeWidget.saveWidgetData('widget_hint_key', widgetData.getHintMessageKey());
    }

    // Save last update time
    await HomeWidget.saveWidgetData('widget_last_update', DateTime.now().toIso8601String());
  }
}
