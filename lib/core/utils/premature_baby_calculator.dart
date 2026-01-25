import '../../../data/models/baby_model.dart';

/// 조산아 관련 계산 유틸리티
class PrematureBabyCalculator {
  /// 교정 나이(Corrected Age) 계산
  /// 조산아의 경우 예정일 기준으로 나이를 계산
  static int calculateCorrectedAgeInMonths(BabyModel baby) {
    if (!baby.isPremature || baby.dueDate == null) {
      // 일반 아기는 실제 나이 반환
      return baby.ageInMonths;
    }

    final dueDate = DateTime.parse(baby.dueDate!);
    final now = DateTime.now();

    // 예정일 기준으로 개월 수 계산
    final correctedMonths = ((now.year - dueDate.year) * 12 +
                            now.month - dueDate.month);

    return correctedMonths.clamp(0, 999); // 음수 방지
  }

  /// 교정 나이 vs 실제 나이 차이 (주 단위)
  static int getAgeGapInWeeks(BabyModel baby) {
    if (!baby.isPremature || baby.dueDate == null) {
      return 0;
    }

    final birthDate = DateTime.parse(baby.birthDate);
    final dueDate = DateTime.parse(baby.dueDate!);

    final gapDays = dueDate.difference(birthDate).inDays;
    return (gapDays / 7).round();
  }

  /// 저체중아 여부 판단 (출생 체중 기준)
  /// - 2.5kg 미만: 저체중아 (Low Birth Weight)
  /// - 1.5kg 미만: 극소 저체중아 (Very Low Birth Weight)
  /// - 1.0kg 미만: 초극소 저체중아 (Extremely Low Birth Weight)
  static LowBirthWeightCategory getLowBirthWeightCategory(double birthWeightKg) {
    if (birthWeightKg < 1.0) {
      return LowBirthWeightCategory.extremelyLow;
    } else if (birthWeightKg < 1.5) {
      return LowBirthWeightCategory.veryLow;
    } else if (birthWeightKg < 2.5) {
      return LowBirthWeightCategory.low;
    } else {
      return LowBirthWeightCategory.normal;
    }
  }

  /// 조산아 추적 관찰 권장 기간 (개월)
  /// 미숙아는 교정 2세(24개월)까지 발달 추적 필요
  static bool needsSpecialMonitoring(BabyModel baby) {
    if (!baby.isPremature) return false;

    final correctedMonths = calculateCorrectedAgeInMonths(baby);
    return correctedMonths < 24; // 교정 2세까지
  }

  /// 교정 나이 표시 문구 생성
  static String getCorrectedAgeLabel(BabyModel baby) {
    if (!baby.isPremature || baby.dueDate == null) {
      return '';
    }

    final actualMonths = baby.ageInMonths;
    final correctedMonths = calculateCorrectedAgeInMonths(baby);
    final gapWeeks = getAgeGapInWeeks(baby);

    if (correctedMonths < 0) {
      // 아직 예정일 전
      return '예정일까지 ${-correctedMonths}개월 남음';
    }

    return '교정 ${correctedMonths}개월 (실제 ${actualMonths}개월, ${gapWeeks}주 조산)';
  }

  /// 저체중아 특별 케어 가이드
  static List<CareGuide> getCareGuides(BabyModel baby, double birthWeightKg) {
    final category = getLowBirthWeightCategory(birthWeightKg);
    final guides = <CareGuide>[];

    if (category == LowBirthWeightCategory.normal) {
      return guides; // 정상 체중이면 빈 리스트 반환
    }

    // 공통 가이드
    guides.addAll([
      CareGuide(
        icon: '🍼',
        title: '빈번한 수유',
        description: '2-3시간마다 수유하여 충분한 영양 공급',
        priority: CareGuidePriority.high,
      ),
      CareGuide(
        icon: '🌡️',
        title: '체온 유지',
        description: '실내 온도 24-26℃ 유지, 따뜻하게 입히기',
        priority: CareGuidePriority.high,
      ),
      CareGuide(
        icon: '📊',
        title: '체중 모니터링',
        description: '주 2-3회 체중 측정 및 기록',
        priority: CareGuidePriority.high,
      ),
    ]);

    // 카테고리별 추가 가이드
    if (category == LowBirthWeightCategory.veryLow ||
        category == LowBirthWeightCategory.extremelyLow) {
      guides.addAll([
        CareGuide(
          icon: '👨‍⚕️',
          title: '정기 검진',
          description: '소아과 전문의와 긴밀한 협진 필요',
          priority: CareGuidePriority.critical,
        ),
        CareGuide(
          icon: '👀',
          title: '발달 관찰',
          description: '시력, 청력, 운동 발달 정기 검사',
          priority: CareGuidePriority.high,
        ),
      ]);
    }

    return guides;
  }

  /// 위험 신호 체크리스트
  static List<String> getWarningSignsChecklist() {
    return [
      '24시간 동안 수유를 거부하는 경우',
      '호흡이 불규칙하거나 숨을 헐떡이는 경우',
      '피부색이 창백하거나 청색증이 보이는 경우',
      '지속적인 구토나 설사',
      '38℃ 이상의 고열',
      '처지고 기운이 없는 경우',
      '경련이나 떨림',
      '체중이 계속 줄어드는 경우',
    ];
  }
}

/// 저체중아 분류
enum LowBirthWeightCategory {
  normal,        // 2.5kg 이상
  low,          // 1.5-2.5kg (저체중아)
  veryLow,      // 1.0-1.5kg (극소 저체중아)
  extremelyLow, // 1.0kg 미만 (초극소 저체중아)
}

/// 케어 가이드 우선순위
enum CareGuidePriority {
  normal,   // 일반
  high,     // 중요
  critical, // 매우 중요
}

/// 케어 가이드 모델
class CareGuide {
  final String icon;
  final String title;
  final String description;
  final CareGuidePriority priority;

  CareGuide({
    required this.icon,
    required this.title,
    required this.description,
    required this.priority,
  });
}
