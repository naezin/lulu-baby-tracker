/// 활동 타입 (Domain Entity)
enum ActivityType {
  sleep,
  feeding,
  diaper,
  play,
  health,
}

/// 활동 기록 엔티티 (순수 도메인 모델)
///
/// 이 클래스는 인프라(Firebase, Supabase 등)에 대한 의존성이 전혀 없습니다.
/// DateTime을 직접 사용하여 순수한 비즈니스 로직만 표현합니다.
class ActivityEntity {
  final String id;
  final ActivityType type;
  final DateTime timestamp;
  final DateTime? endTime;
  final int? durationMinutes;
  final String? notes;

  // Sleep specific
  final String? sleepLocation; // 'crib', 'bed', 'stroller'
  final String? sleepQuality; // 'good', 'fair', 'poor'

  // Feeding specific
  final String? feedingType; // 'bottle', 'breast', 'solid'
  final double? amountMl;
  final double? amountOz;
  final String? breastSide; // 'left', 'right', 'both'

  // Diaper specific
  final String? diaperType; // 'wet', 'dirty', 'both'

  // Play specific
  final String? playActivityType;
  final List<String>? developmentTags;

  // Health specific
  final double? temperatureCelsius;
  final String? temperatureUnit; // 'celsius', 'fahrenheit'
  final String? medicationType; // 'fever_reducer', 'antibiotic', 'other'
  final String? medicationName;
  final double? dosageAmount;
  final String? dosageUnit; // 'ml', 'mg'
  final DateTime? nextDoseTime;
  final double? weightKg;
  final double? lengthCm;
  final double? headCircumferenceCm;

  const ActivityEntity({
    required this.id,
    required this.type,
    required this.timestamp,
    this.endTime,
    this.durationMinutes,
    this.notes,
    this.sleepLocation,
    this.sleepQuality,
    this.feedingType,
    this.amountMl,
    this.amountOz,
    this.breastSide,
    this.diaperType,
    this.playActivityType,
    this.developmentTags,
    this.temperatureCelsius,
    this.temperatureUnit,
    this.medicationType,
    this.medicationName,
    this.dosageAmount,
    this.dosageUnit,
    this.nextDoseTime,
    this.weightKg,
    this.lengthCm,
    this.headCircumferenceCm,
  });

  /// copyWith 메서드
  ActivityEntity copyWith({
    String? id,
    ActivityType? type,
    DateTime? timestamp,
    DateTime? endTime,
    int? durationMinutes,
    String? notes,
    String? sleepLocation,
    String? sleepQuality,
    String? feedingType,
    double? amountMl,
    double? amountOz,
    String? breastSide,
    String? diaperType,
    String? playActivityType,
    List<String>? developmentTags,
    double? temperatureCelsius,
    String? temperatureUnit,
    String? medicationType,
    String? medicationName,
    double? dosageAmount,
    String? dosageUnit,
    DateTime? nextDoseTime,
    double? weightKg,
    double? lengthCm,
    double? headCircumferenceCm,
  }) {
    return ActivityEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
      sleepLocation: sleepLocation ?? this.sleepLocation,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      feedingType: feedingType ?? this.feedingType,
      amountMl: amountMl ?? this.amountMl,
      amountOz: amountOz ?? this.amountOz,
      breastSide: breastSide ?? this.breastSide,
      diaperType: diaperType ?? this.diaperType,
      playActivityType: playActivityType ?? this.playActivityType,
      developmentTags: developmentTags ?? this.developmentTags,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      medicationType: medicationType ?? this.medicationType,
      medicationName: medicationName ?? this.medicationName,
      dosageAmount: dosageAmount ?? this.dosageAmount,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      nextDoseTime: nextDoseTime ?? this.nextDoseTime,
      weightKg: weightKg ?? this.weightKg,
      lengthCm: lengthCm ?? this.lengthCm,
      headCircumferenceCm: headCircumferenceCm ?? this.headCircumferenceCm,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ActivityEntity &&
        other.id == id &&
        other.type == type &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => id.hashCode ^ type.hashCode ^ timestamp.hashCode;

  @override
  String toString() {
    return 'ActivityEntity(id: $id, type: $type, timestamp: $timestamp)';
  }
}

/// Daily Summary Entity (일일 요약)
class DailySummary {
  final int totalSleepMinutes;
  final double totalFeedingMl;
  final int diaperCount;
  final int playCount;
  final DateTime date;

  const DailySummary({
    required this.totalSleepMinutes,
    required this.totalFeedingMl,
    required this.diaperCount,
    this.playCount = 0,
    required this.date,
  });

  @override
  String toString() {
    return 'DailySummary(sleep: ${totalSleepMinutes}min, feeding: ${totalFeedingMl}ml, diaper: $diaperCount)';
  }
}
