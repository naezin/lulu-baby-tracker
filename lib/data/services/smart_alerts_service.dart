import 'package:flutter/material.dart';
import '../models/activity_model.dart';
import '../../core/utils/wake_window_calculator.dart';
import '../../core/utils/feeding_interval_calculator.dart';
import '../../presentation/widgets/home/smart_alerts_card.dart';
import 'local_storage_service.dart';

/// 🤖 Smart Alerts Service
/// AI 기반 알림 생성 서비스
/// - 수면 윈도우 기반 알림
/// - 수유 타이밍 알림
/// - 기저귀 패턴 알림
class SmartAlertsService {
  final LocalStorageService _storage = LocalStorageService();

  /// 현재 활성 알림 목록 가져오기
  Future<List<SmartAlert>> getActiveAlerts({
    required int babyAgeInDays,
  }) async {
    final alerts = <SmartAlert>[];

    try {
      // 기존 실시간 알림
      // 1. 수면 윈도우 체크
      final sleepAlert = await _checkSleepWindow(babyAgeInDays);
      if (sleepAlert != null) alerts.add(sleepAlert);

      // 2. 수유 타이밍 체크
      final feedingAlert = await _checkFeedingTime(babyAgeInDays);
      if (feedingAlert != null) alerts.add(feedingAlert);

      // 3. 기저귀 패턴 체크
      final diaperAlert = await _checkDiaperPattern();
      if (diaperAlert != null) alerts.add(diaperAlert);

      // 새로운 인사이트 기반 알림
      final insightAlerts = await _generateInsightAlerts(babyAgeInDays);
      alerts.addAll(insightAlerts);

      // 우선순위 정렬 (urgent > warning > info)
      alerts.sort((a, b) => _getPriorityValue(a.priority).compareTo(_getPriorityValue(b.priority)));

      return alerts.take(5).toList(); // 최대 5개
    } catch (e) {
      // 에러 발생 시 빈 목록 반환
      return [];
    }
  }

  /// 인사이트 기반 알림 생성
  Future<List<SmartAlert>> _generateInsightAlerts(int babyAgeInDays) async {
    final alerts = <SmartAlert>[];

    try {
      // 오늘, 어제, 이번 주 데이터 가져오기
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final weekAgo = today.subtract(const Duration(days: 7));

      final allActivities = await _storage.getActivities();

      final todayActivities = allActivities.where((a) {
        final time = DateTime.parse(a.timestamp);
        return time.isAfter(today);
      }).toList();

      final yesterdayActivities = allActivities.where((a) {
        final time = DateTime.parse(a.timestamp);
        return time.isAfter(yesterday) && time.isBefore(today);
      }).toList();

      final weekActivities = allActivities.where((a) {
        final time = DateTime.parse(a.timestamp);
        return time.isAfter(weekAgo);
      }).toList();

      // 1. 밤 깬 횟수 분석
      final nightWakingsAlert = _analyzeNightWakings(
        todayActivities,
        weekActivities,
      );
      if (nightWakingsAlert != null) alerts.add(nightWakingsAlert);

      // 2. 수유량 변화 분석
      final feedingChangeAlert = _analyzeFeedingChange(
        todayActivities,
        yesterdayActivities,
      );
      if (feedingChangeAlert != null) alerts.add(feedingChangeAlert);

      // 3. 활동 목표 달성률
      final activityAlert = _analyzeActivityGoal(todayActivities);
      if (activityAlert != null) alerts.add(activityAlert);

      // 4. 최장 수면 기록
      final sleepRecordAlert = _analyzeLongestSleep(weekActivities);
      if (sleepRecordAlert != null) alerts.add(sleepRecordAlert);

      // 5. 먹-놀-잠 패턴 분석
      final patternAlert = _analyzeEatPlaySleepPattern(todayActivities);
      if (patternAlert != null) alerts.add(patternAlert);
    } catch (e) {
      // 분석 실패 시 빈 목록 반환
    }

    return alerts;
  }

