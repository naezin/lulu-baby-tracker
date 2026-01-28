/// 수면 분석 데이터 모델
/// 특정 기간의 수면 패턴을 집계하고 분석한 결과
class SleepAnalysisData {
  /// 분석 기간 시작일
  final DateTime startDate;

  /// 분석 기간 종료일
  final DateTime endDate;

  /// 총 수면 횟수
  final int totalSleepCount;

  /// 평균 수면 시간 (분)
  final double averageSleepDurationMinutes;

  /// 총 수면 시간 (분)
  final double totalSleepMinutes;

  /// 밤잠 평균 시간 (분) - 19:00~07:00
  final double averageNightSleepMinutes;

  /// 낮잠 평균 시간 (분) - 07:00~19:00
  final double averageNapMinutes;

  /// 낮잠 횟수
  final int napCount;

  /// 밤잠 횟수
  final int nightSleepCount;

  /// 평균 잠드는 시간 (시간 단위, 24시간제)
  final double averageSleepStartHour;

  /// 평균 기상 시간 (시간 단위, 24시간제)
  final double averageWakeUpHour;

  /// 수면 일관성 점수 (0-100)
  /// 잠드는 시간과 기상 시간의 일관성
  final double consistencyScore;

  /// 최장 수면 시간 (분)
  final double longestSleepMinutes;

  /// 최단 수면 시간 (분)
  final double shortestSleepMinutes;

  /// 수면 품질 등급 (1-5)
  /// 5: 매우 좋음, 4: 좋음, 3: 보통, 2: 나쁨, 1: 매우 나쁨
  final int qualityRating;

  /// 이전 기간 대비 변화율 (%)
  final double? changePercentage;

  /// 추세 (improving, stable, declining)
  final SleepTrend trend;

  SleepAnalysisData({
    required this.startDate,
    required this.endDate,
    required this.totalSleepCount,
    required this.averageSleepDurationMinutes,
    required this.totalSleepMinutes,
    required this.averageNightSleepMinutes,
    required this.averageNapMinutes,
    required this.napCount,
    required this.nightSleepCount,
    required this.averageSleepStartHour,
    required this.averageWakeUpHour,
    required this.consistencyScore,
    required this.longestSleepMinutes,
    required this.shortestSleepMinutes,
    required this.qualityRating,
    this.changePercentage,
    required this.trend,
  });

  /// 하루 평균 수면 시간 (시간 단위)
  double get averageSleepHoursPerDay {
    final days = endDate.difference(startDate).inDays + 1;
    return (totalSleepMinutes / 60) / days;
  }

  /// 밤잠 비율 (%)
  double get nightSleepPercentage {
    if (totalSleepMinutes == 0) return 0;
    return (averageNightSleepMinutes * nightSleepCount / totalSleepMinutes) * 100;
  }

  /// 낮잠 비율 (%)
  double get napPercentage {
    if (totalSleepMinutes == 0) return 0;
    return (averageNapMinutes * napCount / totalSleepMinutes) * 100;
  }

  /// 수면 효율성 (%) - 권장 수면 시간 대비
  /// 신생아: 14-17시간, 3개월: 14-17시간, 6개월: 12-16시간, 12개월: 11-14시간
  double getSleepEfficiency({required int babyAgeInMonths}) {
    final recommendedHours = _getRecommendedSleepHours(babyAgeInMonths);
    final actualHours = averageSleepHoursPerDay;
    return (actualHours / recommendedHours * 100).clamp(0, 100);
  }

  double _getRecommendedSleepHours(int ageInMonths) {
    if (ageInMonths < 3) return 16.0; // 신생아: 14-17시간 평균
    if (ageInMonths < 6) return 15.0; // 3-6개월: 14-17시간 평균
    if (ageInMonths < 12) return 14.0; // 6-12개월: 12-16시간 평균
    return 12.5; // 12개월+: 11-14시간 평균
  }

  /// 사용자 친화적 품질 메시지
  String getQualityMessage({required bool isKorean}) {
    switch (qualityRating) {
      case 5:
        return isKorean ? '매우 좋은 수면 패턴이에요! 👏' : 'Excellent sleep pattern! 👏';
      case 4:
        return isKorean ? '좋은 수면 패턴이에요 😊' : 'Good sleep pattern 😊';
      case 3:
        return isKorean ? '보통이에요. 조금 더 개선할 수 있어요' : 'Fair. Can be improved';
      case 2:
        return isKorean ? '수면 패턴을 개선해보세요' : 'Sleep pattern needs improvement';
      case 1:
        return isKorean ? '수면 전문가와 상담을 고려해보세요' : 'Consider consulting a sleep specialist';
      default:
        return isKorean ? '데이터 부족' : 'Insufficient data';
    }
  }

