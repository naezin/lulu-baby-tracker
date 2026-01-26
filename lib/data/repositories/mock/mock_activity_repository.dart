import '../../../domain/repositories/i_activity_repository.dart';
import '../../../domain/entities/activity_entity.dart';

/// Mock Activity Repository (In-Memory)
/// 로컬 개발 및 테스트용 인메모리 구현
class MockActivityRepository implements IActivityRepository {
  final Map<String, List<ActivityEntity>> _activities = {};

  @override
  Future<void> saveActivity({
    required String babyId,
    required ActivityEntity activity,
  }) async {
    _activities.putIfAbsent(babyId, () => []);
    _activities[babyId]!.add(activity);
  }

  @override
  Future<List<ActivityEntity>> getActivities({
    required String babyId,
    DateTime? startDate,
    DateTime? endDate,
    ActivityType? type,
    int? limit,
  }) async {
    var activities = _activities[babyId] ?? [];

    if (type != null) {
      activities = activities.where((a) => a.type == type).toList();
    }

    if (startDate != null) {
      activities = activities.where((a) => a.timestamp.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      activities = activities.where((a) => a.timestamp.isBefore(endDate)).toList();
    }

    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (limit != null && activities.length > limit) {
      activities = activities.take(limit).toList();
    }

    return activities;
  }

  @override
  Future<ActivityEntity?> getActivityById({
    required String babyId,
    required String activityId,
  }) async {
    final activities = _activities[babyId] ?? [];
    try {
      return activities.firstWhere((a) => a.id == activityId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateActivity({
    required String babyId,
    required ActivityEntity activity,
  }) async {
    final activities = _activities[babyId] ?? [];
    final index = activities.indexWhere((a) => a.id == activity.id);
    if (index != -1) {
      activities[index] = activity;
    }
  }

  @override
  Future<void> deleteActivity({
    required String babyId,
    required String activityId,
  }) async {
    final activities = _activities[babyId] ?? [];
    activities.removeWhere((a) => a.id == activityId);
  }

  @override
  Future<DailySummary> getTodaySummary({required String babyId}) async {
    final now = DateTime.now();
    return getDailySummary(babyId: babyId, date: now);
  }

  @override
  Future<DailySummary> getDailySummary({
    required String babyId,
    required DateTime date,
  }) async {
    final activities = _activities[babyId] ?? [];
    final dayActivities = activities.where((a) {
      return a.timestamp.year == date.year &&
          a.timestamp.month == date.month &&
          a.timestamp.day == date.day;
    }).toList();

    return DailySummary(
      date: date,
      totalSleepMinutes: _calculateTotalSleep(dayActivities),
      totalFeedingMl: _calculateTotalFeeding(dayActivities),
      diaperCount: _countDiapers(dayActivities),
      playCount: _countPlay(dayActivities),
    );
  }

  @override
  Stream<List<ActivityEntity>> watchActivities({
    required String babyId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Stream.value(_activities[babyId] ?? []);
  }

  @override
  Future<List<ActivityEntity>> getSleepPattern({
    required String babyId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final activities = _activities[babyId] ?? [];
    return activities
        .where((a) =>
            a.type == ActivityType.sleep &&
            a.timestamp.isAfter(startDate) &&
            a.timestamp.isBefore(endDate))
        .toList();
  }

  @override
  Future<List<ActivityEntity>> getFeedingPattern({
    required String babyId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final activities = _activities[babyId] ?? [];
    return activities
        .where((a) =>
            a.type == ActivityType.feeding &&
            a.timestamp.isAfter(startDate) &&
            a.timestamp.isBefore(endDate))
        .toList();
  }

  @override
  Future<List<ActivityEntity>> getRecentActivities({
    required String babyId,
    ActivityType? type,
    int limit = 10,
  }) async {
    var activities = _activities[babyId] ?? [];

    if (type != null) {
      activities = activities.where((a) => a.type == type).toList();
    }

    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return activities.take(limit).toList();
  }

  int _calculateTotalSleep(List<ActivityEntity> activities) {
    return activities
        .where((a) => a.type == ActivityType.sleep)
        .fold(0, (sum, a) => sum + (a.durationMinutes ?? 0));
  }

  double _calculateTotalFeeding(List<ActivityEntity> activities) {
    return activities
        .where((a) => a.type == ActivityType.feeding)
        .fold(0.0, (sum, a) => sum + (a.amountMl ?? 0));
  }

  int _countDiapers(List<ActivityEntity> activities) {
    return activities.where((a) => a.type == ActivityType.diaper).length;
  }

  int _countPlay(List<ActivityEntity> activities) {
    return activities.where((a) => a.type == ActivityType.play).length;
  }
}
