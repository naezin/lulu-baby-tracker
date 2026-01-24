import 'package:cloud_firestore/cloud_firestore.dart';

/// 개인화 메모리 서비스
class PersonalizationMemoryService {
  final FirebaseFirestore _firestore;

  PersonalizationMemoryService({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// 사용자 피드백 메모리 저장
  Future<void> saveUserPreference({
    required String babyId,
    required String category,
    required String preference,
    required String context,
  }) async {
    await _firestore
        .collection('babies')
        .doc(babyId)
        .collection('preferences')
        .add({
      'category': category,
      'preference': preference,
      'context': context,
      'timestamp': Timestamp.now(),
    });
  }

  /// 사용자 선호도 조회
  Future<List<UserPreference>> getUserPreferences({
    required String babyId,
    String? category,
    int limit = 50,
  }) async {
    Query query = _firestore
        .collection('babies')
        .doc(babyId)
        .collection('preferences')
        .orderBy('timestamp', descending: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    final snapshot = await query.limit(limit).get();

    return snapshot.docs
        .map((doc) => UserPreference.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }))
        .toList();
  }

  /// 대화 이력 저장 (개인화를 위한)
  Future<void> saveConversationSnippet({
    required String babyId,
    required String userMessage,
    required String? aiResponse,
    required String extractedContext,
  }) async {
    await _firestore
        .collection('babies')
        .doc(babyId)
        .collection('conversation_memory')
        .add({
      'userMessage': userMessage,
      'aiResponse': aiResponse,
      'extractedContext': extractedContext,
      'timestamp': Timestamp.now(),
    });
  }

  /// 개인화 컨텍스트 생성
  Future<String> buildPersonalizedContext({
    required String babyId,
    required String currentSituation,
  }) async {
    // 최근 선호도 조회
    final preferences = await getUserPreferences(
      babyId: babyId,
      limit: 10,
    );

    if (preferences.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    buffer.writeln('\n## 부모님이 이전에 말씀하신 내용:');

    // 수면 관련 선호도
    final sleepPrefs = preferences.where((p) => p.category == 'sleep').toList();
    if (sleepPrefs.isNotEmpty) {
      buffer.writeln('\n수면 관련:');
      for (final pref in sleepPrefs.take(3)) {
        buffer.writeln('- ${pref.preference} (${_formatTimestamp(pref.timestamp)})');
      }
    }

    // 수유 관련 선호도
    final feedingPrefs = preferences.where((p) => p.category == 'feeding').toList();
    if (feedingPrefs.isNotEmpty) {
      buffer.writeln('\n수유 관련:');
      for (final pref in feedingPrefs.take(3)) {
        buffer.writeln('- ${pref.preference} (${_formatTimestamp(pref.timestamp)})');
      }
    }

    // 양육 스타일
    final parentingPrefs = preferences.where((p) => p.category == 'parenting_style').toList();
    if (parentingPrefs.isNotEmpty) {
      buffer.writeln('\n양육 스타일:');
      for (final pref in parentingPrefs.take(3)) {
        buffer.writeln('- ${pref.preference}');
      }
    }

    buffer.writeln('\n이 정보를 참고하여 연속성 있고 개인화된 조언을 제공해주세요.');

    return buffer.toString();
  }

  /// 대화에서 선호도 자동 추출 및 저장
  Future<void> extractAndSavePreferences({
    required String babyId,
    required String userMessage,
  }) async {
    // 키워드 기반 선호도 추출
    final keywords = {
      'sleep': ['안아', '혼자', '침대', '엄마랑', '아빠랑', '재워', '수면'],
      'feeding': ['모유', '분유', '수유', '먹', '젖병'],
      'soothing': ['달래', '토닥', '백색소음', '흔들', '노래'],
    };

    for (final category in keywords.keys) {
      for (final keyword in keywords[category]!) {
        if (userMessage.contains(keyword)) {
          // 문맥 추출 (간단한 방법)
          final sentences = userMessage.split('.');
          for (final sentence in sentences) {
            if (sentence.contains(keyword)) {
              await saveUserPreference(
                babyId: babyId,
                category: category,
                preference: sentence.trim(),
                context: userMessage,
              );
              break;
            }
          }
          break;
        }
      }
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays > 7) {
      return '${diff.inDays ~/ 7}주 전';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}일 전';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}시간 전';
    } else {
      return '방금 전';
    }
  }
}

/// 사용자 선호도 모델
class UserPreference {
  final String id;
  final String category;
  final String preference;
  final String context;
  final DateTime timestamp;

  UserPreference({
    required this.id,
    required this.category,
    required this.preference,
    required this.context,
    required this.timestamp,
  });

  factory UserPreference.fromJson(Map<String, dynamic> json) {
    return UserPreference(
      id: json['id'] as String,
      category: json['category'] as String,
      preference: json['preference'] as String,
      context: json['context'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'preference': preference,
      'context': context,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
