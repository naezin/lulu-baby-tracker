import '../../core/constants/feeding_sleep_constants.dart';

/// 막수-밤잠 상관관계 분석 결과
class FeedSleepCorrelation {
  /// 막수 양 ↔ 첫 연속 수면 시간 상관계수 (-1.0 ~ 1.0)
  final double amountCorrelation;

  /// 막수↔밤잠 간격 ↔ 야간 기상 횟수 상관계수
  final double gapCorrelation;

  /// 최적 막수 양 (ml)
  final double optimalAmountMl;

  /// 최적 막수↔밤잠 간격 (분)
  final int optimalGapMinutes;

  /// 신뢰도 (0.0 ~ 1.0)
  final double confidence;

  /// 분석에 사용된 데이터 일수
  final int dataPoints;

  /// 마지막 분석 시간
  final DateTime analyzedAt;

  const FeedSleepCorrelation({
    required this.amountCorrelation,
    required this.gapCorrelation,
    required this.optimalAmountMl,
    required this.optimalGapMinutes,
    required this.confidence,
    required this.dataPoints,
    required this.analyzedAt,
  });

  bool get hasEnoughData => dataPoints >= FeedingSleepConstants.minDataPointsForAnalysis;
  bool get isReliable => confidence >= FeedingSleepConstants.reliableConfidenceThreshold;

  factory FeedSleepCorrelation.empty() => FeedSleepCorrelation(
        amountCorrelation: 0,
        gapCorrelation: 0,
        optimalAmountMl: 0,
        optimalGapMinutes: 30,
        confidence: 0,
        dataPoints: 0,
        analyzedAt: DateTime.now(),
      );

  /// 월령별 기본값 (데이터 부족 시 폴백)
  factory FeedSleepCorrelation.defaultFor(int ageInMonths) {
    return FeedSleepCorrelation(
      amountCorrelation: 0,
      gapCorrelation: 0,
      optimalAmountMl: FeedingSleepConstants.getOptimalAmount(ageInMonths),
      optimalGapMinutes: FeedingSleepConstants.getOptimalGap(ageInMonths),
      confidence: 0.3,
      dataPoints: 0,
      analyzedAt: DateTime.now(),
    );
  }
}

/// 밤잠 품질 분석 결과
class NightSleepQuality {
  final Duration totalDuration;
  final Duration firstStretch;
  final int wakeUpCount;
  final DateTime? firstWakeUp;
  final DateTime bedtime;
  final DateTime wakeUpTime;

  const NightSleepQuality({
    required this.totalDuration,
    required this.firstStretch,
    required this.wakeUpCount,
    this.firstWakeUp,
    required this.bedtime,
    required this.wakeUpTime,
  });

  int get qualityScore {
    int score = 50;

    // 첫 연속 수면 시간 보너스 (최대 30점)
    final double firstStretchHours = firstStretch.inMinutes / 60;
    score += (firstStretchHours * 6).clamp(0, 30).toInt();

    // 야간 기상 페널티 (최대 -30점)
    score -= (wakeUpCount * 10).clamp(0, 30);

    // 총 수면 시간 보너스 (최대 20점)
    final double totalHours = totalDuration.inMinutes / 60;
    if (totalHours >= 10) {
      score += 20;
    } else if (totalHours >= 8) {
      score += 15;
    } else if (totalHours >= 6) {
      score += 10;
    }

    return score.clamp(0, 100);
  }
}

/// 막수(마지막 수유) 분석 결과
class LastFeedingAnalysis {
  final DateTime feedingTime;
  final double amountMl;
  final String feedingType;
  final Duration timeToBedtime;

  const LastFeedingAnalysis({
    required this.feedingTime,
    required this.amountMl,
    required this.feedingType,
    required this.timeToBedtime,
  });

  /// 월령 대비 충분한 양인지 확인
  bool isSufficient(int ageInMonths) {
    final double minAmount = FeedingSleepConstants.getMinAmount(ageInMonths);
    return amountMl >= minAmount;
  }
}
