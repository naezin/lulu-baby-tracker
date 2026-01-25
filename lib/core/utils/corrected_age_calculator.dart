/// 조산아 교정 나이 계산 유틸리티
/// Fenton 성장 차트 및 WHO 성장 곡선 적용을 위한 정확한 교정 나이 계산
class CorrectedAgeCalculator {
  /// 교정 나이를 일(days) 단위로 계산
  ///
  /// 조산아의 경우 예정일을 기준으로 나이를 계산합니다.
  /// 교정은 만 2세(730일)까지만 적용됩니다.
  ///
  /// Parameters:
  /// - [birthDate]: 실제 출생일
  /// - [dueDate]: 예정일 (만삭 예정일)
  /// - [currentDate]: 현재 날짜 (기본값: DateTime.now())
  ///
  /// Returns:
  /// - 교정 나이 (일 단위)
  /// - 만 2세 이후에는 실제 나이를 반환
  static int calculateCorrectedAgeInDays({
    required DateTime birthDate,
    required DateTime dueDate,
    DateTime? currentDate,
  }) {
    final now = currentDate ?? DateTime.now();

    // 실제 나이 계산 (일 단위)
    final actualAgeInDays = now.difference(birthDate).inDays;

    // 만 2세(730일) 이후에는 교정 중단
    if (actualAgeInDays > 730) {
      return actualAgeInDays;
    }

    // 교정 나이 = 현재 날짜 - 예정일
    final correctedAgeInDays = now.difference(dueDate).inDays;

    // 음수 방지 (아직 예정일 전인 경우 0으로 처리)
    return correctedAgeInDays < 0 ? 0 : correctedAgeInDays;
  }

  /// 교정 나이를 개월과 일로 변환
  ///
  /// Parameters:
  /// - [correctedAgeInDays]: 교정 나이 (일 단위)
  ///
  /// Returns:
  /// - Map<String, int>: {'months': 개월 수, 'days': 남은 일수}
  ///
  /// Example:
  /// ```dart
  /// final result = correctedAgeToMonthsAndDays(65);
  /// print(result); // {'months': 2, 'days': 5}
  /// ```
  static Map<String, int> correctedAgeToMonthsAndDays(int correctedAgeInDays) {
    // 1개월 = 30일로 근사 계산
    final months = correctedAgeInDays ~/ 30;
    final days = correctedAgeInDays % 30;

    return {
      'months': months,
      'days': days,
    };
  }

  /// 저체중아 여부 판단
  ///
  /// WHO 기준: 2.5kg 미만을 저체중아(Low Birth Weight)로 분류
  ///
  /// Parameters:
  /// - [birthWeightKg]: 출생 체중 (kg)
  ///
  /// Returns:
  /// - true: 저체중아 (< 2.5kg)
  /// - false: 정상 체중 (>= 2.5kg)
  static bool isLowBirthWeight(double birthWeightKg) {
    return birthWeightKg < 2.5;
  }

  /// 조산아 여부 판단
  ///
  /// WHO 기준: 37주 미만 출생을 조산(Preterm)으로 분류
  ///
  /// Parameters:
  /// - [gestationalAgeWeeks]: 재태 연령 (주)
  ///
  /// Returns:
  /// - true: 조산아 (< 37주)
  /// - false: 만삭아 (>= 37주)
  static bool isPremature(int gestationalAgeWeeks) {
    return gestationalAgeWeeks < 37;
  }

  /// 교정이 필요한지 여부 판단
  ///
  /// 조건:
  /// 1. 조산아여야 함 (37주 미만)
  /// 2. 실제 나이가 만 2세(730일) 이하여야 함
  ///
  /// Parameters:
  /// - [gestationalAgeWeeks]: 재태 연령 (주)
  /// - [actualAgeInDays]: 실제 나이 (일 단위)
  ///
  /// Returns:
  /// - true: 교정 필요
  /// - false: 교정 불필요
  static bool shouldUseCorrection({
    required int gestationalAgeWeeks,
    required int actualAgeInDays,
  }) {
    // 만삭아는 교정 불필요
    if (!isPremature(gestationalAgeWeeks)) {
      return false;
    }

    // 만 2세 초과 시 교정 중단
    if (actualAgeInDays > 730) {
      return false;
    }

    return true;
  }

