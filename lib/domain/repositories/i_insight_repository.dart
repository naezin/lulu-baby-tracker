import '../entities/insight_entity.dart';

/// AI 인사이트 Repository 인터페이스
abstract class IInsightRepository {
  /// 인사이트 저장
  ///
  /// [babyId]: 아기 ID
  /// [insight]: 저장할 인사이트 엔티티
  Future<void> saveInsight({
    required String babyId,
    required InsightEntity insight,
  });

  /// 인사이트 목록 조회
  ///
  /// [babyId]: 아기 ID
  /// [type]: 인사이트 타입 필터 (null이면 모든 타입)
  /// [startDate]: 조회 시작일
  /// [endDate]: 조회 종료일
  /// [limit]: 최대 조회 개수
  Future<List<InsightEntity>> getInsights({
    required String babyId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  });

  /// 특정 인사이트 조회
  ///
  /// [babyId]: 아기 ID
  /// [insightId]: 인사이트 ID
  /// Returns: 인사이트 엔티티 또는 null
  Future<InsightEntity?> getInsightById({
    required String babyId,
    required String insightId,
  });

  /// 인사이트 삭제
  ///
  /// [babyId]: 아기 ID
  /// [insightId]: 삭제할 인사이트 ID
  Future<void> deleteInsight({
    required String babyId,
    required String insightId,
  });

  /// 피드백 저장
  ///
  /// [babyId]: 아기 ID
  /// [feedback]: 피드백 엔티티
  Future<void> saveFeedback({
    required String babyId,
    required FeedbackEntity feedback,
  });

  /// 특정 인사이트의 피드백 조회
  ///
  /// [babyId]: 아기 ID
  /// [insightId]: 인사이트 ID
  /// Returns: 피드백 엔티티 또는 null
  Future<FeedbackEntity?> getFeedbackByInsightId({
    required String babyId,
    required String insightId,
  });

  /// 최근 인사이트 조회
  ///
  /// [babyId]: 아기 ID
  /// [limit]: 조회 개수 (기본값: 10)
  Future<List<InsightEntity>> getRecentInsights({
    required String babyId,
    int limit = 10,
  });

  /// 특정 태그의 인사이트 조회
  ///
  /// [babyId]: 아기 ID
  /// [tag]: 태그
  /// [limit]: 조회 개수
  Future<List<InsightEntity>> getInsightsByTag({
    required String babyId,
    required String tag,
    int limit = 20,
  });

  /// 관련 활동의 인사이트 조회
  ///
  /// [babyId]: 아기 ID
  /// [activityId]: 활동 ID
  Future<List<InsightEntity>> getInsightsByActivity({
    required String babyId,
    required String activityId,
  });

  /// 실시간 인사이트 스트림
  ///
  /// [babyId]: 아기 ID
  /// [limit]: 조회 개수
  Stream<List<InsightEntity>> watchInsights({
    required String babyId,
    int limit = 50,
  });
}
