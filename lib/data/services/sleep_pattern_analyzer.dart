import '../models/activity_model.dart';
import '../models/sleep_pattern_insight.dart';
import '../../presentation/widgets/charts/sleep_heatmap.dart';
import 'dart:math' as math;

/// 수면 패턴 분석기
/// 히트맵 데이터를 분석하여 인사이트 생성
class SleepPatternAnalyzer {
  /// 수면 활동 목록에서 패턴 인사이트 생성
  SleepPatternInsight analyzePattern({
    required List<ActivityModel> sleepActivities,
    required bool isKorean,
    int? babyAgeInMonths,
  }) {
    if (sleepActivities.isEmpty) {
      return _createEmptyInsight(isKorean);
    }

    // 히트맵 데이터 생성
    final heatmapData = _convertToHeatmapData(sleepActivities);

    // 시간대별 수면 밀도 계산 (0-23시)
    final hourlyDensity = _calculateHourlyDensity(heatmapData);

    // 피크 수면 시간대 찾기
    final peakHours = _findPeakHours(hourlyDensity, threshold: 60);

    // 깨어있는 시간대 찾기
    final wakefulHours = _findWakefulHours(hourlyDensity, threshold: 20);

    // 최적 수면 시작 시간 찾기 (밤잠)
    final optimalHour = _findOptimalSleepStartHour(hourlyDensity);

    // 일관성 있는 수면 기간 찾기
    final consistentPeriod = _findConsistentPeriod(hourlyDensity, isKorean);

    // 패턴 강도 계산 (표준편차 기반)
    final patternStrength = _calculatePatternStrength(hourlyDensity);

    // 인사이트 타입 결정
    final type = _determineInsightType(patternStrength, peakHours.length);

    // 메시지 생성
    final messages = _generateMessages(
      hourlyDensity: hourlyDensity,
      peakHours: peakHours,
      wakefulHours: wakefulHours,
      optimalHour: optimalHour,
      patternStrength: patternStrength,
      type: type,
      isKorean: isKorean,
      babyAgeInMonths: babyAgeInMonths,
    );

    return SleepPatternInsight(
      mainFinding: messages['mainFinding']!,
      positivePattern: messages['positivePattern'],
      improvementArea: messages['improvementArea'],
      actionableAdvice: messages['actionableAdvice']!,
      optimalSleepHour: optimalHour,
      consistentPeriod: consistentPeriod,
      peakSleepHours: peakHours,
      wakefulHours: wakefulHours,
      patternStrength: patternStrength,
      type: type,
      additionalNote: messages['additionalNote'],
    );
  }

  /// ActivityModel을 SleepDataPoint로 변환
  List<SleepDataPoint> _convertToHeatmapData(List<ActivityModel> activities) {
    final dataPoints = <SleepDataPoint>[];

    for (final activity in activities) {
      if (activity.endTime == null) continue;

      final startTime = DateTime.parse(activity.timestamp);
      final endTime = DateTime.parse(activity.endTime!);

      var current = startTime;
      while (current.isBefore(endTime)) {
        final nextHour = DateTime(current.year, current.month, current.day, current.hour + 1);
        final minutesInThisHour = endTime.isBefore(nextHour)
            ? endTime.difference(current).inMinutes
            : nextHour.difference(current).inMinutes;

        if (minutesInThisHour > 0) {
          dataPoints.add(SleepDataPoint(
            date: DateTime(current.year, current.month, current.day),
            hour: current.hour,
            minutes: minutesInThisHour.clamp(0, 60),
          ));
        }

        current = nextHour;
      }
    }

    return dataPoints;
  }

  /// 시간대별 수면 밀도 계산 (0-100)
  Map<int, double> _calculateHourlyDensity(List<SleepDataPoint> dataPoints) {
    final hourlyMinutes = <int, List<int>>{};

    for (var point in dataPoints) {
      hourlyMinutes.putIfAbsent(point.hour, () => []);
      hourlyMinutes[point.hour]!.add(point.minutes);
    }

    final density = <int, double>{};
    for (var hour = 0; hour < 24; hour++) {
      if (hourlyMinutes.containsKey(hour)) {
        final minutes = hourlyMinutes[hour]!;
        final avgMinutes = minutes.reduce((a, b) => a + b) / minutes.length;
        density[hour] = (avgMinutes / 60 * 100).clamp(0, 100);
      } else {
        density[hour] = 0.0;
      }
    }

    return density;
  }

