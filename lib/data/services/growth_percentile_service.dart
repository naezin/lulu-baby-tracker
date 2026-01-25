import '../constants/who_growth_data.dart';

/// 성장 측정 지표
enum GrowthMetric {
  weight,           // 체중
  length,           // 신장
  headCircumference // 머리둘레
}

/// 성별
enum Gender {
  male,   // 남아
  female  // 여아
}

/// 성장 상태 평가 결과
enum GrowthStatus {
  severelyUnderweight,  // 심각한 저체중 (< p3)
  underweight,          // 저체중 (p3-p15)
  normal,               // 정상 (p15-p85)
  overweight,           // 과체중 (p85-p97)
  severelyOverweight    // 심각한 과체중 (> p97)
}

/// WHO 성장 기준 백분위수 계산 서비스
///
/// 아기의 체중, 신장, 머리둘레를 WHO 표준 성장 곡선과 비교하여
/// 백분위수를 계산하고 성장 상태를 평가합니다.
class GrowthPercentileService {

  /// 특정 월령과 측정값에 대한 백분위수 계산
  ///
  /// [ageInMonths]: 아기 월령 (0-24개월)
  /// [value]: 측정값 (kg, cm)
  /// [metric]: 측정 지표 (체중, 신장, 머리둘레)
  /// [gender]: 성별
  ///
  /// Returns: 백분위수 (0-100), 데이터가 없으면 null
  double? calculatePercentile({
    required int ageInMonths,
    required double value,
    required GrowthMetric metric,
    required Gender gender,
  }) {
    if (ageInMonths < 0 || ageInMonths > 24) {
      return null;
    }

    final standardValues = _getStandardValues(metric, gender);
    if (standardValues == null || !standardValues.containsKey(ageInMonths)) {
      return null;
    }

    final percentiles = standardValues[ageInMonths]!;

    // 측정값이 범위를 벗어난 경우
    if (value < percentiles['p3']!) {
      return _extrapolateBelow(value, percentiles['p3']!);
    }
    if (value > percentiles['p97']!) {
      return _extrapolateAbove(value, percentiles['p97']!);
    }

    // 선형 보간으로 백분위수 계산
    return _interpolatePercentile(value, percentiles);
  }

  /// 특정 백분위수에 해당하는 측정값 계산
  ///
  /// [ageInMonths]: 아기 월령 (0-24개월)
  /// [percentile]: 백분위수 (0-100)
  /// [metric]: 측정 지표
  /// [gender]: 성별
  ///
  /// Returns: 해당 백분위수의 측정값, 데이터가 없으면 null
  double? getValueAtPercentile({
    required int ageInMonths,
    required double percentile,
    required GrowthMetric metric,
    required Gender gender,
  }) {
    if (ageInMonths < 0 || ageInMonths > 24) {
      return null;
    }
    if (percentile < 0 || percentile > 100) {
      return null;
    }

    final standardValues = _getStandardValues(metric, gender);
    if (standardValues == null || !standardValues.containsKey(ageInMonths)) {
      return null;
    }

    final percentiles = standardValues[ageInMonths]!;

    // 표준 백분위수 값 직접 반환
    if (percentile == 3) return percentiles['p3'];
    if (percentile == 15) return percentiles['p15'];
    if (percentile == 50) return percentiles['p50'];
    if (percentile == 85) return percentiles['p85'];
    if (percentile == 97) return percentiles['p97'];

    // 선형 보간으로 중간값 계산
    return _interpolateValue(percentile, percentiles);
  }

  /// 성장 상태 평가
  ///
  /// [ageInMonths]: 아기 월령
  /// [value]: 측정값
  /// [metric]: 측정 지표
  /// [gender]: 성별
  ///
  /// Returns: 성장 상태 평가 결과
  GrowthStatus? evaluateGrowthStatus({
    required int ageInMonths,
    required double value,
    required GrowthMetric metric,
    required Gender gender,
  }) {
    final percentile = calculatePercentile(
      ageInMonths: ageInMonths,
      value: value,
      metric: metric,
      gender: gender,
    );

    if (percentile == null) return null;

    if (percentile < 3) {
      return GrowthStatus.severelyUnderweight;
    } else if (percentile < 15) {
      return GrowthStatus.underweight;
    } else if (percentile <= 85) {
      return GrowthStatus.normal;
    } else if (percentile <= 97) {
      return GrowthStatus.overweight;
    } else {
      return GrowthStatus.severelyOverweight;
    }
  }

