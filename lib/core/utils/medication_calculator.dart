/// 약물 복용량 계산 유틸리티
/// Based on AAP (American Academy of Pediatrics) guidelines
class MedicationCalculator {
  /// 아세트아미노펜 (Tylenol) 복용량 계산
  /// 권장: 10-15 mg/kg per dose, every 4-6 hours
  /// 최대: 75 mg/kg per day (not to exceed 4000 mg/day)
  static DosageRecommendation calculateAcetaminophen(double weightKg) {
    final minDose = weightKg * 10; // mg
    final maxDose = weightKg * 15; // mg
    final maxDaily = weightKg * 75; // mg

    // 일반적인 농도: 160mg/5ml (32mg/ml)
    final minMl = minDose / 32;
    final maxMl = maxDose / 32;

    return DosageRecommendation(
      medicationName: 'Acetaminophen (Tylenol)',
      weightKg: weightKg,
      minDoseMg: minDose,
      maxDoseMg: maxDose,
      minDoseMl: minMl,
      maxDoseMl: maxMl,
      maxDailyMg: maxDaily,
      frequencyHours: '4-6',
      concentration: '160mg/5ml',
      warnings: _getAcetaminophenWarnings(weightKg),
    );
  }

  /// 이부프로펜 (Advil/Motrin) 복용량 계산
  /// 권장: 5-10 mg/kg per dose, every 6-8 hours
  /// 최대: 40 mg/kg per day (not to exceed 1200 mg/day for children)
  /// 주의: 6개월 미만 사용 금지
  static DosageRecommendation? calculateIbuprofen(double weightKg, int ageInMonths) {
    if (ageInMonths < 6) {
      return null; // 6개월 미만은 이부프로펜 사용 금지
    }

    final minDose = weightKg * 5; // mg
    final maxDose = weightKg * 10; // mg
    final maxDaily = weightKg * 40; // mg

    // 일반적인 농도: 100mg/5ml (20mg/ml)
    final minMl = minDose / 20;
    final maxMl = maxDose / 20;

    return DosageRecommendation(
      medicationName: 'Ibuprofen (Advil/Motrin)',
      weightKg: weightKg,
      minDoseMg: minDose,
      maxDoseMg: maxDose,
      minDoseMl: minMl,
      maxDoseMl: maxMl,
      maxDailyMg: maxDaily,
      frequencyHours: '6-8',
      concentration: '100mg/5ml',
      warnings: _getIbuprofenWarnings(weightKg, ageInMonths),
    );
  }

  static List<String> _getAcetaminophenWarnings(double weightKg) {
    final warnings = <String>[];

    if (weightKg < 2.7) {
      warnings.add('⚠️ Weight too low - consult pediatrician');
    }

    warnings.add('Do not exceed 5 doses in 24 hours');
    warnings.add('Wait at least 4 hours between doses');
    warnings.add('Contact doctor if fever lasts more than 3 days');

    return warnings;
  }

  static List<String> _getIbuprofenWarnings(double weightKg, int ageInMonths) {
    final warnings = <String>[];

    warnings.add('⚠️ NOT for infants under 6 months');

    if (weightKg < 5.5) {
      warnings.add('⚠️ Weight too low - consult pediatrician');
    }

    warnings.add('Do not exceed 4 doses in 24 hours');
    warnings.add('Wait at least 6 hours between doses');
    warnings.add('Give with food or milk to prevent stomach upset');
    warnings.add('Contact doctor if fever lasts more than 3 days');

    return warnings;
  }
}

/// 복용량 권장사항 모델
class DosageRecommendation {
  final String medicationName;
  final double weightKg;
  final double minDoseMg;
  final double maxDoseMg;
  final double minDoseMl;
  final double maxDoseMl;
  final double maxDailyMg;
  final String frequencyHours;
  final String concentration;
  final List<String> warnings;

