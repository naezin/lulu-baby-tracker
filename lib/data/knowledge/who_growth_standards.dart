/// WHO 성장 기준 데이터
/// 출처: WHO Child Growth Standards (2006)
/// https://www.who.int/tools/child-growth-standards

class WHOGrowthStandards {
  /// 체중 백분위 데이터 (남아, 0-24개월)
  /// 키: 월령, 값: [P3, P15, P50, P85, P97] (kg)
  static const Map<int, List<double>> weightBoys = {
    0: [2.5, 2.9, 3.3, 3.9, 4.4],   // 0개월
    1: [3.4, 3.9, 4.5, 5.1, 5.8],   // 1개월
    2: [4.3, 4.9, 5.6, 6.3, 7.1],   // 2개월
    3: [5.0, 5.7, 6.4, 7.2, 8.0],   // 3개월
    4: [5.6, 6.2, 7.0, 7.8, 8.7],   // 4개월
    5: [6.0, 6.7, 7.5, 8.4, 9.3],   // 5개월
    6: [6.4, 7.1, 7.9, 8.8, 9.8],   // 6개월
    7: [6.7, 7.4, 8.3, 9.2, 10.3],  // 7개월
    8: [6.9, 7.7, 8.6, 9.6, 10.7],  // 8개월
    9: [7.1, 8.0, 8.9, 9.9, 11.0],  // 9개월
    10: [7.4, 8.2, 9.2, 10.2, 11.4], // 10개월
    11: [7.6, 8.4, 9.4, 10.5, 11.7], // 11개월
    12: [7.7, 8.6, 9.6, 10.8, 12.0], // 12개월
  };

  /// 체중 백분위 데이터 (여아, 0-24개월)
  static const Map<int, List<double>> weightGirls = {
    0: [2.4, 2.8, 3.2, 3.7, 4.2],   // 0개월
    1: [3.2, 3.6, 4.2, 4.8, 5.5],   // 1개월
    2: [3.9, 4.5, 5.1, 5.8, 6.6],   // 2개월
    3: [4.5, 5.2, 5.8, 6.6, 7.5],   // 3개월
    4: [5.0, 5.7, 6.4, 7.3, 8.2],   // 4개월
    5: [5.4, 6.1, 6.9, 7.8, 8.8],   // 5개월
    6: [5.7, 6.5, 7.3, 8.2, 9.3],   // 6개월
    7: [6.0, 6.8, 7.6, 8.6, 9.8],   // 7개월
    8: [6.3, 7.0, 7.9, 9.0, 10.2],  // 8개월
    9: [6.5, 7.3, 8.2, 9.3, 10.5],  // 9개월
    10: [6.7, 7.5, 8.5, 9.6, 10.9], // 10개월
    11: [6.9, 7.7, 8.7, 9.9, 11.2], // 11개월
    12: [7.0, 7.9, 8.9, 10.1, 11.5], // 12개월
  };

  /// 신장 백분위 데이터 (남아, 0-24개월, cm)
  static const Map<int, List<double>> lengthBoys = {
    0: [46.1, 48.0, 49.9, 51.8, 53.7],   // 0개월
    1: [50.8, 52.8, 54.7, 56.7, 58.6],   // 1개월
    2: [54.4, 56.4, 58.4, 60.4, 62.4],   // 2개월
    3: [57.3, 59.4, 61.4, 63.5, 65.5],   // 3개월
    6: [63.3, 65.5, 67.6, 69.8, 71.9],   // 6개월
    9: [67.7, 70.1, 72.0, 74.2, 76.5],   // 9개월
    12: [71.0, 73.4, 75.7, 78.1, 80.5],  // 12개월
  };

