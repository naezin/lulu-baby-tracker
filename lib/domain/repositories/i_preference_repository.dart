import '../entities/preference_entity.dart';

/// 사용자 선호도 Repository 인터페이스
abstract class IPreferenceRepository {
  /// 선호도 저장
  ///
  /// [babyId]: 아기 ID
  /// [preference]: 저장할 선호도 엔티티
  Future<void> savePreference({
    required String babyId,
    required PreferenceEntity preference,
  });

  /// 선호도 목록 조회
  ///
  /// [babyId]: 아기 ID
  /// [category]: 카테고리 필터 (null이면 모든 카테고리)
  /// [limit]: 최대 조회 개수
  Future<List<PreferenceEntity>> getPreferences({
    required String babyId,
    String? category,
    int limit = 50,
  });

  /// 특정 카테고리의 최신 선호도 조회
  ///
  /// [babyId]: 아기 ID
  /// [category]: 카테고리
  /// Returns: 선호도 엔티티 또는 null
  Future<PreferenceEntity?> getLatestPreference({
    required String babyId,
    required String category,
  });

  /// 선호도 삭제
  ///
  /// [babyId]: 아기 ID
  /// [preferenceId]: 삭제할 선호도 ID
  Future<void> deletePreference({
    required String babyId,
    required String preferenceId,
  });

  /// 대화 스니펫 저장
  ///
  /// [babyId]: 아기 ID
  /// [snippet]: 저장할 대화 스니펫 엔티티
  Future<void> saveConversationSnippet({
    required String babyId,
    required ConversationSnippet snippet,
  });

  /// 대화 히스토리 조회
  ///
  /// [babyId]: 아기 ID
  /// [limit]: 최대 조회 개수
  Future<List<ConversationSnippet>> getConversationHistory({
    required String babyId,
    int limit = 20,
  });

  /// 특정 주제의 대화 스니펫 조회
  ///
  /// [babyId]: 아기 ID
  /// [topic]: 주제 태그
  /// [limit]: 최대 조회 개수
  Future<List<ConversationSnippet>> getConversationsByTopic({
    required String babyId,
    required String topic,
    int limit = 10,
  });

  /// 대화 스니펫 삭제
  ///
  /// [babyId]: 아기 ID
  /// [snippetId]: 삭제할 스니펫 ID
  Future<void> deleteConversationSnippet({
    required String babyId,
    required String snippetId,
  });

  /// 모든 개인화 데이터 삭제 (계정 삭제 시)
  ///
  /// [babyId]: 아기 ID
  Future<void> deleteAllPersonalizationData({
    required String babyId,
  });

  /// 실시간 선호도 스트림
  ///
  /// [babyId]: 아기 ID
  /// [category]: 카테고리 필터
  Stream<List<PreferenceEntity>> watchPreferences({
    required String babyId,
    String? category,
  });

  /// 실시간 대화 히스토리 스트림
  ///
  /// [babyId]: 아기 ID
  /// [limit]: 조회 개수
  Stream<List<ConversationSnippet>> watchConversationHistory({
    required String babyId,
    int limit = 20,
  });
}
