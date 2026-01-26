import '../../../domain/repositories/i_preference_repository.dart';
import '../../../domain/entities/preference_entity.dart';

/// Mock Preference Repository (In-Memory)
class MockPreferenceRepository implements IPreferenceRepository {
  final List<PreferenceEntity> _preferences = [];
  final List<ConversationSnippet> _snippets = [];

  @override
  Future<void> savePreference({
    required String babyId,
    required PreferenceEntity preference,
  }) async {
    _preferences.add(preference);
  }

  @override
  Future<List<PreferenceEntity>> getPreferences({
    required String babyId,
    String? category,
    int limit = 50,
  }) async {
    var filtered = _preferences.where((p) => p.babyId == babyId);
    if (category != null) {
      filtered = filtered.where((p) => p.category == category);
    }
    return filtered.take(limit).toList();
  }

  @override
  Future<PreferenceEntity?> getLatestPreference({
    required String babyId,
    required String category,
  }) async {
    try {
      return _preferences
          .where((p) => p.babyId == babyId && p.category == category)
          .reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deletePreference({
    required String babyId,
    required String preferenceId,
  }) async {
    _preferences.removeWhere((p) => p.id == preferenceId && p.babyId == babyId);
  }

  @override
  Future<void> saveConversationSnippet({
    required String babyId,
    required ConversationSnippet snippet,
  }) async {
    _snippets.add(snippet);
  }

  @override
  Future<List<ConversationSnippet>> getConversationHistory({
    required String babyId,
    int limit = 20,
  }) async {
    return _snippets
        .where((s) => s.babyId == babyId)
        .take(limit)
        .toList();
  }

  @override
  Future<List<ConversationSnippet>> getConversationsByTopic({
    required String babyId,
    required String topic,
    int limit = 10,
  }) async {
    return _snippets
        .where((s) => s.babyId == babyId && s.topics.contains(topic))
        .take(limit)
        .toList();
  }

  @override
  Future<void> deleteConversationSnippet({
    required String babyId,
    required String snippetId,
  }) async {
    _snippets.removeWhere((s) => s.id == snippetId && s.babyId == babyId);
  }

  @override
  Future<void> deleteAllPersonalizationData({
    required String babyId,
  }) async {
    _preferences.removeWhere((p) => p.babyId == babyId);
    _snippets.removeWhere((s) => s.babyId == babyId);
  }

  @override
  Stream<List<PreferenceEntity>> watchPreferences({
    required String babyId,
    String? category,
  }) {
    var filtered = _preferences.where((p) => p.babyId == babyId);
    if (category != null) {
      filtered = filtered.where((p) => p.category == category);
    }
    return Stream.value(filtered.toList());
  }

  @override
  Stream<List<ConversationSnippet>> watchConversationHistory({
    required String babyId,
    int limit = 20,
  }) {
    return Stream.value(
      _snippets.where((s) => s.babyId == babyId).take(limit).toList(),
    );
  }
}
