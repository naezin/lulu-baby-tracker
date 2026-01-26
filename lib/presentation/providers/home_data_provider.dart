import 'package:flutter/material.dart';
import '../../core/utils/sweet_spot_calculator.dart';
import '../../data/models/home_data_model.dart';
import '../../data/models/notification_state.dart';
import '../../data/services/daily_summary_service.dart';
import '../../data/services/notification_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../di/injection_container.dart' as di;
import '../../domain/repositories/i_activity_repository.dart';

/// 홈 화면 통합 데이터 Provider
class HomeDataProvider extends ChangeNotifier {
  HomeDataModel _data = HomeDataModel.empty();
  bool _isLoading = false;
  String? _error;

  final NotificationService _notificationService = NotificationService();
  late final DailySummaryService _dailySummaryService;

  String? _lastBabyId;  // 🆕 Track last baby ID for change detection

  HomeDataProvider() {
    // DI에서 ActivityRepository를 가져와서 DailySummaryService 초기화
    try {
      _dailySummaryService = DailySummaryService(
        activityRepository: di.sl<IActivityRepository>(),
      );
    } catch (e) {
      print('⚠️ [HomeDataProvider] Failed to initialize DailySummaryService: $e');
      rethrow;
    }
  }

  /// 🆕 BabyProvider 리스너 등록 메서드 (HomeScreen에서 호출)
  void setupBabyListener(String? currentBabyId) {
    _lastBabyId = currentBabyId;
  }

  /// 🆕 아기 변경 감지 및 데이터 새로고침
  Future<void> onBabyChanged({
    required String? newBabyId,
    required String babyName,
    required DateTime? lastWakeUpTime,
    required int ageInMonths,
    required AppLocalizations l10n,
  }) async {
    if (_lastBabyId == newBabyId) {
      return;  // Same baby, no need to refresh
    }

    print('🔄 [HomeDataProvider] Baby changed from $_lastBabyId to $newBabyId - reloading all data');
    _lastBabyId = newBabyId;

    if (newBabyId != null && lastWakeUpTime != null) {
      await loadAll(
        babyId: newBabyId,
        babyName: babyName,
        lastWakeUpTime: lastWakeUpTime,
        ageInMonths: ageInMonths,
        l10n: l10n,
      );
    }
  }

  // Getters
  HomeDataModel get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SweetSpotResult? get sweetSpot => _data.sweetSpot;
  DailySummary? get dailySummary => _data.dailySummary;
  NotificationState get notificationState => _data.notificationState;

  /// 모든 데이터 로드
  Future<void> loadAll({
    required String babyId,
    required String babyName,
    required DateTime lastWakeUpTime,
    required int ageInMonths,
    required AppLocalizations l10n,
  }) async {
    _isLoading = true;
    _error = null;
    // ⚠️ 로딩 시작 시 notifyListeners() 호출하지 않음
    // UI가 로딩 상태를 확인하지 않고 이전 데이터만 표시하므로, 데이터 로드 완료까지 기다림

    try {
      // 1. Sweet Spot 계산
      final sweetSpot = SweetSpotCalculator.calculate(
        ageInMonths: ageInMonths,
        lastWakeUpTime: lastWakeUpTime,
        napNumber: _estimateNapNumber(),
      );

      // 2. 오늘 요약 로드
      final summary = await _dailySummaryService.getTodaysSummary(babyId);

      // 3. 알림 상태 확인
      print('🔔 [HomeDataProvider] Checking notification service...');
      final pendingNotifications = await _notificationService.getPendingNotifications().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          print('⚠️ [HomeDataProvider] Notification service timeout - continuing without notifications');
          return [];
        },
      );
      print('🔔 [HomeDataProvider] Got ${pendingNotifications.length} pending notifications');
      final hasScheduledNotification = pendingNotifications.isNotEmpty;

      DateTime? scheduledTime;
      if (hasScheduledNotification && sweetSpot != null) {
        scheduledTime = sweetSpot.sweetSpotStart.subtract(
          Duration(minutes: _data.notificationState.minutesBefore),
        );
      }

      _data = _data.copyWith(
        sweetSpot: sweetSpot,
        dailySummary: summary,
        notificationState: _data.notificationState.copyWith(
          isEnabled: hasScheduledNotification,
          scheduledTime: scheduledTime,
        ),
        lastUpdated: DateTime.now(),
      );

