import '../../../../data/models/activity_model.dart';

/// 인사이트 상태
enum InsightStatus {
  good,     // ✅ 좋음
  warning,  // ⚠️ 주의
  info,     // ℹ️ 정보
}

/// 수면 인사이트
class WeeklySleepInsight {
  final int avgMinutes;
  final int diffMinutes; // 지난 기간 대비
  final int recommendedMinMinutes;
  final int recommendedMaxMinutes;
  final InsightStatus status;

  WeeklySleepInsight({
    required this.avgMinutes,
    required this.diffMinutes,
    required this.recommendedMinMinutes,
    required this.recommendedMaxMinutes,
    required this.status,
  });
}

/// 야간 기상 인사이트
class WeeklyWakeUpInsight {
  final double avgCount;
  final int diffCount;
  final double peerAvgCount;
  final InsightStatus status;

  WeeklyWakeUpInsight({
    required this.avgCount,
    required this.diffCount,
    required this.peerAvgCount,
    required this.status,
  });
}

/// 수유 인사이트
class WeeklyFeedingInsight {
  final double avgDailyMl;
  final double diffMl;
  final double recommendedMinMl;
  final double recommendedMaxMl;
  final InsightStatus status;

  WeeklyFeedingInsight({
    required this.avgDailyMl,
    required this.diffMl,
    required this.recommendedMinMl,
    required this.recommendedMaxMl,
    required this.status,
  });
}

/// 패턴 인사이트
class PatternInsight {
  final double eatPlaySleepRate; // 먹-놀-잠 순서 준수율
  final int feedToSleepCount; // 수유 후 바로 잠든 횟수
  final int totalDays;

  PatternInsight({
    required this.eatPlaySleepRate,
    required this.feedToSleepCount,
    required this.totalDays,
  });
}

/// 인사이트 생성 서비스
class InsightGenerator {

  /// 월령별 권장 밤잠 시간 (분)
  final Map<int, List<int>> _sleepRecommendations = {
    0: [420, 540],   // 0-1개월: 7-9시간
    1: [420, 540],   // 1-2개월: 7-9시간
    2: [360, 480],   // 2-3개월: 6-8시간
    3: [360, 480],   // 3-4개월: 6-8시간
    4: [360, 420],   // 4-6개월: 6-7시간
    6: [360, 420],   // 6-9개월: 6-7시간
    9: [360, 420],   // 9-12개월: 6-7시간
  };

  /// 월령별 평균 야간 기상 횟수
  final Map<int, double> _wakeUpAverages = {
    0: 4.0,
    1: 3.5,
    2: 3.0,
    3: 2.5,
    4: 2.0,
    6: 1.5,
    9: 1.0,
  };

  /// 수면 인사이트 생성
  WeeklySleepInsight generateSleepInsight({
    required List<ActivityModel> activities,
    required List<ActivityModel> prevActivities,
    required int babyAgeInDays,
  }) {
    final sleepActivities = activities
        .where((a) => a.type == ActivityType.sleep && a.durationMinutes != null)
        .toList();

    final prevSleepActivities = prevActivities
        .where((a) => a.type == ActivityType.sleep && a.durationMinutes != null)
        .toList();

    // 밤잠만 필터 (20:00 - 08:00 사이 시작)
    int totalMinutes = 0;
    int nightCount = 0;

    for (final activity in sleepActivities) {
      final hour = DateTime.parse(activity.timestamp).hour;
      if (hour >= 20 || hour < 8) {
        totalMinutes += activity.durationMinutes!;
        nightCount++;
      }
    }

    int prevTotalMinutes = 0;
    int prevNightCount = 0;

    for (final activity in prevSleepActivities) {
      final hour = DateTime.parse(activity.timestamp).hour;
      if (hour >= 20 || hour < 8) {
        prevTotalMinutes += activity.durationMinutes!;
        prevNightCount++;
      }
    }

    final avgMinutes = nightCount > 0 ? totalMinutes ~/ nightCount : 0;
    final prevAvgMinutes = prevNightCount > 0 ? prevTotalMinutes ~/ prevNightCount : avgMinutes;

    // 월령별 권장 범위
    final monthAge = babyAgeInDays ~/ 30;
    final recommendations = _sleepRecommendations[monthAge] ?? _sleepRecommendations[0]!;

    final status = avgMinutes >= recommendations[0] && avgMinutes <= recommendations[1]
        ? InsightStatus.good
        : avgMinutes < recommendations[0]
            ? InsightStatus.warning
            : InsightStatus.info;

    return WeeklySleepInsight(
      avgMinutes: avgMinutes,
      diffMinutes: avgMinutes - prevAvgMinutes,
      recommendedMinMinutes: recommendations[0],
      recommendedMaxMinutes: recommendations[1],
      status: status,
    );
  }

