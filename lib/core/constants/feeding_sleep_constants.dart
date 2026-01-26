/// 막수-밤잠 관련 도메인 상수
///
/// WHO/AAP 가이드라인 기반
/// 출처: AAP Safe Sleep Guidelines (2022)
abstract class FeedingSleepConstants {
  // ============================================
  // 막수 시간대 설정
  // ============================================

  /// 막수 시작 시간 (17:00)
  static const int lastFeedingStartHour = 17;

  /// 막수 종료 시간 (21:00)
  static const int lastFeedingEndHour = 21;

  // ============================================
  // 월령별 최소 막수량 (ml)
  // ============================================

  static const Map<int, double> _minLastFeedingByAge = {
    1: 60.0,   // 0-1개월
    3: 90.0,   // 2-3개월
    5: 120.0,  // 4-5개월
    6: 150.0,  // 6개월+
  };

  // ============================================
  // 월령별 최적 막수량 (ml)
  // ============================================

  static const Map<int, double> _optimalLastFeedingByAge = {
    1: 90.0,   // 0-1개월
    3: 120.0,  // 2-3개월
    5: 150.0,  // 4-5개월
    6: 180.0,  // 6개월+
  };

  // ============================================
  // 월령별 최적 막수↔밤잠 간격 (분)
  // ============================================

  static const Map<int, int> _optimalGapMinutesByAge = {
    1: 20,   // 0-1개월
    3: 30,   // 2-3개월
    5: 30,   // 4-5개월
    6: 45,   // 6개월+
  };

  // ============================================
  // 분석 설정
  // ============================================

  /// 최소 데이터 포인트 (신뢰도 계산용)
  static const int minDataPointsForAnalysis = 3;

  /// 신뢰할 수 있는 최소 confidence
  static const double reliableConfidenceThreshold = 0.6;

  /// 막수↔밤잠 최대 시간 간격 (시간)
  static const int maxHoursBetweenFeedAndSleep = 12;

  /// 최소 막수↔밤잠 간격 (분)
  static const int minGapMinutes = 15;

  /// 최대 막수↔밤잠 간격 (분)
  static const int maxGapMinutes = 90;

  // ============================================
  // Helper Methods
  // ============================================

  /// 월령에 맞는 최소 막수량 반환
  static double getMinAmount(int ageInMonths) {
    if (ageInMonths <= 1) return _minLastFeedingByAge[1]!;
    if (ageInMonths <= 3) return _minLastFeedingByAge[3]!;
    if (ageInMonths <= 5) return _minLastFeedingByAge[5]!;
    return _minLastFeedingByAge[6]!;
  }

  /// 월령에 맞는 최적 막수량 반환
  static double getOptimalAmount(int ageInMonths) {
    if (ageInMonths <= 1) return _optimalLastFeedingByAge[1]!;
    if (ageInMonths <= 3) return _optimalLastFeedingByAge[3]!;
    if (ageInMonths <= 5) return _optimalLastFeedingByAge[5]!;
    return _optimalLastFeedingByAge[6]!;
  }

  /// 월령에 맞는 최적 간격 반환
  static int getOptimalGap(int ageInMonths) {
    if (ageInMonths <= 1) return _optimalGapMinutesByAge[1]!;
    if (ageInMonths <= 3) return _optimalGapMinutesByAge[3]!;
    if (ageInMonths <= 5) return _optimalGapMinutesByAge[5]!;
    return _optimalGapMinutesByAge[6]!;
  }

  /// 막수 시간대인지 확인
  static bool isLastFeedingTime(int hour) {
    return hour >= lastFeedingStartHour && hour <= lastFeedingEndHour;
  }

  /// 막수↔밤잠 간격을 유효 범위로 제한
  static int clampGapMinutes(int gapMinutes) {
    return gapMinutes.clamp(minGapMinutes, maxGapMinutes);
  }
}