  /// 재태 연령을 주와 일로 변환
  ///
  /// Parameters:
  /// - [gestationalAgeDays]: 재태 연령 (일 단위)
  ///
  /// Returns:
  /// - Map<String, int>: {'weeks': 주 수, 'days': 남은 일수}
  ///
  /// Example:
  /// ```dart
  /// final result = gestationalAgeToDaysAndWeeks(252);
  /// print(result); // {'weeks': 36, 'days': 0}
  /// ```
  static Map<String, int> gestationalAgeToDaysAndWeeks(int gestationalAgeDays) {
    final weeks = gestationalAgeDays ~/ 7;
    final days = gestationalAgeDays % 7;

    return {
      'weeks': weeks,
      'days': days,
    };
  }

  /// 조산 정도 분류
  ///
  /// WHO 분류:
  /// - 극도 조산(Extremely preterm): < 28주
  /// - 매우 조산(Very preterm): 28-32주
  /// - 중등도 조산(Moderate to late preterm): 32-37주
  ///
  /// Parameters:
  /// - [gestationalAgeWeeks]: 재태 연령 (주)
  ///
  /// Returns:
  /// - PretermCategory: 조산 분류
  static PretermCategory getPretermCategory(int gestationalAgeWeeks) {
    if (gestationalAgeWeeks >= 37) {
      return PretermCategory.fullTerm;
    } else if (gestationalAgeWeeks >= 32) {
      return PretermCategory.moderateToLate;
    } else if (gestationalAgeWeeks >= 28) {
      return PretermCategory.very;
    } else {
      return PretermCategory.extremely;
    }
  }

  /// 교정 나이 표시 문자열 생성
  ///
  /// Parameters:
  /// - [correctedAgeInDays]: 교정 나이 (일 단위)
  ///
  /// Returns:
  /// - String: "N개월 M일" 형식의 문자열
  ///
  /// Example:
  /// ```dart
  /// final label = getCorrectedAgeLabel(65);
  /// print(label); // "2개월 5일"
  /// ```
  static String getCorrectedAgeLabel(int correctedAgeInDays) {
    final age = correctedAgeToMonthsAndDays(correctedAgeInDays);

    if (age['months']! == 0) {
      return '${age['days']}일';
    } else if (age['days']! == 0) {
      return '${age['months']}개월';
    } else {
      return '${age['months']}개월 ${age['days']}일';
    }
  }

  /// Fenton 차트 적용 가능 여부 확인
  ///
  /// Fenton 2013 차트는 재태 22-50주에 적용 가능합니다.
  ///
  /// Parameters:
  /// - [gestationalAgeWeeks]: 재태 연령 (주)
  ///
  /// Returns:
  /// - true: Fenton 차트 적용 가능 (22-50주)
  /// - false: Fenton 차트 적용 불가
  static bool canUseFentonChart(int gestationalAgeWeeks) {
    return gestationalAgeWeeks >= 22 && gestationalAgeWeeks <= 50;
  }
}

/// 조산 정도 분류 열거형
enum PretermCategory {
  /// 만삭아 (>= 37주)
  fullTerm,

  /// 중등도-후기 조산 (32-36주)
  moderateToLate,

  /// 매우 조산 (28-31주)
  very,

  /// 극도 조산 (< 28주)
  extremely,
}

/// PretermCategory 확장 메서드
extension PretermCategoryExtension on PretermCategory {
  /// 한글 라벨
  String get label {
    switch (this) {
      case PretermCategory.fullTerm:
        return '만삭아';
      case PretermCategory.moderateToLate:
        return '중등도-후기 조산';
      case PretermCategory.very:
        return '매우 조산';
      case PretermCategory.extremely:
        return '극도 조산';
    }
  }

  /// 영문 라벨
  String get englishLabel {
    switch (this) {
      case PretermCategory.fullTerm:
        return 'Full Term';
      case PretermCategory.moderateToLate:
        return 'Moderate to Late Preterm';
      case PretermCategory.very:
        return 'Very Preterm';
      case PretermCategory.extremely:
        return 'Extremely Preterm';
    }
  }

  /// 위험도 (1-4, 높을수록 위험)
  int get riskLevel {
    switch (this) {
      case PretermCategory.fullTerm:
        return 0;
      case PretermCategory.moderateToLate:
        return 1;
      case PretermCategory.very:
        return 2;
      case PretermCategory.extremely:
        return 3;
    }
  }
}
