import 'package:flutter/material.dart';

/// 깨시(Awake Time) 계산기
/// 아기의 월령에 따라 권장 깨시와 과자극 위험도를 계산
class AwakeTimeCalculator {
  /// 월령별 권장 깨시 범위 (분)
  static Map<int, AwakeTimeRange> get ageRanges => {
        // 0-1개월: 30-60분
        0: AwakeTimeRange(min: 30, max: 60, optimal: 45),
        // 1-2개월: 45-75분
        1: AwakeTimeRange(min: 45, max: 75, optimal: 60),
        // 2-3개월: 60-90분 (72일령은 여기)
        2: AwakeTimeRange(min: 60, max: 90, optimal: 75),
        // 3-4개월: 75-120분
        3: AwakeTimeRange(min: 75, max: 120, optimal: 90),
        // 4-6개월: 120-150분
        4: AwakeTimeRange(min: 120, max: 150, optimal: 135),
        5: AwakeTimeRange(min: 120, max: 150, optimal: 135),
        // 6-8개월: 150-180분
        6: AwakeTimeRange(min: 150, max: 180, optimal: 165),
        7: AwakeTimeRange(min: 150, max: 180, optimal: 165),
        // 8-12개월: 180-240분
        8: AwakeTimeRange(min: 180, max: 240, optimal: 210),
        9: AwakeTimeRange(min: 180, max: 240, optimal: 210),
        10: AwakeTimeRange(min: 180, max: 240, optimal: 210),
        11: AwakeTimeRange(min: 180, max: 240, optimal: 210),
      };

  /// 현재 깨시 계산
  static AwakeTimeResult calculateAwakeTime({
    required DateTime lastWakeUpTime,
    required int ageInMonths,
    DateTime? now,
  }) {
    now ??= DateTime.now();
    final awakeMinutes = now.difference(lastWakeUpTime).inMinutes;
    final range = ageRanges[ageInMonths] ?? AwakeTimeRange(min: 60, max: 90, optimal: 75);

    // 상태 판단
    AwakeTimeStatus status;
    if (awakeMinutes < range.min) {
      status = AwakeTimeStatus.tooEarly;
    } else if (awakeMinutes >= range.min && awakeMinutes <= range.optimal) {
      status = AwakeTimeStatus.optimal;
    } else if (awakeMinutes > range.optimal && awakeMinutes <= range.max) {
      status = AwakeTimeStatus.approaching;
    } else {
      status = AwakeTimeStatus.overtired;
    }

    return AwakeTimeResult(
      awakeMinutes: awakeMinutes,
      range: range,
      status: status,
      lastWakeUpTime: lastWakeUpTime,
      ageInMonths: ageInMonths,
    );
  }
}

/// 깨시 범위
class AwakeTimeRange {
  final int min; // 최소 권장 시간 (분)
  final int max; // 최대 권장 시간 (분)
  final int optimal; // 최적 시간 (분)

  AwakeTimeRange({
    required this.min,
    required this.max,
    required this.optimal,
  });

  String get displayRange => '${min}-${max}분';
}

/// 깨시 상태
enum AwakeTimeStatus {
  tooEarly, // 너무 이름
  optimal, // 최적
  approaching, // 수면 시간 접근 중
  overtired, // 과자극 (너무 오래 깨어있음)
}

/// 깨시 계산 결과
class AwakeTimeResult {
  final int awakeMinutes;
  final AwakeTimeRange range;
  final AwakeTimeStatus status;
  final DateTime lastWakeUpTime;
  final int ageInMonths;

  AwakeTimeResult({
    required this.awakeMinutes,
    required this.range,
    required this.status,
    required this.lastWakeUpTime,
    required this.ageInMonths,
  });

  /// 최적 시간까지 남은 시간 (분)
  int get minutesUntilOptimal => range.optimal - awakeMinutes;

  /// 최대 시간까지 남은 시간 (분)
  int get minutesUntilMax => range.max - awakeMinutes;

  /// 진행률 (0.0 ~ 1.0)
  double get progress {
    if (awakeMinutes <= 0) return 0.0;
    if (awakeMinutes >= range.max) return 1.0;
    return awakeMinutes / range.max;
  }

  /// 사용자 친화적 메시지
  String get userFriendlyMessage {
    switch (status) {
      case AwakeTimeStatus.tooEarly:
        return '아직 깨어난 지 얼마 안 됐어요';
      case AwakeTimeStatus.optimal:
        return '놀이 시간에 최적인 상태예요';
      case AwakeTimeStatus.approaching:
        return '곧 수면 신호를 보일 수 있어요';
      case AwakeTimeStatus.overtired:
        return '지금 재우는 게 좋아요';
    }
  }

  /// 상태별 컬러
  Color get statusColor {
    switch (status) {
      case AwakeTimeStatus.tooEarly:
        return const Color(0xFF7BB8E8); // 파란색
      case AwakeTimeStatus.optimal:
        return const Color(0xFF5FB37B); // 초록색
      case AwakeTimeStatus.approaching:
        return const Color(0xFFE8B87E); // 주황색
      case AwakeTimeStatus.overtired:
        return const Color(0xFFE87878); // 빨간색
    }
  }

  /// 아이콘
  IconData get icon {
    switch (status) {
      case AwakeTimeStatus.tooEarly:
        return Icons.bedtime_outlined;
      case AwakeTimeStatus.optimal:
        return Icons.toys_outlined;
      case AwakeTimeStatus.approaching:
        return Icons.access_time_rounded;
      case AwakeTimeStatus.overtired:
        return Icons.warning_rounded;
    }
  }

  /// 이모지
  String get emoji {
    switch (status) {
      case AwakeTimeStatus.tooEarly:
        return '😴';
      case AwakeTimeStatus.optimal:
        return '😊';
      case AwakeTimeStatus.approaching:
        return '🥱';
      case AwakeTimeStatus.overtired:
        return '😫';
    }
  }
}
