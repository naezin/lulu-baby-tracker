import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/utils/sweet_spot_calculator.dart';
import '../../data/models/baby_model.dart';
import '../../core/theme/app_theme.dart';

/// SweetSpot 상태 관리 Provider
class SweetSpotProvider extends ChangeNotifier {
  SweetSpotResult? _currentSweetSpot;
  List<SweetSpotResult>? _dailySchedule;
  BabyModel? _currentBaby;
  DateTime? _lastSleepActivity;

  // 🆕 v2.1 - Timer & Night Mode
  Timer? _countdownTimer;
  bool _disposed = false;

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

  // ═══════════════════════════════════════════════════════════════
  // 🆕 v2.1 COMPUTED PROPERTIES FOR UI
  // ═══════════════════════════════════════════════════════════════

  /// 남은 시간 (분 단위, 음수 가능)
  int get minutesRemaining {
    if (_currentSweetSpot == null) return 0;
    final now = DateTime.now();
    return _currentSweetSpot!.sweetSpotStart.difference(now).inMinutes;
  }

  /// 포맷팅된 카운트다운 (한국어: "52분", 영어: "52 min")
  String getFormattedCountdown({required bool isKorean}) {
    final minutes = minutesRemaining;
    if (isKorean) {
      return '$minutes분';
    } else {
      return '$minutes min';
    }
  }

  /// 목표 시간 포맷팅 (12시간제 + "X분 후")
  /// 예: "오후 2:30에 재우세요 (18분 후)"
  String getTargetTimeFormatted({required bool isKorean}) {
    if (_currentSweetSpot == null) return '--:--';

    final target = _currentSweetSpot!.sweetSpotStart;
    final hour = target.hour;
    final minute = target.minute.toString().padLeft(2, '0');
    final remaining = minutesRemaining;
    final displayHour = _convertTo12Hour(hour);

    if (isKorean) {
      final period = hour < 12 ? '오전' : '오후';
      return '$period $displayHour:$minute에 재우세요 (${remaining}분 후)';
    } else {
      final period = hour < 12 ? 'AM' : 'PM';
      return 'Put to sleep at $displayHour:$minute $period ($remaining min)';
    }
  }

  /// 🆕 4가지 긴급도 상태
  SweetSpotUrgencyState get urgencyState {
    final minutes = minutesRemaining;
    if (minutes > 30) return SweetSpotUrgencyState.tooEarly;
    if (minutes > 10) return SweetSpotUrgencyState.approaching;
    if (minutes >= -5) return SweetSpotUrgencyState.optimal;
    return SweetSpotUrgencyState.overtired;
  }

  /// 🆕 상태별 색상 (야간 모드 지원)
  Color getStateColor({required bool isNightMode}) {
    final baseColor = _getBaseStateColor();
    if (isNightMode) {
      // 야간 모드: 30% 어둡게
      return Color.lerp(baseColor, Colors.black, 0.3) ?? baseColor;
    }
    return baseColor;
  }

  Color _getBaseStateColor() {
    switch (urgencyState) {
      case SweetSpotUrgencyState.tooEarly:
        return const Color(0xFF4A90E2); // 파란색
      case SweetSpotUrgencyState.approaching:
        return const Color(0xFFF5A623); // 주황색
      case SweetSpotUrgencyState.optimal:
        return const Color(0xFF7ED321); // 녹색
      case SweetSpotUrgencyState.overtired:
        return const Color(0xFFE87878); // 빨간색
    }
  }

  /// 🆕 깨어있는 시간 (분)
  int get awakeMinutes {
    if (_lastSleepActivity == null) return 0;
    return DateTime.now().difference(_lastSleepActivity!).inMinutes;
  }

  /// 🆕 Wake Window (분) - 기본값 80분 (3개월 기준)
  int get wakeWindowMinutes {
    return _currentSweetSpot?.wakeWindowData.maxMinutes ?? 80;
  }

  /// 🆕 야간 모드 여부 (17:00 ~ 06:00)
  bool get isNightMode {
    final hour = DateTime.now().hour;
    return hour >= AppTheme.nightModeStartHour || hour < AppTheme.nightModeEndHour;
  }

  /// 🆕 12시간제 변환 헬퍼 (자정/정오 버그 수정)
  int _convertTo12Hour(int hour24) {
    if (hour24 == 0) return 12;  // 자정 → 12
    if (hour24 <= 12) return hour24;
    return hour24 - 12;
  }

  /// 🆕 친근한 깨어있는 시간 메시지
  String getAwakeMessage({required bool isKorean}) {
    final minutes = awakeMinutes;
    if (isKorean) {
      return '😊 ${minutes}분째 깨어있어요';
    } else {
      return '😊 Awake for $minutes min';
    }
  }

  /// 🆕 상태별 컨텍스트 메시지
  String getContextMessage({required bool isKorean}) {
    switch (urgencyState) {
      case SweetSpotUrgencyState.tooEarly:
        return isKorean
          ? '아직 놀 시간이에요! 자연스럽게 활동하세요.'
          : 'Still play time! Keep activities natural.';
      case SweetSpotUrgencyState.approaching:
        return isKorean
          ? '곧 졸려할 거예요. 수면 루틴을 시작하세요!'
          : 'Getting sleepy soon. Start the sleep routine!';
      case SweetSpotUrgencyState.optimal:
        return isKorean
          ? '지금 재우면 가장 쉽게 잠들어요!'
          : 'Perfect time to put baby to sleep!';
      case SweetSpotUrgencyState.overtired:
        return isKorean
          ? '괜찮아요! 지금이라도 재워보세요. 🌙'
          : "It's okay! Try putting baby to sleep now. 🌙";
    }
  }

  /// 🆕 상태 라벨 (칩에 표시)
  String getStateLabel({required bool isKorean}) {
    switch (urgencyState) {
      case SweetSpotUrgencyState.tooEarly:
        return isKorean ? '💙 놀이 시간' : '💙 Play Time';
      case SweetSpotUrgencyState.approaching:
        return isKorean ? '🧡 수면 준비' : '🧡 Get Ready';
      case SweetSpotUrgencyState.optimal:
        return isKorean ? '💚 지금이에요!' : '💚 Perfect Time!';
      case SweetSpotUrgencyState.overtired:
        return isKorean ? '❤️ 지금 재워주세요' : '❤️ Sleep Now';
    }
  }

  /// 🆕 "지금 재우기" 버튼 표시 여부
  bool get shouldShowSleepButton {
    return urgencyState == SweetSpotUrgencyState.optimal ||
           urgencyState == SweetSpotUrgencyState.overtired;
  }

  // ═══════════════════════════════════════════════════════════════
  // 🆕 v2.1 COUNTDOWN TIMER
  // ═══════════════════════════════════════════════════════════════

  /// 1분마다 UI 갱신을 위한 타이머 시작
  void startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        if (!_disposed) {
          notifyListeners();
        }
      },
    );
  }

  /// 타이머 중지
  void stopCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    super.dispose();
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

// ═══════════════════════════════════════════════════════════════
// 🆕 v2.1 URGENCY STATE ENUM
// ═══════════════════════════════════════════════════════════════

/// Sweet Spot 긴급도 상태
enum SweetSpotUrgencyState {
  tooEarly,    // 30분+ 남음 (파란색)
  approaching, // 10-30분 남음 (주황색)
  optimal,     // 0-10분 (녹색)
  overtired,   // Sweet Spot 지남 (빨간색)
}