  SmartAlert? _analyzeNightWakings(
    List<ActivityModel> today,
    List<ActivityModel> week,
  ) {
    try {
      // 어젯밤 (오후 7시 ~ 오전 7시) 깬 횟수
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      final lastNight = today.where((a) {
        if (a.type != ActivityType.sleep) return false;
        final time = DateTime.parse(a.timestamp);
        final isLastNight = (time.day == yesterday.day && time.hour >= 19) ||
                            (time.day == now.day && time.hour <= 7);
        return isLastNight;
      }).length;

      if (lastNight == 0) return null;

      // 주간 평균
      final weekNights = week.where((a) {
        if (a.type != ActivityType.sleep) return false;
        final time = DateTime.parse(a.timestamp);
        return time.hour >= 19 || time.hour <= 7;
      }).length;
      final avgNights = weekNights > 0 ? (weekNights / 7).round() : 2;

      return SmartAlert.nightWakings(
        count: lastNight,
        avgCount: avgNights > 0 ? avgNights : 2,
      );
    } catch (e) {
      return null;
    }
  }

  SmartAlert? _analyzeFeedingChange(
    List<ActivityModel> today,
    List<ActivityModel> yesterday,
  ) {
    try {
      int calculateTotalMl(List<ActivityModel> activities) {
        return activities
            .where((a) => a.type == ActivityType.feeding)
            .fold(0, (sum, a) => sum + (a.amountMl?.toInt() ?? 0));
      }

      final todayMl = calculateTotalMl(today);
      final yesterdayMl = calculateTotalMl(yesterday);

      if (todayMl == 0 && yesterdayMl == 0) return null;

      return SmartAlert.feedingChange(
        todayMl: todayMl,
        avgMl: yesterdayMl > 0 ? yesterdayMl : todayMl,
      );
    } catch (e) {
      return null;
    }
  }

