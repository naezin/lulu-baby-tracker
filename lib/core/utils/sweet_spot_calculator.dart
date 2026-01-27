/// SweetSpot Calculator
///
/// 아기의 월령에 따른 최적의 낮잠 시간(Sweet Spot)을 계산합니다.
/// Wake Windows(깨어있는 시간) 기반으로 다음 낮잠 권장 시간을 예측합니다.
library;

class SweetSpotCalculator {
  /// 월령별 Wake Windows 테이블 (단위: 시간)
  static const Map<int, WakeWindowData> _wakeWindowTable = {
    0: WakeWindowData(
      minHours: 0.5,
      maxHours: 1.0,
      recommendedNaps: 5,
      description: 'Newborn (0-1 month)',
    ),
    1: WakeWindowData(
      minHours: 1.0,
      maxHours: 1.5,
      recommendedNaps: 4,
      description: '1-2 months',
    ),
    2: WakeWindowData(
      minHours: 1.25,
      maxHours: 1.75,
      recommendedNaps: 4,
      description: '2-3 months',
    ),
    3: WakeWindowData(
      minHours: 1.5,
      maxHours: 2.0,
      recommendedNaps: 4,
      description: '3-4 months',
    ),
    4: WakeWindowData(
      minHours: 1.75,
      maxHours: 2.5,
      recommendedNaps: 3,
      description: '4-5 months',
    ),
    5: WakeWindowData(
      minHours: 2.0,
      maxHours: 2.75,
      recommendedNaps: 3,
      description: '5-6 months',
    ),
    6: WakeWindowData(
      minHours: 2.25,
      maxHours: 3.0,
      recommendedNaps: 3,
      description: '6-7 months',
    ),
    7: WakeWindowData(
      minHours: 2.5,
      maxHours: 3.25,
      recommendedNaps: 2,
      description: '7-8 months',
    ),
    8: WakeWindowData(
      minHours: 2.75,
      maxHours: 3.5,
      recommendedNaps: 2,
      description: '8-9 months',
    ),
    9: WakeWindowData(
      minHours: 3.0,
      maxHours: 3.75,
      recommendedNaps: 2,
      description: '9-12 months',
    ),
    12: WakeWindowData(
      minHours: 3.5,
      maxHours: 4.5,
      recommendedNaps: 2,
      description: '12-15 months',
    ),
    15: WakeWindowData(
      minHours: 4.0,
      maxHours: 5.0,
      recommendedNaps: 1,
      description: '15-18 months',
    ),
    18: WakeWindowData(
      minHours: 4.5,
      maxHours: 6.0,
      recommendedNaps: 1,
      description: '18-24 months',
    ),
  };

  /// SweetSpot 계산
  ///
  /// [ageInMonths]: 아기의 월령 (교정 월령 사용 권장)
  /// [lastWakeUpTime]: 마지막으로 잠에서 깬 시간
  /// [napNumber]: 오늘의 몇 번째 낮잠인지 (선택사항, 1부터 시작)
  static SweetSpotResult calculate({
    required int ageInMonths,
    required DateTime lastWakeUpTime,
    int? napNumber,
  }) {
    // 월령에 맞는 Wake Window 데이터 가져오기
    final wakeWindowData = _getWakeWindowData(ageInMonths);

    // 낮잠 횟수에 따른 Wake Window 조정
    final adjustedWakeWindow = _adjustWakeWindowByNapNumber(
      wakeWindowData,
      napNumber,
    );

    // Sweet Spot 시간대 계산
    final sweetSpotStart = lastWakeUpTime.add(
      Duration(minutes: (adjustedWakeWindow.minHours * 60).round()),
    );

    final sweetSpotEnd = lastWakeUpTime.add(
      Duration(minutes: (adjustedWakeWindow.maxHours * 60).round()),
    );

    // 과도하게 깨어있는지 체크
    final now = DateTime.now();
    final isOvertired = now.isAfter(sweetSpotEnd);
    final minutesSinceWakeUp = now.difference(lastWakeUpTime).inMinutes;

    return SweetSpotResult(
      sweetSpotStart: sweetSpotStart,
      sweetSpotEnd: sweetSpotEnd,
      wakeWindowData: adjustedWakeWindow,
      lastWakeUpTime: lastWakeUpTime,
      ageInMonths: ageInMonths,
      napNumber: napNumber,
      isOvertired: isOvertired,
      minutesSinceWakeUp: minutesSinceWakeUp,
      urgencyLevel: _calculateUrgency(now, sweetSpotStart, sweetSpotEnd),
    );
  }

