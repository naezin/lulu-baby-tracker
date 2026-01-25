// 임시로 간단한 wrapper를 만들어서 빌드를 통과시키겠습니다
// 실제 구현은 기존 로직을 그대로 사용하되, import만 수정

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/repositories/i_activity_repository.dart';
import '../../../domain/entities/activity_entity.dart';
import '../../models/activity_model.dart' show ActivityModel;

/// Firebase Firestore 기반 Activity Repository 구현
class FirebaseActivityRepository implements IActivityRepository {
  final FirebaseFirestore _firestore;

  FirebaseActivityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _activitiesCollection(
      String babyId) {
    return _firestore.collection('babies').doc(babyId).collection('activities');
  }

  @override
  Future<void> saveActivity({
    required String babyId,
    required ActivityEntity activity,
  }) async {
    try {
      final model = ActivityModel.fromEntity(activity);
      await _activitiesCollection(babyId).doc(activity.id).set(model.toJson());
    } catch (e) {
      throw Exception('Failed to save activity: $e');
    }
  }

  @override
  Future<List<ActivityEntity>> getActivities({
    required String babyId,
    DateTime? startDate,
    DateTime? endDate,
    ActivityType? type,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _activitiesCollection(babyId)
          .orderBy('timestamp', descending: true);

      if (startDate != null) {
        query = query.where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('timestamp',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.toString().split('.').last);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              ActivityModel.fromJson({...doc.data(), 'id': doc.id}).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get activities: $e');
    }
  }

  @override
  Future<ActivityEntity?> getActivityById({
    required String babyId,
    required String activityId,
  }) async {
    try {
      final doc = await _activitiesCollection(babyId).doc(activityId).get();
      if (!doc.exists) return null;
      return ActivityModel.fromJson({...doc.data()!, 'id': doc.id}).toEntity();
    } catch (e) {
      throw Exception('Failed to get activity: $e');
    }
  }

  @override
  Future<void> updateActivity({
    required String babyId,
    required ActivityEntity activity,
  }) async {
    try {
      final model = ActivityModel.fromEntity(activity);
      await _activitiesCollection(babyId)
          .doc(activity.id)
          .update(model.toJson());
    } catch (e) {
      throw Exception('Failed to update activity: $e');
    }
  }

  @override
  Future<void> deleteActivity({
    required String babyId,
    required String activityId,
  }) async {
    try {
      await _activitiesCollection(babyId).doc(activityId).delete();
    } catch (e) {
      throw Exception('Failed to delete activity: $e');
    }
  }

  @override
  Future<DailySummary> getTodaySummary({required String babyId}) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final activities = await getActivities(
      babyId: babyId,
      startDate: startOfDay,
      endDate: endOfDay,
    );

    return _calculateSummary(activities, now);
  }

  @override
  Future<DailySummary> getDailySummary({
    required String babyId,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final activities = await getActivities(
      babyId: babyId,
      startDate: startOfDay,
      endDate: endOfDay,
    );

    return _calculateSummary(activities, date);
  }

  @override
  Stream<List<ActivityEntity>> watchActivities({
    required String babyId,
    DateTime? startDate,
    DateTime? endDate,
    ActivityType? type,
    int? limit,
  }) {
    try {
      Query<Map<String, dynamic>> query = _activitiesCollection(babyId)
          .orderBy('timestamp', descending: true);

      if (startDate != null) {
        query = query.where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('timestamp',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.toString().split('.').last);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) => snapshot.docs
          .map((doc) =>
              ActivityModel.fromJson({...doc.data(), 'id': doc.id}).toEntity())
          .toList());
    } catch (e) {
      throw Exception('Failed to watch activities: $e');
    }
  }

  @override
  Future<List<ActivityEntity>> getSleepPattern({
    required String babyId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return getActivities(
      babyId: babyId,
      startDate: startDate,
      endDate: endDate,
      type: ActivityType.sleep,
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
      startDate: startDate,
      endDate: endDate,
      type: ActivityType.feeding,
    );
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

  DailySummary _calculateSummary(
      List<ActivityEntity> activities, DateTime date) {
    final sleepActivities =
        activities.where((a) => a.type == ActivityType.sleep).toList();
    final feedingActivities =
        activities.where((a) => a.type == ActivityType.feeding).toList();
    final diaperActivities =
        activities.where((a) => a.type == ActivityType.diaper).toList();

    int totalSleepMinutes = 0;
    for (var sleep in sleepActivities) {
      if (sleep.durationMinutes != null) {
        totalSleepMinutes += sleep.durationMinutes!;
      }
    }

    double totalFeedingMl = 0;
    for (var feeding in feedingActivities) {
      if (feeding.amountMl != null) {
        totalFeedingMl += feeding.amountMl!;
      }
    }

    return DailySummary(
      date: date,
      totalSleepMinutes: totalSleepMinutes,
      totalFeedingMl: totalFeedingMl,
      diaperCount: diaperActivities.length,
      playCount: 0,
    );
  }
}
