/// 놀이 액티비티 데이터 모델
class PlayActivityModel {
  final String id;
  final String babyId;
  final PlayActivityType type;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationMinutes;
  final String? notes;
  final List<DevelopmentTag> developmentTags;
  final String createdAt;
  final String updatedAt;

  PlayActivityModel({
    required this.id,
    required this.babyId,
    required this.type,
    required this.startTime,
    this.endTime,
    this.durationMinutes,
    this.notes,
    this.developmentTags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlayActivityModel.fromJson(Map<String, dynamic> json) {
    return PlayActivityModel(
      id: json['id'] as String,
      babyId: json['babyId'] as String,
      type: PlayActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PlayActivityType.other,
      ),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      durationMinutes: json['durationMinutes'] as int?,
      notes: json['notes'] as String?,
      developmentTags: (json['developmentTags'] as List<dynamic>?)
              ?.map((e) => DevelopmentTag.values.firstWhere(
                    (tag) => tag.name == e,
                    orElse: () => DevelopmentTag.cognitive,
                  ))
              .toList() ??
          [],
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'babyId': babyId,
      'type': type.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'notes': notes,
      'developmentTags': developmentTags.map((e) => e.name).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  PlayActivityModel copyWith({
    String? id,
    String? babyId,
    PlayActivityType? type,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    String? notes,
    List<DevelopmentTag>? developmentTags,
    String? createdAt,
    String? updatedAt,
  }) {
    return PlayActivityModel(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
      developmentTags: developmentTags ?? this.developmentTags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 놀이 액티비티 타입
enum PlayActivityType {
  tummyTime, // 터미타임
  reading, // 책 읽기
  rattlePlaying, // 딸랑이 놀이
  massage, // 마사지
  walk, // 산책
  bath, // 목욕
  music, // 음악 감상
  singing, // 노래 부르기
  exercise, // 가벼운 운동
  sensoryPlay, // 감각 놀이
  other, // 기타
}

/// 발달 태그 (어떤 발달에 도움이 되는지)
enum DevelopmentTag {
  grossMotor, // 대근육 (목, 몸통 등)
  fineMotor, // 소근육 (손가락 등)
  cognitive, // 인지 발달
  visual, // 시각 발달
  auditory, // 청각 발달
  social, // 사회성 발달
  emotional, // 정서 발달
  language, // 언어 발달
}

/// 놀이 액티비티 확장 (추천 정보)
extension PlayActivityTypeExtension on PlayActivityType {
  String get emoji {
    switch (this) {
      case PlayActivityType.tummyTime:
        return '🤸';
      case PlayActivityType.reading:
        return '📚';
      case PlayActivityType.rattlePlaying:
        return '🔔';
      case PlayActivityType.massage:
        return '💆';
      case PlayActivityType.walk:
        return '🚶';
      case PlayActivityType.bath:
        return '🛁';
      case PlayActivityType.music:
        return '🎵';
      case PlayActivityType.singing:
        return '🎤';
      case PlayActivityType.exercise:
        return '🏃';
      case PlayActivityType.sensoryPlay:
        return '🎨';
      case PlayActivityType.other:
        return '🎯';
    }
  }

  List<DevelopmentTag> get developmentTags {
    switch (this) {
      case PlayActivityType.tummyTime:
        return [
          DevelopmentTag.grossMotor,
          DevelopmentTag.visual,
          DevelopmentTag.cognitive
        ];
      case PlayActivityType.reading:
        return [
          DevelopmentTag.visual,
          DevelopmentTag.cognitive,
          DevelopmentTag.language
        ];
      case PlayActivityType.rattlePlaying:
        return [
          DevelopmentTag.auditory,
          DevelopmentTag.fineMotor,
          DevelopmentTag.cognitive
        ];
      case PlayActivityType.massage:
        return [
          DevelopmentTag.emotional,
          DevelopmentTag.social,
          DevelopmentTag.grossMotor
        ];
      case PlayActivityType.walk:
        return [DevelopmentTag.visual, DevelopmentTag.cognitive];
      case PlayActivityType.bath:
        return [DevelopmentTag.fineMotor, DevelopmentTag.emotional];
      case PlayActivityType.music:
        return [
          DevelopmentTag.auditory,
          DevelopmentTag.cognitive,
          DevelopmentTag.emotional
        ];
      case PlayActivityType.singing:
        return [
          DevelopmentTag.auditory,
          DevelopmentTag.language,
          DevelopmentTag.social
        ];
      case PlayActivityType.exercise:
        return [DevelopmentTag.grossMotor, DevelopmentTag.cognitive];
      case PlayActivityType.sensoryPlay:
        return [
          DevelopmentTag.cognitive,
          DevelopmentTag.fineMotor,
          DevelopmentTag.visual
        ];
      case PlayActivityType.other:
        return [DevelopmentTag.cognitive];
    }
  }

  /// 72일령 아기에게 특히 추천되는 액티비티인지
  bool get isRecommendedFor72Days {
    switch (this) {
      case PlayActivityType.tummyTime:
      case PlayActivityType.reading:
      case PlayActivityType.rattlePlaying:
      case PlayActivityType.massage:
      case PlayActivityType.music:
        return true;
      default:
        return false;
    }
  }

  /// 권장 지속 시간 (분)
  int get recommendedDurationMinutes {
    switch (this) {
      case PlayActivityType.tummyTime:
        return 5; // 터미타임은 5분 정도로 짧게
      case PlayActivityType.reading:
        return 10;
      case PlayActivityType.rattlePlaying:
        return 10;
      case PlayActivityType.massage:
        return 15;
      case PlayActivityType.walk:
        return 20;
      case PlayActivityType.bath:
        return 15;
      case PlayActivityType.music:
        return 10;
      case PlayActivityType.singing:
        return 10;
      case PlayActivityType.exercise:
        return 10;
      case PlayActivityType.sensoryPlay:
        return 10;
      case PlayActivityType.other:
        return 10;
    }
  }
}

extension DevelopmentTagExtension on DevelopmentTag {
  String get emoji {
    switch (this) {
      case DevelopmentTag.grossMotor:
        return '💪';
      case DevelopmentTag.fineMotor:
        return '✋';
      case DevelopmentTag.cognitive:
        return '🧠';
      case DevelopmentTag.visual:
        return '👁️';
      case DevelopmentTag.auditory:
        return '👂';
      case DevelopmentTag.social:
        return '👥';
      case DevelopmentTag.emotional:
        return '💖';
      case DevelopmentTag.language:
        return '💬';
    }
  }
}
