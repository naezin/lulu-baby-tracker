import 'package:flutter/foundation.dart';

/// 알림 권한 상태
enum NotificationPermission {
  granted,    // 허용됨
  denied,     // 거부됨
  notAsked,   // 아직 요청 안 함
}

/// 알림 상태 모델
@immutable
class NotificationState {
  final bool isEnabled;
  final DateTime? scheduledTime;
  final int minutesBefore;
  final NotificationPermission permission;

  const NotificationState({
    this.isEnabled = false,
    this.scheduledTime,
    this.minutesBefore = 15,
    this.permission = NotificationPermission.notAsked,
  });

  /// 알림 표시 가능 여부
  bool get canShowNotification =>
      isEnabled && permission == NotificationPermission.granted;

  /// 알림 예약 상태 메시지
  String getStatusMessage({required bool isKorean}) {
    if (!isEnabled) {
      return isKorean
          ? '🔕 알림을 켜면 Sweet Spot을 놓치지 않아요'
          : '🔕 Turn on alerts to never miss a Sweet Spot';
    }

    if (permission == NotificationPermission.denied) {
      return isKorean
          ? '🔔 알림 권한을 허용해주세요'
          : '🔔 Please allow notification permission';
    }

    if (scheduledTime == null) {
      return isKorean
          ? '🔔 다음 Sweet Spot에 알림 예정'
          : '🔔 Alert scheduled for next Sweet Spot';
    }

    final timeStr = _formatTime(scheduledTime!);
    return isKorean
        ? '🔔 $timeStr에 알려드릴게요'
        : '🔔 We\'ll notify you at $timeStr';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  NotificationState copyWith({
    bool? isEnabled,
    DateTime? scheduledTime,
    int? minutesBefore,
    NotificationPermission? permission,
  }) {
    return NotificationState(
      isEnabled: isEnabled ?? this.isEnabled,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      minutesBefore: minutesBefore ?? this.minutesBefore,
      permission: permission ?? this.permission,
    );
  }
}
