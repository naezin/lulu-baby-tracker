import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/repositories/i_insight_repository.dart';
import '../../../domain/entities/insight_entity.dart';
import '../../models/insight_model.dart';

/// Firebase Firestore 기반 Insight Repository 구현
class FirebaseInsightRepository implements IInsightRepository {
  final FirebaseFirestore _firestore;

  FirebaseInsightRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ============================================================
  // Collection References
  // ============================================================

  CollectionReference<Map<String, dynamic>> _insightsCollection(
      String babyId) {
    return _firestore.collection('babies').doc(babyId).collection('insights');
  }

  CollectionReference<Map<String, dynamic>> _feedbacksCollection(
      String babyId) {
    return _firestore.collection('babies').doc(babyId).collection('feedbacks');
  }

  // ============================================================
  // CRUD Operations - Insights
  // ============================================================

  @override
  Future<void> saveInsight({
    required String babyId,
    required InsightEntity insight,
  }) async {
    try {
      final model = InsightModel.fromEntity(insight);
      await _insightsCollection(babyId).doc(insight.id).set(model.toJson());
    } catch (e) {
      throw Exception('Failed to save insight: $e');
    }
  }

  @override
  Future<List<InsightEntity>> getInsights({
    required String babyId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _insightsCollection(babyId)
          .orderBy('timestamp', descending: true);

      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }

      if (startDate != null) {
        query = query.where('timestamp',
            isGreaterThanOrEqualTo: startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.where('timestamp',
            isLessThanOrEqualTo: endDate.toIso8601String());
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              InsightModel.fromJson({...doc.data(), 'id': doc.id}).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get insights: $e');
    }
  }

  @override
  Future<InsightEntity?> getInsightById({
    required String babyId,
    required String insightId,
  }) async {
    try {
      final doc = await _insightsCollection(babyId).doc(insightId).get();
      if (!doc.exists) return null;
      return InsightModel.fromJson({...doc.data()!, 'id': doc.id}).toEntity();
    } catch (e) {
      throw Exception('Failed to get insight by ID: $e');
    }
  }

  @override
  Future<void> deleteInsight({
    required String babyId,
    required String insightId,
  }) async {
    try {
      await _insightsCollection(babyId).doc(insightId).delete();
    } catch (e) {
      throw Exception('Failed to delete insight: $e');
    }
  }

  @override
  Future<List<InsightEntity>> getRecentInsights({
    required String babyId,
    int limit = 10,
  }) async {
    return getInsights(babyId: babyId, limit: limit);
  }

  @override
  Future<List<InsightEntity>> getInsightsByTag({
    required String babyId,
    required String tag,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _insightsCollection(babyId)
          .where('tags', arrayContains: tag)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) =>
              InsightModel.fromJson({...doc.data(), 'id': doc.id}).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get insights by tag: $e');
    }
  }

  @override
  Future<List<InsightEntity>> getInsightsByActivity({
    required String babyId,
    required String activityId,
  }) async {
    try {
      final snapshot = await _insightsCollection(babyId)
          .where('relatedActivityId', isEqualTo: activityId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
              InsightModel.fromJson({...doc.data(), 'id': doc.id}).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get insights by activity: $e');
    }
  }

  // ============================================================
  // CRUD Operations - Feedbacks
  // ============================================================

  @override
  Future<void> saveFeedback({
    required String babyId,
    required FeedbackEntity feedback,
  }) async {
    try {
      final model = FeedbackModel.fromEntity(feedback);
      await _feedbacksCollection(babyId).doc(feedback.id).set(model.toJson());
    } catch (e) {
      throw Exception('Failed to save feedback: $e');
    }
  }

  @override
  Future<FeedbackEntity?> getFeedbackByInsightId({
    required String babyId,
    required String insightId,
  }) async {
    try {
      final snapshot = await _feedbacksCollection(babyId)
          .where('insightId', isEqualTo: insightId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      return FeedbackModel.fromJson({...doc.data(), 'id': doc.id}).toEntity();
    } catch (e) {
      throw Exception('Failed to get feedback by insight ID: $e');
    }
  }

  // ============================================================
  // Stream Operations
  // ============================================================

  @override
  Stream<List<InsightEntity>> watchInsights({
    required String babyId,
    int limit = 50,
  }) {
    try {
      return _insightsCollection(babyId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => InsightModel.fromJson({...doc.data(), 'id': doc.id})
                  .toEntity())
              .toList());
    } catch (e) {
      throw Exception('Failed to watch insights: $e');
    }
  }
}
