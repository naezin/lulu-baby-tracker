import 'package:flutter/material.dart';
import '../models/activity_model.dart';
import '../../presentation/widgets/analytics/weekly_insight_card.dart';
import 'local_storage_service.dart';

/// 📊 Weekly Insight Service
/// 주간 패턴 분석 및 인사이트 생성
class WeeklyInsightService {
  final LocalStorageService _storage = LocalStorageService();

  /// 주간 수면 인사이트 생성
  Future<WeeklyInsightData?> getSleepInsight() async {
    try {
      final activities = await _storage.getActivitiesByType(ActivityType.sleep);
      if (activities.isEmpty) return null;

      // 지난 주 데이터
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      final weekActivities = activities.where((a) {
        final timestamp = DateTime.parse(a.timestamp);
        return timestamp.isAfter(weekAgo) && timestamp.isBefore(now);
      }).toList();

      if (weekActivities.isEmpty) return null;

      // 통계 계산
      final totalSleepMinutes = weekActivities
          .map((a) => a.durationMinutes ?? 0)
          .reduce((a, b) => a + b);

      final avgSleepMinutes = (totalSleepMinutes / weekActivities.length).round();
      final sleepCount = weekActivities.length;

      // 인사이트 생성
      String insight;
      String? trend;

      if (avgSleepMinutes >= 60) {
        insight = '이번 주 아기가 잘 잤어요! 평균 $avgSleepMinutes분씩 $sleepCount번 잤습니다.';
        trend = 'improving';
      } else if (avgSleepMinutes < 30) {
        insight = '이번 주 수면 시간이 짧았어요. 수면 환경을 개선해보세요.';
        trend = 'declining';
      } else {
        insight = '이번 주 수면 패턴이 안정적이에요. 평균 $avgSleepMinutes분씩 잤습니다.';
        trend = 'stable';
      }

      final metrics = [
        InsightMetric(
          icon: Icons.bedtime_rounded,
          label: '평균 수면',
          value: '$avgSleepMinutes분',
        ),
        InsightMetric(
          icon: Icons.calendar_today_outlined,
          label: '수면 횟수',
          value: '$sleepCount회',
        ),
      ];

      return WeeklyInsightData(
        title: '이번 주 수면 패턴',
        insight: insight,
        trend: trend,
        metrics: metrics,
      );
    } catch (e) {
      return null;
    }
  }

  /// 주간 수유 인사이트 생성
  Future<WeeklyInsightData?> getFeedingInsight() async {
    try {
      final activities = await _storage.getActivitiesByType(ActivityType.feeding);
      if (activities.isEmpty) return null;

      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      final weekActivities = activities.where((a) {
        final timestamp = DateTime.parse(a.timestamp);
        return timestamp.isAfter(weekAgo) && timestamp.isBefore(now);
      }).toList();

      if (weekActivities.isEmpty) return null;

      // 통계 계산
      final totalAmount = weekActivities
          .map((a) => a.amountMl ?? 0)
          .reduce((a, b) => a + b);

      final avgAmount = (totalAmount / weekActivities.length).round();
      final feedingCount = weekActivities.length;
      final dailyAvg = (feedingCount / 7).round();

      // 인사이트 생성
      String insight;
      String? trend;

      if (dailyAvg >= 6) {
        insight = '이번 주 수유가 규칙적이에요! 하루 평균 $dailyAvg회, ${avgAmount}ml씩 먹었어요.';
        trend = 'stable';
      } else if (dailyAvg < 4) {
        insight = '이번 주 수유 횟수가 적었어요. 수유량을 확인해보세요.';
        trend = 'declining';
      } else {
        insight = '이번 주 수유 패턴이 양호해요. 평균 ${avgAmount}ml씩 먹었습니다.';
        trend = 'improving';
      }

      final metrics = [
        InsightMetric(
          icon: Icons.restaurant_rounded,
          label: '평균 수유량',
          value: '${avgAmount}ml',
        ),
        InsightMetric(
          icon: Icons.calendar_today_outlined,
          label: '하루 평균',
          value: '$dailyAvg회',
        ),
      ];

      return WeeklyInsightData(
        title: '이번 주 수유 패턴',
        insight: insight,
        trend: trend,
        metrics: metrics,
      );
    } catch (e) {
      return null;
    }
  }

  /// 주간 전체 인사이트 생성
  Future<List<WeeklyInsightData>> getAllInsights() async {
    final insights = <WeeklyInsightData>[];

    final sleepInsight = await getSleepInsight();
    if (sleepInsight != null) insights.add(sleepInsight);

    final feedingInsight = await getFeedingInsight();
    if (feedingInsight != null) insights.add(feedingInsight);

    return insights;
  }
}

/// 주간 인사이트 데이터 모델
class WeeklyInsightData {
  final String title;
  final String insight;
  final String? trend;
  final List<InsightMetric> metrics;

  WeeklyInsightData({
    required this.title,
    required this.insight,
    this.trend,
    required this.metrics,
  });
}
