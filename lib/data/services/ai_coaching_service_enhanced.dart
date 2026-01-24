import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../models/activity_model.dart';
import '../models/ai_insight_model.dart';
import '../models/baby_model.dart';
import 'openai_service.dart';
import 'personalization_memory_service.dart';
import '../analysis/cross_correlation_analyzer.dart';
import '../analysis/chain_of_thought_reasoner.dart';
import '../knowledge/expert_guidelines.dart';

/// 고도화된 AI 코칭 서비스
/// - 전문가 페르소나
/// - 다각도 상관관계 분석
/// - Chain of Thought 추론
/// - 강화된 위험 징후 필터링
/// - 개인화 메모리
class AICoachingServiceEnhanced {
  final FirebaseFirestore _firestore;
  final OpenAIService _openAIService;
  final PersonalizationMemoryService _memoryService;

  AICoachingServiceEnhanced({
    required FirebaseFirestore firestore,
    required OpenAIService openAIService,
    required PersonalizationMemoryService memoryService,
  })  : _firestore = firestore,
        _openAIService = openAIService,
        _memoryService = memoryService;

  /// 차트 이벤트 클릭 시 고도화된 분석
  Future<AIInsightModel> analyzeEventContext({
    required String babyId,
    required ActivityModel clickedEvent,
    required int babyAgeInDays,
    required double babyWeightKg,
  }) async {
    // 1. 데이터 컨텍스트 생성 (6시간 전후)
    final context = await _buildEventContext(
      babyId: babyId,
      eventTime: DateTime.parse(clickedEvent.timestamp),
      babyAgeInDays: babyAgeInDays,
      activityType: clickedEvent.type.toString().split('.').last,
    );

    // 2. 다각도 상관관계 분석
    final correlation = CrossCorrelationAnalyzer.analyze(
      context: context,
      babyWeightKg: babyWeightKg,
    );

    // 3. 강화된 위험 수준 평가
    final riskLevel = _assessRiskLevelEnhanced(context, correlation);

    // 4. Chain of Thought 추론
    final reasoning = ChainOfThoughtReasoner.performReasoning(
      context: context,
      correlation: correlation,
      babyWeightKg: babyWeightKg,
    );

    // 5. 개인화 컨텍스트 로드
    final personalizedContext = await _memoryService.buildPersonalizedContext(
      babyId: babyId,
      currentSituation: clickedEvent.type.toString(),
    );

    // 6. AI 분석 요청 (전문가 페르소나 + CoT)
    final aiContent = await _generateAIInsightEnhanced(
      context: context,
      correlation: correlation,
      reasoning: reasoning,
      riskLevel: riskLevel,
      babyAgeInDays: babyAgeInDays,
      babyWeightKg: babyWeightKg,
      personalizedContext: personalizedContext,
    );

    // 7. 인사이트 모델 생성
    final insight = AIInsightModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      eventId: clickedEvent.id,
      eventContext: context,
      content: aiContent,
      riskLevel: riskLevel,
    );

    // 8. Firestore에 저장
    await _saveInsightToFirestore(babyId: babyId, insight: insight);

