import '../../../domain/repositories/i_insight_repository.dart';
import '../../../domain/entities/insight.dart';

/// Mock Insight Repository (In-Memory)
class MockInsightRepository implements IInsightRepository {
  final List<Insight> _insights = [];

  @override
  Future<List<Insight>> getInsightsByUserId(String userId) async {
    return _insights.where((i) => i.userId == userId).toList();
  }

  @override
  Future<void> addInsight(Insight insight) async {
    _insights.add(insight);
  }

  @override
  Future<void> deleteInsight(String insightId) async {
    _insights.removeWhere((i) => i.id == insightId);
  }

  @override
  Future<Insight?> getInsightById(String insightId) async {
    try {
      return _insights.firstWhere((i) => i.id == insightId);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<List<Insight>> watchInsights(String userId) {
    return Stream.value(_insights.where((i) => i.userId == userId).toList());
  }
}
