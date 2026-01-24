import '../models/ai_insight_model.dart';
import 'cross_correlation_analyzer.dart';
import '../knowledge/expert_guidelines.dart';

/// Chain of Thought 추론기
class ChainOfThoughtReasoner {
  /// 단계별 추론 수행
  static ReasoningProcess performReasoning({
    required ActivityEventContext context,
    required CorrelationAnalysisResult correlation,
    required double babyWeightKg,
  }) {
    // Step 1: 데이터 확인
    final dataReview = _reviewData(context, correlation);

    // Step 2: 원인 가설 설정
    final hypotheses = _generateHypotheses(context, correlation);

    // Step 3: 의학적 근거 매칭
    final medicalEvidence = _matchMedicalEvidence(hypotheses, context);

    // Step 4: 최종 솔루션 도출
    final solution = _deriveSolution(
      hypotheses: hypotheses,
      evidence: medicalEvidence,
      context: context,
      babyWeightKg: babyWeightKg,
    );

    return ReasoningProcess(
      step1_dataReview: dataReview,
      step2_hypotheses: hypotheses,
      step3_medicalEvidence: medicalEvidence,
      step4_solution: solution,
    );
  }

  /// Step 1: 데이터 확인
  static DataReview _reviewData(
    ActivityEventContext context,
    CorrelationAnalysisResult correlation,
  ) {
    final observations = <String>[];
    final concerns = <String>[];

    // 수유 데이터 확인
    if (!correlation.feedingCorrelation.isSufficient) {
      observations.add('마지막 수유가 ${correlation.feedingCorrelation.lastFeedingHoursAgo?.toStringAsFixed(1) ?? "기록 없음"}시간 전입니다.');
      concerns.add('수유량 또는 간격이 부족할 수 있습니다.');
    } else {
      observations.add('수유는 적절합니다.');
    }

    // 체온 확인
    if (correlation.healthCorrelation.temperatureStatus != TemperatureStatus.normal) {
      observations.add('체온: ${correlation.healthCorrelation.latestTemperature?.toStringAsFixed(1)}°C');
      concerns.add('발열이 있어 불편감을 느낄 수 있습니다.');
    }

    // 수면 압력 확인
    if (correlation.sleepPressureCorrelation.pressureLevel == PressureLevel.low) {
      observations.add('각성 시간이 ${correlation.sleepPressureCorrelation.wakeWindowMinutes}분으로 짧습니다.');
      concerns.add('아직 충분히 피곤하지 않을 수 있습니다.');
    } else if (correlation.sleepPressureCorrelation.pressureLevel == PressureLevel.excessive) {
      observations.add('각성 시간이 ${correlation.sleepPressureCorrelation.wakeWindowMinutes}분으로 깁니다.');
      concerns.add('과자극 상태로 진정이 어려울 수 있습니다.');
    }

    // 시간대 확인
    if (correlation.timeOfDayCorrelation.timeType == TimeOfDayType.eveningColicPeak) {
      observations.add('저녁 시간대 (${correlation.timeOfDayCorrelation.hourOfDay}시)');
      concerns.add('영아 산통이 심해지는 시간대입니다.');
    }

    return DataReview(
      observations: observations,
      concerns: concerns,
      summary: _summarizeDataReview(observations, concerns),
    );
  }

  static String _summarizeDataReview(List<String> observations, List<String> concerns) {
    final buffer = StringBuffer();
    buffer.writeln('[Step 1: 데이터 확인]');
    buffer.writeln('');
    buffer.writeln('관찰된 사실:');
    for (final obs in observations) {
      buffer.writeln('• $obs');
    }
    buffer.writeln('');
    if (concerns.isNotEmpty) {
      buffer.writeln('우려사항:');
      for (final concern in concerns) {
        buffer.writeln('• $concern');
      }
    }
    return buffer.toString();
  }

