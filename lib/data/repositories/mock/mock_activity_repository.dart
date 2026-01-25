import '../../../domain/repositories/i_activity_repository.dart';
import '../../../domain/entities/activity.dart';

/// Mock Activity Repository (In-Memory)
/// 로컬 개발 및 테스트용 인메모리 구현
class MockActivityRepository implements IActivityRepository {
  final List<Activity> _activities = [];

  @override
  Future<List<Activity>> getActivitiesByUserId(String userId) async {
    return _activities.where((a) => a.userId == userId).toList();
  }

  @override
  Future<List<Activity>> getActivitiesByDate(
    String userId,
    DateTime date,
  ) async {
    return _activities
        .where((a) =>
            a.userId == userId &&
            a.timestamp.year == date.year &&
            a.timestamp.month == date.month &&
            a.timestamp.day == date.day)
        .toList();
  }

  @override
  Future<List<Activity>> getActivitiesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _activities
        .where((a) =>
            a.userId == userId &&
            a.timestamp.isAfter(startDate) &&
            a.timestamp.isBefore(endDate))
        .toList();
  }

  @override
  Future<void> addActivity(Activity activity) async {
    _activities.add(activity);
  }

  @override
  Future<void> updateActivity(Activity activity) async {
    final index = _activities.indexWhere((a) => a.id == activity.id);
    if (index != -1) {
      _activities[index] = activity;
    }
  }

  @override
  Future<void> deleteActivity(String activityId) async {
    _activities.removeWhere((a) => a.id == activityId);
  }

  @override
  Future<Activity?> getActivityById(String activityId) async {
    try {
      return _activities.firstWhere((a) => a.id == activityId);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<List<Activity>> watchActivitiesByDate(
    String userId,
    DateTime date,
  ) {
    // Mock: 단순히 현재 데이터를 Stream으로 반환
    return Stream.value(_activities
        .where((a) =>
            a.userId == userId &&
            a.timestamp.year == date.year &&
            a.timestamp.month == date.month &&
            a.timestamp.day == date.day)
        .toList());
  }
}