  /// 피크 수면 시간대 찾기
  List<int> _findPeakHours(Map<int, double> hourlyDensity, {double threshold = 60}) {
    return hourlyDensity.entries
        .where((e) => e.value >= threshold)
        .map((e) => e.key)
        .toList()
      ..sort();
  }

  /// 깨어있는 시간대 찾기
  List<int> _findWakefulHours(Map<int, double> hourlyDensity, {double threshold = 20}) {
    return hourlyDensity.entries
        .where((e) => e.value < threshold)
        .map((e) => e.key)
        .toList()
      ..sort();
  }

  /// 최적 수면 시작 시간 찾기 (밤잠, 19:00-23:00)
  int? _findOptimalSleepStartHour(Map<int, double> hourlyDensity) {
    final nightHours = [19, 20, 21, 22, 23];
    double maxDensity = 0;
    int? optimalHour;

    for (var hour in nightHours) {
      final density = hourlyDensity[hour] ?? 0;
      if (density > maxDensity) {
        maxDensity = density;
        optimalHour = hour;
      }
    }

    return maxDensity > 50 ? optimalHour : null;
  }

  /// 일관성 있는 수면 기간 찾기
  String? _findConsistentPeriod(Map<int, double> hourlyDensity, bool isKorean) {
    // 연속된 고밀도 구간 찾기
    final consistentHours = <List<int>>[];
    List<int> currentStreak = [];

    for (var hour = 0; hour < 24; hour++) {
      if ((hourlyDensity[hour] ?? 0) >= 70) {
        currentStreak.add(hour);
      } else {
        if (currentStreak.length >= 3) {
          consistentHours.add(List.from(currentStreak));
        }
        currentStreak.clear();
      }
    }

    if (currentStreak.length >= 3) {
      consistentHours.add(currentStreak);
    }

    if (consistentHours.isEmpty) return null;

    // 가장 긴 구간 선택
    final longest = consistentHours.reduce((a, b) => a.length > b.length ? a : b);
    final start = longest.first;
    final end = longest.last;

    if (isKorean) {
      return '${_formatHour(start, isKorean)} ~ ${_formatHour(end, isKorean)}';
    } else {
      return '${_formatHour(start, isKorean)} - ${_formatHour(end, isKorean)}';
    }
  }

  /// 시간 포맷 (예: "오후 7시" 또는 "7 PM")
  String _formatHour(int hour, bool isKorean) {
    if (isKorean) {
      final period = hour < 12 ? '오전' : '오후';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$period ${displayHour}시';
    } else {
      final period = hour < 12 ? 'AM' : 'PM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour $period';
    }
  }

  /// 패턴 강도 계산 (표준편차 역수 기반)
  double _calculatePatternStrength(Map<int, double> hourlyDensity) {
    final values = hourlyDensity.values.toList();
    if (values.isEmpty) return 0.0;

    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values
        .map((v) => math.pow(v - mean, 2))
        .reduce((a, b) => a + b) / values.length;
    final stdDev = math.sqrt(variance);

    // 표준편차가 클수록 불규칙 -> 작은 강도
    // 표준편차가 작을수록 규칙적 -> 큰 강도
    final strength = (1 - (stdDev / 50)).clamp(0.0, 1.0) * 100.0;

    return strength;
  }

  /// 인사이트 타입 결정
  InsightType _determineInsightType(double patternStrength, int peakHourCount) {
    if (patternStrength >= 80 && peakHourCount >= 8) {
      return InsightType.excellent;
    } else if (patternStrength >= 60 && peakHourCount >= 6) {
      return InsightType.good;
    } else if (patternStrength >= 40 || peakHourCount >= 4) {
      return InsightType.needsImprovement;
    } else {
      return InsightType.concerning;
    }
  }

