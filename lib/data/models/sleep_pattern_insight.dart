/// 수면 패턴 인사이트 모델
/// 히트맵 데이터를 분석하여 사용자에게 실용적인 조언 제공
class SleepPatternInsight {
  /// 주요 발견사항
  final String mainFinding;

  /// 긍정적인 패턴
  final String? positivePattern;

  /// 개선이 필요한 패턴
  final String? improvementArea;

  /// 실용적인 조언
  final String actionableAdvice;

  /// 최적의 수면 시간대 (시작 시간, 24시간제)
  final int? optimalSleepHour;

  /// 가장 일관성 있는 수면 시간대
  final String? consistentPeriod;

  /// 수면 집중도가 높은 시간대
  final List<int> peakSleepHours;

  /// 수면 집중도가 낮은 시간대 (깨어있는 시간)
  final List<int> wakefulHours;

  /// 패턴 강도 (0-100)
  /// 높을수록 수면 패턴이 규칙적
  final double patternStrength;

  /// 인사이트 타입
  final InsightType type;

  /// 추가 메모 (선택사항)
  final String? additionalNote;

  SleepPatternInsight({
    required this.mainFinding,
    this.positivePattern,
    this.improvementArea,
    required this.actionableAdvice,
    this.optimalSleepHour,
    this.consistentPeriod,
    required this.peakSleepHours,
    required this.wakefulHours,
    required this.patternStrength,
    required this.type,
    this.additionalNote,
  });

  /// 패턴 강도 레벨
  PatternStrengthLevel get strengthLevel {
    if (patternStrength >= 80) return PatternStrengthLevel.veryStrong;
    if (patternStrength >= 60) return PatternStrengthLevel.strong;
    if (patternStrength >= 40) return PatternStrengthLevel.moderate;
    if (patternStrength >= 20) return PatternStrengthLevel.weak;
    return PatternStrengthLevel.veryWeak;
  }

  /// 패턴 강도 메시지
  String getStrengthMessage({required bool isKorean}) {
    switch (strengthLevel) {
      case PatternStrengthLevel.veryStrong:
        return isKorean ? '매우 규칙적인 수면 패턴' : 'Very consistent sleep pattern';
      case PatternStrengthLevel.strong:
        return isKorean ? '규칙적인 수면 패턴' : 'Consistent sleep pattern';
      case PatternStrengthLevel.moderate:
        return isKorean ? '보통의 수면 패턴' : 'Moderate sleep pattern';
      case PatternStrengthLevel.weak:
        return isKorean ? '불규칙한 수면 패턴' : 'Irregular sleep pattern';
      case PatternStrengthLevel.veryWeak:
        return isKorean ? '매우 불규칙한 수면 패턴' : 'Very irregular sleep pattern';
    }
  }

  /// 이모지 아이콘
  String get emoji {
    switch (type) {
      case InsightType.excellent:
        return '🌟';
      case InsightType.good:
        return '👍';
      case InsightType.needsImprovement:
        return '💡';
      case InsightType.concerning:
        return '⚠️';
    }
  }

  /// 최적 수면 시간 포맷 (예: "오후 7:00")
  String? getOptimalTimeFormatted({required bool isKorean}) {
    if (optimalSleepHour == null) return null;

    final hour = optimalSleepHour!;
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final period = isKorean
        ? (hour < 12 ? '오전' : '오후')
        : (hour < 12 ? 'AM' : 'PM');

    return isKorean
        ? '$period $displayHour:00'
        : '$displayHour:00 $period';
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'mainFinding': mainFinding,
      'positivePattern': positivePattern,
      'improvementArea': improvementArea,
      'actionableAdvice': actionableAdvice,
      'optimalSleepHour': optimalSleepHour,
      'consistentPeriod': consistentPeriod,
      'peakSleepHours': peakSleepHours,
      'wakefulHours': wakefulHours,
      'patternStrength': patternStrength,
      'type': type.toString().split('.').last,
      'additionalNote': additionalNote,
    };
  }

  /// JSON 역직렬화
  factory SleepPatternInsight.fromJson(Map<String, dynamic> json) {
    return SleepPatternInsight(
      mainFinding: json['mainFinding'] as String,
      positivePattern: json['positivePattern'] as String?,
      improvementArea: json['improvementArea'] as String?,
      actionableAdvice: json['actionableAdvice'] as String,
      optimalSleepHour: json['optimalSleepHour'] as int?,
      consistentPeriod: json['consistentPeriod'] as String?,
      peakSleepHours: List<int>.from(json['peakSleepHours'] as List),
      wakefulHours: List<int>.from(json['wakefulHours'] as List),
      patternStrength: (json['patternStrength'] as num).toDouble(),
      type: InsightType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => InsightType.good,
      ),
      additionalNote: json['additionalNote'] as String?,
    );
  }

  @override
  String toString() {
    return 'SleepPatternInsight('
        'type: $type, '
        'strength: ${patternStrength.toStringAsFixed(0)}%, '
        'mainFinding: $mainFinding)';
  }
}

/// 인사이트 타입
enum InsightType {
  /// 매우 좋음 (80-100점)
  excellent,

  /// 좋음 (60-79점)
  good,

  /// 개선 필요 (40-59점)
  needsImprovement,

  /// 우려됨 (0-39점)
  concerning,
}

/// 패턴 강도 레벨
enum PatternStrengthLevel {
  veryStrong,   // 80-100%
  strong,       // 60-79%
  moderate,     // 40-59%
  weak,         // 20-39%
  veryWeak,     // 0-19%
}
