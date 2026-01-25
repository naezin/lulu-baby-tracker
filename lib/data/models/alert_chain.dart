import 'package:flutter/foundation.dart';
import 'scheduled_alert.dart';

/// 알림 체인 타입
enum AlertChainType {
  bedtime,      // 밤잠 체인 (막수 → 루틴 → Sweet Spot)
  nap,          // 낮잠 체인 (준비 → Sweet Spot)
  feeding,      // 수유 체인 (예상 시간 알림)
  custom,       // 사용자 정의
}

/// 알림 체인 모델
/// 연속된 알림을 하나의 그룹으로 관리
@immutable
class AlertChain {
  final String id;
  final AlertChainType type;
  final String name;
  final DateTime anchorTime;          // 기준 시간 (예: Sweet Spot 시간)
  final List<ScheduledAlert> alerts;  // 체인 내 알림들
  final bool isActive;
  final DateTime createdAt;

  const AlertChain({
    required this.id,
    required this.type,
    required this.name,
    required this.anchorTime,
    required this.alerts,
    this.isActive = true,
    required this.createdAt,
  });

  /// 밤잠 체인 생성 팩토리
  /// T-60분: 저녁 루틴, T-45분: 막수, T-15분: 수면 루틴, T-0분: Sweet Spot
  factory AlertChain.bedtime({
    required DateTime sweetSpotTime,
    required String babyName,
    required bool isKorean,
  }) {
    final id = 'bedtime_${sweetSpotTime.millisecondsSinceEpoch}';

    return AlertChain(
      id: id,
      type: AlertChainType.bedtime,
      name: isKorean ? '밤잠 준비' : 'Bedtime Routine',
      anchorTime: sweetSpotTime,
      alerts: [
        ScheduledAlert(
          id: '${id}_60',
          chainId: id,
          type: AlertType.routine,
          offsetMinutes: -60,
          title: isKorean ? '🛁 저녁 루틴 시작' : '🛁 Start Evening Routine',
          body: isKorean
              ? '$babyName이의 목욕/마사지 시간이에요'
              : 'Time for $babyName\'s bath/massage',
          priority: AlertPriority.low,
        ),
        ScheduledAlert(
          id: '${id}_45',
          chainId: id,
          type: AlertType.feeding,
          offsetMinutes: -45,
          title: isKorean ? '🍼 막수 시작' : '🍼 Last Feed',
          body: isKorean
              ? '마지막 수유를 시작하세요. 충분히 먹이면 밤잠이 길어져요!'
              : 'Start the last feed. A full tummy means longer sleep!',
          priority: AlertPriority.medium,
        ),
        ScheduledAlert(
          id: '${id}_15',
          chainId: id,
          type: AlertType.routine,
          offsetMinutes: -15,
          title: isKorean ? '🌙 수면 루틴 시작' : '🌙 Start Sleep Routine',
          body: isKorean
              ? '조명을 어둡게 하고 자장가를 불러주세요'
              : 'Dim the lights and start the lullaby',
          priority: AlertPriority.high,
        ),
        ScheduledAlert(
          id: '${id}_0',
          chainId: id,
          type: AlertType.sweetSpot,
          offsetMinutes: 0,
          title: isKorean ? '✨ Sweet Spot!' : '✨ Sweet Spot!',
          body: isKorean
              ? '지금이 $babyName이를 재우기 가장 좋은 시간이에요!'
              : 'Perfect time to put $babyName to sleep!',
          priority: AlertPriority.critical,
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  /// 낮잠 체인 생성 팩토리
  /// T-15분: 준비, T-5분: 졸림 신호, T-0분: Sweet Spot
  factory AlertChain.nap({
    required DateTime sweetSpotTime,
    required String babyName,
    required bool isKorean,
    required int napNumber,  // 몇 번째 낮잠인지
  }) {
    final id = 'nap${napNumber}_${sweetSpotTime.millisecondsSinceEpoch}';
    final napLabel = isKorean ? '$napNumber번째 낮잠' : 'Nap #$napNumber';

    return AlertChain(
      id: id,
      type: AlertChainType.nap,
      name: napLabel,
      anchorTime: sweetSpotTime,
      alerts: [
        ScheduledAlert(
          id: '${id}_15',
          chainId: id,
          type: AlertType.routine,
          offsetMinutes: -15,
          title: isKorean ? '💤 낮잠 준비' : '💤 Nap Time Soon',
          body: isKorean
              ? '$napLabel 시간이 다가오고 있어요'
              : '$napLabel is coming up',
          priority: AlertPriority.medium,
        ),
        ScheduledAlert(
          id: '${id}_5',
          chainId: id,
          type: AlertType.tip,
          offsetMinutes: -5,
          title: isKorean ? '👀 졸림 신호 확인' : '👀 Watch for Sleep Cues',
          body: isKorean
              ? '하품, 눈 비비기, 칭얼거림을 확인하세요'
              : 'Look for yawning, eye rubbing, or fussiness',
          priority: AlertPriority.medium,
        ),
        ScheduledAlert(
          id: '${id}_0',
          chainId: id,
          type: AlertType.sweetSpot,
          offsetMinutes: 0,
          title: isKorean ? '✨ 낮잠 Sweet Spot!' : '✨ Nap Sweet Spot!',
          body: isKorean
              ? '지금 $babyName이를 재워보세요!'
              : 'Time to put $babyName down for a nap!',
          priority: AlertPriority.high,
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  /// 수유 체인 생성 팩토리
  factory AlertChain.feeding({
    required DateTime expectedFeedingTime,
    required String babyName,
    required bool isKorean,
  }) {
    final id = 'feeding_${expectedFeedingTime.millisecondsSinceEpoch}';

    return AlertChain(
      id: id,
      type: AlertChainType.feeding,
      name: isKorean ? '수유 시간' : 'Feeding Time',
      anchorTime: expectedFeedingTime,
      alerts: [
        ScheduledAlert(
          id: '${id}_15',
          chainId: id,
          type: AlertType.feeding,
          offsetMinutes: -15,
          title: isKorean ? '🍼 수유 시간 다가옴' : '🍼 Feeding Time Soon',
          body: isKorean
              ? '15분 후 수유 시간이에요'
              : 'Feeding time in 15 minutes',
          priority: AlertPriority.low,
        ),
        ScheduledAlert(
          id: '${id}_0',
          chainId: id,
          type: AlertType.feeding,
          offsetMinutes: 0,
          title: isKorean ? '🍼 수유 시간' : '🍼 Feeding Time',
          body: isKorean
              ? '$babyName이 배고플 시간이에요'
              : '$babyName might be getting hungry',
          priority: AlertPriority.medium,
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  /// 다음 알림 가져오기
  ScheduledAlert? get nextAlert {
    final now = DateTime.now();
    final upcomingAlerts = alerts
        .map((a) => MapEntry(a, anchorTime.add(Duration(minutes: a.offsetMinutes))))
        .where((entry) => entry.value.isAfter(now))
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return upcomingAlerts.isNotEmpty ? upcomingAlerts.first.key : null;
  }

  /// 알림 실제 시간 계산
  DateTime getAlertTime(ScheduledAlert alert) {
    return anchorTime.add(Duration(minutes: alert.offsetMinutes));
  }

  AlertChain copyWith({
    String? id,
    AlertChainType? type,
    String? name,
    DateTime? anchorTime,
    List<ScheduledAlert>? alerts,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AlertChain(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      anchorTime: anchorTime ?? this.anchorTime,
      alerts: alerts ?? this.alerts,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