  SmartAlert? _analyzeActivityGoal(List<ActivityModel> today) {
    try {
      // 터미타임 목표: 30분
      final tummyTime = today
          .where((a) =>
              a.type == ActivityType.play &&
              (a.notes?.toLowerCase().contains('tummy') == true))
          .fold(0, (sum, a) => sum + (a.durationMinutes ?? 0));

      if (tummyTime > 0 || today.any((a) => a.type == ActivityType.play)) {
        return SmartAlert.activityGoal(
          currentMinutes: tummyTime,
          goalMinutes: 30,
          activityName: '터미타임',
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  SmartAlert? _analyzeLongestSleep(List<ActivityModel> week) {
    try {
      final sleeps = week
          .where((a) => a.type == ActivityType.sleep)
          .map((a) => a.durationMinutes ?? 0)
          .toList();

      if (sleeps.isEmpty) return null;

      final longest = sleeps.reduce((a, b) => a > b ? a : b);
      final previousLongest = sleeps.length > 1
          ? sleeps.sublist(0, sleeps.length - 1).reduce((a, b) => a > b ? a : b)
          : longest;

      if (longest >= 180) { // 3시간 이상만 표시
        return SmartAlert.longestSleep(
          minutes: longest,
          previousRecord: previousLongest,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  SmartAlert? _analyzeEatPlaySleepPattern(List<ActivityModel> today) {
    try {
      // 수유 후 바로 잠든 횟수 체크
      final sorted = today.toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      int feedToSleepCount = 0;
      for (int i = 0; i < sorted.length - 1; i++) {
        if (sorted[i].type == ActivityType.feeding &&
            sorted[i + 1].type == ActivityType.sleep) {
          final feedTime = DateTime.parse(sorted[i].timestamp);
          final sleepTime = DateTime.parse(sorted[i + 1].timestamp);
          if (sleepTime.difference(feedTime).inMinutes < 15) {
            feedToSleepCount++;
          }
        }
      }

      if (feedToSleepCount >= 2) {
        return SmartAlert(
          type: AlertType.tip,
          emoji: '💬',
          title: '수유 후 바로 재우는 패턴이 보여요',
          subtitle: '먹기→놀기→자기 순서를 시도해보세요',
          actionLabel: '팁 보기',
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 수면 윈도우 체크
  Future<SmartAlert?> _checkSleepWindow(int ageInDays) async {
    final lastWakeTime = await _storage.getLastWakeUpTime();
    if (lastWakeTime == null) return null;

    final prediction = WakeWindowCalculator.calculateNextSleepTime(
      lastWakeTime: lastWakeTime,
      ageInDays: ageInDays,
    );

    final now = DateTime.now();
    final awakeMinutes = now.difference(lastWakeTime).inMinutes;
    final standardWindow = prediction.standardWakeWindow;

    // Urgent: 깨어있는 시간이 권장 시간의 120%를 초과
    if (awakeMinutes > standardWindow * 1.2) {
      return SmartAlert(
        id: 'sleep_urgent',
        title: '아기가 너무 오래 깨어있어요!',
        message: '${(awakeMinutes - standardWindow).toInt()}분 초과했습니다. 지금 재우는 것을 권장해요.',
        priority: AlertPriority.urgent,
        icon: Icons.bedtime_rounded,
        timestamp: now,
      );
    }

    // Warning: 깨어있는 시간이 권장 시간의 90%를 초과
    if (awakeMinutes > standardWindow * 0.9) {
      return SmartAlert(
        id: 'sleep_warning',
        title: '곧 재울 시간이에요',
        message: '${prediction.minutesUntilSweetSpot}분 후에 재우는 것이 좋아요.',
        priority: AlertPriority.warning,
        icon: Icons.bedtime_outlined,
        timestamp: now,
      );
    }

    return null;
  }

  /// 수유 타이밍 체크
  Future<SmartAlert?> _checkFeedingTime(int ageInDays) async {
    final feedingActivities = await _storage.getActivitiesByType(ActivityType.feeding);
    if (feedingActivities.isEmpty) return null;

    feedingActivities.sort((a, b) =>
        DateTime.parse(b.timestamp).compareTo(DateTime.parse(a.timestamp)));

    final lastFeeding = feedingActivities.first;
    final lastFeedTime = DateTime.parse(lastFeeding.timestamp);
    final amountMl = lastFeeding.amountMl ?? 120.0;

    final prediction = FeedingIntervalCalculator.calculateNextFeedingTime(
      lastFeedingTime: lastFeedTime,
      lastFeedingAmountMl: amountMl,
      ageInDays: ageInDays,
    );

    final now = DateTime.now();

    // Urgent: 수유 시간 초과
    if (prediction.isUrgent && prediction.minutesUntilFeeding < -15) {
      return SmartAlert(
        id: 'feeding_urgent',
        title: '수유 시간이 지났어요!',
        message: '${(-prediction.minutesUntilFeeding).toInt()}분 지연되었습니다.',
        priority: AlertPriority.urgent,
        icon: Icons.restaurant_rounded,
        timestamp: now,
      );
    }

    // Warning: 곧 수유 시간
    if (prediction.minutesUntilFeeding <= 15 && prediction.minutesUntilFeeding > 0) {
      return SmartAlert(
        id: 'feeding_warning',
        title: '곧 수유 시간이에요',
        message: '${prediction.minutesUntilFeeding}분 후 수유 예정입니다.',
        priority: AlertPriority.warning,
        icon: Icons.restaurant_outlined,
        timestamp: now,
      );
    }

    return null;
  }

  /// 기저귀 패턴 체크
  Future<SmartAlert?> _checkDiaperPattern() async {
    final diaperActivities = await _storage.getActivitiesByType(ActivityType.diaper);
    if (diaperActivities.isEmpty) return null;

    diaperActivities.sort((a, b) =>
        DateTime.parse(b.timestamp).compareTo(DateTime.parse(a.timestamp)));

    final lastDiaper = diaperActivities.first;
    final lastDiaperTime = DateTime.parse(lastDiaper.timestamp);
    final now = DateTime.now();
    final hoursSinceLastChange = now.difference(lastDiaperTime).inHours;

    // Warning: 3시간 이상 기저귀 미교체
    if (hoursSinceLastChange >= 3) {
      return SmartAlert(
        id: 'diaper_warning',
        title: '기저귀를 확인해주세요',
        message: '마지막 교체 후 $hoursSinceLastChange시간이 지났어요.',
        priority: AlertPriority.warning,
        icon: Icons.child_care_rounded,
        timestamp: now,
      );
    }

    return null;
  }

  /// 우선순위 값 (정렬용)
  int _getPriorityValue(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.urgent:
        return 0;
      case AlertPriority.warning:
        return 1;
      case AlertPriority.info:
        return 2;
    }
  }
}