  /// 성장 상태에 대한 한글 설명 반환
  String getStatusDescription(GrowthStatus status) {
    switch (status) {
      case GrowthStatus.severelyUnderweight:
        return '심각한 저체중';
      case GrowthStatus.underweight:
        return '저체중';
      case GrowthStatus.normal:
        return '정상';
      case GrowthStatus.overweight:
        return '과체중';
      case GrowthStatus.severelyOverweight:
        return '심각한 과체중';
    }
  }

  // ==================== Private Methods ====================

  /// 측정 지표와 성별에 따른 표준 데이터 반환
  Map<int, Map<String, double>>? _getStandardValues(
    GrowthMetric metric,
    Gender gender,
  ) {
    switch (metric) {
      case GrowthMetric.weight:
        return gender == Gender.male
            ? WHOGrowthData.weightForAgeBoys
            : WHOGrowthData.weightForAgeGirls;
      case GrowthMetric.length:
        return gender == Gender.male
            ? WHOGrowthData.lengthForAgeBoys
            : WHOGrowthData.lengthForAgeGirls;
      case GrowthMetric.headCircumference:
        return gender == Gender.male
            ? WHOGrowthData.headCircumferenceBoys
            : WHOGrowthData.headCircumferenceGirls;
    }
  }

  /// 선형 보간으로 백분위수 계산
  ///
  /// p3, p15, p50, p85, p97 사이의 값을 선형 보간하여 계산
  double _interpolatePercentile(
    double value,
    Map<String, double> percentiles,
  ) {
    final p3 = percentiles['p3']!;
    final p15 = percentiles['p15']!;
    final p50 = percentiles['p50']!;
    final p85 = percentiles['p85']!;
    final p97 = percentiles['p97']!;

    // 어느 구간에 속하는지 찾아서 선형 보간
    if (value <= p15) {
      return _linearInterpolate(value, p3, p15, 3, 15);
    } else if (value <= p50) {
      return _linearInterpolate(value, p15, p50, 15, 50);
    } else if (value <= p85) {
      return _linearInterpolate(value, p50, p85, 50, 85);
    } else {
      return _linearInterpolate(value, p85, p97, 85, 97);
    }
  }

  /// 선형 보간으로 측정값 계산
  double _interpolateValue(
    double percentile,
    Map<String, double> percentiles,
  ) {
    final p3 = percentiles['p3']!;
    final p15 = percentiles['p15']!;
    final p50 = percentiles['p50']!;
    final p85 = percentiles['p85']!;
    final p97 = percentiles['p97']!;

    // 어느 구간에 속하는지 찾아서 선형 보간
    if (percentile <= 15) {
      return _linearInterpolate(percentile, 3, 15, p3, p15);
    } else if (percentile <= 50) {
      return _linearInterpolate(percentile, 15, 50, p15, p50);
    } else if (percentile <= 85) {
      return _linearInterpolate(percentile, 50, 85, p50, p85);
    } else {
      return _linearInterpolate(percentile, 85, 97, p85, p97);
    }
  }

  /// 선형 보간 공식
  ///
  /// x가 [x1, x2] 사이에 있을 때, 대응하는 y 값을 [y1, y2] 사이에서 계산
  double _linearInterpolate(
    double x,
    double x1,
    double x2,
    double y1,
    double y2,
  ) {
    if (x2 == x1) return y1; // 0으로 나누기 방지
    return y1 + (x - x1) * (y2 - y1) / (x2 - x1);
  }

  /// p3 미만 값에 대한 외삽 (최대 0백분위수)
  double _extrapolateBelow(double value, double p3Value) {
    // 간단한 선형 외삽: p3보다 아래는 0에 가까운 값
    final diff = p3Value - value;
    final percentile = 3.0 - (diff / p3Value) * 3.0;
    return percentile.clamp(0.0, 3.0);
  }

  /// p97 초과 값에 대한 외삽 (최대 100백분위수)
  double _extrapolateAbove(double value, double p97Value) {
    // 간단한 선형 외삽: p97보다 위는 100에 가까운 값
    final diff = value - p97Value;
    final percentile = 97.0 + (diff / p97Value) * 3.0;
    return percentile.clamp(97.0, 100.0);
  }
}
