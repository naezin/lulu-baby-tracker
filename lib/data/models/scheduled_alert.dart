import 'package:flutter/foundation.dart';

/// 알림 타입
enum AlertType {
  sweetSpot,    // Sweet Spot 알림
  feeding,      // 수유 알림
  routine,      // 루틴 알림 (목욕, 수면 의식 등)
  tip,          // 팁/조언 알림
  celebration,  // 성취 축하 알림
  reminder,     // 일반 리마인더
}

/// 알림 우선순위
enum AlertPriority {
  low,       // 무시 가능
  medium,    // 일반
  high,      // 중요
  critical,  // 놓치면 안 됨
}

/// 개별 알림 모델
@immutable
class ScheduledAlert {
  final String id;
  final String chainId;           // 소속 체인 ID
  final AlertType type;
  final int offsetMinutes;        // 기준 시간으로부터 오프셋 (음수: 이전, 양수: 이후)
  final String title;
  final String body;
  final AlertPriority priority;
  final Map<String, dynamic>? actionPayload;  // 딥링크 등 액션 데이터
  final bool isSent;              // 발송 여부
  final DateTime? sentAt;         // 발송 시간

  const ScheduledAlert({
    required this.id,
    required this.chainId,
    required this.type,
    required this.offsetMinutes,
    required this.title,
    required this.body,
    required this.priority,
    this.actionPayload,
    this.isSent = false,
    this.sentAt,
  });

  /// 알림 아이콘
  String get emoji {
    switch (type) {
      case AlertType.sweetSpot:
        return '✨';
      case AlertType.feeding:
        return '🍼';
      case AlertType.routine:
        return '🌙';
      case AlertType.tip:
        return '💡';
      case AlertType.celebration:
        return '🎉';
      case AlertType.reminder:
        return '🔔';
    }
  }

  /// 오프셋 텍스트 (예: "15분 전", "지금")
  String getOffsetText({required bool isKorean}) {
    if (offsetMinutes == 0) {
      return isKorean ? '지금' : 'Now';
    } else if (offsetMinutes < 0) {
      return isKorean
          ? '${-offsetMinutes}분 전'
          : '${-offsetMinutes}min before';
    } else {
      return isKorean
          ? '${offsetMinutes}분 후'
          : '${offsetMinutes}min after';
    }
  }

  ScheduledAlert copyWith({
    String? id,
    String? chainId,
    AlertType? type,
    int? offsetMinutes,
    String? title,
    String? body,
    AlertPriority? priority,
    Map<String, dynamic>? actionPayload,
    bool? isSent,
    DateTime? sentAt,
  }) {
    return ScheduledAlert(
      id: id ?? this.id,
      chainId: chainId ?? this.chainId,
      type: type ?? this.type,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      title: title ?? this.title,
      body: body ?? this.body,
      priority: priority ?? this.priority,
      actionPayload: actionPayload ?? this.actionPayload,
      isSent: isSent ?? this.isSent,
      sentAt: sentAt ?? this.sentAt,
    );
  }
}
