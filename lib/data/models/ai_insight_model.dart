import 'package:cloud_firestore/cloud_firestore.dart';

/// AI 인사이트 리포트 모델
class AIInsightModel {
  final String id;
  final DateTime timestamp;
  final String eventId; // 클릭한 이벤트의 ID
  final ActivityEventContext eventContext;
  final AIInsightContent content;
  final RiskLevel riskLevel;
  final String? feedbackRating; // 'positive', 'negative', null
  final DateTime? feedbackTimestamp;

  AIInsightModel({
    required this.id,
    required this.timestamp,
    required this.eventId,
    required this.eventContext,
    required this.content,
    required this.riskLevel,
    this.feedbackRating,
    this.feedbackTimestamp,
  });

  factory AIInsightModel.fromJson(Map<String, dynamic> json) {
    return AIInsightModel(
      id: json['id'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      eventId: json['eventId'] as String,
      eventContext: ActivityEventContext.fromJson(json['eventContext'] as Map<String, dynamic>),
      content: AIInsightContent.fromJson(json['content'] as Map<String, dynamic>),
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.toString() == 'RiskLevel.${json['riskLevel']}',
      ),
      feedbackRating: json['feedbackRating'] as String?,
      feedbackTimestamp: json['feedbackTimestamp'] != null
          ? (json['feedbackTimestamp'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': Timestamp.fromDate(timestamp),
      'eventId': eventId,
      'eventContext': eventContext.toJson(),
      'content': content.toJson(),
      'riskLevel': riskLevel.toString().split('.').last,
      'feedbackRating': feedbackRating,
      'feedbackTimestamp': feedbackTimestamp != null
          ? Timestamp.fromDate(feedbackTimestamp!)
          : null,
    };
  }

  /// 피드백 추가
  AIInsightModel withFeedback(String rating) {
    return AIInsightModel(
      id: id,
      timestamp: timestamp,
      eventId: eventId,
      eventContext: eventContext,
      content: content,
      riskLevel: riskLevel,
      feedbackRating: rating,
      feedbackTimestamp: DateTime.now(),
    );
  }
}

/// 위험 수준
enum RiskLevel {
  normal,     // 정상 - AI 코칭
  caution,    // 주의 - AI 코칭 + 경고
  critical,   // 위험 - 전문가 상담 권고
}

/// 활동 이벤트 컨텍스트 (6시간 전후 데이터)
class ActivityEventContext {
  final String activityType;
  final DateTime eventTime;
  final int babyAgeInDays;

  // 전후 6시간 맥락 데이터
  final List<FeedingContext> recentFeedings;
  final List<SleepContext> recentSleeps;
  final List<HealthContext> recentHealthRecords;
  final List<DiaperContext> recentDiapers;

  // 월령별 표준 데이터
  final StandardMetrics standardMetrics;

  ActivityEventContext({
    required this.activityType,
    required this.eventTime,
    required this.babyAgeInDays,
    required this.recentFeedings,
    required this.recentSleeps,
    required this.recentHealthRecords,
    required this.recentDiapers,
    required this.standardMetrics,
  });

  factory ActivityEventContext.fromJson(Map<String, dynamic> json) {
    return ActivityEventContext(
      activityType: json['activityType'] as String,
      eventTime: (json['eventTime'] as Timestamp).toDate(),
      babyAgeInDays: json['babyAgeInDays'] as int,
      recentFeedings: (json['recentFeedings'] as List)
          .map((e) => FeedingContext.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentSleeps: (json['recentSleeps'] as List)
          .map((e) => SleepContext.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentHealthRecords: (json['recentHealthRecords'] as List)
          .map((e) => HealthContext.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentDiapers: (json['recentDiapers'] as List)
          .map((e) => DiaperContext.fromJson(e as Map<String, dynamic>))
          .toList(),
      standardMetrics: StandardMetrics.fromJson(json['standardMetrics'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activityType': activityType,
      'eventTime': Timestamp.fromDate(eventTime),
      'babyAgeInDays': babyAgeInDays,
      'recentFeedings': recentFeedings.map((e) => e.toJson()).toList(),
      'recentSleeps': recentSleeps.map((e) => e.toJson()).toList(),
      'recentHealthRecords': recentHealthRecords.map((e) => e.toJson()).toList(),
      'recentDiapers': recentDiapers.map((e) => e.toJson()).toList(),
      'standardMetrics': standardMetrics.toJson(),
    };
  }
}

/// 수유 컨텍스트
class FeedingContext {
  final DateTime time;
  final double? amountMl;
  final String feedingType;
  final int hoursAgo;

  FeedingContext({
    required this.time,
    this.amountMl,
    required this.feedingType,
    required this.hoursAgo,
  });

  factory FeedingContext.fromJson(Map<String, dynamic> json) {
    return FeedingContext(
      time: (json['time'] as Timestamp).toDate(),
      amountMl: json['amountMl'] as double?,
      feedingType: json['feedingType'] as String,
      hoursAgo: json['hoursAgo'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': Timestamp.fromDate(time),
      'amountMl': amountMl,
      'feedingType': feedingType,
      'hoursAgo': hoursAgo,
    };
  }
}

/// 수면 컨텍스트
class SleepContext {
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final String? quality;
  final int hoursAgo;

  SleepContext({
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    this.quality,
    required this.hoursAgo,
  });

  factory SleepContext.fromJson(Map<String, dynamic> json) {
    return SleepContext(
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: json['endTime'] != null
          ? (json['endTime'] as Timestamp).toDate()
          : null,
      durationMinutes: json['durationMinutes'] as int,
      quality: json['quality'] as String?,
      hoursAgo: json['hoursAgo'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'durationMinutes': durationMinutes,
      'quality': quality,
      'hoursAgo': hoursAgo,
    };
  }
}

/// 건강 컨텍스트
class HealthContext {
  final DateTime time;
  final double? temperatureCelsius;
  final String? medicationType;
  final int hoursAgo;

  HealthContext({
    required this.time,
    this.temperatureCelsius,
    this.medicationType,
    required this.hoursAgo,
  });

  factory HealthContext.fromJson(Map<String, dynamic> json) {
    return HealthContext(
      time: (json['time'] as Timestamp).toDate(),
      temperatureCelsius: json['temperatureCelsius'] as double?,
      medicationType: json['medicationType'] as String?,
      hoursAgo: json['hoursAgo'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': Timestamp.fromDate(time),
      'temperatureCelsius': temperatureCelsius,
      'medicationType': medicationType,
      'hoursAgo': hoursAgo,
    };
  }
}

/// 기저귀 컨텍스트
class DiaperContext {
  final DateTime time;
  final String diaperType;
  final int hoursAgo;

  DiaperContext({
    required this.time,
    required this.diaperType,
    required this.hoursAgo,
  });

  factory DiaperContext.fromJson(Map<String, dynamic> json) {
    return DiaperContext(
      time: (json['time'] as Timestamp).toDate(),
      diaperType: json['diaperType'] as String,
      hoursAgo: json['hoursAgo'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': Timestamp.fromDate(time),
      'diaperType': diaperType,
      'hoursAgo': hoursAgo,
    };
  }
}

/// 월령별 표준 지표 (생후 72일 / 2개월)
class StandardMetrics {
  final int ageInDays;
  final double averageSleepHoursPerDay;
  final double averageNapCount;
  final double averageFeedingInterval;
  final String typicalChallenges; // "영아 산통", "낮밤 구분 시작" 등

  StandardMetrics({
    required this.ageInDays,
    required this.averageSleepHoursPerDay,
    required this.averageNapCount,
    required this.averageFeedingInterval,
    required this.typicalChallenges,
  });

  factory StandardMetrics.fromJson(Map<String, dynamic> json) {
    return StandardMetrics(
      ageInDays: json['ageInDays'] as int,
      averageSleepHoursPerDay: json['averageSleepHoursPerDay'] as double,
      averageNapCount: json['averageNapCount'] as double,
      averageFeedingInterval: json['averageFeedingInterval'] as double,
      typicalChallenges: json['typicalChallenges'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ageInDays': ageInDays,
      'averageSleepHoursPerDay': averageSleepHoursPerDay,
      'averageNapCount': averageNapCount,
      'averageFeedingInterval': averageFeedingInterval,
      'typicalChallenges': typicalChallenges,
    };
  }

  /// 생후 일수에 따른 표준 지표 생성
  factory StandardMetrics.forAgeInDays(int days) {
    if (days <= 30) {
      // 신생아 (0-1개월)
      return StandardMetrics(
        ageInDays: days,
        averageSleepHoursPerDay: 16.0,
        averageNapCount: 4.5,
        averageFeedingInterval: 2.5,
        typicalChallenges: '빈번한 수유, 낮밤 구분 없음, 짧은 수면 주기',
      );
    } else if (days <= 90) {
      // 2-3개월
      return StandardMetrics(
        ageInDays: days,
        averageSleepHoursPerDay: 14.5,
        averageNapCount: 3.5,
        averageFeedingInterval: 3.0,
        typicalChallenges: '영아 산통 (6-8주 정점), 낮밤 구분 시작, 수면 퇴행 가능성',
      );
    } else if (days <= 180) {
      // 4-6개월
      return StandardMetrics(
        ageInDays: days,
        averageSleepHoursPerDay: 14.0,
        averageNapCount: 3.0,
        averageFeedingInterval: 3.5,
        typicalChallenges: '4개월 수면 퇴행, 뒤집기 시작, 이유식 준비',
      );
    } else {
      // 6개월 이상
      return StandardMetrics(
        ageInDays: days,
        averageSleepHoursPerDay: 13.5,
        averageNapCount: 2.5,
        averageFeedingInterval: 4.0,
        typicalChallenges: '이유식 시작, 밤잠 연장, 분리불안 시작',
      );
    }
  }
}

/// AI 인사이트 콘텐츠
class AIInsightContent {
  final String empathyMessage;     // 공감 메시지
  final String dataInsight;        // 데이터 통찰
  final String actionGuidance;     // 행동 지침
  final String? expertAdvice;      // 전문가 조언 (위험 수준이 높을 때)
  final String rawAIResponse;      // 원본 AI 응답 (디버깅용)

  AIInsightContent({
    required this.empathyMessage,
    required this.dataInsight,
    required this.actionGuidance,
    this.expertAdvice,
    required this.rawAIResponse,
  });

  factory AIInsightContent.fromJson(Map<String, dynamic> json) {
    return AIInsightContent(
      empathyMessage: json['empathyMessage'] as String,
      dataInsight: json['dataInsight'] as String,
      actionGuidance: json['actionGuidance'] as String,
      expertAdvice: json['expertAdvice'] as String?,
      rawAIResponse: json['rawAIResponse'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empathyMessage': empathyMessage,
      'dataInsight': dataInsight,
      'actionGuidance': actionGuidance,
      'expertAdvice': expertAdvice,
      'rawAIResponse': rawAIResponse,
    };
  }
}
