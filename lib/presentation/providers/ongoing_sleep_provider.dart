import 'package:flutter/foundation.dart';
import '../../data/models/activity_model.dart';
import '../../data/services/local_storage_service.dart';
import 'sweet_spot_provider.dart';

/// 🛏️ OngoingSleepProvider - 진행 중인 수면 상태 관리
///
/// **목적**: 앱 전체에서 진행 중인 수면 상태를 중앙 집중식으로 관리
/// - 수면 시작/종료/취소
/// - 경과 시간 계산
/// - SweetSpotProvider와 연동하여 다음 권장 시간 재계산
class OngoingSleepProvider with ChangeNotifier {
  final LocalStorageService _storage;
  final SweetSpotProvider _sweetSpotProvider;

  ActivityModel? _ongoingSleep;
  ActivityModel? _lastCompletedSleep;  // 🆕 마지막 완료된 수면 (CelebrationFeedback용)

  OngoingSleepProvider({
    required LocalStorageService storage,
    required SweetSpotProvider sweetSpotProvider,
  })  : _storage = storage,
        _sweetSpotProvider = sweetSpotProvider;

  // ==================== Getters ====================

  /// 진행 중인 수면이 있는지
  bool get isOngoing => _ongoingSleep != null;

  /// 현재 진행 중인 수면 활동
  ActivityModel? get currentSleep => _ongoingSleep;

  /// 마지막 완료된 수면 (CelebrationFeedback용)
  ActivityModel? get lastCompletedSleep => _lastCompletedSleep;

