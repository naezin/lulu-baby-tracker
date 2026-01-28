import '../models/activity_model.dart';
import '../models/sleep_analysis_data.dart';
import 'dart:math' as math;

/// 수면 분석 서비스
/// ActivityModel 데이터를 분석하여 SleepAnalysisData 생성
class SleepAnalysisService {
  /// 특정 기간의 수면 데이터 분석
  SleepAnalysisData analyzeSleepPeriod({
    required List<ActivityModel> sleepActivities,
    required DateTime startDate,
    required DateTime endDate,
    List<ActivityModel>? previousPeriodActivities,
  }) {
    // 완료된 수면만 필터링
    final completedSleeps = sleepActivities
        .where((a) => a.type == ActivityType.sleep && a.endTime != null)
        .toList();

    if (completedSleeps.isEmpty) {
      return _createEmptyAnalysis(startDate, endDate);
    }

    // 기본 통계 계산
    final totalCount = completedSleeps.length;
    final durations = completedSleeps.map((s) => _calculateDurationMinutes(s)).toList();
    final totalMinutes = durations.fold(0.0, (sum, d) => sum + d);
    final avgDuration = totalMinutes / totalCount;

    // 낮잠/밤잠 분류
    final naps = <ActivityModel>[];
    final nightSleeps = <ActivityModel>[];

    for (final sleep in completedSleeps) {
      if (_isNightSleep(sleep)) {
        nightSleeps.add(sleep);
      } else {
        naps.add(sleep);
      }
    }

    final avgNightMinutes = nightSleeps.isNotEmpty
        ? nightSleeps.map((s) => _calculateDurationMinutes(s)).reduce((a, b) => a + b) / nightSleeps.length
        : 0.0;

    final avgNapMinutes = naps.isNotEmpty
        ? naps.map((s) => _calculateDurationMinutes(s)).reduce((a, b) => a + b) / naps.length
        : 0.0;

    // 시간 통계
    final sleepStartHours = completedSleeps.map((s) {
      final start = DateTime.parse(s.timestamp);
      return start.hour + start.minute / 60.0;
    }).toList();

    final wakeUpHours = completedSleeps.map((s) {
      final end = DateTime.parse(s.endTime!);
      return end.hour + end.minute / 60.0;
    }).toList();

    final avgSleepStart = sleepStartHours.reduce((a, b) => a + b) / sleepStartHours.length;
    final avgWakeUp = wakeUpHours.reduce((a, b) => a + b) / wakeUpHours.length;

    // 일관성 점수 계산 (표준편차 기반)
    final consistencyScore = _calculateConsistencyScore(sleepStartHours, wakeUpHours);

    // 최장/최단 수면
    final longest = durations.reduce(math.max);
    final shortest = durations.reduce(math.min);

    // 품질 등급 계산
    final qualityRating = _calculateQualityRating(
      avgDuration: avgDuration,
      consistencyScore: consistencyScore,
      nightSleepCount: nightSleeps.length,
      napCount: naps.length,
    );

    // 변화율 및 추세
    double? changePercentage;
    SleepTrend trend = SleepTrend.stable;

    if (previousPeriodActivities != null && previousPeriodActivities.isNotEmpty) {
      final prevCompleted = previousPeriodActivities
          .where((a) => a.type == ActivityType.sleep && a.endTime != null)
          .toList();

      if (prevCompleted.isNotEmpty) {
        final prevTotalMinutes = prevCompleted
            .map((s) => _calculateDurationMinutes(s))
            .fold(0.0, (sum, d) => sum + d);
        final prevAvgDuration = prevTotalMinutes / prevCompleted.length;

        changePercentage = ((avgDuration - prevAvgDuration) / prevAvgDuration) * 100;
        trend = _determineTrend(changePercentage, consistencyScore);
      }
    }

    return SleepAnalysisData(
      startDate: startDate,
      endDate: endDate,
      totalSleepCount: totalCount,
      averageSleepDurationMinutes: avgDuration,
      totalSleepMinutes: totalMinutes,
      averageNightSleepMinutes: avgNightMinutes,
      averageNapMinutes: avgNapMinutes,
      napCount: naps.length,
      nightSleepCount: nightSleeps.length,
      averageSleepStartHour: avgSleepStart,
      averageWakeUpHour: avgWakeUp,
      consistencyScore: consistencyScore,
      longestSleepMinutes: longest,
      shortestSleepMinutes: shortest,
      qualityRating: qualityRating,
      changePercentage: changePercentage,
      trend: trend,
    );
  }

  /// 수면 시간 계산 (분)
  double _calculateDurationMinutes(ActivityModel sleep) {
    if (sleep.endTime == null) return 0;
    final start = DateTime.parse(sleep.timestamp);
    final end = DateTime.parse(sleep.endTime!);
    return end.difference(start).inMinutes.toDouble();
  }

