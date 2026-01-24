import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../models/activity_model.dart';
import '../models/ai_insight_model.dart';
import '../models/baby_model.dart';
import 'openai_service.dart';

/// AI 코칭 서비스
class AICoachingService {
  final FirebaseFirestore _firestore;
  final OpenAIService _openAIService;

  AICoachingService({
    required FirebaseFirestore firestore,
    required OpenAIService openAIService,
  })  : _firestore = firestore,
        _openAIService = openAIService;

  /// 차트 이벤트 클릭 시 컨텍스트 생성 및 AI 분석
  Future<AIInsightModel> analyzeEventContext({
    required String babyId,
    required ActivityModel clickedEvent,
    required int babyAgeInDays,
  }) async {
    // 1. 데이터 컨텍스트 생성 (6시간 전후)
    final context = await _buildEventContext(
      babyId: babyId,
      eventTime: DateTime.parse(clickedEvent.timestamp),
      babyAgeInDays: babyAgeInDays,
      activityType: clickedEvent.type.toString().split('.').last,
    );

    // 2. 위험 수준 평가
    final riskLevel = _assessRiskLevel(context);

    // 3. AI 분석 요청
    final aiContent = await _generateAIInsight(
      context: context,
      riskLevel: riskLevel,
    );

    // 4. 인사이트 모델 생성
    final insight = AIInsightModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      eventId: clickedEvent.id,
      eventContext: context,
      content: aiContent,
      riskLevel: riskLevel,
    );

    // 5. Firestore에 저장
    await _saveInsightToFirestore(babyId: babyId, insight: insight);

