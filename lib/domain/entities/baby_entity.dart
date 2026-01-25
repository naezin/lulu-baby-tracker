/// Baby 엔티티 (순수 도메인 모델)
class BabyEntity {
  final String id;
  final String userId;
  final String name;
  final DateTime birthDate;
  final DateTime? dueDate;
  final bool isPremature;
  final String? gender; // 'male', 'female', 'other'
  final String? photoUrl;

  // 출생 시 신체 정보
  final double? birthWeightKg;
  final double? birthHeightCm;
  final double? birthHeadCircumferenceCm;

  final String? weightUnit; // 'kg' or 'lb'
  final SleepGoals? sleepGoals;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BabyEntity({
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

  /// 생후 개월 수 계산
  int get ageInMonths {
    final now = DateTime.now();
    return ((now.year - birthDate.year) * 12 + now.month - birthDate.month);
  }

  /// 생후 일수 계산
  int get ageInDays {
    final now = DateTime.now();
    return now.difference(birthDate).inDays;
  }

  /// 생후 주수 계산
  int get ageInWeeks => (ageInDays / 7).floor();

  BabyEntity copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? birthDate,
    DateTime? dueDate,
    bool? isPremature,
    String? gender,
    String? photoUrl,
    double? birthWeightKg,
    double? birthHeightCm,
    double? birthHeadCircumferenceCm,
    String? weightUnit,
    SleepGoals? sleepGoals,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BabyEntity(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BabyEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'BabyEntity(id: $id, name: $name, age: ${ageInDays}days)';
}

/// 수면 목표 설정 (Value Object)
class SleepGoals {
  final int nightSleepHours; // 밤잠 목표 시간
  final int napCount; // 낮잠 횟수 목표
  final int totalDailySleepHours; // 하루 총 수면 시간 목표

  const SleepGoals({
    required this.nightSleepHours,
    required this.napCount,
    required this.totalDailySleepHours,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SleepGoals &&
        other.nightSleepHours == nightSleepHours &&
        other.napCount == napCount &&
        other.totalDailySleepHours == totalDailySleepHours;
  }

  @override
  int get hashCode =>
      nightSleepHours.hashCode ^ napCount.hashCode ^ totalDailySleepHours.hashCode;
}