  DosageRecommendation({
    required this.medicationName,
    required this.weightKg,
    required this.minDoseMg,
    required this.maxDoseMg,
    required this.minDoseMl,
    required this.maxDoseMl,
    required this.maxDailyMg,
    required this.frequencyHours,
    required this.concentration,
    required this.warnings,
  });

  String get dosageRangeMl =>
      '${minDoseMl.toStringAsFixed(1)} - ${maxDoseMl.toStringAsFixed(1)} ml';

  String get dosageRangeMg =>
      '${minDoseMg.toStringAsFixed(0)} - ${maxDoseMg.toStringAsFixed(0)} mg';
}

/// 고열 가이드라인 (AAP 기준)
class FeverGuidelines {
  static FeverAdvice getAdvice(double tempCelsius, int ageInMonths) {
    final severity = _getSeverity(tempCelsius, ageInMonths);
    final actions = _getActions(tempCelsius, ageInMonths);
    final tips = _getTips(tempCelsius, ageInMonths);

    return FeverAdvice(
      temperature: tempCelsius,
      ageInMonths: ageInMonths,
      severity: severity,
      actions: actions,
      tips: tips,
    );
  }

  static FeverSeverity _getSeverity(double tempC, int ageInMonths) {
    // 3개월 미만
    if (ageInMonths < 3) {
      if (tempC >= 38.0) {
        return FeverSeverity.emergency; // 즉시 의사 상담 필요
      } else if (tempC >= 37.5) {
        return FeverSeverity.warning;
      }
      return FeverSeverity.normal;
    }

    // 3-6개월
    if (ageInMonths < 6) {
      if (tempC >= 39.0) {
        return FeverSeverity.high;
      } else if (tempC >= 38.0) {
        return FeverSeverity.moderate;
      }
      return FeverSeverity.normal;
    }

    // 6개월 이상
    if (tempC >= 40.0) {
      return FeverSeverity.emergency;
    } else if (tempC >= 39.0) {
      return FeverSeverity.high;
    } else if (tempC >= 38.0) {
      return FeverSeverity.moderate;
    }

    return FeverSeverity.normal;
  }

  static List<String> _getActions(double tempC, int ageInMonths) {
    final actions = <String>[];

    if (ageInMonths < 3 && tempC >= 38.0) {
      actions.add('🚨 CALL PEDIATRICIAN IMMEDIATELY');
      actions.add('Infants under 3 months with fever need urgent evaluation');
      return actions;
    }

    if (tempC >= 40.0) {
      actions.add('⚠️ Very high fever - contact doctor');
    } else if (tempC >= 39.0) {
      actions.add('Consider fever reducer medication');
      actions.add('Monitor closely');
    } else if (tempC >= 38.0) {
      actions.add('Monitor temperature every 2-4 hours');
      actions.add('Offer plenty of fluids');
    }

    return actions;
  }

  static List<String> _getTips(double tempC, int ageInMonths) {
    final tips = <String>[];

    tips.add('💧 Keep baby well-hydrated');
    tips.add('👶 Dress in light clothing');
    tips.add('🌡️ Measure temperature every 2-4 hours');

    if (tempC >= 38.0) {
      tips.add('🛁 Lukewarm sponge bath may help (not cold water)');
      tips.add('❌ Avoid bundling or over-dressing');
    }

    if (ageInMonths >= 6) {
      tips.add('💊 Alternate acetaminophen and ibuprofen if needed');
    } else {
      tips.add('💊 Only acetaminophen for infants under 6 months');
    }

    return tips;
  }
}

enum FeverSeverity {
  normal,
  warning,
  moderate,
  high,
  emergency,
}

class FeverAdvice {
  final double temperature;
  final int ageInMonths;
  final FeverSeverity severity;
  final List<String> actions;
  final List<String> tips;

  FeverAdvice({
    required this.temperature,
    required this.ageInMonths,
    required this.severity,
    required this.actions,
    required this.tips,
  });

  bool get needsUrgentCare => severity == FeverSeverity.emergency;
  bool get isHigh => severity == FeverSeverity.high || severity == FeverSeverity.emergency;
}