  /// 추세 메시지
  String getTrendMessage({required bool isKorean}) {
    switch (trend) {
      case SleepTrend.improving:
        return isKorean ? '개선되고 있어요 📈' : 'Improving 📈';
      case SleepTrend.stable:
        return isKorean ? '안정적이에요 ➡️' : 'Stable ➡️';
      case SleepTrend.declining:
        return isKorean ? '주의가 필요해요 📉' : 'Needs attention 📉';
    }
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalSleepCount': totalSleepCount,
      'averageSleepDurationMinutes': averageSleepDurationMinutes,
      'totalSleepMinutes': totalSleepMinutes,
      'averageNightSleepMinutes': averageNightSleepMinutes,
      'averageNapMinutes': averageNapMinutes,
      'napCount': napCount,
      'nightSleepCount': nightSleepCount,
      'averageSleepStartHour': averageSleepStartHour,
      'averageWakeUpHour': averageWakeUpHour,
      'consistencyScore': consistencyScore,
      'longestSleepMinutes': longestSleepMinutes,
      'shortestSleepMinutes': shortestSleepMinutes,
      'qualityRating': qualityRating,
      'changePercentage': changePercentage,
      'trend': trend.toString().split('.').last,
    };
  }

  /// JSON 역직렬화
  factory SleepAnalysisData.fromJson(Map<String, dynamic> json) {
    return SleepAnalysisData(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalSleepCount: json['totalSleepCount'] as int,
      averageSleepDurationMinutes: (json['averageSleepDurationMinutes'] as num).toDouble(),
      totalSleepMinutes: (json['totalSleepMinutes'] as num).toDouble(),
      averageNightSleepMinutes: (json['averageNightSleepMinutes'] as num).toDouble(),
      averageNapMinutes: (json['averageNapMinutes'] as num).toDouble(),
      napCount: json['napCount'] as int,
      nightSleepCount: json['nightSleepCount'] as int,
      averageSleepStartHour: (json['averageSleepStartHour'] as num).toDouble(),
      averageWakeUpHour: (json['averageWakeUpHour'] as num).toDouble(),
      consistencyScore: (json['consistencyScore'] as num).toDouble(),
      longestSleepMinutes: (json['longestSleepMinutes'] as num).toDouble(),
      shortestSleepMinutes: (json['shortestSleepMinutes'] as num).toDouble(),
      qualityRating: json['qualityRating'] as int,
      changePercentage: json['changePercentage'] != null
          ? (json['changePercentage'] as num).toDouble()
          : null,
      trend: SleepTrend.values.firstWhere(
        (e) => e.toString().split('.').last == json['trend'],
        orElse: () => SleepTrend.stable,
      ),
    );
  }

  /// 복사 메서드
  SleepAnalysisData copyWith({
    DateTime? startDate,
    DateTime? endDate,
    int? totalSleepCount,
    double? averageSleepDurationMinutes,
    double? totalSleepMinutes,
    double? averageNightSleepMinutes,
    double? averageNapMinutes,
    int? napCount,
    int? nightSleepCount,
    double? averageSleepStartHour,
    double? averageWakeUpHour,
    double? consistencyScore,
    double? longestSleepMinutes,
    double? shortestSleepMinutes,
    int? qualityRating,
    double? changePercentage,
    SleepTrend? trend,
  }) {
    return SleepAnalysisData(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalSleepCount: totalSleepCount ?? this.totalSleepCount,
      averageSleepDurationMinutes: averageSleepDurationMinutes ?? this.averageSleepDurationMinutes,
      totalSleepMinutes: totalSleepMinutes ?? this.totalSleepMinutes,
      averageNightSleepMinutes: averageNightSleepMinutes ?? this.averageNightSleepMinutes,
      averageNapMinutes: averageNapMinutes ?? this.averageNapMinutes,
      napCount: napCount ?? this.napCount,
      nightSleepCount: nightSleepCount ?? this.nightSleepCount,
      averageSleepStartHour: averageSleepStartHour ?? this.averageSleepStartHour,
      averageWakeUpHour: averageWakeUpHour ?? this.averageWakeUpHour,
      consistencyScore: consistencyScore ?? this.consistencyScore,
      longestSleepMinutes: longestSleepMinutes ?? this.longestSleepMinutes,
      shortestSleepMinutes: shortestSleepMinutes ?? this.shortestSleepMinutes,
      qualityRating: qualityRating ?? this.qualityRating,
      changePercentage: changePercentage ?? this.changePercentage,
      trend: trend ?? this.trend,
    );
  }

  @override
  String toString() {
    return 'SleepAnalysisData('
        'period: ${startDate.toString().split(' ')[0]} ~ ${endDate.toString().split(' ')[0]}, '
        'avgSleep: ${averageSleepDurationMinutes.toStringAsFixed(0)}min, '
        'quality: $qualityRating/5, '
        'trend: $trend)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SleepAnalysisData &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.totalSleepCount == totalSleepCount &&
        other.averageSleepDurationMinutes == averageSleepDurationMinutes &&
        other.totalSleepMinutes == totalSleepMinutes &&
        other.qualityRating == qualityRating &&
        other.trend == trend;
  }

  @override
  int get hashCode {
    return Object.hash(
      startDate,
      endDate,
      totalSleepCount,
      averageSleepDurationMinutes,
      totalSleepMinutes,
      qualityRating,
      trend,
    );
  }
}

/// 수면 추세
enum SleepTrend {
  /// 개선 중
  improving,

  /// 안정적
  stable,

  /// 악화 중
  declining,
}
