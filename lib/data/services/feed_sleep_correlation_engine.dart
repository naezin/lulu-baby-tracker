import 'dart:math' as math;
import '../../core/constants/feeding_sleep_constants.dart';
import '../../domain/repositories/i_activity_repository.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/entities/feed_sleep_correlation.dart';

/// 막수-밤잠 상관관계 분석 엔진
class FeedSleepCorrelationEngine {
  final IActivityRepository _repository;

  FeedSleepCorrelationEngine({required IActivityRepository repository})
      : _repository = repository;

  /// 7일간 데이터 분석
  Future<FeedSleepCorrelation> analyze({
    required String babyId,
    int days = 7,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime startDate = now.subtract(Duration(days: days));

    // 수유 데이터 조회
    final List<ActivityEntity> feedings = await _repository.getActivities(
      babyId: babyId,
      startDate: startDate,
      type: ActivityType.feeding,
    );

    // 수면 데이터 조회
    final List<ActivityEntity> sleeps = await _repository.getActivities(
      babyId: babyId,
      startDate: startDate,
      type: ActivityType.sleep,
    );

    // 막수 추출
    final List<LastFeedingAnalysis> lastFeedings = _extractLastFeedings(
      feedings: feedings,
      sleeps: sleeps,
    );

    // 밤잠 품질 매칭
    final List<NightSleepQuality> nightSleeps = _matchNightSleeps(
      lastFeedings: lastFeedings,
      sleeps: sleeps,
    );

    // 최소 데이터 포인트 확인
    if (lastFeedings.length < FeedingSleepConstants.minDataPointsForAnalysis ||
        nightSleeps.length < FeedingSleepConstants.minDataPointsForAnalysis) {
      return FeedSleepCorrelation.empty();
    }

    // 상관계수 계산
    final double amountCorrelation = _calculateCorrelation(
      x: lastFeedings.map((LastFeedingAnalysis f) => f.amountMl).toList(),
      y: nightSleeps
          .map((NightSleepQuality s) => s.firstStretch.inMinutes.toDouble())
          .toList(),
    );

    final double gapCorrelation = _calculateCorrelation(
      x: lastFeedings
          .map((LastFeedingAnalysis f) => f.timeToBedtime.inMinutes.toDouble())
          .toList(),
      y: nightSleeps
          .map((NightSleepQuality s) => s.wakeUpCount.toDouble())
          .toList(),
    );

    // 최적값 찾기
    final double optimalAmount = _findOptimalAmount(lastFeedings, nightSleeps);
    final int optimalGap = _findOptimalGap(lastFeedings, nightSleeps);
    final double confidence = _calculateConfidence(lastFeedings.length, days);

    return FeedSleepCorrelation(
      amountCorrelation: amountCorrelation,
      gapCorrelation: gapCorrelation,
      optimalAmountMl: optimalAmount,
      optimalGapMinutes: optimalGap,
      confidence: confidence,
      dataPoints: lastFeedings.length,
      analyzedAt: now,
    );
  }

  /// 막수 추출 (FeedingSleepConstants 시간대 사용)
  List<LastFeedingAnalysis> _extractLastFeedings({
    required List<ActivityEntity> feedings,
    required List<ActivityEntity> sleeps,
  }) {
    final Map<String, LastFeedingAnalysis> dailyLastFeedings = {};

    for (final ActivityEntity feeding in feedings) {
      final int hour = feeding.timestamp.hour;

      // ✅ 상수 사용: 막수 시간대 확인
      if (!FeedingSleepConstants.isLastFeedingTime(hour)) continue;

      // 해당 막수 이후의 밤잠 찾기
      final List<ActivityEntity> nextSleeps = sleeps.where((ActivityEntity s) {
        final Duration diff = s.timestamp.difference(feeding.timestamp);
        return diff.inHours >= 0 &&
            diff.inHours < FeedingSleepConstants.maxHoursBetweenFeedAndSleep;
      }).toList();

      if (nextSleeps.isEmpty) continue;

      nextSleeps.sort((ActivityEntity a, ActivityEntity b) =>
          a.timestamp.compareTo(b.timestamp));
      final DateTime bedtime = nextSleeps.first.timestamp;

      // ⚠️ 날짜 키는 bedtime 기준 (자정 경계 문제 해결)
      final String dateKey =
          '${bedtime.year}-${bedtime.month}-${bedtime.day}';

      final LastFeedingAnalysis analysis = LastFeedingAnalysis(
        feedingTime: feeding.timestamp,
        amountMl: feeding.amountMl ?? 0,
        feedingType: feeding.feedingType ?? 'unknown',
        timeToBedtime: bedtime.difference(feeding.timestamp),
      );

      // 같은 밤잠에 대해 더 늦은 막수로 업데이트
      if (!dailyLastFeedings.containsKey(dateKey) ||
          feeding.timestamp
              .isAfter(dailyLastFeedings[dateKey]!.feedingTime)) {
        dailyLastFeedings[dateKey] = analysis;
      }
    }

    return dailyLastFeedings.values.toList();
  }

  /// 막수와 매칭되는 밤잠 품질 분석
  List<NightSleepQuality> _matchNightSleeps({
    required List<LastFeedingAnalysis> lastFeedings,
    required List<ActivityEntity> sleeps,
  }) {
    final List<NightSleepQuality> nightSleeps = [];

    for (final LastFeedingAnalysis feeding in lastFeedings) {
      // 막수 후 12시간 내의 수면 찾기 (상수 사용)
      final List<ActivityEntity> relevantSleeps = sleeps
          .where((ActivityEntity s) {
            final Duration diff = s.timestamp.difference(feeding.feedingTime);
            return diff.inHours >= 0 &&
                diff.inHours <
                    FeedingSleepConstants.maxHoursBetweenFeedAndSleep;
          })
          .where((ActivityEntity s) => s.endTime != null)
          .toList();

      if (relevantSleeps.isEmpty) continue;

      relevantSleeps.sort((ActivityEntity a, ActivityEntity b) =>
          a.timestamp.compareTo(b.timestamp));

      final ActivityEntity firstSleep = relevantSleeps.first;
      final DateTime bedtime = firstSleep.timestamp;

      // ⚠️ null 안전 처리
      final DateTime? firstEndTime = firstSleep.endTime;
      if (firstEndTime == null) continue;

      final Duration firstStretch = firstEndTime.difference(bedtime);
      final int wakeUpCount = relevantSleeps.length - 1;

      // 총 수면 시간 계산
      int totalMinutes = 0;
      for (final ActivityEntity sleep in relevantSleeps) {
        totalMinutes += sleep.durationMinutes ?? 0;
      }

      // 마지막 수면의 종료 시간
      final ActivityEntity lastSleep = relevantSleeps.last;
      final DateTime? lastEndTime = lastSleep.endTime;
      if (lastEndTime == null) continue;

      nightSleeps.add(NightSleepQuality(
        totalDuration: Duration(minutes: totalMinutes),
        firstStretch: firstStretch,
        wakeUpCount: wakeUpCount,
        firstWakeUp: wakeUpCount > 0 ? firstEndTime : null,
        bedtime: bedtime,
        wakeUpTime: lastEndTime,
      ));
    }

    return nightSleeps;
  }

  /// 피어슨 상관계수 계산
  double _calculateCorrelation({
    required List<double> x,
    required List<double> y,
  }) {
    if (x.length != y.length || x.length < 2) return 0;

    final int n = x.length;
    final double meanX = x.reduce((double a, double b) => a + b) / n;
    final double meanY = y.reduce((double a, double b) => a + b) / n;

    double numerator = 0;
    double denomX = 0;
    double denomY = 0;

    for (int i = 0; i < n; i++) {
      final double dx = x[i] - meanX;
      final double dy = y[i] - meanY;
      numerator += dx * dy;
      denomX += dx * dx;
      denomY += dy * dy;
    }

    final double denom = math.sqrt(denomX * denomY);
    if (denom == 0) return 0;

    return numerator / denom;
  }

  double _findOptimalAmount(
    List<LastFeedingAnalysis> feedings,
    List<NightSleepQuality> sleeps,
  ) {
    if (feedings.isEmpty) {
      return FeedingSleepConstants.getOptimalAmount(3); // 기본값
    }

    double bestAmount = FeedingSleepConstants.getOptimalAmount(3);
    int bestStretch = 0;

    final int minLength = math.min(feedings.length, sleeps.length);
    for (int i = 0; i < minLength; i++) {
      if (sleeps[i].firstStretch.inMinutes > bestStretch) {
        bestStretch = sleeps[i].firstStretch.inMinutes;
        bestAmount = feedings[i].amountMl;
      }
    }

    return bestAmount > 0
        ? bestAmount
        : FeedingSleepConstants.getOptimalAmount(3);
  }

  int _findOptimalGap(
    List<LastFeedingAnalysis> feedings,
    List<NightSleepQuality> sleeps,
  ) {
    if (feedings.isEmpty) {
      return FeedingSleepConstants.getOptimalGap(3); // 기본값
    }

    int bestGap = FeedingSleepConstants.getOptimalGap(3);
    int fewestWakeUps = 999;

    final int minLength = math.min(feedings.length, sleeps.length);
    for (int i = 0; i < minLength; i++) {
      if (sleeps[i].wakeUpCount < fewestWakeUps) {
        fewestWakeUps = sleeps[i].wakeUpCount;
        bestGap = feedings[i].timeToBedtime.inMinutes;
      }
    }

    // ✅ 상수 사용: 유효 범위로 제한
    return FeedingSleepConstants.clampGapMinutes(bestGap);
  }

  double _calculateConfidence(int dataPoints, int days) {
    final double dataRatio = dataPoints / days;
    final double baseConfidence = (dataPoints / 14).clamp(0.0, 1.0);
    final double completenessBonus = dataRatio * 0.2;
    return (baseConfidence * 0.8 + completenessBonus).clamp(0.0, 1.0);
  }
}
