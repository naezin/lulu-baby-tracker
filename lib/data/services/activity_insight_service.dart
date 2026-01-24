import '../models/activity_model.dart';
import '../../presentation/widgets/records/activity_insight_card.dart';

/// 🧠 Activity Insight Service
/// "이게 정상인가요?" 질문에 답하는 인사이트 생성
class ActivityInsightService {
  /// 수면 활동 인사이트 생성
  static ActivityInsight getSleepInsight(ActivityModel activity, int babyAgeInDays) {
    final durationMinutes = activity.durationMinutes ?? 0;

    // 나이별 권장 수면 시간 (분)
    final recommendedDuration = _getRecommendedSleepDuration(babyAgeInDays);

    if (durationMinutes == 0) {
      return ActivityInsight(
        message: '수면 시간이 기록되지 않았어요',
        type: InsightType.neutral,
      );
    }

    // 매우 긴 낮잠 (3시간 이상)
    if (durationMinutes >= 180) {
      return ActivityInsight(
        message: '긴 낮잠이에요! 밤잠에 영향을 줄 수 있으니 주의하세요.',
        type: InsightType.warning,
      );
    }

    // 매우 짧은 낮잠 (20분 미만)
    if (durationMinutes < 20) {
      return ActivityInsight(
        message: '짧은 낮잠이에요. 아기가 충분히 쉬지 못했을 수 있어요.',
        type: InsightType.concern,
      );
    }

    // 적절한 낮잠
    if (durationMinutes >= 30 && durationMinutes <= 120) {
      return ActivityInsight(
        message: '좋은 낮잠이에요! 이 정도 길이가 적당해요.',
        type: InsightType.positive,
      );
    }

    return ActivityInsight(
      message: '평균적인 낮잠 시간이에요',
      type: InsightType.neutral,
    );
  }

  /// 수유 활동 인사이트 생성
  static ActivityInsight getFeedingInsight(ActivityModel activity, int babyAgeInDays) {
    final amountMl = activity.amountMl ?? 0;

    // 나이별 권장 수유량 (ml)
    final recommendedAmount = _getRecommendedFeedingAmount(babyAgeInDays);

    if (amountMl == 0) {
      return ActivityInsight(
        message: '수유량이 기록되지 않았어요',
        type: InsightType.neutral,
      );
    }

    // 권장량의 150% 이상
    if (amountMl > recommendedAmount * 1.5) {
      return ActivityInsight(
        message: '평균보다 많이 먹었어요. 성장기일 수 있어요!',
        type: InsightType.positive,
      );
    }

    // 권장량의 50% 미만
    if (amountMl < recommendedAmount * 0.5) {
      return ActivityInsight(
        message: '평균보다 적게 먹었어요. 다음 수유 시간을 확인하세요.',
        type: InsightType.warning,
      );
    }

    // 적절한 수유량
    if (amountMl >= recommendedAmount * 0.8 && amountMl <= recommendedAmount * 1.2) {
      return ActivityInsight(
        message: '적절한 수유량이에요!',
        type: InsightType.positive,
      );
    }

    return ActivityInsight(
      message: '평균적인 수유량이에요',
      type: InsightType.neutral,
    );
  }

  /// 기저귀 활동 인사이트 생성
  static ActivityInsight getDiaperInsight(ActivityModel activity) {
    final notes = activity.notes?.toLowerCase() ?? '';

    if (notes.contains('혈변') || notes.contains('blood')) {
      return ActivityInsight(
        message: '혈변이 있어요. 소아과 상담을 권장해요.',
        type: InsightType.concern,
      );
    }

    if (notes.contains('설사') || notes.contains('diarrhea')) {
      return ActivityInsight(
        message: '설사 증상이 있어요. 수분 섭취에 주의하세요.',
        type: InsightType.warning,
      );
    }

    if (notes.contains('정상') || notes.contains('normal')) {
      return ActivityInsight(
        message: '정상 배변이에요!',
        type: InsightType.positive,
      );
    }

    return ActivityInsight(
      message: '기저귀를 교체했어요',
      type: InsightType.neutral,
    );
  }

  /// 활동(놀이) 인사이트 생성
  static ActivityInsight getPlayInsight(ActivityModel activity, int babyAgeInDays) {
    final durationMinutes = activity.durationMinutes ?? 0;

    if (durationMinutes == 0) {
      return ActivityInsight(
        message: '활동 시간이 기록되지 않았어요',
        type: InsightType.neutral,
      );
    }

    // 터미 타임 (Tummy Time)
    if (activity.notes?.toLowerCase().contains('tummy') ?? false) {
      if (durationMinutes >= 5 && babyAgeInDays < 60) {
        return ActivityInsight(
          message: '훌륭한 터미 타임이에요! 발달에 도움이 돼요.',
          type: InsightType.positive,
        );
      }
    }

    // 긴 활동 시간
    if (durationMinutes > 45) {
      return ActivityInsight(
        message: '긴 활동 시간이에요. 아기가 피곤할 수 있으니 주의하세요.',
        type: InsightType.warning,
      );
    }

    // 적절한 활동 시간
    if (durationMinutes >= 15 && durationMinutes <= 30) {
      return ActivityInsight(
        message: '적절한 활동 시간이에요!',
        type: InsightType.positive,
      );
    }

    return ActivityInsight(
      message: '아기와 즐거운 시간을 보냈어요',
      type: InsightType.neutral,
    );
  }

  /// 건강 활동 인사이트 생성
  static ActivityInsight getHealthInsight(ActivityModel activity) {
    final notes = activity.notes?.toLowerCase() ?? '';

    if (notes.contains('열') || notes.contains('fever')) {
      return ActivityInsight(
        message: '열이 있어요. 체온을 계속 확인하세요.',
        type: InsightType.concern,
      );
    }

    if (notes.contains('약') || notes.contains('medicine')) {
      return ActivityInsight(
        message: '약을 복용했어요. 복용 시간을 기억하세요.',
        type: InsightType.neutral,
      );
    }

    if (notes.contains('예방접종') || notes.contains('vaccine')) {
      return ActivityInsight(
        message: '예방접종을 했어요. 부작용에 주의하세요.',
        type: InsightType.warning,
      );
    }

    return ActivityInsight(
      message: '건강 기록이 추가되었어요',
      type: InsightType.neutral,
    );
  }

  /// 나이별 권장 수면 시간 (분)
  static int _getRecommendedSleepDuration(int ageInDays) {
    if (ageInDays < 30) return 90;  // 신생아: 1.5시간
    if (ageInDays < 90) return 60;  // 0-3개월: 1시간
    if (ageInDays < 180) return 45; // 3-6개월: 45분
    return 30;                        // 6개월+: 30분
  }

  /// 나이별 권장 수유량 (ml)
  static double _getRecommendedFeedingAmount(int ageInDays) {
    if (ageInDays < 7) return 60.0;    // 0-1주: 60ml
    if (ageInDays < 30) return 90.0;   // 1-4주: 90ml
    if (ageInDays < 60) return 120.0;  // 1-2개월: 120ml
    if (ageInDays < 90) return 150.0;  // 2-3개월: 150ml
    if (ageInDays < 180) return 180.0; // 3-6개월: 180ml
    return 210.0;                       // 6개월+: 210ml
  }
}

/// 인사이트 데이터 모델
class ActivityInsight {
  final String message;
  final InsightType type;

  ActivityInsight({
    required this.message,
    required this.type,
  });
}
