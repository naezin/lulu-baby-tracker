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
  final double? weightKg; // 몸무게 (kg)
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
    this.weightKg,
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
      weightKg: json['weightKg'] as double?,
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
      'weightKg': weightKg,
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

  BabyModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? birthDate,
    String? dueDate,
    bool? isPremature,
    String? gender,
    String? photoUrl,
    double? weightKg,
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
      weightKg: weightKg ?? this.weightKg,
      weightUnit: weightUnit ?? this.weightUnit,
      sleepGoals: sleepGoals ?? this.sleepGoals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