    return insight;
  }

  /// 이벤트 컨텍스트 생성 (기존 로직 유지)
  Future<ActivityEventContext> _buildEventContext({
    required String babyId,
    required DateTime eventTime,
    required int babyAgeInDays,
    required String activityType,
  }) async {
    final startTime = eventTime.subtract(Duration(hours: 6));
    final endTime = eventTime.add(Duration(hours: 6));

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

  /// 강화된 위험 수준 평가
  RiskLevel _assessRiskLevelEnhanced(
    ActivityEventContext context,
    CorrelationAnalysisResult correlation,
  ) {
    // 1. 응급 상황 체크
    if (correlation.healthCorrelation.temperatureStatus == TemperatureStatus.emergency) {
      return RiskLevel.critical;
    }

    // 2. 고열 + 다른 증상
    if (correlation.healthCorrelation.temperatureStatus == TemperatureStatus.fever) {
      // 수유량도 감소했다면 critical
      if (!correlation.feedingCorrelation.isSufficient) {
        return RiskLevel.critical;
      }
      return RiskLevel.caution;
    }

    // 3. 수유량 급감 (40% 이상 감소)
    if (correlation.feedingCorrelation.lastFeedingAmount != null) {
      final ratio = correlation.feedingCorrelation.lastFeedingAmount! /
          correlation.feedingCorrelation.recommendedAmount;

      if (ratio < ExpertGuidelines.feedingReductionThresholds['severe_concern']!) {
        return RiskLevel.critical;
      } else if (ratio < ExpertGuidelines.feedingReductionThresholds['moderate_concern']!) {
        return RiskLevel.caution;
      }
    }

    // 4. 하루 총 수유량 체크
    final feedingsLast24h = context.recentFeedings
        .where((f) => f.hoursAgo <= 24 && f.amountMl != null)
        .toList();

    if (feedingsLast24h.length >= 3) {
      final totalAmount = feedingsLast24h
          .map((f) => f.amountMl!)
          .fold(0.0, (sum, amount) => sum + amount);

      // 하루 권장량의 60% 미만
      final dailyRecommended = correlation.feedingCorrelation.recommendedAmount * 8;
      if (totalAmount < dailyRecommended * 0.6) {
        return RiskLevel.critical;
      }
    }

    // 5. 극심한 통증성 울음
    // Note: Crying tracking feature can be added in future updates

    // 6. 배변 횟수 이상
    if (correlation.healthCorrelation.diaperCount24h < 3) {
      return RiskLevel.caution;
    }

    return RiskLevel.normal;
  }

  /// 고도화된 AI 인사이트 생성
  Future<AIInsightContent> _generateAIInsightEnhanced({
    required ActivityEventContext context,
    required CorrelationAnalysisResult correlation,
    required ReasoningProcess reasoning,
    required RiskLevel riskLevel,
    required int babyAgeInDays,
    required double babyWeightKg,
    required String personalizedContext,
  }) async {
    // Critical 상태면 전문가 상담 권고
    if (riskLevel == RiskLevel.critical) {
      return AIInsightContent(
        empathyMessage: reasoning.step4_solution.empathyMessage,
        dataInsight: _buildCriticalDataInsight(correlation),
        actionGuidance: '즉시 소아과 전문의와 상담하시기를 권장합니다.',
        expertAdvice: '현재 데이터를 PDF로 내보내어 의사에게 보여주실 수 있습니다.',
        rawAIResponse: reasoning.toFullReasoningText(),
      );
    }

    // 전문가 페르소나 프롬프트 생성
    final systemPrompt = ExpertPersona.getContextualizedPrompt(
      babyAgeInDays: babyAgeInDays,
      babyWeightKg: babyWeightKg,
    );

    // 분석 프롬프트 생성
    final analysisPrompt = _buildEnhancedAnalysisPrompt(
      context: context,
      correlation: correlation,
      reasoning: reasoning,
      personalizedContext: personalizedContext,
    );

    try {
      final response = await _openAIService.sendMessage(
        messages: [
          ChatMessage(role: 'system', content: systemPrompt),
          ChatMessage.user(analysisPrompt),
        ],
      );

      final parsedContent = _parseAIResponse(response.content);

      return AIInsightContent(
        empathyMessage: parsedContent['empathy'] ?? reasoning.step4_solution.empathyMessage,
        dataInsight: parsedContent['insight'] ?? correlation.toAnalysisText(),
        actionGuidance: parsedContent['action'] ?? reasoning.step4_solution.actionItems.join('\n'),
        expertAdvice: riskLevel == RiskLevel.caution
            ? '증상이 지속되면 전문의 상담을 고려해 주세요.'
            : null,
        rawAIResponse: '${reasoning.toFullReasoningText()}\n\n---AI Response---\n${response.content}',
      );
    } catch (e) {
      // AI 호출 실패 시 Chain of Thought 결과 사용
      return AIInsightContent(
        empathyMessage: reasoning.step4_solution.empathyMessage,
        dataInsight: correlation.toAnalysisText(),
        actionGuidance: reasoning.step4_solution.actionItems.join('\n'),
        rawAIResponse: 'CoT Fallback: ${reasoning.toFullReasoningText()}\n\nError: ${e.toString()}',
      );
    }
  }

  /// 고도화된 분석 프롬프트 생성
  String _buildEnhancedAnalysisPrompt({
    required ActivityEventContext context,
    required CorrelationAnalysisResult correlation,
    required ReasoningProcess reasoning,
    required String personalizedContext,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('## 상황 분석 요청\n');
    buffer.writeln('아기가 ${context.activityType} 활동 중 어려움을 겪고 있습니다.\n');

    // Chain of Thought 결과
    buffer.writeln('### 내부 추론 과정:');
    buffer.writeln(reasoning.toFullReasoningText());
    buffer.writeln();

    // 상관관계 분석
    buffer.writeln('### 다각도 분석 결과:');
    buffer.writeln(correlation.toAnalysisText());
    buffer.writeln();

    // 개인화 컨텍스트
    if (personalizedContext.isNotEmpty) {
      buffer.writeln(personalizedContext);
      buffer.writeln();
    }

    // AAP 가이드라인 참고
    buffer.writeln('### 참고 가이드라인:');
    buffer.writeln(ExpertGuidelines.aapSafeSleepGuidelines);
    buffer.writeln(ExpertGuidelines.eatPlaySleepCycle);
    buffer.writeln();

    // 요청 사항
    buffer.writeln('---');
    buffer.writeln('위 분석을 바탕으로, 부모에게 다음 세 가지를 제공해주세요:');
    buffer.writeln();
    buffer.writeln('[공감]');
    buffer.writeln('부모의 감정과 상황에 공감하는 따뜻한 메시지 (2-3문장)');
    if (personalizedContext.isNotEmpty) {
      buffer.writeln('※ 이전 대화를 언급하여 연속성을 높여주세요');
    }
    buffer.writeln();
    buffer.writeln('[통찰]');
    buffer.writeln('"데이터를 분석해보니 ~한 이유로 보입니다"로 시작하는 논리적 근거 (3-4문장)');
    buffer.writeln('※ 반드시 구체적인 데이터와 의학적 근거를 인용하세요');
    buffer.writeln();
    buffer.writeln('[행동]');
    buffer.writeln('오늘 바로 시도할 수 있는 구체적이고 실행 가능한 조언 (3-5개 항목)');
    buffer.writeln('※ 단계별로 번호를 매겨 제시하세요');

    return buffer.toString();
  }

  /// Critical 데이터 인사이트
  String _buildCriticalDataInsight(CorrelationAnalysisResult correlation) {
    final issues = <String>[];

    if (correlation.healthCorrelation.temperatureStatus != TemperatureStatus.normal) {
      issues.add(correlation.healthCorrelation.temperatureAnalysis ?? '');
    }

    if (!correlation.feedingCorrelation.isSufficient) {
      issues.add(correlation.feedingCorrelation.analysis);
    }

    if (correlation.healthCorrelation.diaperCount24h < 3) {
      issues.add(correlation.healthCorrelation.diaperAnalysis);
    }

    return issues.join('\n\n');
  }

  /// AI 응답 파싱
  Map<String, String> _parseAIResponse(String response) {
    final result = <String, String>{};

    final empathyMatch = RegExp(r'\[공감\](.*?)(?=\[|$)', dotAll: true).firstMatch(response);
    if (empathyMatch != null) {
      result['empathy'] = empathyMatch.group(1)?.trim() ?? '';
    }

    final insightMatch = RegExp(r'\[통찰\](.*?)(?=\[|$)', dotAll: true).firstMatch(response);
    if (insightMatch != null) {
      result['insight'] = insightMatch.group(1)?.trim() ?? '';
    }

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
