import '../../domain/entities/activity_entity.dart' as entity;

/// 활동 타입
enum ActivityType {
  sleep,
  feeding,
  diaper,
  play,
  health,
}

/// 활동 기록 모델
class ActivityModel {
  final String id;
  final ActivityType type;
  final String timestamp; // ISO 8601 format
  final String? endTime; // 종료 시간 (수면, 놀이 등)
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
  final String? playActivityType; // PlayActivityType enum as string
  final List<String>? developmentTags; // DevelopmentTag enums as strings

  // Health specific
  final double? temperatureCelsius;
  final String? temperatureUnit; // 'celsius', 'fahrenheit'
  final String? medicationType; // 'fever_reducer', 'antibiotic', 'other'
  final String? medicationName; // 'acetaminophen', 'ibuprofen', etc.
  final double? dosageAmount;
  final String? dosageUnit; // 'ml', 'mg'
  final DateTime? nextDoseTime; // For medication safety timer
  final double? weightKg; // 체중 기록 (kg)
  final double? lengthCm; // 신장 기록 (cm)
  final double? headCircumferenceCm; // 머리둘레 (cm)

  ActivityModel({
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

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      type: ActivityType.values.firstWhere(
        (e) => e.toString() == 'ActivityType.${json['type']}',
      ),
      timestamp: json['timestamp'] as String,
      endTime: json['endTime'] as String?,
      durationMinutes: json['durationMinutes'] as int?,
      notes: json['notes'] as String?,
      sleepLocation: json['sleepLocation'] as String?,
      sleepQuality: json['sleepQuality'] as String?,
      feedingType: json['feedingType'] as String?,
      amountMl: json['amountMl'] as double?,
      amountOz: json['amountOz'] as double?,
      breastSide: json['breastSide'] as String?,
      diaperType: json['diaperType'] as String?,
      playActivityType: json['playActivityType'] as String?,
      developmentTags: (json['developmentTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      temperatureCelsius: json['temperatureCelsius'] as double?,
      temperatureUnit: json['temperatureUnit'] as String?,
      medicationType: json['medicationType'] as String?,
      medicationName: json['medicationName'] as String?,
      dosageAmount: json['dosageAmount'] as double?,
      dosageUnit: json['dosageUnit'] as String?,
      nextDoseTime: json['nextDoseTime'] != null
          ? DateTime.parse(json['nextDoseTime'] as String)
          : null,
      weightKg: json['weightKg'] as double?,
      lengthCm: json['lengthCm'] as double?,
      headCircumferenceCm: json['headCircumferenceCm'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'timestamp': timestamp,
      'endTime': endTime,
      'durationMinutes': durationMinutes,
      'notes': notes,
      'sleepLocation': sleepLocation,
      'sleepQuality': sleepQuality,
      'feedingType': feedingType,
      'amountMl': amountMl,
      'amountOz': amountOz,
      'breastSide': breastSide,
      'diaperType': diaperType,
      'playActivityType': playActivityType,
      'developmentTags': developmentTags,
      'temperatureCelsius': temperatureCelsius,
      'temperatureUnit': temperatureUnit,
      'medicationType': medicationType,
      'medicationName': medicationName,
      'dosageAmount': dosageAmount,
      'dosageUnit': dosageUnit,
      'nextDoseTime': nextDoseTime?.toIso8601String(),
      'weightKg': weightKg,
      'lengthCm': lengthCm,
      'headCircumferenceCm': headCircumferenceCm,
    };
  }

  /// Sleep 활동 생성
  factory ActivityModel.sleep({
    required String id,
    required DateTime startTime,
    DateTime? endTime,
    String? location,
    String? quality,
    String? notes,
  }) {
    final duration = endTime?.difference(startTime).inMinutes;

    return ActivityModel(
      id: id,
      type: ActivityType.sleep,
      timestamp: startTime.toIso8601String(),
      endTime: endTime?.toIso8601String(),
      durationMinutes: duration,
      sleepLocation: location,
      sleepQuality: quality,
      notes: notes,
    );
  }

  /// Feeding 활동 생성
  factory ActivityModel.feeding({
    required String id,
    required DateTime time,
    required String feedingType,
    double? amountMl,
    double? amountOz,
    String? breastSide,
    String? notes,
  }) {
    return ActivityModel(
      id: id,
      type: ActivityType.feeding,
      timestamp: time.toIso8601String(),
      feedingType: feedingType,
      amountMl: amountMl,
      amountOz: amountOz,
      breastSide: breastSide,
      notes: notes,
    );
  }

  /// Diaper 활동 생성
  factory ActivityModel.diaper({
    required String id,
    required DateTime time,
    required String diaperType,
    String? notes,
  }) {
    return ActivityModel(
      id: id,
      type: ActivityType.diaper,
      timestamp: time.toIso8601String(),
      diaperType: diaperType,
      notes: notes,
    );
  }

  /// Play 활동 생성
  factory ActivityModel.play({
    required String id,
    required DateTime startTime,
    DateTime? endTime,
    int? durationMinutes,
    required String playActivityType,
    List<String>? developmentTags,
    String? notes,
  }) {
    return ActivityModel(
      id: id,
      type: ActivityType.play,
      timestamp: startTime.toIso8601String(),
      endTime: endTime?.toIso8601String(),
      durationMinutes: durationMinutes,
      playActivityType: playActivityType,
      developmentTags: developmentTags,
      notes: notes,
    );
  }

  /// Temperature 기록 생성
  factory ActivityModel.temperature({
    required String id,
    required DateTime time,
    required double temperature,
    required String unit, // 'celsius' or 'fahrenheit'
    String? notes,
  }) {
    return ActivityModel(
      id: id,
      type: ActivityType.health,
      timestamp: time.toIso8601String(),
      temperatureCelsius: unit == 'celsius'
          ? temperature
          : (temperature - 32) * 5 / 9, // Convert F to C for storage
      temperatureUnit: unit,
      notes: notes,
    );
  }

  /// Medication 기록 생성
  factory ActivityModel.medication({
    required String id,
    required DateTime time,
    required String medicationType,
    String? medicationName,
    double? dosageAmount,
    String? dosageUnit,
    int? hoursUntilNextDose,
    String? notes,
  }) {
    DateTime? nextDose;
    if (hoursUntilNextDose != null) {
      nextDose = time.add(Duration(hours: hoursUntilNextDose));
    }

    return ActivityModel(
      id: id,
      type: ActivityType.health,
      timestamp: time.toIso8601String(),
      medicationType: medicationType,
      medicationName: medicationName,
      dosageAmount: dosageAmount,
      dosageUnit: dosageUnit,
      nextDoseTime: nextDose,
      notes: notes,
    );
  }

  /// Entity → Model 변환
  factory ActivityModel.fromEntity(entity.ActivityEntity entityObj) {
    return ActivityModel(
      id: entityObj.id,
      type: _entityTypeToModel(entityObj.type),
      timestamp: entityObj.timestamp.toIso8601String(),
      endTime: entityObj.endTime?.toIso8601String(),
      durationMinutes: entityObj.durationMinutes,
      notes: entityObj.notes,
      sleepLocation: entityObj.sleepLocation,
      sleepQuality: entityObj.sleepQuality,
      feedingType: entityObj.feedingType,
      amountMl: entityObj.amountMl,
      amountOz: entityObj.amountOz,
      breastSide: entityObj.breastSide,
      diaperType: entityObj.diaperType,
      playActivityType: entityObj.playActivityType,
      developmentTags: entityObj.developmentTags,
      temperatureCelsius: entityObj.temperatureCelsius,
      temperatureUnit: entityObj.temperatureUnit,
      medicationType: entityObj.medicationType,
      medicationName: entityObj.medicationName,
      dosageAmount: entityObj.dosageAmount,
      dosageUnit: entityObj.dosageUnit,
      nextDoseTime: entityObj.nextDoseTime,
      weightKg: entityObj.weightKg,
      lengthCm: entityObj.lengthCm,
      headCircumferenceCm: entityObj.headCircumferenceCm,
    );
  }

  /// Model → Entity 변환
  entity.ActivityEntity toEntity() {
    return entity.ActivityEntity(
      id: id,
      type: _modelTypeToEntity(type),
      timestamp: DateTime.parse(timestamp),
      endTime: endTime != null ? DateTime.parse(endTime!) : null,
      durationMinutes: durationMinutes,
      notes: notes,
      sleepLocation: sleepLocation,
      sleepQuality: sleepQuality,
      feedingType: feedingType,
      amountMl: amountMl,
      amountOz: amountOz,
      breastSide: breastSide,
      diaperType: diaperType,
      playActivityType: playActivityType,
      developmentTags: developmentTags,
      temperatureCelsius: temperatureCelsius,
      temperatureUnit: temperatureUnit,
      medicationType: medicationType,
      medicationName: medicationName,
      dosageAmount: dosageAmount,
      dosageUnit: dosageUnit,
      nextDoseTime: nextDoseTime,
      weightKg: weightKg,
      lengthCm: lengthCm,
      headCircumferenceCm: headCircumferenceCm,
    );
  }

  /// Entity Type → Model Type
  static ActivityType _entityTypeToModel(entity.ActivityType entityType) {
    switch (entityType) {
      case entity.ActivityType.sleep:
        return ActivityType.sleep;
      case entity.ActivityType.feeding:
        return ActivityType.feeding;
      case entity.ActivityType.diaper:
        return ActivityType.diaper;
      case entity.ActivityType.play:
        return ActivityType.play;
      case entity.ActivityType.health:
        return ActivityType.health;
    }
  }

  /// Model Type → Entity Type
  static entity.ActivityType _modelTypeToEntity(ActivityType modelType) {
    switch (modelType) {
      case ActivityType.sleep:
        return entity.ActivityType.sleep;
      case ActivityType.feeding:
        return entity.ActivityType.feeding;
      case ActivityType.diaper:
        return entity.ActivityType.diaper;
      case ActivityType.play:
        return entity.ActivityType.play;
      case ActivityType.health:
        return entity.ActivityType.health;
    }
  }
}