      // 4. Sweet Spot 변경 시 알림 재스케줄
      if (_data.notificationState.isEnabled && sweetSpot != null) {
        print('🔔 [HomeDataProvider] Rescheduling notifications...');
        try {
          await _rescheduleNotification(
            sweetSpot: sweetSpot,
            babyName: babyName,
            l10n: l10n,
          ).timeout(const Duration(seconds: 2));
          print('🔔 [HomeDataProvider] Notifications rescheduled');
        } catch (e) {
          print('⚠️ [HomeDataProvider] Failed to reschedule notifications: $e');
        }
      }
    } catch (e) {
      _error = e.toString();
      print('⚠️ [HomeDataProvider] Error loading data: $e');
    } finally {
      _isLoading = false;
      print('📢 [HomeDataProvider] loadAll() completed - calling notifyListeners()');
      print('   dailySummary: ${_data.dailySummary != null ? "sleep=${_data.dailySummary!.totalSleepMinutes}min" : "NULL"}');
      notifyListeners();
    }
  }

  /// 알림 토글
  Future<bool> toggleNotification({
    required String babyName,
    required AppLocalizations l10n,
  }) async {
    final currentState = _data.notificationState;

    if (currentState.isEnabled) {
      // 알림 끄기
      await _notificationService.cancelAllNotifications();
      _data = _data.copyWith(
        notificationState: currentState.copyWith(
          isEnabled: false,
          scheduledTime: null,
        ),
      );
    } else {
      // 알림 켜기
      // 권한 확인
      if (currentState.permission == NotificationPermission.notAsked) {
        final granted = await _notificationService.requestPermission();
        _data = _data.copyWith(
          notificationState: currentState.copyWith(
            permission: granted
                ? NotificationPermission.granted
                : NotificationPermission.denied,
          ),
        );

        if (!granted) {
          notifyListeners();
          return false;
        }
      } else if (currentState.permission == NotificationPermission.denied) {
        notifyListeners();
        return false;
      }

      // 알림 스케줄
      if (_data.sweetSpot != null) {
        await _rescheduleNotification(
          sweetSpot: _data.sweetSpot!,
          babyName: babyName,
          l10n: l10n,
        );

        final scheduledTime = _data.sweetSpot!.sweetSpotStart.subtract(
          Duration(minutes: currentState.minutesBefore),
        );

        _data = _data.copyWith(
          notificationState: currentState.copyWith(
            isEnabled: true,
            scheduledTime: scheduledTime,
            permission: NotificationPermission.granted,
          ),
        );
      }
    }

    notifyListeners();
    return true;
  }

  /// 알림 재스케줄
  Future<void> _rescheduleNotification({
    required SweetSpotResult sweetSpot,
    required String babyName,
    required AppLocalizations l10n,
  }) async {
    await _notificationService.scheduleSweetSpotNotification(
      sweetSpotTime: sweetSpot.sweetSpotStart,
      babyName: babyName,
      l10n: l10n,
    );
  }

  /// Sweet Spot 업데이트 (기록 저장 후 호출)
  Future<void> updateSweetSpot({
    required DateTime lastWakeUpTime,
    required int ageInMonths,
    required String babyName,
    required AppLocalizations l10n,
  }) async {
    final sweetSpot = SweetSpotCalculator.calculate(
      ageInMonths: ageInMonths,
      lastWakeUpTime: lastWakeUpTime,
      napNumber: _estimateNapNumber(),
    );

    _data = _data.copyWith(
      sweetSpot: sweetSpot,
      lastUpdated: DateTime.now(),
    );

    // 알림 활성화 상태면 재스케줄
    if (_data.notificationState.isEnabled && sweetSpot != null) {
      await _rescheduleNotification(
        sweetSpot: sweetSpot,
        babyName: babyName,
        l10n: l10n,
      );

      final scheduledTime = sweetSpot.sweetSpotStart.subtract(
        Duration(minutes: _data.notificationState.minutesBefore),
      );

      _data = _data.copyWith(
        notificationState: _data.notificationState.copyWith(
          scheduledTime: scheduledTime,
        ),
      );
    }

    notifyListeners();
  }

  /// Daily Summary 새로고침
  Future<void> refreshDailySummary(String babyId) async {
    print('🔄 [HomeDataProvider] refreshDailySummary called with babyId: $babyId');
    try {
      final summary = await _dailySummaryService.getTodaysSummary(babyId);
      print('   ✅ Got summary: sleep=${summary.totalSleepMinutes}min, feeding=${summary.feedingCount}, diaper=${summary.diaperCount}');
      _data = _data.copyWith(
        dailySummary: summary,
        lastUpdated: DateTime.now(),
      );
      print('   📢 Calling notifyListeners()');
      notifyListeners();
    } catch (e) {
      // 에러 무시, 기존 데이터 유지
      print('⚠️ [HomeDataProvider] Error refreshing daily summary: $e');
    }
  }

  /// 낮잠 번호 추정 (시간대 기반)
  int _estimateNapNumber() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour < 10) return 1;
    if (hour < 13) return 2;
    if (hour < 16) return 3;
    return 4;
  }
}
