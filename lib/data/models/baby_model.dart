import '../../domain/entities/baby_entity.dart' as entity;

/// Baby 데이터 모델
class BabyModel {
  final String id;
  final String userId;
  final String name;
  final String birthDate; // ISO 8601 format
  final String? dueDate; // ISO 8601 format (조산아의 경우)
  final bool isPremature;
  final String? gender; // 'male', 'female', 'other'
  final String? photoUrl;

  // 출생 시 신체 정보 (필수)
  final double? birthWeightKg; // 출생 시 체중 (kg)
  final double? birthHeightCm; // 출생 시 키 (cm)
  final double? birthHeadCircumferenceCm; // 출생 시 머리둘레 (cm)

  final String? weightUnit; // 'kg' or 'lb'
  final SleepGoals? sleepGoals;
  final String createdAt;
  final String updatedAt;

  BabyModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.birthDate,
    this.dueDate,
    required this.isPremature,
    this.gender,
    this.photoUrl,
    this.birthWeightKg,
    this.birthHeightCm,
    this.birthHeadCircumferenceCm,
    this.weightUnit,
    this.sleepGoals,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BabyModel.fromJson(Map<String, dynamic> json) {
    return BabyModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      birthDate: json['birthDate'] as String,
      dueDate: json['dueDate'] as String?,
      isPremature: json['isPremature'] as bool? ?? false,
      gender: json['gender'] as String?,
      photoUrl: json['photoUrl'] as String?,
      birthWeightKg: json['birthWeightKg'] as double?,
      birthHeightCm: json['birthHeightCm'] as double?,
      birthHeadCircumferenceCm: json['birthHeadCircumferenceCm'] as double?,
      weightUnit: json['weightUnit'] as String?,
      sleepGoals: json['sleepGoals'] != null
          ? SleepGoals.fromJson(json['sleepGoals'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'birthDate': birthDate,
      'dueDate': dueDate,
      'isPremature': isPremature,
      'gender': gender,
      'photoUrl': photoUrl,
      'birthWeightKg': birthWeightKg,
      'birthHeightCm': birthHeightCm,
      'birthHeadCircumferenceCm': birthHeadCircumferenceCm,
      'weightUnit': weightUnit,
      'sleepGoals': sleepGoals?.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Helper: 생후 개월 수 계산
  int get ageInMonths {
    final birth = DateTime.parse(birthDate);
    final now = DateTime.now();
    return ((now.year - birth.year) * 12 + now.month - birth.month);
  }

  // Helper: 생후 일수 계산
  int get ageInDays {
    final birth = DateTime.parse(birthDate);
    final now = DateTime.now();
    return now.difference(birth).inDays;
  }

  /// 교정 월령 (조산아용) - 조산아가 아니면 일반 월령 반환
  int get correctedAgeInMonths {
    if (!isPremature || dueDate == null) {
      return ageInMonths;
    }

    final birth = DateTime.parse(birthDate);
    final due = DateTime.parse(dueDate!);
    final prematureWeeks = due.difference(birth).inDays ~/ 7;

    final correctedBirthDate = birth.add(Duration(days: prematureWeeks * 7));
    final now = DateTime.now();

    int months = (now.year - correctedBirthDate.year) * 12 +
                 now.month - correctedBirthDate.month;
    if (now.day < correctedBirthDate.day) months--;

    return months > 0 ? months : 0;
  }

  BabyModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? birthDate,
    String? dueDate,
    bool? isPremature,
    String? gender,
    String? photoUrl,
    double? birthWeightKg,
    double? birthHeightCm,
    double? birthHeadCircumferenceCm,
    String? weightUnit,
    SleepGoals? sleepGoals,
    String? createdAt,
    String? updatedAt,
  }) {
    return BabyModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      dueDate: dueDate ?? this.dueDate,
      isPremature: isPremature ?? this.isPremature,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      birthWeightKg: birthWeightKg ?? this.birthWeightKg,
      birthHeightCm: birthHeightCm ?? this.birthHeightCm,
      birthHeadCircumferenceCm: birthHeadCircumferenceCm ?? this.birthHeadCircumferenceCm,
      weightUnit: weightUnit ?? this.weightUnit,
      sleepGoals: sleepGoals ?? this.sleepGoals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Entity → Model 변환
  factory BabyModel.fromEntity(entity.BabyEntity entityObj) {
    return BabyModel(
      id: entityObj.id,
      userId: entityObj.userId,
      name: entityObj.name,
      birthDate: entityObj.birthDate.toIso8601String(),
      dueDate: entityObj.dueDate?.toIso8601String(),
      isPremature: entityObj.isPremature,
      gender: entityObj.gender,
      photoUrl: entityObj.photoUrl,
      birthWeightKg: entityObj.birthWeightKg,
      birthHeightCm: entityObj.birthHeightCm,
      birthHeadCircumferenceCm: entityObj.birthHeadCircumferenceCm,
      weightUnit: entityObj.weightUnit,
      sleepGoals: entityObj.sleepGoals != null
          ? SleepGoals(
              nightSleepHours: entityObj.sleepGoals!.nightSleepHours,
              napCount: entityObj.sleepGoals!.napCount,
              totalDailySleepHours: entityObj.sleepGoals!.totalDailySleepHours,
            )
          : null,
      createdAt: entityObj.createdAt.toIso8601String(),
      updatedAt: entityObj.updatedAt.toIso8601String(),
    );
  }

  /// Model → Entity 변환
  entity.BabyEntity toEntity() {
    return entity.BabyEntity(
      id: id,
      userId: userId,
      name: name,
      birthDate: DateTime.parse(birthDate),
      dueDate: dueDate != null ? DateTime.parse(dueDate!) : null,
      isPremature: isPremature,
      gender: gender,
      photoUrl: photoUrl,
      birthWeightKg: birthWeightKg,
      birthHeightCm: birthHeightCm,
      birthHeadCircumferenceCm: birthHeadCircumferenceCm,
      weightUnit: weightUnit,
      sleepGoals: sleepGoals != null
          ? entity.SleepGoals(
              nightSleepHours: sleepGoals!.nightSleepHours,
              napCount: sleepGoals!.napCount,
              totalDailySleepHours: sleepGoals!.totalDailySleepHours,
            )
          : null,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}

/// 수면 목표 설정
class SleepGoals {
  final int nightSleepHours; // 밤잠 목표 시간
  final int napCount; // 낮잠 횟수 목표
  final int totalDailySleepHours; // 하루 총 수면 시간 목표

  SleepGoals({
    required this.nightSleepHours,
    required this.napCount,
    required this.totalDailySleepHours,
  });

  factory SleepGoals.fromJson(Map<String, dynamic> json) {
    return SleepGoals(
      nightSleepHours: json['nightSleepHours'] as int,
      napCount: json['napCount'] as int,
      totalDailySleepHours: json['totalDailySleepHours'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nightSleepHours': nightSleepHours,
      'napCount': napCount,
      'totalDailySleepHours': totalDailySleepHours,
    };
  }
}