  /// 월령에 맞는 Wake Window 데이터 조회
  static WakeWindowData _getWakeWindowData(int ageInMonths) {
    // 정확한 매칭 시도
    if (_wakeWindowTable.containsKey(ageInMonths)) {
      return _wakeWindowTable[ageInMonths]!;
    }

    // 가장 가까운 하위 월령 찾기
    int closestAge = 0;
    for (var age in _wakeWindowTable.keys) {
      if (age <= ageInMonths && age > closestAge) {
        closestAge = age;
      }
    }

    return _wakeWindowTable[closestAge]!;
  }

  /// 낮잠 횟수에 따른 Wake Window 조정
  ///
  /// 첫 번째 낮잠은 짧게, 마지막 낮잠 전은 길게 조정
  static WakeWindowData _adjustWakeWindowByNapNumber(
    WakeWindowData baseData,
    int? napNumber,
  ) {
    if (napNumber == null) return baseData;

    // 첫 번째 낮잠: Wake Window 10% 감소
    if (napNumber == 1) {
      return WakeWindowData(
        minHours: baseData.minHours * 0.9,
        maxHours: baseData.maxHours * 0.9,
        recommendedNaps: baseData.recommendedNaps,
        description: '${baseData.description} (First nap)',
      );
    }

    // 마지막 낮잠: Wake Window 15% 증가
    if (napNumber >= baseData.recommendedNaps) {
      return WakeWindowData(
        minHours: baseData.minHours * 1.15,
        maxHours: baseData.maxHours * 1.15,
        recommendedNaps: baseData.recommendedNaps,
        description: '${baseData.description} (Last nap before bedtime)',
      );
    }

    return baseData;
  }

  /// 긴급도 계산
  static UrgencyLevel _calculateUrgency(
    DateTime now,
    DateTime sweetSpotStart,
    DateTime sweetSpotEnd,
  ) {
    if (now.isBefore(sweetSpotStart)) {
      final minutesUntilStart = sweetSpotStart.difference(now).inMinutes;
      if (minutesUntilStart > 30) {
        return UrgencyLevel.tooEarly;
      } else {
        return UrgencyLevel.approaching;
      }
    } else if (now.isAfter(sweetSpotEnd)) {
      return UrgencyLevel.overtired;
    } else {
      return UrgencyLevel.optimal;
    }
  }

  /// 오늘의 낮잠 스케줄 전체 계획 생성
  ///
  /// [ageInMonths]: 아기의 월령
  /// [morningWakeUpTime]: 아침에 일어난 시간
  static List<SweetSpotResult> calculateDailyNapSchedule({
    required int ageInMonths,
    required DateTime morningWakeUpTime,
  }) {
    final wakeWindowData = _getWakeWindowData(ageInMonths);
    final napCount = wakeWindowData.recommendedNaps;

    final schedule = <SweetSpotResult>[];
    DateTime lastWakeUp = morningWakeUpTime;

    for (int i = 1; i <= napCount; i++) {
      final sweetSpot = calculate(
        ageInMonths: ageInMonths,
        lastWakeUpTime: lastWakeUp,
        napNumber: i,
      );

      schedule.add(sweetSpot);

      // 다음 낮잠을 위해 예상 기상 시간 계산
      // 평균 낮잠 시간을 1시간으로 가정
      lastWakeUp = sweetSpot.sweetSpotStart.add(const Duration(hours: 1));
    }

    return schedule;
  }
}

/// Wake Window 데이터 모델
class WakeWindowData {
  final double minHours;
  final double maxHours;
  final int recommendedNaps;
  final String description;

  const WakeWindowData({
    required this.minHours,
    required this.maxHours,
    required this.recommendedNaps,
    required this.description,
  });

  int get minMinutes => (minHours * 60).round();
  int get maxMinutes => (maxHours * 60).round();

  String get displayRange =>
      '${_formatHours(minHours)} - ${_formatHours(maxHours)}';