  /// 수면 시작 시간
  DateTime? get sleepStartTime {
    if (_ongoingSleep == null) return null;
    try {
      return DateTime.parse(_ongoingSleep!.timestamp);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [OngoingSleep] Failed to parse sleep start time: $e');
      }
      return null;
    }
  }

  /// 경과 시간 (Duration)
  Duration get elapsedTime {
    final start = sleepStartTime;
    if (start == null) return Duration.zero;
    return DateTime.now().difference(start);
  }

  /// 경과 시간 (포맷팅된 문자열: "1시간 23분")
  String get formattedElapsedTime {
    final elapsed = elapsedTime;
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes % 60;

    if (hours > 0) {
      return '$hours시간 $minutes분';
    } else {
      return '$minutes분';
    }
  }

  /// 진행률 (0.0 ~ 1.0) - 권장 수면 시간 대비
  /// SweetSpotProvider의 권장 Wake Window 시간을 100%로 계산
  double get progressRatio {
    if (_ongoingSleep == null) return 0.0;

    final elapsed = elapsedTime.inMinutes;
    final recommended = _sweetSpotProvider.wakeWindowMinutes;

    if (recommended <= 0) return 0.0;

    final ratio = elapsed / recommended;
    return ratio.clamp(0.0, 1.0); // 최대 100%로 제한
  }

  // ==================== Actions ====================

  /// 🛏️ 수면 시작
  /// - 새로운 수면 활동 생성 (endTime 없음 = 진행 중)
  /// - LocalStorage에 저장
  /// - UI 업데이트 (notifyListeners)
  Future<void> startSleep({
    required String babyId,
    String? location,
    String? notes,
  }) async {
    if (kDebugMode) {
      debugPrint('🛏️ [OngoingSleep] Starting sleep...');
    }

    try {
      // 이미 진행 중인 수면이 있으면 에러
      if (_ongoingSleep != null) {
        if (kDebugMode) {
          debugPrint('⚠️ [OngoingSleep] Already has ongoing sleep');
        }
        throw Exception('Already has ongoing sleep');
      }

      // 새로운 수면 활동 생성
      final now = DateTime.now();
      final activity = ActivityModel.sleep(
        id: 'sleep_${now.millisecondsSinceEpoch}',
        babyId: babyId,
        startTime: now,
        endTime: null, // 진행 중이므로 null
        location: location,
        notes: notes,
      );

      // LocalStorage에 저장
      await _storage.saveActivity(activity);

      // 상태 업데이트
      _ongoingSleep = activity;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('✅ [OngoingSleep] Sleep started: ${activity.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [OngoingSleep] Failed to start sleep: $e');
      }
      rethrow;
    }
  }

  /// ⏰ 수면 종료
  /// - endTime 설정
  /// - durationMinutes 자동 계산 (copyWith 내부에서)
  /// - SweetSpotProvider 업데이트 (마지막 기상 시간)
  /// - Celebration Feedback 표시 (WidgetService)
  Future<void> endSleep({
    String? quality,
    String? notes,
  }) async {
    if (kDebugMode) {
      debugPrint('⏰ [OngoingSleep] Ending sleep...');
    }

    try {
      if (_ongoingSleep == null) {
        if (kDebugMode) {
          debugPrint('⚠️ [OngoingSleep] No ongoing sleep to end');
        }
        throw Exception('No ongoing sleep to end');
      }

      final now = DateTime.now();
      final endTime = now.toIso8601String();

      // copyWith로 endTime 설정 (duration 자동 계산됨)
      final completedSleep = _ongoingSleep!.copyWith(
        endTime: endTime,
        sleepQuality: quality ?? _ongoingSleep!.sleepQuality,
        notes: notes ?? _ongoingSleep!.notes,
      );

      // LocalStorage 업데이트
      await _storage.updateActivity(completedSleep);

      // SweetSpotProvider 업데이트 (마지막 기상 시간)
      _sweetSpotProvider.onSleepActivityRecorded(
        wakeUpTime: now,
      );

      // 상태 업데이트
      _lastCompletedSleep = completedSleep;  // 🆕 Celebration Feedback 표시용
      _ongoingSleep = null;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('✅ [OngoingSleep] Sleep ended: ${completedSleep.id}');
        debugPrint('   Duration: ${completedSleep.durationMinutes} minutes');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [OngoingSleep] Failed to end sleep: $e');
      }
      rethrow;
    }
  }

  /// ❌ 수면 취소
  /// - 진행 중인 수면 삭제 (기록하지 않음)
  /// - LocalStorage에서 삭제
  Future<void> cancelSleep() async {
    if (kDebugMode) {
      debugPrint('❌ [OngoingSleep] Cancelling sleep...');
    }

    try {
      if (_ongoingSleep == null) {
        if (kDebugMode) {
          debugPrint('⚠️ [OngoingSleep] No ongoing sleep to cancel');
        }
        return;
      }

      // LocalStorage에서 삭제
      await _storage.deleteActivity(_ongoingSleep!.id);

      // 상태 초기화
      _ongoingSleep = null;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('✅ [OngoingSleep] Sleep cancelled');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [OngoingSleep] Failed to cancel sleep: $e');
      }
      rethrow;
    }
  }

  /// 🔄 앱 시작 시 진행 중인 수면 복원
  /// - LocalStorage에서 endTime이 없는 sleep 활동 찾기
  /// - 오늘 시작된 수면만 복원 (어제 이전 수면은 무시)
  Future<void> restoreOngoingSleep() async {
    if (kDebugMode) {
      debugPrint('🔄 [OngoingSleep] Restoring ongoing sleep...');
    }

    try {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      // 오늘의 수면 활동 가져오기
      final sleepActivities = await _storage.getActivitiesByDateRange(
        startDate: todayStart,
        endDate: today,
      );

      // endTime이 없는 수면 찾기
      final ongoingSleep = sleepActivities
          .where((a) => a.type == ActivityType.sleep && a.endTime == null)
          .toList();

      if (ongoingSleep.isEmpty) {
        if (kDebugMode) {
          debugPrint('   No ongoing sleep found');
        }
        _ongoingSleep = null;
        notifyListeners();
        return;
      }

      // 가장 최근 진행 중인 수면 사용
      ongoingSleep.sort((a, b) =>
          DateTime.parse(b.timestamp).compareTo(DateTime.parse(a.timestamp)));

      _ongoingSleep = ongoingSleep.first;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('✅ [OngoingSleep] Restored ongoing sleep: ${_ongoingSleep!.id}');
        debugPrint('   Started at: ${_ongoingSleep!.timestamp}');
        debugPrint('   Elapsed: $formattedElapsedTime');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [OngoingSleep] Failed to restore ongoing sleep: $e');
      }
      _ongoingSleep = null;
      notifyListeners();
    }
  }
}
