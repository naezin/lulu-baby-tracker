import '../models/activity_model.dart';
import '../models/ai_insight_model.dart';
import '../knowledge/expert_guidelines.dart';

/// 다각도 상관관계 분석기
class CrossCorrelationAnalyzer {
  /// 종합 상관관계 분석
  static CorrelationAnalysisResult analyze({
    required ActivityEventContext context,
    required double babyWeightKg,
  }) {
    final feedingAnalysis = _analyzeFeedingCorrelation(context, babyWeightKg);
    final healthAnalysis = _analyzeHealthCorrelation(context);
    final sleepPressureAnalysis = _analyzeSleepPressure(context);
    final timeOfDayAnalysis = _analyzeTimeOfDay(context);

    return CorrelationAnalysisResult(
      feedingCorrelation: feedingAnalysis,
      healthCorrelation: healthAnalysis,
      sleepPressureCorrelation: sleepPressureAnalysis,
      timeOfDayCorrelation: timeOfDayAnalysis,
    );
  }

  /// 1. 수유 연관성 분석
  static FeedingCorrelation _analyzeFeedingCorrelation(
    ActivityEventContext context,
    double babyWeightKg,
  ) {
    final recentFeedings = context.recentFeedings
        .where((f) => f.hoursAgo <= 6)
        .toList();

    if (recentFeedings.isEmpty) {
      return FeedingCorrelation(
        isSufficient: false,
        lastFeedingHoursAgo: null,
        lastFeedingAmount: null,
        recommendedAmount: (babyWeightKg * 150 / 8).round().toDouble(),
        analysis: '최근 6시간 내 수유 기록이 없습니다. 배고픔이 원인일 가능성이 높습니다.',
      );
    }

    // 마지막 수유 (막수)
    final lastFeeding = recentFeedings.reduce(
      (a, b) => a.hoursAgo < b.hoursAgo ? a : b,
    );

    // 권장 수유량
    final recommendedPerFeeding = (babyWeightKg * 150 / 8).round().toDouble();

    // 충분성 판단
    final isSufficient = lastFeeding.amountMl != null &&
        lastFeeding.amountMl! >= recommendedPerFeeding * 0.8;

    String analysis;
    if (lastFeeding.hoursAgo >= 4) {
      analysis = '마지막 수유가 ${lastFeeding.hoursAgo}시간 전입니다. '
          '이 월령의 평균 수유 간격(3시간)을 넘었으므로 배고픔이 원인일 수 있습니다.';
    } else if (!isSufficient && lastFeeding.amountMl != null) {
      analysis = '마지막 수유량(${lastFeeding.amountMl}ml)이 권장량(${recommendedPerFeeding.round()}ml)의 '
          '${((lastFeeding.amountMl! / recommendedPerFeeding) * 100).round()}%입니다. '
          '충분히 먹지 못해 일찍 배고플 수 있습니다.';
    } else {
      analysis = '마지막 수유는 적절했습니다. 배고픔보다는 다른 원인일 가능성이 높습니다.';
    }

    return FeedingCorrelation(
      isSufficient: isSufficient,
      lastFeedingHoursAgo: lastFeeding.hoursAgo.toDouble(),
      lastFeedingAmount: lastFeeding.amountMl,
      recommendedAmount: recommendedPerFeeding,
      analysis: analysis,
    );
  }

  /// 2. 신체 컨디션 분석
  static HealthCorrelation _analyzeHealthCorrelation(
    ActivityEventContext context,
  ) {
    final recentHealth = context.recentHealthRecords
        .where((h) => h.hoursAgo <= 24)
        .toList();

    // 체온 체크
    TemperatureStatus tempStatus = TemperatureStatus.normal;
    double? latestTemp;
    String? tempAnalysis;

    final tempRecords = recentHealth
        .where((h) => h.temperatureCelsius != null)
        .toList();

    if (tempRecords.isNotEmpty) {
      final latest = tempRecords.reduce(
        (a, b) => a.hoursAgo < b.hoursAgo ? a : b,
      );
      latestTemp = latest.temperatureCelsius;

      if (latestTemp! >= ExpertGuidelines.temperatureThresholds['emergency']!) {
        tempStatus = TemperatureStatus.emergency;
        tempAnalysis = '체온이 ${latestTemp.toStringAsFixed(1)}°C로 매우 높습니다. 즉시 응급실 방문이 필요합니다.';
      } else if (latestTemp >= ExpertGuidelines.temperatureThresholds['fever']!) {
        tempStatus = TemperatureStatus.fever;
        tempAnalysis = '체온이 ${latestTemp.toStringAsFixed(1)}°C로 발열 상태입니다. 소아과 상담을 권장합니다.';
      } else if (latestTemp >= ExpertGuidelines.temperatureThresholds['low_fever']!) {
        tempStatus = TemperatureStatus.lowFever;
        tempAnalysis = '체온이 ${latestTemp.toStringAsFixed(1)}°C로 약간 높습니다. 관찰이 필요합니다.';
      } else {
        tempAnalysis = '체온은 정상 범위(${latestTemp.toStringAsFixed(1)}°C)입니다.';
      }
    }

    // 배변 횟수 체크
    final diaperCount = context.recentDiapers
        .where((d) => d.hoursAgo <= 24)
        .length;

    String diaperAnalysis;
    if (diaperCount < 4) {
      diaperAnalysis = '최근 24시간 배변 횟수(${diaperCount}회)가 적습니다. 수분/수유 섭취 확인이 필요합니다.';
    } else if (diaperCount > 12) {
      diaperAnalysis = '최근 24시간 배변 횟수(${diaperCount}회)가 많습니다. 소화 상태를 관찰해주세요.';
    } else {
      diaperAnalysis = '배변 횟수(${diaperCount}회)는 정상 범위입니다.';
    }

    return HealthCorrelation(
      temperatureStatus: tempStatus,
      latestTemperature: latestTemp,
      temperatureAnalysis: tempAnalysis,
      diaperCount24h: diaperCount,
      diaperAnalysis: diaperAnalysis,
    );
  }