  /// Step 2: 원인 가설 설정
  static List<Hypothesis> _generateHypotheses(
    ActivityEventContext context,
    CorrelationAnalysisResult correlation,
  ) {
    final hypotheses = <Hypothesis>[];

    // 가설 1: 배고픔
    if (!correlation.feedingCorrelation.isSufficient) {
      hypotheses.add(Hypothesis(
        cause: '배고픔',
        likelihood: HypothesisLikelihood.high,
        reasoning: '마지막 수유가 부족하거나 오래 전이어서 배고픔을 느낄 가능성이 높습니다.',
        supportingData: [
          '마지막 수유: ${correlation.feedingCorrelation.lastFeedingHoursAgo?.toStringAsFixed(1)}시간 전',
          '수유량: ${correlation.feedingCorrelation.lastFeedingAmount?.toStringAsFixed(0)}ml (권장: ${correlation.feedingCorrelation.recommendedAmount.toStringAsFixed(0)}ml)',
        ],
      ));
    }

    // 가설 2: 불편감 (체온, 배변 등)
    if (correlation.healthCorrelation.temperatureStatus != TemperatureStatus.normal) {
      hypotheses.add(Hypothesis(
        cause: '발열로 인한 불편감',
        likelihood: HypothesisLikelihood.high,
        reasoning: '체온이 높아 불편함을 느끼고 있을 가능성이 높습니다.',
        supportingData: [
          '체온: ${correlation.healthCorrelation.latestTemperature?.toStringAsFixed(1)}°C',
        ],
      ));
    }

    // 가설 3: 수면 압력 부족
    if (correlation.sleepPressureCorrelation.pressureLevel == PressureLevel.low) {
      hypotheses.add(Hypothesis(
        cause: '수면 압력 부족',
        likelihood: HypothesisLikelihood.medium,
        reasoning: '각성 시간이 짧아 아직 충분히 피곤하지 않을 수 있습니다.',
        supportingData: [
          '각성 시간: ${correlation.sleepPressureCorrelation.wakeWindowMinutes}분',
          '마지막 낮잠: ${correlation.sleepPressureCorrelation.lastNapDuration}분',
        ],
      ));
    }

    // 가설 4: 과자극
    if (correlation.sleepPressureCorrelation.pressureLevel == PressureLevel.excessive) {
      hypotheses.add(Hypothesis(
        cause: '과자극 상태',
        likelihood: HypothesisLikelihood.high,
        reasoning: '각성 시간이 너무 길어 과자극 상태에 있을 수 있습니다.',
        supportingData: [
          '각성 시간: ${correlation.sleepPressureCorrelation.wakeWindowMinutes}분 (권장보다 많이 초과)',
        ],
      ));
    }

    // 가설 5: 영아 산통
    if (correlation.timeOfDayCorrelation.timeType == TimeOfDayType.eveningColicPeak &&
        context.babyAgeInDays >= 42 && context.babyAgeInDays <= 90) {
      hypotheses.add(Hypothesis(
        cause: '영아 산통',
        likelihood: HypothesisLikelihood.medium,
        reasoning: '저녁 시간대이고 생후 6-12주 사이로 영아 산통이 발생하기 쉬운 시기입니다.',
        supportingData: [
          '시간: ${correlation.timeOfDayCorrelation.hourOfDay}시 (산통 호발 시간)',
          '월령: ${(context.babyAgeInDays / 7).floor()}주 (산통 정점기)',
        ],
      ));
    }

    // 가설 6: 발달 도약
    if (context.babyAgeInDays % 30 <= 5) {
      hypotheses.add(Hypothesis(
        cause: '발달 도약(Wonder Week)',
        likelihood: HypothesisLikelihood.low,
        reasoning: '월령 변화 시기로 발달 도약을 겪고 있을 수 있습니다.',
        supportingData: [
          '생후 ${context.babyAgeInDays}일 (발달 도약 가능 시기)',
        ],
      ));
    }

    // 가설이 없으면 기본 가설 추가
    if (hypotheses.isEmpty) {
      hypotheses.add(Hypothesis(
        cause: '정상적인 아기의 깨어남',
        likelihood: HypothesisLikelihood.medium,
        reasoning: '이 월령 아기는 짧은 수면 주기(45-60분)로 인해 자주 깰 수 있습니다.',
        supportingData: [
          '생후 ${(context.babyAgeInDays / 30).floor()}개월',
        ],
      ));
    }

    return hypotheses;
  }