  /// 메시지 생성
  Map<String, String?> _generateMessages({
    required Map<int, double> hourlyDensity,
    required List<int> peakHours,
    required List<int> wakefulHours,
    required int? optimalHour,
    required double patternStrength,
    required InsightType type,
    required bool isKorean,
    int? babyAgeInMonths,
  }) {
    String mainFinding;
    String? positivePattern;
    String? improvementArea;
    String actionableAdvice;
    String? additionalNote;

    if (isKorean) {
      // 한국어 메시지
      switch (type) {
        case InsightType.excellent:
          mainFinding = '매우 안정적인 수면 패턴을 보이고 있어요! 👏';
          positivePattern = '${peakHours.length}시간 동안 깊은 수면을 유지하고 있어요';
          actionableAdvice = '현재의 수면 루틴을 계속 유지해주세요';
          break;
        case InsightType.good:
          mainFinding = '좋은 수면 패턴을 유지하고 있어요 😊';
          positivePattern = optimalHour != null
              ? '${_formatHour(optimalHour, true)}에 잠드는 패턴이 안정적이에요'
              : '일정한 수면 시간대를 보이고 있어요';
          actionableAdvice = '조금 더 일관된 수면 시간을 유지하면 더 좋아질 거예요';
          break;
        case InsightType.needsImprovement:
          mainFinding = '수면 패턴이 조금 불규칙해요';
          improvementArea = wakefulHours.length >= 12
              ? '낮 시간대 수면이 부족해요'
              : '수면 시간대가 일정하지 않아요';
          actionableAdvice = '매일 비슷한 시간에 재우려고 노력해보세요';
          additionalNote = '2주 정도 꾸준히 실천하면 패턴이 개선될 거예요';
          break;
        case InsightType.concerning:
          mainFinding = '수면 패턴이 많이 불규칙해요';
          improvementArea = '일정한 수면 시간대가 없어요';
          actionableAdvice = '수면 루틴을 새로 만들어보세요. 취침 전 30분 전부터 조명을 어둡게 하고, 조용한 활동을 해주세요';
          additionalNote = '개선이 어려우면 소아과 전문의와 상담해보세요';
          break;
      }
    } else {
      // 영어 메시지
      switch (type) {
        case InsightType.excellent:
          mainFinding = 'Very stable sleep pattern! 👏';
          positivePattern = 'Deep sleep maintained for ${peakHours.length} hours';
          actionableAdvice = 'Keep maintaining your current sleep routine';
          break;
        case InsightType.good:
          mainFinding = 'Good sleep pattern 😊';
          positivePattern = optimalHour != null
              ? 'Consistent bedtime around ${_formatHour(optimalHour, false)}'
              : 'Showing consistent sleep periods';
          actionableAdvice = 'Try to maintain more consistent sleep times';
          break;
        case InsightType.needsImprovement:
          mainFinding = 'Sleep pattern is somewhat irregular';
          improvementArea = wakefulHours.length >= 12
              ? 'Insufficient daytime sleep'
              : 'Inconsistent sleep timing';
          actionableAdvice = 'Try putting baby to sleep at similar times daily';
          additionalNote = 'Pattern should improve with 2 weeks of consistency';
          break;
        case InsightType.concerning:
          mainFinding = 'Sleep pattern is very irregular';
          improvementArea = 'No consistent sleep periods';
          actionableAdvice = 'Establish a new sleep routine. Dim lights 30min before bed and engage in quiet activities';
          additionalNote = 'Consider consulting a pediatrician if improvement is difficult';
          break;
      }
    }

    return {
      'mainFinding': mainFinding,
      'positivePattern': positivePattern,
      'improvementArea': improvementArea,
      'actionableAdvice': actionableAdvice,
      'additionalNote': additionalNote,
    };
  }

  /// 빈 인사이트 생성 (데이터 부족 시)
  SleepPatternInsight _createEmptyInsight(bool isKorean) {
    return SleepPatternInsight(
      mainFinding: isKorean
          ? '아직 분석할 수면 데이터가 부족해요'
          : 'Insufficient sleep data for analysis',
      actionableAdvice: isKorean
          ? '수면 기록을 더 추가해주세요'
          : 'Please add more sleep records',
      peakSleepHours: [],
      wakefulHours: List.generate(24, (i) => i),
      patternStrength: 0,
      type: InsightType.needsImprovement,
    );
  }
}
