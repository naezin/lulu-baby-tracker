/// AI 인사이트 엔티티
class InsightEntity {
  final String id;
  final String babyId;
  final String type; // 'sweet_spot', 'sleep_regression', 'feeding_pattern', etc.
  final String title;
  final String content;
  final List<String> tags;
  final DateTime timestamp;
  final String? relatedActivityId;
  final Map<String, dynamic>? metadata; // 추가 데이터
  final DateTime createdAt;

  const InsightEntity({
    required this.id,
    required this.babyId,
    required this.type,
    required this.title,
    required this.content,
    required this.tags,
    required this.timestamp,
    this.relatedActivityId,
    this.metadata,
    required this.createdAt,
  });

  InsightEntity copyWith({
    String? id,
    String? babyId,
    String? type,
    String? title,
    String? content,
    List<String>? tags,
    DateTime? timestamp,
    String? relatedActivityId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return InsightEntity(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      timestamp: timestamp ?? this.timestamp,
      relatedActivityId: relatedActivityId ?? this.relatedActivityId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InsightEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'InsightEntity(id: $id, type: $type, title: $title)';
}

/// 피드백 엔티티
class FeedbackEntity {
  final String id;
  final String babyId;
  final String insightId;
  final String rating; // 'helpful', 'not_helpful', 'neutral'
  final String? comment;
  final DateTime createdAt;

  const FeedbackEntity({
    required this.id,
    required this.babyId,
    required this.insightId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  @override
  String toString() => 'FeedbackEntity(insightId: $insightId, rating: $rating)';
}