  /// Step 3: 의학적 근거 매칭
  static List<MedicalEvidence> _matchMedicalEvidence(
    List<Hypothesis> hypotheses,
    ActivityEventContext context,
  ) {
    final evidenceList = <MedicalEvidence>[];

    for (final hypothesis in hypotheses) {
      String? evidence;
      String? source;

      switch (hypothesis.cause) {
        case '배고픔':
          evidence = '생후 2개월 아기는 평균 3시간 간격으로 수유가 필요하며, 밤에도 1-2회 수유가 정상적입니다. '
              '수유량이 부족하거나 간격이 길면 배고픔으로 깰 수 있습니다.';
          source = 'AAP, WHO 수유 가이드라인';
          break;

        case '발열로 인한 불편감':
          evidence = '영아의 정상 체온은 36.5-37.5°C입니다. 38°C 이상은 발열로 간주하며, '
              '발열 시 아기는 불편함을 느껴 수면이 방해될 수 있습니다.';
          source = 'AAP 소아 발열 가이드라인';
          break;

        case '수면 압력 부족':
        case '과자극 상태':
          evidence = ExpertGuidelines.medicalEvidenceDatabase['밤잠_빈번한_깨어남'] ??
              ExpertGuidelines.sleepPressureConcept;
          source = 'Dr. Marc Weissbluth, "Healthy Sleep Habits, Happy Child"';
          break;

        case '영아 산통':
          evidence = ExpertGuidelines.medicalEvidenceDatabase['영아_산통'];
          source = 'Dr. Harvey Karp, "The Happiest Baby on the Block"';
          break;

        case '발달 도약(Wonder Week)':
          evidence = '아기는 특정 주차(5주, 8주, 12주 등)에 급격한 발달을 겪으며, '
              '이 시기에는 수면 패턴이 일시적으로 퇴행할 수 있습니다.';
          source = 'Dr. Frans Plooij, "The Wonder Weeks"';
          break;

        default:
          evidence = '생후 2개월 아기의 수면 주기는 45-60분으로 짧아, 주기 사이에 깨는 것이 정상입니다. '
              '스스로 다시 잠드는 능력은 생후 4-6개월에 발달합니다.';
          source = '소아 수면 의학 연구';
      }

      evidenceList.add(MedicalEvidence(
        hypothesis: hypothesis.cause,
        evidence: evidence,
        source: source,
      ));
    }

    return evidenceList;
  }

