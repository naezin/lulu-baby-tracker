import '../../data/models/activity_model.dart';
import 'insight_calculator.dart';

/// 🎯 SmartCTADecider - 맥락 기반 CTA 결정 로직
///
/// **목적**: 방금 기록한 활동과 오늘의 기록 현황에 따라
/// 사용자에게 가장 도움이 될 다음 액션을 제안
///
/// **우선순위**:
/// 1. 수면 → 수유 (깨어난 후 배고픔)
/// 2. 수유 → 기저귀 (수유 후 배변)
/// 3. 기저귀 → 놀이/산책 (기저귀 갈고 활동)
/// 4. 기본: 분석 화면 보기
class SmartCTADecider {
  /// 🎯 다음 액션 결정
  static SmartCTA? decide({
    required ActivityType lastActivity,
    required TodayInsightData todayData,
  }) {
    // 1. 수면 완료 → 수유 제안
    if (lastActivity == ActivityType.sleep) {
      return SmartCTA(
        text: '수유 기록하기',
        route: '/log/feeding',
        reason: '방금 일어났으니 배가 고플 수 있어요',
      );
    }

    // 2. 수유 완료 → 기저귀 제안
    if (lastActivity == ActivityType.feeding) {
      return SmartCTA(
        text: '기저귀 확인하기',
        route: '/log/diaper',
        reason: '수유 후에는 기저귀를 확인해주세요',
      );
    }

    // 3. 기저귀 교체 → 놀이 제안
    if (lastActivity == ActivityType.diaper) {
      return SmartCTA(
        text: '놀이 시간 기록하기',
        route: '/log/play',
        reason: '기저귀를 갈고 즐거운 시간을 보내세요',
      );
    }

    // 4. 놀이 완료 → 수유 제안
    if (lastActivity == ActivityType.play) {
      return SmartCTA(
        text: '수유 기록하기',
        route: '/log/feeding',
        reason: '활동 후에는 배가 고플 수 있어요',
      );
    }

    // 7. 기본: 분석 화면 보기 (모든 기록 확인)
    return SmartCTA(
      text: '분석 화면 보기',
      route: '/analysis',
      reason: '오늘의 기록을 한눈에 확인해보세요',
    );
  }
}

/// 🎯 Smart CTA 데이터
class SmartCTA {
  final String text;
  final String route;
  final String reason;

  SmartCTA({
    required this.text,
    required this.route,
    required this.reason,
  });
}
