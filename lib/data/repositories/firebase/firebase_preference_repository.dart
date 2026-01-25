import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/repositories/i_preference_repository.dart';
import '../../../domain/entities/preference_entity.dart';
import '../../models/preference_model.dart';

/// Firebase Firestore 기반 Preference Repository 구현
class FirebasePreferenceRepository implements IPreferenceRepository {
  final FirebaseFirestore _firestore;

  FirebasePreferenceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ============================================================
  // Collection References
  // ============================================================

  CollectionReference<Map<String, dynamic>> _preferencesCollection(
      String babyId) {
    return _firestore
        .collection('babies')
        .doc(babyId)
        .collection('preferences');
  }

  CollectionReference<Map<String, dynamic>> _conversationsCollection(
      String babyId) {
    return _firestore
        .collection('babies')
        .doc(babyId)
        .collection('conversations');
  }

  // ============================================================
  // CRUD Operations - Preferences
  // ============================================================

  @override
  Future<void> savePreference({
    required String babyId,
    required PreferenceEntity preference,
  }) async {
    try {
      final model = PreferenceModel.fromEntity(preference);
      await _preferencesCollection(babyId)
          .doc(preference.id)
          .set(model.toJson());
    } catch (e) {
      throw Exception('Failed to save preference: $e');
    }
  }

  @override
  Future<List<PreferenceEntity>> getPreferences({
    required String babyId,
    String? category,
    int limit = 50,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _preferencesCollection(babyId)
          .orderBy('timestamp', descending: true);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => PreferenceModel.fromJson({...doc.data(), 'id': doc.id})
              .toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get preferences: $e');
    }
  }

  @override
  Future<PreferenceEntity?> getLatestPreference({
    required String babyId,
    required String category,
  }) async {
    try {
      final snapshot = await _preferencesCollection(babyId)
          .where('category', isEqualTo: category)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      return PreferenceModel.fromJson({...doc.data(), 'id': doc.id})
          .toEntity();
    } catch (e) {
      throw Exception('Failed to get latest preference: $e');
    }
  }

  @override
  Future<void> deletePreference({
    required String babyId,
    required String preferenceId,
  }) async {
    try {
      await _preferencesCollection(babyId).doc(preferenceId).delete();
    } catch (e) {
      throw Exception('Failed to delete preference: $e');
    }
  }

  // ============================================================
  // CRUD Operations - Conversation Snippets
  // ============================================================

  @override
  Future<void> saveConversationSnippet({
    required String babyId,
    required ConversationSnippet snippet,
  }) async {
    try {
      final model = ConversationSnippetModel.fromEntity(snippet);
      await _conversationsCollection(babyId).doc(snippet.id).set(model.toJson());
    } catch (e) {
      throw Exception('Failed to save conversation snippet: $e');
    }
  }

  @override
  Future<List<ConversationSnippet>> getConversationHistory({
    required String babyId,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _conversationsCollection(babyId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) =>
              ConversationSnippetModel.fromJson({...doc.data(), 'id': doc.id})
                  .toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get conversation history: $e');
    }
  }

  @override
  Future<List<ConversationSnippet>> getConversationsByTopic({
    required String babyId,
    required String topic,
    int limit = 10,
  }) async {
    try {
      final snapshot = await _conversationsCollection(babyId)
          .where('topics', arrayContains: topic)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) =>
              ConversationSnippetModel.fromJson({...doc.data(), 'id': doc.id})
                  .toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get conversations by topic: $e');
    }
  }

  @override
  Future<void> deleteConversationSnippet({
    required String babyId,
    required String snippetId,
  }) async {
    try {
      await _conversationsCollection(babyId).doc(snippetId).delete();
    } catch (e) {
      throw Exception('Failed to delete conversation snippet: $e');
    }
  }

  @override
  Future<void> deleteAllPersonalizationData({required String babyId}) async {
    try {
      // Delete all preferences
      final prefSnapshot = await _preferencesCollection(babyId).get();
      for (final doc in prefSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete all conversation snippets
      final convSnapshot = await _conversationsCollection(babyId).get();
      for (final doc in convSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete all personalization data: $e');
    }
  }

  // ============================================================
  // Stream Operations
  // ============================================================

  @override
  Stream<List<PreferenceEntity>> watchPreferences({
    required String babyId,
    String? category,
  }) {
    try {
      Query<Map<String, dynamic>> query = _preferencesCollection(babyId)
          .orderBy('timestamp', descending: true);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      return query.snapshots().map((snapshot) => snapshot.docs
          .map((doc) =>
              PreferenceModel.fromJson({...doc.data(), 'id': doc.id})
                  .toEntity())
          .toList());
    } catch (e) {
      throw Exception('Failed to watch preferences: $e');
    }
  }

  @override
  Stream<List<ConversationSnippet>> watchConversationHistory({
    required String babyId,
    int limit = 20,
  }) {
    try {
      return _conversationsCollection(babyId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ConversationSnippetModel.fromJson(
                  {...doc.data(), 'id': doc.id}).toEntity())
              .toList());
    } catch (e) {
      throw Exception('Failed to watch conversation history: $e');
    }
  }
}
