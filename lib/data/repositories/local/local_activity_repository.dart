import '../../../domain/repositories/i_activity_repository.dart';
import '../../../domain/entities/activity_entity.dart';
import '../../services/local_storage_service.dart';
import '../../models/activity_model.dart' as models;

/// Local Storage Activity Repository
/// LocalStorageService를 사용하는 ActivityRepository 구현
class LocalActivityRepository implements IActivityRepository {
  final LocalStorageService _storageService;

  LocalActivityRepository(this._storageService);

  @override
  Future<void> saveActivity({
    required String babyId,
    required ActivityEntity activity,
  }) async {
    // ActivityEntity를 ActivityModel로 변환
    final model = models.ActivityModel(
      id: activity.id,
      babyId: babyId,
      type: _entityTypeToModelType(activity.type),
      timestamp: activity.timestamp.toIso8601String(),
      durationMinutes: activity.durationMinutes,
      amountMl: activity.amountMl?.toDouble(),
      notes: activity.notes,
      feedingType: activity.feedingType,
      diaperType: activity.diaperType,
      endTime: activity.endTime?.toIso8601String(),
    );
    await _storageService.saveActivity(model);
  }

  @override
  Future<List<ActivityEntity>> getActivities({
    required String babyId,
    DateTime? startDate,
    DateTime? endDate,
    ActivityType? type,
    int? limit,
  }) async {
    var activityModels = await _storageService.getActivities();

    // babyId 필터
    activityModels = activityModels.where((a) => a.babyId == babyId).toList();

    // 타입 필터
    if (type != null) {
      final modelType = _entityTypeToModelType(type);
      activityModels = activityModels.where((a) => a.type == modelType).toList();
    }

    // 날짜 필터
    if (startDate != null) {
      activityModels = activityModels.where((a) {
        final timestamp = DateTime.parse(a.timestamp);
        return timestamp.isAfter(startDate) || timestamp.isAtSameMomentAs(startDate);
      }).toList();
    }

    if (endDate != null) {
      activityModels = activityModels.where((a) {
        final timestamp = DateTime.parse(a.timestamp);
        return timestamp.isBefore(endDate);
      }).toList();
    }

    // 최신순 정렬
    activityModels.sort((a, b) {
      final aTime = DateTime.parse(a.timestamp);
      final bTime = DateTime.parse(b.timestamp);
      return bTime.compareTo(aTime);
    });

    // 개수 제한
    if (limit != null && activityModels.length > limit) {
      activityModels = activityModels.take(limit).toList();
    }

    // ActivityEntity로 변환
    return activityModels.map((model) => _modelToEntity(model)).toList();
  }

  @override
  Future<ActivityEntity?> getActivityById({
    required String babyId,
    required String activityId,
  }) async {
    final activities = await _storageService.getActivities();
    try {
      final model = activities.firstWhere((a) => a.id == activityId && a.babyId == babyId);
      return _modelToEntity(model);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateActivity({
    required String babyId,
    required ActivityEntity activity,
  }) async {
    final model = models.ActivityModel(
      id: activity.id,
      babyId: babyId,
      type: _entityTypeToModelType(activity.type),
      timestamp: activity.timestamp.toIso8601String(),
      durationMinutes: activity.durationMinutes,
      amountMl: activity.amountMl?.toDouble(),
      notes: activity.notes,
      feedingType: activity.feedingType,
      diaperType: activity.diaperType,
      endTime: activity.endTime?.toIso8601String(),
    );
    await _storageService.updateActivity(model);
  }

  @override
  Future<void> deleteActivity({
    required String babyId,
    required String activityId,
  }) async {
    await _storageService.deleteActivity(activityId);
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
    final activities = await getActivities(
      babyId: babyId,
      startDate: DateTime(date.year, date.month, date.day),
      endDate: DateTime(date.year, date.month, date.day, 23, 59, 59),
    );

    int totalSleepMinutes = 0;
    double totalFeedingMl = 0;
    int diaperCount = 0;
    int playCount = 0;

    for (final activity in activities) {
      switch (activity.type) {
        case ActivityType.sleep:
          if (activity.durationMinutes != null) {
            totalSleepMinutes += activity.durationMinutes!;
          }
          break;
        case ActivityType.feeding:
          if (activity.amountMl != null) {
            totalFeedingMl += activity.amountMl!.toDouble();
          }
          break;
        case ActivityType.diaper:
          diaperCount++;
          break;
        case ActivityType.play:
          playCount++;
          break;
        default:
          break;
      }
    }

    return DailySummary(
      date: date,
      totalSleepMinutes: totalSleepMinutes,
      totalFeedingMl: totalFeedingMl,
      diaperCount: diaperCount,
      playCount: playCount,
    );
  }

  @override
  Future<ActivityEntity?> getLastActivity({
    required String babyId,
    ActivityType? type,
  }) async {
    final activities = await getActivities(
      babyId: babyId,
      type: type,
      limit: 1,
    );

    return activities.isNotEmpty ? activities.first : null;
  }

  @override
  Future<List<ActivityEntity>> getRecentActivities({
    required String babyId,
    ActivityType? type,
    int limit = 10,
  }) async {
    return getActivities(
      babyId: babyId,
      type: type,
      limit: limit,
    );
  }

  @override
  Stream<List<ActivityEntity>> watchActivities({
    required String babyId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    // LocalStorage는 실시간 감지를 지원하지 않으므로
    // 현재 데이터를 한 번만 스트림으로 반환
    return Stream.fromFuture(
      getActivities(
        babyId: babyId,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  Future<List<ActivityEntity>> getSleepPattern({
    required String babyId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return getActivities(
      babyId: babyId,
      type: ActivityType.sleep,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<List<ActivityEntity>> getFeedingPattern({
    required String babyId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return getActivities(
      babyId: babyId,
      type: ActivityType.feeding,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// ActivityModel을 ActivityEntity로 변환
  ActivityEntity _modelToEntity(models.ActivityModel model) {
    return ActivityEntity(
      id: model.id,
      type: _modelTypeToEntityType(model.type),
      timestamp: DateTime.parse(model.timestamp),
      durationMinutes: model.durationMinutes,
      amountMl: model.amountMl,
      notes: model.notes,
      feedingType: model.feedingType,
      diaperType: model.diaperType,
      endTime: model.endTime != null ? DateTime.parse(model.endTime!) : null,
    );
  }

  /// Entity ActivityType을 Model ActivityType으로 변환
  models.ActivityType _entityTypeToModelType(ActivityType entityType) {
    switch (entityType) {
      case ActivityType.sleep:
        return models.ActivityType.sleep;
      case ActivityType.feeding:
        return models.ActivityType.feeding;
      case ActivityType.diaper:
        return models.ActivityType.diaper;
      case ActivityType.play:
        return models.ActivityType.play;
      case ActivityType.health:
        return models.ActivityType.health;
    }
  }

  /// Model ActivityType을 Entity ActivityType으로 변환
  ActivityType _modelTypeToEntityType(models.ActivityType modelType) {
    switch (modelType) {
      case models.ActivityType.sleep:
        return ActivityType.sleep;
      case models.ActivityType.feeding:
        return ActivityType.feeding;
      case models.ActivityType.diaper:
        return ActivityType.diaper;
      case models.ActivityType.play:
        return ActivityType.play;
      case models.ActivityType.health:
        return ActivityType.health;
    }
  }
}
