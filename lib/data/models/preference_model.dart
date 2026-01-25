import '../../domain/entities/preference_entity.dart';

/// 선호도 모델 (Data Layer)
class PreferenceModel {
  final String id;
  final String babyId;
  final String category;
  final String preference;
  final String context;
  final String timestamp; // ISO 8601
  final String createdAt; // ISO 8601

  PreferenceModel({
    required this.id,
    required this.babyId,
    required this.category,
    required this.preference,
    required this.context,
    required this.timestamp,
    required this.createdAt,
  });

  factory PreferenceModel.fromJson(Map<String, dynamic> json) {
    return PreferenceModel(
      id: json['id'] as String,
      babyId: json['babyId'] as String,
      category: json['category'] as String,
      preference: json['preference'] as String,
      context: json['context'] as String,
      timestamp: json['timestamp'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'babyId': babyId,
      'category': category,
      'preference': preference,
      'context': context,
      'timestamp': timestamp,
      'createdAt': createdAt,
    };
  }

  /// Entity → Model 변환
  factory PreferenceModel.fromEntity(PreferenceEntity entity) {
    return PreferenceModel(
      id: entity.id,
      babyId: entity.babyId,
      category: entity.category,
      preference: entity.preference,
      context: entity.context,
      timestamp: entity.timestamp.toIso8601String(),
      createdAt: entity.createdAt.toIso8601String(),
    );
  }

  /// Model → Entity 변환
  PreferenceEntity toEntity() {
    return PreferenceEntity(
      id: id,
      babyId: babyId,
      category: category,
      preference: preference,
      context: context,
      timestamp: DateTime.parse(timestamp),
      createdAt: DateTime.parse(createdAt),
    );
  }
}

/// 대화 스니펫 모델
class ConversationSnippetModel {
  final String id;
  final String babyId;
  final String userMessage;
  final String? assistantResponse;
  final List<String> topics;
  final String timestamp; // ISO 8601
  final String createdAt; // ISO 8601

  ConversationSnippetModel({
    required this.id,
    required this.babyId,
    required this.userMessage,
    this.assistantResponse,
    required this.topics,
    required this.timestamp,
    required this.createdAt,
  });

  factory ConversationSnippetModel.fromJson(Map<String, dynamic> json) {
    return ConversationSnippetModel(
      id: json['id'] as String,
      babyId: json['babyId'] as String,
      userMessage: json['userMessage'] as String,
      assistantResponse: json['assistantResponse'] as String?,
      topics:
          (json['topics'] as List<dynamic>).map((e) => e as String).toList(),
      timestamp: json['timestamp'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'babyId': babyId,
      'userMessage': userMessage,
      'assistantResponse': assistantResponse,
      'topics': topics,
      'timestamp': timestamp,
      'createdAt': createdAt,
    };
  }

  /// Entity → Model 변환
  factory ConversationSnippetModel.fromEntity(ConversationSnippet entity) {
    return ConversationSnippetModel(
      id: entity.id,
      babyId: entity.babyId,
      userMessage: entity.userMessage,
      assistantResponse: entity.assistantResponse,
      topics: entity.topics,
      timestamp: entity.timestamp.toIso8601String(),
      createdAt: entity.createdAt.toIso8601String(),
    );
  }

  /// Model → Entity 변환
  ConversationSnippet toEntity() {
    return ConversationSnippet(
      id: id,
      babyId: babyId,
      userMessage: userMessage,
      assistantResponse: assistantResponse,
      topics: topics,
      timestamp: DateTime.parse(timestamp),
      createdAt: DateTime.parse(createdAt),
    );
  }
}