  /// Step 4: 최종 솔루션 도출
  static Solution _deriveSolution({
    required List<Hypothesis> hypotheses,
    required List<MedicalEvidence> evidence,
    required ActivityEventContext context,
    required double babyWeightKg,
  }) {
    // 가장 가능성 높은 가설 선택
    hypotheses.sort((a, b) => b.likelihood.index.compareTo(a.likelihood.index));
    final primaryHypothesis = hypotheses.first;

    // 솔루션 생성
    final actions = <String>[];
    String empathyMessage;
    String reasoning;

    switch (primaryHypothesis.cause) {
      case '배고픔':
        empathyMessage = '밤중 수유는 정말 힘드시죠. 하지만 이 시기 아기에게는 꼭 필요한 영양 공급입니다.';
        reasoning = '데이터를 분석해보니 마지막 수유가 부족하거나 오래 전이어서 배고픔으로 깬 것으로 보입니다.';
        actions.addAll([
          '충분한 수유를 제공해주세요 (권장: ${(babyWeightKg * 150 / 8).round()}ml)',
          '수유 후 트림을 충분히 시켜주세요',
          '낮 수유도 규칙적으로 하여 밤 수유를 줄여갑니다',
        ]);
        break;

      case '발열로 인한 불편감':
        empathyMessage = '아기가 아플 때는 부모님도 함께 마음이 아프시죠. 세심한 관찰이 필요한 시기입니다.';
        reasoning = '체온이 높아 불편함을 느끼고 있어 수면이 방해받고 있습니다.';
        actions.addAll([
          '체온을 지속적으로 모니터링해주세요',
          '실온을 시원하게 유지하고 가벼운 옷을 입혀주세요',
          '수분 섭취를 충분히 해주세요',
          '증상이 지속되면 소아과 상담을 받으세요',
        ]);
        break;

      case '수면 압력 부족':
        empathyMessage = '아기의 수면 리듬을 맞추는 것은 시간이 필요합니다. 조금씩 패턴을 찾아가고 계신 중입니다.';
        reasoning = '각성 시간이 짧아 아직 충분히 피곤하지 않은 상태로 보입니다.';
        actions.addAll([
          '조금 더 놀아주거나 활동 시간을 가진 후 재워보세요',
          '적정 각성 시간은 약 ${ExpertGuidelines.sleepStatisticsByAge[context.babyAgeInDays]?.wakeWindowMinutes ?? 75}분입니다',
          '피곤해하는 신호(하품, 눈 비비기, 보챔)를 관찰하세요',
        ]);
        break;

      case '과자극 상태':
        empathyMessage = '"골든 타임"을 놓쳤을 때는 정말 어렵죠. 하지만 진정시킬 방법은 있습니다.';
        reasoning = '각성 시간이 너무 길어 과자극 상태에 있어 오히려 잠들기 어려운 상태입니다.';
        actions.addAll([
          '환경을 조용하고 어둡게 만들어주세요',
          '백색소음을 켜주세요',
          '부드럽게 흔들거나 안아주며 진정시켜주세요',
          '다음에는 ${ExpertGuidelines.sleepStatisticsByAge[context.babyAgeInDays]?.wakeWindowMinutes ?? 75}분 전에 재워보세요',
        ]);
        break;

      case '영아 산통':
        empathyMessage = '산통으로 우는 아기를 달래는 것은 가장 힘든 육아 중 하나입니다. 당신은 충분히 잘하고 계십니다.';
        reasoning = '저녁 시간대이고 생후 6-12주 사이로 영아 산통의 정점기에 있습니다.';
        actions.addAll([
          '5S 기법을 시도해보세요: 포대기(Swaddle), 옆으로 눕히기(Side), 쉿 소리(Shush), 흔들기(Swing), 빨기(Suck)',
          '배 마사지를 시계방향으로 해주세요',
          '백색소음이나 진공청소기 소리를 들려주세요',
          '부모님도 교대로 쉬어가며 스트레스를 관리하세요',
          '3개월경이면 대부분 사라지니 조금만 더 힘내세요',
        ]);
        break;

      default:
        empathyMessage = '밤에 자주 깨는 아기를 돌보는 것은 정말 힘든 일입니다. 하지만 이것도 지나갈 시간입니다.';
        reasoning = '이 월령 아기는 짧은 수면 주기로 인해 자주 깰 수 있으며, 이는 정상적인 발달 과정입니다.';
        actions.addAll([
          '일관된 수면 루틴을 만들어주세요',
          '밤에는 조명을 어둡게, 낮에는 밝게 유지하여 낮밤 구분을 도와주세요',
          '졸린 상태에서 침대에 눕혀 스스로 잠드는 연습을 시켜주세요',
        ]);
    }

    return Solution(
      primaryCause: primaryHypothesis.cause,
      empathyMessage: empathyMessage,
      reasoning: reasoning,
      actionItems: actions,
      allHypotheses: hypotheses,
      supportingEvidence: evidence,
    );
  }
}

