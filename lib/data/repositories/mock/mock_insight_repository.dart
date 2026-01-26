import '../../../domain/repositories/i_insight_repository.dart';
import '../../../domain/entities/insight_entity.dart';

/// Mock Insight Repository (In-Memory)
class MockInsightRepository implements IInsightRepository {
  final List<InsightEntity> _insights = [];
  final Map<String, FeedbackEntity> _feedbacks = {};

  @override
  Future<void> saveInsight({
    required String babyId,
    required InsightEntity insight,
  }) async {
    _insights.add(insight);
  }

  @override
  Future<List<InsightEntity>> getInsights({
    required String babyId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    var filtered = _insights.where((i) => i.babyId == babyId);

    if (type != null) {
      filtered = filtered.where((i) => i.type == type);
    }

    if (startDate != null) {
      filtered = filtered.where((i) => i.timestamp.isAfter(startDate));
    }

    if (endDate != null) {
      filtered = filtered.where((i) => i.timestamp.isBefore(endDate));
    }

    return filtered.take(limit).toList();
  }

  @override
  Future<InsightEntity?> getInsightById({
    required String babyId,
    required String insightId,
  }) async {
    try {
      return _insights.firstWhere(
        (i) => i.id == insightId && i.babyId == babyId,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteInsight({
    required String babyId,
    required String insightId,
  }) async {
    _insights.removeWhere((i) => i.id == insightId && i.babyId == babyId);
  }

  @override
  Future<void> saveFeedback({
    required String babyId,
    required FeedbackEntity feedback,
  }) async {
    _feedbacks[feedback.insightId] = feedback;
  }

  @override
  Future<FeedbackEntity?> getFeedbackByInsightId({
    required String babyId,
    required String insightId,
  }) async {
    return _feedbacks[insightId];
  }

  @override
  Future<List<InsightEntity>> getRecentInsights({
    required String babyId,
    int limit = 10,
  }) async {
    return _insights
        .where((i) => i.babyId == babyId)
        .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp))
        ..take(limit);
  }

  @override
  Future<List<InsightEntity>> getInsightsByTag({
    required String babyId,
    required String tag,
    int limit = 20,
  }) async {
    return _insights
        .where((i) => i.babyId == babyId && i.tags.contains(tag))
        .take(limit)
        .toList();
  }

  @override
  Future<List<InsightEntity>> getInsightsByActivity({
    required String babyId,
    required String activityId,
  }) async {
    return _insights
        .where((i) => i.babyId == babyId && i.relatedActivityId == activityId)
        .toList();
  }

  @override
  Stream<List<InsightEntity>> watchInsights({
    required String babyId,
    int limit = 50,
  }) {
    return Stream.value(
      _insights.where((i) => i.babyId == babyId).take(limit).toList(),
    );
  }
}
