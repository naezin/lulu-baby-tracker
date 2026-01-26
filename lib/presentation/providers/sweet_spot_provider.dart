import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/utils/sweet_spot_calculator.dart';
import '../../data/models/baby_model.dart';

/// SweetSpot 상태 관리 Provider
class SweetSpotProvider extends ChangeNotifier {
  SweetSpotResult? _currentSweetSpot;
  List<SweetSpotResult>? _dailySchedule;
  BabyModel? _currentBaby;
  DateTime? _lastSleepActivity;

  SweetSpotResult? get currentSweetSpot => _currentSweetSpot;
  List<SweetSpotResult>? get dailySchedule => _dailySchedule;
  BabyModel? get currentBaby => _currentBaby;

  /// 초기화 메서드 - HomeScreen에서 호출
  Future<void> initialize({
    required BabyModel baby,
    required DateTime? lastWakeUpTime,
  }) async {
    _currentBaby = baby;
    _lastSleepActivity = lastWakeUpTime;

    if (lastWakeUpTime != null) {
      _calculateCurrentSweetSpot();
    } else {
      _currentSweetSpot = null;
      print('📭 [SweetSpotProvider] No sleep data for baby ${baby.name}');
    }

    notifyListeners();
  }

  /// Activity 기록 후 업데이트 - 수면 기록 시 호출
  void onSleepActivityRecorded({
    required DateTime wakeUpTime,
    int? napNumber,
  }) {
    _lastSleepActivity = wakeUpTime;
    _calculateCurrentSweetSpot();
  }

  /// 수동 새로고침
  void refreshSweetSpot() {
    if (_currentBaby != null && _lastSleepActivity != null) {
      _calculateCurrentSweetSpot();
    }
  }

  /// 아기 정보 설정
  void setBaby(BabyModel baby) {
    _currentBaby = baby;
    notifyListeners();
  }

  /// 마지막 수면 활동 업데이트
  void updateLastSleepActivity(DateTime wakeUpTime) {
    _lastSleepActivity = wakeUpTime;
    _calculateCurrentSweetSpot();
  }

  /// 현재 Sweet Spot 계산
  void _calculateCurrentSweetSpot() {
    if (_currentBaby == null || _lastSleepActivity == null) {
      _currentSweetSpot = null;
      notifyListeners();
      return;
    }

    // 교정 월령 사용 (조산아 고려)
    final ageInMonths = _currentBaby!.correctedAgeInMonths;

    // 오늘 발생한 낮잠 횟수 계산 (실제로는 Activity 기록에서 가져와야 함)
    final napNumber = _estimateNapNumber();

    _currentSweetSpot = SweetSpotCalculator.calculate(
      ageInMonths: ageInMonths,
      lastWakeUpTime: _lastSleepActivity!,
      napNumber: napNumber,
    );

    notifyListeners();
  }

  /// 하루 낮잠 스케줄 생성
  void generateDailySchedule(DateTime morningWakeUpTime) {
    if (_currentBaby == null) {
      _dailySchedule = null;
      notifyListeners();
      return;
    }

    final ageInMonths = _currentBaby!.correctedAgeInMonths;

    _dailySchedule = SweetSpotCalculator.calculateDailyNapSchedule(
      ageInMonths: ageInMonths,
      morningWakeUpTime: morningWakeUpTime,
    );

    notifyListeners();
  }

  /// 다음 낮잠까지 남은 시간 (분)
  int? get minutesUntilNextNap {
    if (_currentSweetSpot == null) return null;

    final now = DateTime.now();
    if (now.isAfter(_currentSweetSpot!.sweetSpotStart)) {
      return 0; // 이미 Sweet Spot 시작됨
    }

    return _currentSweetSpot!.minutesUntilSweetSpot;
  }

  /// Sweet Spot 활성 상태 확인
  bool get isSweetSpotActive {
    if (_currentSweetSpot == null) return false;
    return _currentSweetSpot!.isActive;
  }

  /// 긴급도 레벨
  UrgencyLevel? get urgencyLevel {
    return _currentSweetSpot?.urgencyLevel;
  }

  /// 사용자 친화적 메시지
  String get userMessage {
    if (_currentSweetSpot == null) {
      return 'Track your baby\'s sleep to see Sweet Spot predictions';
    }
    return _currentSweetSpot!.userFriendlyMessage;
  }

  /// 낮잠 번호 추정 (시간대 기반 추정)
  int? _estimateNapNumber() {
    final now = DateTime.now();
    final hour = now.hour;

    // 시간대별 대략적인 낮잠 순서 추정
    if (hour < 10) return 1;
    if (hour < 13) return 2;
    if (hour < 16) return 3;
    return 4;
  }

  /// Sweet Spot 상태 새로고침
  void refresh() {
    _calculateCurrentSweetSpot();
  }

  /// 초기화
  void clear() {
    _currentSweetSpot = null;
    _dailySchedule = null;
    _currentBaby = null;
    _lastSleepActivity = null;
    notifyListeners();
  }
}

/// BabyModel 확장 (교정 월령 계산)
extension BabyModelExtension on BabyModel {
  int get correctedAgeInMonths {
    final now = DateTime.now();
    final birthDate = DateTime.parse(this.birthDate);
    final dueDate = this.dueDate != null ? DateTime.parse(this.dueDate!) : birthDate;

    // 조산 주수 계산
    final prematureWeeks = dueDate.difference(birthDate).inDays ~/ 7;

    // 교정 나이 = 실제 나이 - 조산 주수
    final correctedBirthDate = birthDate.add(Duration(days: prematureWeeks * 7));
    final monthsDiff = _calculateMonths(correctedBirthDate, now);

    return monthsDiff > 0 ? monthsDiff : 0;
  }

  int _calculateMonths(DateTime start, DateTime end) {
    int months = (end.year - start.year) * 12 + end.month - start.month;
    if (end.day < start.day) months--;
    return months;
  }
}