  /// 밤잠 여부 판단 (19:00 ~ 07:00)
  bool _isNightSleep(ActivityModel sleep) {
    final start = DateTime.parse(sleep.timestamp);
    final hour = start.hour;
    return hour >= 19 || hour < 7;
  }

  /// 일관성 점수 계산 (0-100)
  /// 잠드는 시간과 기상 시간의 표준편차가 낮을수록 높은 점수
  double _calculateConsistencyScore(List<double> sleepStarts, List<double> wakeUps) {
    if (sleepStarts.length < 2) return 100.0; // 데이터 부족 시 만점

    final sleepStdDev = _calculateStandardDeviation(sleepStarts);
    final wakeStdDev = _calculateStandardDeviation(wakeUps);

    // 표준편차가 1시간 이하면 100점, 3시간 이상이면 0점
    final avgStdDev = (sleepStdDev + wakeStdDev) / 2;
    final score = (1 - (avgStdDev / 3)).clamp(0.0, 1.0) * 100.0;

    return score;
  }

  /// 표준편차 계산
  double _calculateStandardDeviation(List<double> values) {
    if (values.isEmpty) return 0;

    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values
        .map((v) => math.pow(v - mean, 2))
        .reduce((a, b) => a + b) / values.length;

    return math.sqrt(variance);
  }

  /// 품질 등급 계산 (1-5)
  int _calculateQualityRating({
    required double avgDuration,
    required double consistencyScore,
    required int nightSleepCount,
    required int napCount,
  }) {
    int score = 0;

    // 평균 수면 시간 (최대 2점)
    if (avgDuration >= 120) {
      score += 2; // 2시간 이상
    } else if (avgDuration >= 60) {
      score += 1; // 1시간 이상
    }

    // 일관성 (최대 2점)
    if (consistencyScore >= 80) {
      score += 2;
    } else if (consistencyScore >= 60) {
      score += 1;
    }

    // 밤잠/낮잠 균형 (최대 1점)
    if (nightSleepCount > 0 && napCount > 0) {
      score += 1;
    }

    // 1-5 범위로 변환
    return (score / 5 * 5).ceil().clamp(1, 5);
  }

  /// 추세 결정
  SleepTrend _determineTrend(double changePercentage, double consistencyScore) {
    // 변화율 + 일관성 점수 고려
    if (changePercentage > 10 && consistencyScore >= 70) {
      return SleepTrend.improving;
    } else if (changePercentage < -10 || consistencyScore < 50) {
      return SleepTrend.declining;
    } else {
      return SleepTrend.stable;
    }
  }

  /// 빈 분석 데이터 생성 (데이터 부족 시)
  SleepAnalysisData _createEmptyAnalysis(DateTime startDate, DateTime endDate) {
    return SleepAnalysisData(
      startDate: startDate,
      endDate: endDate,
      totalSleepCount: 0,
      averageSleepDurationMinutes: 0,
      totalSleepMinutes: 0,
      averageNightSleepMinutes: 0,
      averageNapMinutes: 0,
      napCount: 0,
      nightSleepCount: 0,
      averageSleepStartHour: 0,
      averageWakeUpHour: 0,
      consistencyScore: 0,
      longestSleepMinutes: 0,
      shortestSleepMinutes: 0,
      qualityRating: 0,
      changePercentage: null,
      trend: SleepTrend.stable,
    );
  }

  /// 주간 분석 (최근 7일)
  SleepAnalysisData analyzeWeekly(List<ActivityModel> activities) {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 7));

    final weekActivities = activities.where((a) {
      final date = DateTime.parse(a.timestamp);
      return date.isAfter(startDate) && date.isBefore(now);
    }).toList();

    final prevStartDate = startDate.subtract(const Duration(days: 7));
    final prevActivities = activities.where((a) {
      final date = DateTime.parse(a.timestamp);
      return date.isAfter(prevStartDate) && date.isBefore(startDate);
    }).toList();

    return analyzeSleepPeriod(
      sleepActivities: weekActivities,
      startDate: startDate,
      endDate: now,
      previousPeriodActivities: prevActivities,
    );
  }

  /// 월간 분석 (최근 30일)
  SleepAnalysisData analyzeMonthly(List<ActivityModel> activities) {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30));

    final monthActivities = activities.where((a) {
      final date = DateTime.parse(a.timestamp);
      return date.isAfter(startDate) && date.isBefore(now);
    }).toList();

    final prevStartDate = startDate.subtract(const Duration(days: 30));
    final prevActivities = activities.where((a) {
      final date = DateTime.parse(a.timestamp);
      return date.isAfter(prevStartDate) && date.isBefore(startDate);
    }).toList();

    return analyzeSleepPeriod(
      sleepActivities: monthActivities,
      startDate: startDate,
      endDate: now,
      previousPeriodActivities: prevActivities,
    );
  }
}
