import '../../data/models/activity_model.dart';
import '../../data/services/local_storage_service.dart';

/// 📊 InsightCalculator - 기록 완료 후 인사이트 계산 (캐싱 포함)
///
/// **목적**: 오늘 기록 현황을 빠르게 계산하여 CelebrationFeedback에 전달
/// - 오늘의 각 활동 카운트
/// - 진행 중인 수면 처리
/// - 메모리 캐싱으로 성능 최적화
class InsightCalculator {
  final LocalStorageService _storage;

  // 캐시 저장소
  static DateTime? _cacheDate;
  static Map<ActivityType, int>? _cachedCounts;
  static Duration? _cachedSleepDuration;
  static int? _cachedOngoingSleepCount;

  InsightCalculator(this._storage);

  /// 🧹 캐시 무효화 (새로운 기록 추가 후 호출)
  static void invalidateCache() {
    _cacheDate = null;
    _cachedCounts = null;
    _cachedSleepDuration = null;
    _cachedOngoingSleepCount = null;
  }

  /// 📈 오늘의 활동 통계 계산
  Future<TodayInsightData> calculateTodayInsight() async {
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    // 캐시가 유효하면 재사용
    if (_cacheDate == todayKey && _cachedCounts != null) {
      return TodayInsightData(
        activityCounts: Map.from(_cachedCounts!),
        totalSleepDuration: _cachedSleepDuration ?? Duration.zero,
        ongoingSleepCount: _cachedOngoingSleepCount ?? 0,
      );
    }

    // 캐시 미스 - 오늘 기록 조회
    final todayActivities = await _storage.getActivitiesByDateRange(
      startDate: todayKey,
      endDate: todayKey,
    );

    // 활동 타입별 카운트
    final counts = <ActivityType, int>{};
    for (final activity in todayActivities) {
      counts[activity.type] = (counts[activity.type] ?? 0) + 1;
    }

    // 수면 관련 계산
    final sleepActivities = todayActivities
        .where((a) => a.type == ActivityType.sleep)
        .toList();

    final totalSleepDuration = _calculateTotalSleepDuration(sleepActivities);
    final ongoingSleepCount = _countOngoingSleep(sleepActivities);

    // 캐시 저장
    _cacheDate = todayKey;
    _cachedCounts = counts;
    _cachedSleepDuration = totalSleepDuration;
    _cachedOngoingSleepCount = ongoingSleepCount;

    return TodayInsightData(
      activityCounts: counts,
      totalSleepDuration: totalSleepDuration,
      ongoingSleepCount: ongoingSleepCount,
    );
  }

  /// 💤 총 수면 시간 계산 (완료된 수면만)
  Duration _calculateTotalSleepDuration(List<ActivityModel> sleepActivities) {
    int totalMinutes = 0;

    for (final sleep in sleepActivities) {
      // endTime이 없으면 진행 중이므로 제외
      if (sleep.endTime == null || sleep.durationMinutes == null) continue;

      // 음수 방어
      if (sleep.durationMinutes! < 0) continue;

      totalMinutes += sleep.durationMinutes!;
    }

    return Duration(minutes: totalMinutes);
  }

  /// 🔢 진행 중인 수면 개수
  int _countOngoingSleep(List<ActivityModel> sleepActivities) {
    return sleepActivities.where((s) => s.endTime == null).length;
  }

  /// 📝 활동 타입별 인사이트 메시지 생성
  String generateInsightMessage(ActivityType type, TodayInsightData data) {
    final count = data.activityCounts[type] ?? 0;

    switch (type) {
      case ActivityType.sleep:
        if (data.ongoingSleepCount > 0) {
          return '진행 중인 수면이 ${data.ongoingSleepCount}건 있어요';
        }
        final hours = data.totalSleepDuration.inHours;
        final minutes = data.totalSleepDuration.inMinutes % 60;
        return '오늘 총 $hours시간 $minutes분 잠을 잤어요';

      case ActivityType.feeding:
        return '오늘 $count번째 수유를 기록했어요';

      case ActivityType.diaper:
        return '오늘 $count번째 기저귀를 갈아주셨어요';

      case ActivityType.play:
        return '오늘 $count번째 놀이 활동을 했어요';

      case ActivityType.health:
        return '오늘 $count번째 건강 기록이에요';
    }
  }
}

/// 📊 오늘의 인사이트 데이터
class TodayInsightData {
  final Map<ActivityType, int> activityCounts;
  final Duration totalSleepDuration;
  final int ongoingSleepCount;

  TodayInsightData({
    required this.activityCounts,
    required this.totalSleepDuration,
    required this.ongoingSleepCount,
  });
}
