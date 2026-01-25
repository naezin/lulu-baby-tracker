import 'package:flutter/foundation.dart';

/// 코칭 메시지 타입
enum CoachingMessageType {
  tip,          // 일반 팁
  encouragement,// 격려
  celebration,  // 축하
  reminder,     // 리마인더
  insight,      // 인사이트
}

/// 코칭 메시지 모델
@immutable
class CoachingMessage {
  final String id;
  final CoachingMessageType type;
  final String title;
  final String body;
  final String? actionLabel;       // 액션 버튼 텍스트
  final String? actionRoute;       // 액션 라우트
  final DateTime createdAt;
  final DateTime? expiresAt;       // 만료 시간

  const CoachingMessage({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.actionLabel,
    this.actionRoute,
    required this.createdAt,
    this.expiresAt,
  });

  /// 타입별 이모지
  String get emoji {
    switch (type) {
      case CoachingMessageType.tip:
        return '💡';
      case CoachingMessageType.encouragement:
        return '💪';
      case CoachingMessageType.celebration:
        return '🎉';
      case CoachingMessageType.reminder:
        return '🔔';
      case CoachingMessageType.insight:
        return '📊';
    }
  }

  /// 만료 여부
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// 격려 메시지 생성 팩토리
  factory CoachingMessage.encouragement({
    required String babyName,
    required bool isKorean,
    required int completedNaps,
  }) {
    return CoachingMessage(
      id: 'enc_${DateTime.now().millisecondsSinceEpoch}',
      type: CoachingMessageType.encouragement,
      title: isKorean ? '잘하고 있어요! 💪' : 'You\'re doing great! 💪',
      body: isKorean
          ? '오늘 $completedNaps번의 낮잠을 성공했어요. $babyName이도 부모님도 최고예요!'
          : 'You\'ve completed $completedNaps naps today. Great job!',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 2)),
    );
  }

  /// Sweet Spot 놓침 위로 메시지
  factory CoachingMessage.missedSweetSpot({
    required bool isKorean,
  }) {
    return CoachingMessage(
      id: 'missed_${DateTime.now().millisecondsSinceEpoch}',
      type: CoachingMessageType.encouragement,
      title: isKorean ? '괜찮아요 🌙' : 'It\'s okay 🌙',
      body: isKorean
          ? 'Sweet Spot을 놓쳤어도 괜찮아요. 지금 재워도 좋아요. 다음에 또 기회가 있어요!'
          : 'Missing the Sweet Spot is okay. You can still try now. There\'s always next time!',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  /// 밤잠 성공 축하 메시지
  factory CoachingMessage.bedtimeSuccess({
    required String babyName,
    required bool isKorean,
  }) {
    return CoachingMessage(
      id: 'bedtime_${DateTime.now().millisecondsSinceEpoch}',
      type: CoachingMessageType.celebration,
      title: isKorean ? '오늘 하루 수고했어요! 🌟' : 'Great day! 🌟',
      body: isKorean
          ? '$babyName이가 잠들었어요. 부모님도 푹 쉬세요. 내일 또 함께해요!'
          : '$babyName is asleep. Get some rest too. See you tomorrow!',
      createdAt: DateTime.now(),
    );
  }
}