  String _formatHours(double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}

/// SweetSpot 계산 결과
class SweetSpotResult {
  final DateTime sweetSpotStart;
  final DateTime sweetSpotEnd;
  final WakeWindowData wakeWindowData;
  final DateTime lastWakeUpTime;
  final int ageInMonths;
  final int? napNumber;
  final bool isOvertired;
  final int minutesSinceWakeUp;
  final UrgencyLevel urgencyLevel;

  const SweetSpotResult({
    required this.sweetSpotStart,
    required this.sweetSpotEnd,
    required this.wakeWindowData,
    required this.lastWakeUpTime,
    required this.ageInMonths,
    this.napNumber,
    required this.isOvertired,
    required this.minutesSinceWakeUp,
    required this.urgencyLevel,
  });

  /// Sweet Spot이 현재 활성 상태인지
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(sweetSpotStart) && now.isBefore(sweetSpotEnd);
  }

  /// Sweet Spot까지 남은 시간 (분)
  int get minutesUntilSweetSpot {
    final now = DateTime.now();
    if (now.isAfter(sweetSpotStart)) return 0;
    return sweetSpotStart.difference(now).inMinutes;
  }

  /// Sweet Spot 종료까지 남은 시간 (분)
  int get minutesUntilSweetSpotEnd {
    final now = DateTime.now();
    if (now.isAfter(sweetSpotEnd)) return 0;
    return sweetSpotEnd.difference(now).inMinutes;
  }

  /// 사용자 친화적인 메시지 생성
  String get userFriendlyMessage {
    switch (urgencyLevel) {
      case UrgencyLevel.tooEarly:
        return 'Still awake time! Sweet spot starts in $minutesUntilSweetSpot minutes.';
      case UrgencyLevel.approaching:
        return 'Sweet spot approaching! Consider starting wind-down routine.';
      case UrgencyLevel.optimal:
        return '✨ Perfect time for a nap! Sweet spot window is active.';
      case UrgencyLevel.overtired:
        return '⚠️ Baby may be overtired. Try to settle for sleep now.';
    }
  }

  /// 시간 포맷팅 (예: "2:30 PM - 3:00 PM")
  String getFormattedTimeRange({bool use24Hour = false}) {
    final startFormat = _formatTime(sweetSpotStart, use24Hour);
    final endFormat = _formatTime(sweetSpotEnd, use24Hour);
    return '$startFormat - $endFormat';
  }

  String _formatTime(DateTime time, bool use24Hour) {
    if (use24Hour) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      // 🔧 자정(0시) → 12, 정오(12시) → 12, 오후(13-23시) → 1-11
      final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
      final period = time.hour >= 12 ? 'PM' : 'AM';
      return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
    }
  }

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'sweetSpotStart': sweetSpotStart.toIso8601String(),
      'sweetSpotEnd': sweetSpotEnd.toIso8601String(),
      'lastWakeUpTime': lastWakeUpTime.toIso8601String(),
      'ageInMonths': ageInMonths,
      'napNumber': napNumber,
      'isOvertired': isOvertired,
      'minutesSinceWakeUp': minutesSinceWakeUp,
      'urgencyLevel': urgencyLevel.toString(),
      'wakeWindowMinHours': wakeWindowData.minHours,
      'wakeWindowMaxHours': wakeWindowData.maxHours,
      'recommendedNaps': wakeWindowData.recommendedNaps,
    };
  }
}

/// 긴급도 레벨
enum UrgencyLevel {
  tooEarly,    // Sweet Spot 시작 30분 이상 전
  approaching, // Sweet Spot 시작 30분 이내
  optimal,     // Sweet Spot 활성 구간
  overtired,   // Sweet Spot 종료 후 (과도하게 깨어있음)
}

/// 긴급도 확장 메서드
extension UrgencyLevelExtension on UrgencyLevel {
  String get displayName {
    switch (this) {
      case UrgencyLevel.tooEarly:
        return 'Too Early';
      case UrgencyLevel.approaching:
        return 'Approaching';
      case UrgencyLevel.optimal:
        return 'Optimal Window';
      case UrgencyLevel.overtired:
        return 'Overtired';
    }
  }

  String get emoji {
    switch (this) {
      case UrgencyLevel.tooEarly:
        return '⏰';
      case UrgencyLevel.approaching:
        return '⏳';
      case UrgencyLevel.optimal:
        return '✨';
      case UrgencyLevel.overtired:
        return '⚠️';
    }
  }
}