  /// 야간 기상 인사이트 생성
  WeeklyWakeUpInsight generateWakeUpInsight({
    required List<ActivityModel> activities,
    required List<ActivityModel> prevActivities,
    required int babyAgeInDays,
  }) {
    // 밤 시간대 수면 시작 횟수 = 깬 횟수 + 1
    int wakeUpCount = 0;
    int nightCount = 0;

    final sortedActivities = [...activities]
      ..sort((a, b) => DateTime.parse(a.timestamp).compareTo(DateTime.parse(b.timestamp)));

    DateTime? currentNight;
    int currentNightWakeUps = 0;

    for (final activity in sortedActivities) {
      if (activity.type != ActivityType.sleep) continue;

      final time = DateTime.parse(activity.timestamp);
      final hour = time.hour;

      // 밤 시간 (20:00 - 08:00)
      if (hour >= 20 || hour < 8) {
        final nightDate = hour >= 20
            ? DateTime(time.year, time.month, time.day)
            : DateTime(time.year, time.month, time.day - 1);

        if (currentNight == null || nightDate != currentNight) {
          if (currentNight != null) {
            wakeUpCount += currentNightWakeUps;
            nightCount++;
          }
          currentNight = nightDate;
          currentNightWakeUps = 0;
        }
        currentNightWakeUps++;
      }
    }

    // 마지막 밤 처리
    if (currentNight != null) {
      wakeUpCount += currentNightWakeUps;
      nightCount++;
    }

    final avgCount = nightCount > 0 ? wakeUpCount / nightCount : 0.0;

    // 지난 기간과 비교 (간소화)
    final prevAvgCount = avgCount; // TODO: 실제 계산

    // 월령별 평균과 비교
    final monthAge = babyAgeInDays ~/ 30;
    final peerAvg = _wakeUpAverages[monthAge] ?? 2.5;

    final status = avgCount <= peerAvg
        ? InsightStatus.good
        : InsightStatus.warning;

    return WeeklyWakeUpInsight(
      avgCount: avgCount,
      diffCount: (avgCount - prevAvgCount).round(),
      peerAvgCount: peerAvg,
      status: status,
    );
  }

  /// 수유 인사이트 생성
  WeeklyFeedingInsight generateFeedingInsight({
    required List<ActivityModel> activities,
    required List<ActivityModel> prevActivities,
    required double babyWeightKg,
  }) {
    final feedingActivities = activities
        .where((a) => a.type == ActivityType.feeding && a.amountMl != null)
        .toList();

    // 일별 그룹핑
    final Map<String, double> dailyMl = {};

    for (final activity in feedingActivities) {
      final date = DateTime.parse(activity.timestamp);
      final dateKey = '${date.year}-${date.month}-${date.day}';
      dailyMl[dateKey] = (dailyMl[dateKey] ?? 0) + activity.amountMl!;
    }

    final avgDailyMl = dailyMl.isEmpty
        ? 0.0
        : dailyMl.values.reduce((a, b) => a + b) / dailyMl.length;

    // 체중 기반 권장량 (150-200ml/kg/day)
    final recommendedMin = babyWeightKg * 150;
    final recommendedMax = babyWeightKg * 200;

    // 지난 기간 비교
    final Map<String, double> prevDailyMl = {};
    for (final activity in prevActivities) {
      if (activity.type != ActivityType.feeding || activity.amountMl == null) continue;
      final date = DateTime.parse(activity.timestamp);
      final dateKey = '${date.year}-${date.month}-${date.day}';
      prevDailyMl[dateKey] = (prevDailyMl[dateKey] ?? 0) + activity.amountMl!;
    }

    final prevAvgDailyMl = prevDailyMl.isEmpty
        ? avgDailyMl
        : prevDailyMl.values.reduce((a, b) => a + b) / prevDailyMl.length;

    final status = avgDailyMl >= recommendedMin && avgDailyMl <= recommendedMax
        ? InsightStatus.good
        : InsightStatus.warning;

    return WeeklyFeedingInsight(
      avgDailyMl: avgDailyMl,
      diffMl: avgDailyMl - prevAvgDailyMl,
      recommendedMinMl: recommendedMin,
      recommendedMaxMl: recommendedMax,
      status: status,
    );
  }

  /// 패턴 인사이트 생성
  PatternInsight generatePatternInsight({
    required List<ActivityModel> activities,
  }) {
    // 시간순 정렬
    final sorted = [...activities]
      ..sort((a, b) => DateTime.parse(a.timestamp).compareTo(DateTime.parse(b.timestamp)));

    int feedToSleepCount = 0;
    int eatPlaySleepCount = 0;
    int totalPatterns = 0;

    for (int i = 0; i < sorted.length - 1; i++) {
      final current = sorted[i];
      final next = sorted[i + 1];

      // 수유 → 수면 (직접)
      if (current.type == ActivityType.feeding && next.type == ActivityType.sleep) {
        final gap = DateTime.parse(next.timestamp)
            .difference(DateTime.parse(current.timestamp))
            .inMinutes;

        if (gap < 30) {
          feedToSleepCount++;
          totalPatterns++;
        }
      }

      // 수유 → 놀이 → 수면 (이상적)
      if (i < sorted.length - 2) {
        final nextNext = sorted[i + 2];
        if (current.type == ActivityType.feeding &&
            next.type == ActivityType.play &&
            nextNext.type == ActivityType.sleep) {
          eatPlaySleepCount++;
          totalPatterns++;
        }
      }
    }

    final rate = totalPatterns > 0
        ? eatPlaySleepCount / totalPatterns
        : 0.5;

    // 일수 계산
    final dates = activities.map((a) {
      final d = DateTime.parse(a.timestamp);
      return '${d.year}-${d.month}-${d.day}';
    }).toSet();

    return PatternInsight(
      eatPlaySleepRate: rate,
      feedToSleepCount: feedToSleepCount,
      totalDays: dates.length,
    );
  }
}