  /// 3. 수면 압력 분석
  static SleepPressureCorrelation _analyzeSleepPressure(
    ActivityEventContext context,
  ) {
    final recentSleeps = context.recentSleeps
        .where((s) => s.hoursAgo <= 6)
        .toList();

    if (recentSleeps.isEmpty) {
      return SleepPressureCorrelation(
        pressureLevel: PressureLevel.high,
        lastNapHoursAgo: null,
        lastNapDuration: null,
        wakeWindowMinutes: null,
        analysis: '최근 6시간 낮잠 기록이 없습니다. 수면 압력이 높아 쉽게 잠들 수 있는 상태입니다.',
      );
    }

    // 마지막 낮잠
    final lastNap = recentSleeps.reduce(
      (a, b) => a.hoursAgo < b.hoursAgo ? a : b,
    );

    // 각성 시간 계산
    final wakeWindowMinutes = (lastNap.hoursAgo * 60).round();

    // 월령별 적정 각성 시간
    final stats = ExpertGuidelines.sleepStatisticsByAge[context.babyAgeInDays] ??
        ExpertGuidelines.sleepStatisticsByAge[72]!;

    PressureLevel pressureLevel;
    String analysis;

    if (wakeWindowMinutes < stats.wakeWindowMinutes * 0.7) {
      // 너무 짧음
      pressureLevel = PressureLevel.low;
      analysis = '마지막 낮잠 후 ${wakeWindowMinutes}분 경과했습니다. '
          '이 월령의 적정 각성 시간(${stats.wakeWindowMinutes}분)보다 짧아 수면 압력이 부족할 수 있습니다. '
          '조금 더 놀아준 후 재우는 것이 좋습니다.';
    } else if (wakeWindowMinutes > stats.wakeWindowMinutes * 1.5) {
      // 너무 김
      pressureLevel = PressureLevel.excessive;
      analysis = '마지막 낮잠 후 ${wakeWindowMinutes}분 경과했습니다. '
          '적정 각성 시간(${stats.wakeWindowMinutes}분)을 많이 넘어 과자극 상태일 수 있습니다. '
          '이미 "골든 타임"을 놓쳤을 수 있으니 진정시키는 것이 우선입니다.';
    } else {
      // 적절함
      pressureLevel = PressureLevel.optimal;
      analysis = '마지막 낮잠 후 ${wakeWindowMinutes}분 경과했습니다. '
          '적정 각성 시간(${stats.wakeWindowMinutes}분) 내에 있어 수면 압력이 적절합니다. '
          '지금이 재우기 좋은 "골든 타임"입니다.';
    }

    // 낮잠 시간 분석
    if (lastNap.hoursAgo <= 2) {
      final napTime = context.eventTime.subtract(Duration(hours: lastNap.hoursAgo));
      if (napTime.hour >= 16) {
        analysis += '\n\n늦은 시간(${napTime.hour}시)의 낮잠은 밤잠을 방해할 수 있습니다. '
            '오후 4시 이후 낮잠은 짧게(30분 이내) 하는 것이 좋습니다.';
      }
    }

    return SleepPressureCorrelation(
      pressureLevel: pressureLevel,
      lastNapHoursAgo: lastNap.hoursAgo.toDouble(),
      lastNapDuration: lastNap.durationMinutes,
      wakeWindowMinutes: wakeWindowMinutes,
      analysis: analysis,
    );
  }