/// 추론 프로세스
class ReasoningProcess {
  final DataReview step1_dataReview;
  final List<Hypothesis> step2_hypotheses;
  final List<MedicalEvidence> step3_medicalEvidence;
  final Solution step4_solution;

  ReasoningProcess({
    required this.step1_dataReview,
    required this.step2_hypotheses,
    required this.step3_medicalEvidence,
    required this.step4_solution,
  });

  /// 전체 추론 과정을 텍스트로
  String toFullReasoningText() {
    final buffer = StringBuffer();

    // Step 1
    buffer.writeln(step1_dataReview.summary);
    buffer.writeln();

    // Step 2
    buffer.writeln('[Step 2: 원인 가설 설정]');
    buffer.writeln();
    for (var i = 0; i < step2_hypotheses.length; i++) {
      final h = step2_hypotheses[i];
      buffer.writeln('가설 ${i + 1}: ${h.cause} (${_likelihoodToKorean(h.likelihood)})');
      buffer.writeln('  추론: ${h.reasoning}');
      if (h.supportingData.isNotEmpty) {
        buffer.writeln('  근거:');
        for (final data in h.supportingData) {
          buffer.writeln('    - $data');
        }
      }
      buffer.writeln();
    }

    // Step 3
    buffer.writeln('[Step 3: 의학적 근거 매칭]');
    buffer.writeln();
    for (final evidence in step3_medicalEvidence) {
      buffer.writeln('${evidence.hypothesis}:');
      buffer.writeln('  ${evidence.evidence}');
      buffer.writeln('  출처: ${evidence.source}');
      buffer.writeln();
    }

    // Step 4
    buffer.writeln('[Step 4: 최종 솔루션]');
    buffer.writeln();
    buffer.writeln('주요 원인: ${step4_solution.primaryCause}');
    buffer.writeln('논리적 근거: ${step4_solution.reasoning}');
    buffer.writeln();
    buffer.writeln('행동 지침:');
    for (var i = 0; i < step4_solution.actionItems.length; i++) {
      buffer.writeln('${i + 1}. ${step4_solution.actionItems[i]}');
    }

    return buffer.toString();
  }

  String _likelihoodToKorean(HypothesisLikelihood likelihood) {
    switch (likelihood) {
      case HypothesisLikelihood.low:
        return '가능성 낮음';
      case HypothesisLikelihood.medium:
        return '가능성 중간';
      case HypothesisLikelihood.high:
        return '가능성 높음';
    }
  }
}

/// 데이터 리뷰
class DataReview {
  final List<String> observations;
  final List<String> concerns;
  final String summary;

  DataReview({
    required this.observations,
    required this.concerns,
    required this.summary,
  });
}

/// 가설
class Hypothesis {
  final String cause;
  final HypothesisLikelihood likelihood;
  final String reasoning;
  final List<String> supportingData;

  Hypothesis({
    required this.cause,
    required this.likelihood,
    required this.reasoning,
    required this.supportingData,
  });
}

/// 가설 가능성
enum HypothesisLikelihood {
  low,
  medium,
  high,
}

/// 의학적 근거
class MedicalEvidence {
  final String hypothesis;
  final String evidence;
  final String source;

  MedicalEvidence({
    required this.hypothesis,
    required this.evidence,
    required this.source,
  });
}

/// 솔루션
class Solution {
  final String primaryCause;
  final String empathyMessage;
  final String reasoning;
  final List<String> actionItems;
  final List<Hypothesis> allHypotheses;
  final List<MedicalEvidence> supportingEvidence;

  Solution({
    required this.primaryCause,
    required this.empathyMessage,
    required this.reasoning,
    required this.actionItems,
    required this.allHypotheses,
    required this.supportingEvidence,
  });
}