    return insight;
  }

  /// 이벤트 컨텍스트 생성 (6시간 전후 데이터)
  Future<ActivityEventContext> _buildEventContext({
    required String babyId,
    required DateTime eventTime,
    required int babyAgeInDays,
    required String activityType,
  }) async {
    final startTime = eventTime.subtract(Duration(hours: 6));
    final endTime = eventTime.add(Duration(hours: 6));

    // 활동 데이터 조회
    final activitiesSnapshot = await _firestore
        .collection('babies')
        .doc(babyId)
        .collection('activities')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startTime))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endTime))
        .orderBy('timestamp')
        .get();

    final activities = activitiesSnapshot.docs
        .map((doc) => ActivityModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();

    // 수유 데이터
    final feedings = activities
        .where((a) => a.type == ActivityType.feeding)
        .map((a) {
      final time = DateTime.parse(a.timestamp);
      return FeedingContext(
        time: time,
        amountMl: a.amountMl,
        feedingType: a.feedingType ?? 'unknown',
        hoursAgo: eventTime.difference(time).inHours,
      );
    }).toList();

    // 수면 데이터
    final sleeps = activities
        .where((a) => a.type == ActivityType.sleep)
        .map((a) {
      final time = DateTime.parse(a.timestamp);
      return SleepContext(
        startTime: time,
        endTime: a.endTime != null ? DateTime.parse(a.endTime!) : null,
        durationMinutes: a.durationMinutes ?? 0,
        quality: a.sleepQuality,
        hoursAgo: eventTime.difference(time).inHours,
      );
    }).toList();

    // 건강 데이터
    final healthRecords = activities
        .where((a) => a.type == ActivityType.health)
        .map((a) {
      final time = DateTime.parse(a.timestamp);
      return HealthContext(
        time: time,
        temperatureCelsius: a.temperatureCelsius,
        medicationType: a.medicationType,
        hoursAgo: eventTime.difference(time).inHours,
      );
    }).toList();

    // 기저귀 데이터
    final diapers = activities
        .where((a) => a.type == ActivityType.diaper)
        .map((a) {
      final time = DateTime.parse(a.timestamp);
      return DiaperContext(
        time: time,
        diaperType: a.diaperType ?? 'unknown',
        hoursAgo: eventTime.difference(time).inHours,
      );
    }).toList();

    // 표준 지표
    final standardMetrics = StandardMetrics.forAgeInDays(babyAgeInDays);

    return ActivityEventContext(
      activityType: activityType,
      eventTime: eventTime,
      babyAgeInDays: babyAgeInDays,
      recentFeedings: feedings,
      recentSleeps: sleeps,
      recentHealthRecords: healthRecords,
      recentDiapers: diapers,
      standardMetrics: standardMetrics,
    );
  }

  /// 위험 수준 평가
  RiskLevel _assessRiskLevel(ActivityEventContext context) {
    // 고열 감지 (38도 이상)
    final highFever = context.recentHealthRecords.any(
      (h) => h.temperatureCelsius != null && h.temperatureCelsius! >= 38.0,
    );

    if (highFever) {
      return RiskLevel.critical;
    }

    // 수유량 급감 감지 (평소 대비 50% 미만)
    if (context.recentFeedings.length >= 2) {
      final recentFeedings = context.recentFeedings
          .where((f) => f.amountMl != null && f.hoursAgo <= 24)
          .toList();

      if (recentFeedings.length >= 2) {
        final olderFeedings = recentFeedings
            .where((f) => f.hoursAgo > 6)
            .map((f) => f.amountMl!)
            .toList();

        final recentAvg = recentFeedings
            .where((f) => f.hoursAgo <= 6)
            .map((f) => f.amountMl!)
            .fold(0.0, (sum, amount) => sum + amount) /
            recentFeedings.where((f) => f.hoursAgo <= 6).length;

        if (olderFeedings.isNotEmpty) {
          final olderAvg = olderFeedings.fold(0.0, (sum, amount) => sum + amount) /
              olderFeedings.length;

          if (recentAvg < olderAvg * 0.5) {
            return RiskLevel.critical;
          }
        }
      }
    }

    // 수면 패턴 이상 감지
    final poorSleepCount = context.recentSleeps
        .where((s) => s.quality == 'poor' && s.hoursAgo <= 12)
        .length;

    if (poorSleepCount >= 3) {
      return RiskLevel.caution;
    }

    return RiskLevel.normal;
  }

  /// AI 인사이트 생성
  Future<AIInsightContent> _generateAIInsight({
    required ActivityEventContext context,
    required RiskLevel riskLevel,
  }) async {
    // 위험 수준이 높으면 전문가 상담 권고
    if (riskLevel == RiskLevel.critical) {
      return AIInsightContent(
        empathyMessage: '아기의 상태가 면밀한 관찰이 필요해 보입니다.',
        dataInsight: _buildCriticalDataInsight(context),
        actionGuidance: '즉시 소아과 전문의와 상담하시기를 권장합니다.',
        expertAdvice: '현재 데이터를 PDF로 내보내어 의사에게 보여주실 수 있습니다.',
        rawAIResponse: '',
      );
    }

    // AI에게 분석 요청
    final prompt = _buildAnalysisPrompt(context, riskLevel);

    try {
      final response = await _openAIService.sendMessage(
        messages: [ChatMessage.user(prompt)],
        babyContext: BabyContext(
          name: 'Baby',
          ageInMonths: (context.babyAgeInDays / 30).floor(),
          ageInWeeks: (context.babyAgeInDays / 7).floor(),
        ),
      );

      final parsedContent = _parseAIResponse(response.content);

      return AIInsightContent(
        empathyMessage: parsedContent['empathy'] ?? '함께 아기를 돌보고 있습니다.',
        dataInsight: parsedContent['insight'] ?? '데이터를 분석 중입니다.',
        actionGuidance: parsedContent['action'] ?? '계속 관찰해 주세요.',
        expertAdvice: riskLevel == RiskLevel.caution
            ? '증상이 지속되면 전문의 상담을 고려해 주세요.'
            : null,
        rawAIResponse: response.content,
      );
    } catch (e) {
      // AI 호출 실패 시 기본 응답
      return AIInsightContent(
        empathyMessage: '아기를 돌보시느라 수고하십니다.',
        dataInsight: '데이터를 확인 중입니다. 잠시 후 다시 시도해 주세요.',
        actionGuidance: '현재 패턴을 계속 기록해 주세요.',
        rawAIResponse: 'Error: ${e.toString()}',
      );
    }
  }

  /// 위험 데이터 인사이트 생성
  String _buildCriticalDataInsight(ActivityEventContext context) {
    final issues = <String>[];

    // 고열 체크
    final highFever = context.recentHealthRecords
        .where((h) => h.temperatureCelsius != null && h.temperatureCelsius! >= 38.0)
        .toList();

    if (highFever.isNotEmpty) {
      final maxTemp = highFever
          .map((h) => h.temperatureCelsius!)
          .reduce((a, b) => a > b ? a : b);
      issues.add('최근 체온이 ${maxTemp.toStringAsFixed(1)}°C로 측정되었습니다.');
    }

    // 수유량 체크
    if (context.recentFeedings.isNotEmpty) {
      final recentFeedings = context.recentFeedings
          .where((f) => f.amountMl != null && f.hoursAgo <= 6)
          .toList();

      if (recentFeedings.isEmpty || recentFeedings.length < 2) {
        issues.add('최근 6시간 동안 수유 기록이 부족합니다.');
      }
    }

    return issues.join(' ');
  }

  /// AI 분석 프롬프트 생성
  String _buildAnalysisPrompt(ActivityEventContext context, RiskLevel riskLevel) {
    final buffer = StringBuffer();

    buffer.writeln('아기 상태 분석 요청:');
    buffer.writeln('');
    buffer.writeln('생후 ${context.babyAgeInDays}일 (약 ${(context.babyAgeInDays / 30).floor()}개월)');
    buffer.writeln('');
    buffer.writeln('## 최근 6시간 데이터:');
    buffer.writeln('');

    // 수유 데이터
    if (context.recentFeedings.isNotEmpty) {
      buffer.writeln('### 수유:');
      for (final feeding in context.recentFeedings.take(3)) {
        buffer.writeln('- ${feeding.hoursAgo}시간 전: ${feeding.amountMl ?? 0}ml (${feeding.feedingType})');
      }
      buffer.writeln('');
    }

    // 수면 데이터
    if (context.recentSleeps.isNotEmpty) {
      buffer.writeln('### 수면:');
      for (final sleep in context.recentSleeps.take(3)) {
        buffer.writeln('- ${sleep.hoursAgo}시간 전: ${sleep.durationMinutes}분 (${sleep.quality ?? "기록 없음"})');
      }
      buffer.writeln('');
    }

    // 건강 데이터
    if (context.recentHealthRecords.isNotEmpty) {
      buffer.writeln('### 건강:');
      for (final health in context.recentHealthRecords.take(3)) {
        if (health.temperatureCelsius != null) {
          buffer.writeln('- ${health.hoursAgo}시간 전: 체온 ${health.temperatureCelsius}°C');
        }
      }
      buffer.writeln('');
    }

    buffer.writeln('## 이 시기 표준:');
    buffer.writeln('- 하루 평균 수면: ${context.standardMetrics.averageSleepHoursPerDay}시간');
    buffer.writeln('- 평균 낮잠 횟수: ${context.standardMetrics.averageNapCount}회');
    buffer.writeln('- 평균 수유 간격: ${context.standardMetrics.averageFeedingInterval}시간');
    buffer.writeln('- 전형적 과제: ${context.standardMetrics.typicalChallenges}');
    buffer.writeln('');

    buffer.writeln('다음 세 가지를 각각 2-3문장으로 답변해 주세요:');
    buffer.writeln('1. [공감] 부모의 감정에 공감하는 메시지');
    buffer.writeln('2. [통찰] 데이터에서 발견한 패턴과 의미');
    buffer.writeln('3. [행동] 오늘 시도해볼 수 있는 구체적인 조언');
    buffer.writeln('');
    buffer.writeln('각 섹션을 [공감], [통찰], [행동] 태그로 명확히 구분해 주세요.');

    return buffer.toString();
  }

  /// AI 응답 파싱
  Map<String, String> _parseAIResponse(String response) {
    final result = <String, String>{};

    // [공감] 섹션 추출
    final empathyMatch = RegExp(r'\[공감\](.*?)(?=\[|$)', dotAll: true).firstMatch(response);
    if (empathyMatch != null) {
      result['empathy'] = empathyMatch.group(1)?.trim() ?? '';
    }

    // [통찰] 섹션 추출
    final insightMatch = RegExp(r'\[통찰\](.*?)(?=\[|$)', dotAll: true).firstMatch(response);
    if (insightMatch != null) {
      result['insight'] = insightMatch.group(1)?.trim() ?? '';
    }

    // [행동] 섹션 추출
    final actionMatch = RegExp(r'\[행동\](.*?)(?=\[|$)', dotAll: true).firstMatch(response);
    if (actionMatch != null) {
      result['action'] = actionMatch.group(1)?.trim() ?? '';
    }

    return result;
  }

  /// Firestore에 인사이트 저장
  Future<void> _saveInsightToFirestore({
    required String babyId,
    required AIInsightModel insight,
  }) async {
    await _firestore
        .collection('babies')
        .doc(babyId)
        .collection('insights')
        .doc(insight.id)
        .set(insight.toJson());
  }

  /// 피드백 저장
  Future<void> saveFeedback({
    required String babyId,
    required String insightId,
    required String rating,
  }) async {
    await _firestore
        .collection('babies')
        .doc(babyId)
        .collection('insights')
        .doc(insightId)
        .update({
      'feedbackRating': rating,
      'feedbackTimestamp': Timestamp.now(),
    });
  }

  /// 인사이트 목록 조회
  Future<List<AIInsightModel>> getInsights({
    required String babyId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    Query query = _firestore
        .collection('babies')
        .doc(babyId)
        .collection('insights')
        .orderBy('timestamp', descending: true);

    if (startDate != null) {
      query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.limit(limit).get();

    return snapshot.docs
        .map((doc) => AIInsightModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
        .toList();
  }
}