  /// 신장 백분위 데이터 (여아, 0-24개월, cm)
  static const Map<int, List<double>> lengthGirls = {
    0: [45.4, 47.3, 49.1, 51.0, 52.9],   // 0개월
    1: [49.8, 51.7, 53.7, 55.6, 57.6],   // 1개월
    2: [53.0, 55.0, 57.1, 59.1, 61.1],   // 2개월
    3: [55.6, 57.7, 59.8, 61.9, 64.0],   // 3개월
    6: [61.2, 63.5, 65.7, 68.0, 70.3],   // 6개월
    9: [65.3, 67.7, 70.1, 72.6, 75.0],   // 9개월
    12: [68.9, 71.4, 74.0, 76.6, 79.2],  // 12개월
  };

  /// 백분위 계산
  /// [currentValue]: 현재 값 (kg 또는 cm)
  /// [ageInMonths]: 월령
  /// [isBoy]: 남아 여부
  /// [isWeight]: 체중 여부 (false면 신장)
  ///
  /// 반환값: 백분위 (0-100)
  static int calculatePercentile({
    required double currentValue,
    required int ageInMonths,
    required bool isBoy,
    required bool isWeight,
  }) {
    // 데이터 선택
    final data = isWeight
        ? (isBoy ? weightBoys : weightGirls)
        : (isBoy ? lengthBoys : lengthGirls);

    // 해당 월령 데이터 가져오기
    if (!data.containsKey(ageInMonths)) {
      // 가장 가까운 월령 찾기
      final closestMonth = data.keys.reduce((a, b) =>
          (a - ageInMonths).abs() < (b - ageInMonths).abs() ? a : b);
      return _calculateFromData(currentValue, data[closestMonth]!);
    }

    return _calculateFromData(currentValue, data[ageInMonths]!);
  }

  /// 데이터에서 백분위 계산
  static int _calculateFromData(double value, List<double> percentiles) {
    final p3 = percentiles[0];
    final p15 = percentiles[1];
    final p50 = percentiles[2];
    final p85 = percentiles[3];
    final p97 = percentiles[4];

    if (value < p3) return 1;
    if (value < p15) return 3 + ((value - p3) / (p15 - p3) * 12).round();
    if (value < p50) return 15 + ((value - p15) / (p50 - p15) * 35).round();
    if (value < p85) return 50 + ((value - p50) / (p85 - p50) * 35).round();
    if (value < p97) return 85 + ((value - p85) / (p97 - p85) * 12).round();
    return 99;
  }

  /// 백분위 상태 판정
  static WHOGrowthStatus getGrowthStatus(int percentile) {
    if (percentile < 3) return WHOGrowthStatus.severeMalnutrition;
    if (percentile < 15) return WHOGrowthStatus.underweight;
    if (percentile >= 85) return WHOGrowthStatus.overweight;
    return WHOGrowthStatus.normal;
  }

  /// 백분위 메시지 생성
  static String getPercentileMessage({
    required int percentile,
    required bool isWeight,
    required String babyName,
  }) {
    final metric = isWeight ? '체중' : '신장';
    final status = getGrowthStatus(percentile);

    switch (status) {
      case WHOGrowthStatus.severeMalnutrition:
        return '$babyName의 $metric이 또래의 ${percentile}%보다 작아요. 소아과 상담을 권장해요.';
      case WHOGrowthStatus.underweight:
        return '$babyName의 $metric이 또래의 ${percentile}%예요. 평균보다 작지만 정상 범위예요.';
      case WHOGrowthStatus.normal:
        return '$babyName의 $metric이 또래의 ${percentile}%예요. 건강하게 자라고 있어요!';
      case WHOGrowthStatus.overweight:
        return '$babyName의 $metric이 또래의 ${percentile}%예요. 평균보다 크게 자라고 있어요!';
    }
  }
}

/// 성장 상태
enum WHOGrowthStatus {
  severeMalnutrition, // 심각한 저체중 (< 3%)
  underweight,        // 저체중 (3-15%)
  normal,            // 정상 (15-85%)
  overweight,        // 과체중 (> 85%)
}
