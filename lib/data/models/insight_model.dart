import '../../domain/entities/insight_entity.dart';

/// AI 인사이트 모델 (Data Layer)
class InsightModel {
  final String id;
  final String babyId;
  final String type;
  final String title;
  final String content;
  final List<String> tags;
  final String timestamp; // ISO 8601
  final String? relatedActivityId;
  final Map<String, dynamic>? metadata;
  final String createdAt; // ISO 8601

  InsightModel({
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

  factory InsightModel.fromJson(Map<String, dynamic> json) {
    return InsightModel(
      id: json['id'] as String,
      babyId: json['babyId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      timestamp: json['timestamp'] as String,
      relatedActivityId: json['relatedActivityId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'babyId': babyId,
      'type': type,
      'title': title,
      'content': content,
      'tags': tags,
      'timestamp': timestamp,
      'relatedActivityId': relatedActivityId,
      'metadata': metadata,
      'createdAt': createdAt,
    };
  }

  /// Entity → Model 변환
  factory InsightModel.fromEntity(InsightEntity entity) {
    return InsightModel(
      id: entity.id,
      babyId: entity.babyId,
      type: entity.type,
      title: entity.title,
      content: entity.content,
      tags: entity.tags,
      timestamp: entity.timestamp.toIso8601String(),
      relatedActivityId: entity.relatedActivityId,
      metadata: entity.metadata,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }

  /// Model → Entity 변환
  InsightEntity toEntity() {
    return InsightEntity(
      id: id,
      babyId: babyId,
      type: type,
      title: title,
      content: content,
      tags: tags,
      timestamp: DateTime.parse(timestamp),
      relatedActivityId: relatedActivityId,
      metadata: metadata,
      createdAt: DateTime.parse(createdAt),
    );
  }
}

/// 피드백 모델
class FeedbackModel {
  final String id;
  final String babyId;
  final String insightId;
  final String rating;
  final String? comment;
  final String createdAt; // ISO 8601

  FeedbackModel({
    required this.id,
    required this.babyId,
    required this.insightId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] as String,
      babyId: json['babyId'] as String,
      insightId: json['insightId'] as String,
      rating: json['rating'] as String,
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'babyId': babyId,
      'insightId': insightId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }

  /// Entity → Model 변환
  factory FeedbackModel.fromEntity(FeedbackEntity entity) {
    return FeedbackModel(
      id: entity.id,
      babyId: entity.babyId,
      insightId: entity.insightId,
      rating: entity.rating,
      comment: entity.comment,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }

  /// Model → Entity 변환
  FeedbackEntity toEntity() {
    return FeedbackEntity(
      id: id,
      babyId: babyId,
      insightId: insightId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
