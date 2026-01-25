/// 사용자 선호도 엔티티
class PreferenceEntity {
  final String id;
  final String babyId;
  final String category; // 'parenting_style', 'sleep_approach', 'feeding_preference', etc.
  final String preference;
  final String context; // 선호도가 추론된 맥락
  final DateTime timestamp;
  final DateTime createdAt;

  const PreferenceEntity({
    required this.id,
    required this.babyId,
    required this.category,
    required this.preference,
    required this.context,
    required this.timestamp,
    required this.createdAt,
  });

  PreferenceEntity copyWith({
    String? id,
    String? babyId,
    String? category,
    String? preference,
    String? context,
    DateTime? timestamp,
    DateTime? createdAt,
  }) {
    return PreferenceEntity(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      category: category ?? this.category,
      preference: preference ?? this.preference,
      context: context ?? this.context,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PreferenceEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'PreferenceEntity(category: $category, preference: $preference)';
}

/// 대화 스니펫 엔티티 (AI 코칭 대화 기록)
class ConversationSnippet {
  final String id;
  final String babyId;
  final String userMessage;
  final String? assistantResponse;
  final List<String> topics; // 대화 주제 태그
  final DateTime timestamp;
  final DateTime createdAt;

  const ConversationSnippet({
    required this.id,
    required this.babyId,
    required this.userMessage,
    this.assistantResponse,
    required this.topics,
    required this.timestamp,
    required this.createdAt,
  });

  ConversationSnippet copyWith({
    String? id,
    String? babyId,
    String? userMessage,
    String? assistantResponse,
    List<String>? topics,
    DateTime? timestamp,
    DateTime? createdAt,
  }) {
    return ConversationSnippet(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      userMessage: userMessage ?? this.userMessage,
      assistantResponse: assistantResponse ?? this.assistantResponse,
      topics: topics ?? this.topics,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConversationSnippet && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ConversationSnippet(id: $id, topics: $topics, timestamp: $timestamp)';
}