  /// 4. 시간대 분석
  static TimeOfDayCorrelation _analyzeTimeOfDay(
    ActivityEventContext context,
  ) {
    final hour = context.eventTime.hour;
    final minute = context.eventTime.minute;

    TimeOfDayType timeType;
    String analysis;

    if (hour >= 18 && hour <= 21) {
      // 저녁 시간대 (영아 산통 호발 시간)
      timeType = TimeOfDayType.eveningColicPeak;
      analysis = '저녁 시간대(${hour}:${minute.toString().padLeft(2, '0')})는 "마녀의 시간(Witching Hour)"으로 불리며 '
          '영아 산통이 가장 심한 시간입니다. 아기가 더 보챌 수 있으며, 이는 정상적인 현상입니다.\n\n'
          '${ExpertGuidelines.infantColicGuidance}';
    } else if (hour >= 22 || hour < 6) {
      // 밤 시간대
      timeType = TimeOfDayType.nightSleep;
      analysis = '밤 시간대(${hour}:${minute.toString().padLeft(2, '0')})입니다. '
          '이 시기 아기는 4-6시간 연속 수면이 가능하지만, 수유를 위해 1-2회 깰 수 있습니다.\n\n'
          '밤 수유 시 주의사항:\n'
          '- 조명을 어둡게 유지\n'
          '- 말을 최소화\n'
          '- 수유 후 바로 재우기\n'
          '- 기저귀는 꼭 필요한 경우만 갈아주기';
    } else if (hour >= 6 && hour < 12) {
      // 아침 시간대
      timeType = TimeOfDayType.morning;
      analysis = '아침 시간대(${hour}:${minute.toString().padLeft(2, '0')})입니다. '
          '낮밤 구분을 위해 커튼을 열어 햇빛을 받게 하고, 활기찬 목소리로 말을 걸어주세요.';
    } else {
      // 오후 시간대
      timeType = TimeOfDayType.afternoon;
      analysis = '오후 시간대(${hour}:${minute.toString().padLeft(2, '0')})입니다. '
          '이 시간대 낮잠이 너무 길거나 늦으면 밤잠에 영향을 줄 수 있습니다.';
    }

    return TimeOfDayCorrelation(
      timeType: timeType,
      hourOfDay: hour,
      analysis: analysis,
    );
  }
}

/// 상관관계 분석 결과
class CorrelationAnalysisResult {
  final FeedingCorrelation feedingCorrelation;
  final HealthCorrelation healthCorrelation;
  final SleepPressureCorrelation sleepPressureCorrelation;
  final TimeOfDayCorrelation timeOfDayCorrelation;

  CorrelationAnalysisResult({
    required this.feedingCorrelation,
    required this.healthCorrelation,
    required this.sleepPressureCorrelation,
    required this.timeOfDayCorrelation,
  });

  /// 종합 분석 텍스트
  String toAnalysisText() {
    final buffer = StringBuffer();

    buffer.writeln('## 다각도 상관관계 분석\n');

    buffer.writeln('### 1. 수유 연관성');
    buffer.writeln(feedingCorrelation.analysis);
    buffer.writeln();

    buffer.writeln('### 2. 신체 컨디션');
    if (healthCorrelation.temperatureAnalysis != null) {
      buffer.writeln(healthCorrelation.temperatureAnalysis!);
    }
    buffer.writeln(healthCorrelation.diaperAnalysis);
    buffer.writeln();

    buffer.writeln('### 3. 수면 압력');
    buffer.writeln(sleepPressureCorrelation.analysis);
    buffer.writeln();

    buffer.writeln('### 4. 시간대 특성');
    buffer.writeln(timeOfDayCorrelation.analysis);

    return buffer.toString();
  }
}

/// 수유 상관관계
class FeedingCorrelation {
  final bool isSufficient;
  final double? lastFeedingHoursAgo;
  final double? lastFeedingAmount;
  final double recommendedAmount;
  final String analysis;

  FeedingCorrelation({
    required this.isSufficient,
    required this.lastFeedingHoursAgo,
    required this.lastFeedingAmount,
    required this.recommendedAmount,
    required this.analysis,
  });
}

/// 건강 상관관계
class HealthCorrelation {
  final TemperatureStatus temperatureStatus;
  final double? latestTemperature;
  final String? temperatureAnalysis;
  final int diaperCount24h;
  final String diaperAnalysis;

  HealthCorrelation({
    required this.temperatureStatus,
    required this.latestTemperature,
    required this.temperatureAnalysis,
    required this.diaperCount24h,
    required this.diaperAnalysis,
  });
}

/// 수면 압력 상관관계
class SleepPressureCorrelation {
  final PressureLevel pressureLevel;
  final double? lastNapHoursAgo;
  final int? lastNapDuration;
  final int? wakeWindowMinutes;
  final String analysis;

  SleepPressureCorrelation({
    required this.pressureLevel,
    required this.lastNapHoursAgo,
    required this.lastNapDuration,
    required this.wakeWindowMinutes,
    required this.analysis,
  });
}

/// 시간대 상관관계
class TimeOfDayCorrelation {
  final TimeOfDayType timeType;
  final int hourOfDay;
  final String analysis;

  TimeOfDayCorrelation({
    required this.timeType,
    required this.hourOfDay,
    required this.analysis,
  });
}

/// 체온 상태
enum TemperatureStatus {
  normal,
  lowFever,
  fever,
  emergency,
}

/// 수면 압력 수준
enum PressureLevel {
  low,        // 부족
  optimal,    // 적절
  high,       // 높음
  excessive,  // 과도
}

/// 시간대 타입
enum TimeOfDayType {
  morning,
  afternoon,
  eveningColicPeak,  // 영아 산통 호발 시간
  nightSleep,
}
