import '../../domain/entities/baby_entity.dart' as entity;

/// Baby 데이터 모델
class BabyModel {
  final String id;
  final String userId;
  final String name;
  final String birthDate; // ISO 8601 format
  final String? dueDate; // ISO 8601 format (조산아의 경우)
  final bool isPremature;
  final bool useCorrectedAge; // 교정 연령 사용 여부
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
    this.useCorrectedAge = true, // 기본값: 조산아면 교정 적용
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
      useCorrectedAge: json['useCorrectedAge'] as bool? ?? true, // 마이그레이션 기본값
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
      'useCorrectedAge': useCorrectedAge,
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

  // Helper: 생후 일수 계산
  int get ageInDays {
    final birth = DateTime.parse(birthDate);
    final now = DateTime.now();
    return now.difference(birth).inDays;
  }

  /// 조산 주수 계산
  int get pretermWeeks {
    if (dueDate == null || !isPremature) return 0;

    final birth = DateTime.parse(birthDate);
    final due = DateTime.parse(dueDate!);
    final diffDays = due.difference(birth).inDays;

    return diffDays > 0 ? (diffDays / 7).ceil() : 0;
  }

  /// WHO 표준 월령 계산 (정확한 방식)
  double _calculateAgeInMonths(DateTime birthDateTime) {
    final now = DateTime.now();

    // 월 단위 계산
    int months = (now.year - birthDateTime.year) * 12 +
                 (now.month - birthDateTime.month);

    // 일수 비율 계산 (더 정확한 방식)
    if (now.day < birthDateTime.day) {
      months--;
      // 이전 달의 남은 일수 + 현재 달의 일수
      final prevMonth = DateTime(now.year, now.month, 0);
      final daysInPrevMonth = prevMonth.day;
      final daysPassed = (daysInPrevMonth - birthDateTime.day) + now.day;
      return months + (daysPassed / daysInPrevMonth);
    } else {
      final daysPassed = now.day - birthDateTime.day;
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      return months + (daysPassed / daysInMonth);
    }
  }

  /// 실제 월령 (정수)
  int get ageInMonths {
    final birth = DateTime.parse(birthDate);
    final now = DateTime.now();
    return ((now.year - birth.year) * 12 + now.month - birth.month);
  }

  /// 실제 월령 (소수점, WHO 표준)
  double get actualAgeInMonths {
    final birth = DateTime.parse(birthDate);
    return _calculateAgeInMonths(birth);
  }

  /// 교정 월령 (소수점, WHO 표준)
  double get correctedAgeInMonths {
    if (!isPremature || !useCorrectedAge) return actualAgeInMonths;

    final birth = DateTime.parse(birthDate);
    final correctedBirth = birth.add(Duration(days: pretermWeeks * 7));

    final correctedAge = _calculateAgeInMonths(correctedBirth);
    return correctedAge > 0 ? correctedAge : 0;
  }

  /// Sweet Spot 계산에 사용할 월령
  double get effectiveAgeInMonths {
    return (isPremature && useCorrectedAge)
        ? correctedAgeInMonths
        : actualAgeInMonths;
  }

  BabyModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? birthDate,
    String? dueDate,
    bool? isPremature,
    bool? useCorrectedAge,
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
      useCorrectedAge: useCorrectedAge ?? this.useCorrectedAge,
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
