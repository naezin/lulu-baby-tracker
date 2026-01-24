/// 전문가 가이드라인 및 지식 베이스
class ExpertGuidelines {
  /// AAP 안전한 수면 환경 지침
  static const String aapSafeSleepGuidelines = '''
**미국 소아과학회(AAP) 안전한 수면 환경 지침:**
1. 아기는 항상 등을 대고 재워야 합니다 (Back to Sleep)
2. 단단한 매트리스에서 재웁니다
3. 침대에 베개, 담요, 인형 등을 두지 않습니다
4. 생후 6개월까지는 부모와 같은 방에서 재웁니다 (침대는 분리)
5. 과열을 피하고 적정 실온(20-22°C)을 유지합니다
6. 모유수유를 권장합니다 (SIDS 위험 감소)
''';

  /// Eat-Play-Sleep 사이클 원칙
  static const String eatPlaySleepCycle = '''
**먹-놀-잠(Eat-Play-Sleep) 사이클:**
- 수유 직후 바로 재우지 않고, 짧은 놀이/활동 시간을 가진 후 재웁니다
- 이는 "먹으면 자야 한다"는 연관성을 끊어주어 수면 독립성을 높입니다
- 2개월 아기: 먹기(20-30분) → 놀기(30-45분) → 자기(1.5-2시간)
''';

  /// 생후 72일(2개월) 발달 특징
  static const String twoMonthDevelopment = '''
**생후 2개월 아기의 발달 특징:**
- 목 가누기 시작 (엎드려 있을 때 머리를 잠깐 들 수 있음)
- 사회적 미소 (눈 마주침에 반응하여 웃음)
- 옹알이 시작 ("아~", "우~" 소리)
- 낮밤 구분 시작 (서캐디안 리듬 형성 중)
- 하루 총 수면: 14-17시간
- 낮잠 횟수: 3-4회
- 밤잠 연속 수면: 4-6시간 (최대)
- 영아 산통 정점기 (6-8주에 최고조, 3개월경 감소)
''';

  /// 월령별 권장 수유량 (5.8kg 기준)
  static String getRecommendedFeedingAmount(double weightKg) {
    // 하루 총량: 체중(kg) × 150ml
    final dailyTotal = (weightKg * 150).round();
    // 평균 수유 간격 3시간 → 하루 8회
    final perFeeding = (dailyTotal / 8).round();

    return '''
**권장 수유량 (체중 ${weightKg}kg 기준):**
- 하루 총량: 약 ${dailyTotal}ml
- 1회 수유량: 약 ${perFeeding}ml
- 수유 간격: 2.5-3.5시간
- 밤 수유: 1-2회
''';
  }

  /// 수면 압력(Sleep Pressure) 개념
  static const String sleepPressureConcept = '''
**수면 압력(Sleep Pressure) 이해:**
- 깨어있는 시간이 길어질수록 "수면 압력"이 쌓여 잠들기 쉬워집니다
- 2개월 아기의 적정 각성 시간: 1-1.5시간
- 각성 시간이 너무 짧으면: 잠들기 어려움 (수면 압력 부족)
- 각성 시간이 너무 길면: 과자극으로 더 힘들게 잠듦
- "골든 타임": 졸리지만 너무 피곤하지 않은 순간에 재우기
''';

  /// 영아 산통 특징 및 대처
  static const String infantColicGuidance = '''
**영아 산통 (Infant Colic):**
- 정의: 건강한 아기가 하루 3시간 이상, 주 3일 이상, 3주 이상 우는 증상
- 정점: 생후 6-8주 (현재 72일이면 감소 추세 시작)
- 특징: 주로 저녁 시간대, 배에 가스, 다리를 배 쪽으로 구부림
- 대처:
  1. "5S 기법" (Swaddling, Side position, Shushing, Swinging, Sucking)
  2. 배 마사지 (시계방향)
  3. 백색소음
  4. 부모의 스트레스 관리 (교대로 돌보기)
''';

  /// 밤잠 깨어남 원인 분석 체크리스트
  static const String nightWakingChecklist = '''
**밤잠 깨어남 원인 체크리스트:**
1. 배고픔 (마지막 수유가 충분했나?)
2. 기저귀 (젖거나 불편함)
3. 체온 조절 (너무 덥거나 춥지 않은가?)
4. 수면 연관 (안아주기, 젖병 물리기 등의 의존성)
5. 발달 도약 (새로운 기술 습득 중)
6. 낮잠 과다/부족 (낮 수면이 밤잠에 영향)
7. 통증/불편감 (배앓이, 이 나기 등)
''';

  /// 수면 훈련 시작 가능 시기
  static const String sleepTrainingReadiness = '''
**수면 훈련 시작 시기:**
- 권장: 생후 4-6개월 이후
- 현재(2개월)는 수면 훈련보다 "수면 루틴" 확립이 우선
- 할 수 있는 것:
  1. 일관된 취침 시간 (±30분 이내)
  2. 취침 루틴 만들기 (목욕 → 수유 → 책 읽기 → 재우기)
  3. 낮과 밤 구분 (낮: 밝고 시끄럽게, 밤: 어둡고 조용하게)
  4. 졸린 상태에서 침대에 눕히기 (완전히 재우지 말고)
''';

  /// 안심시키기(Reassurance) 전략
  static const String reassuranceStrategy = '''
**안심시키기 전략 (수면 독립성 향상):**
- 목표: 부모 없이도 스스로 잠들 수 있는 능력 기르기
- 단계별 접근:
  1주차: 안아주다가 졸린 상태에서 침대에 눕히기
  2주차: 침대에 눕힌 후 손만 얹어주기
  3주차: 침대 옆에 앉아서 쓰다듬기
  4주차: 침대에서 조금 떨어져 지켜보기
- 중요: 급하게 진행하지 말고 아기의 반응을 보며 조절
''';

  /// 의학적 근거 데이터베이스
  static Map<String, String> medicalEvidenceDatabase = {
    '밤잠_빈번한_깨어남': '''
[의학적 근거]
- 2개월 아기는 수면 주기가 짧아(45-60분) 주기 사이에 깰 수 있음
- 렘수면 비율이 높아 얕은 잠이 많음
- 배고픔 신호일 가능성: 마지막 수유 후 3시간 이상 경과 시
- Harvey Karp 박사: "4번째 달"에 접어들면 점차 개선됨
''',

    '낮잠_짧음': '''
[의학적 근거]
- 2개월 아기의 낮잠: 30분~2시간 (평균 45분~1시간)
- 45분 낮잠은 정상 범위 (1 수면 주기)
- 짧은 낮잠 원인: 과자극, 각성시간 부족, 환경(밝음/소음)
- Marc Weissbluth 박사: "낮잠이 밤잠을 만든다" (낮잠이 부족하면 밤잠 악화)
''',

    '영아_산통': '''
[의학적 근거]
- 전체 영아의 10-25%에서 발생
- 원인: 미성숙한 소화기계, 가스, 과자극
- 6주 정점 후 12주경 90% 자연 소멸
- 대처법: 5S 기법 (Dr. Harvey Karp)
''',

    '수유량_부족': '''
[의학적 근거]
- 탈수 징후: 기저귀 하루 6회 미만, 입술 마름, 무기력
- 체중 증가 둔화: 주당 150g 미만
- 즉시 소아과 상담 필요
''',
  };

  /// 연령별 수면 통계
  static Map<int, SleepStatistics> sleepStatisticsByAge = {
    60: SleepStatistics(
      ageInDays: 60,
      totalSleepHours: 15.0,
      nightSleepHours: 9.0,
      napCount: 4,
      longestNightStretch: 5.0,
      wakeWindowMinutes: 60,
    ),
    72: SleepStatistics(
      ageInDays: 72,
      totalSleepHours: 14.5,
      nightSleepHours: 9.5,
      napCount: 3.5,
      longestNightStretch: 5.5,
      wakeWindowMinutes: 75,
    ),
    90: SleepStatistics(
      ageInDays: 90,
      totalSleepHours: 14.0,
      nightSleepHours: 10.0,
      napCount: 3,
      longestNightStretch: 6.0,
      wakeWindowMinutes: 90,
    ),
  };

  /// 체온 기준
  static const Map<String, double> temperatureThresholds = {
    'normal_low': 36.5,
    'normal_high': 37.5,
    'low_fever': 37.6,
    'fever': 38.0,
    'high_fever': 38.5,
    'emergency': 39.0,
  };

  /// 수유량 감소 기준
  static const Map<String, double> feedingReductionThresholds = {
    'mild_concern': 0.7,      // 30% 감소
    'moderate_concern': 0.6,  // 40% 감소
    'severe_concern': 0.5,    // 50% 감소
  };
}

/// 수면 통계 모델
class SleepStatistics {
  final int ageInDays;
  final double totalSleepHours;
  final double nightSleepHours;
  final double napCount;
  final double longestNightStretch;
  final int wakeWindowMinutes;

  SleepStatistics({
    required this.ageInDays,
    required this.totalSleepHours,
    required this.nightSleepHours,
    required this.napCount,
    required this.longestNightStretch,
    required this.wakeWindowMinutes,
  });
}

/// 전문가 페르소나
class ExpertPersona {
  static const String systemPrompt = '''
당신은 20년 경력의 수면 컨설턴트이자 소아과 전문의입니다.

**당신의 전문성:**
- 소아 수면 의학 전문의 자격
- 수면 컨설턴트 국제 인증 (IPHI)
- 10,000+ 가정 상담 경험
- AAP, WHO 가이드라인 전문가

**당신의 접근 방식:**
1. 데이터 기반 분석: 추측이 아닌 실제 데이터로 판단
2. 의학적 근거 제시: 모든 조언에 과학적 근거 포함
3. 개별화된 솔루션: 아기마다 다르다는 것을 인정
4. 부모 공감: 힘든 상황을 이해하고 격려
5. 단계적 접근: 한 번에 하나씩 변화 유도

**당신이 따르는 원칙:**
- 미국 소아과학회(AAP) 안전한 수면 환경 지침 최우선
- Eat-Play-Sleep 사이클 권장
- 발달 단계에 맞는 기대치 설정
- 위험 신호 즉시 식별 및 전문의 연결

**당신의 톤:**
- 전문적이지만 따뜻함
- 단정적이지 않고 제안하는 방식
- 부모를 비난하지 않고 지지
- 복잡한 의학 용어는 쉽게 설명
''';

  static String getContextualizedPrompt({
    required int babyAgeInDays,
    required double babyWeightKg,
  }) {
    return '''
$systemPrompt

**현재 상담 중인 아기 정보:**
- 생후: ${babyAgeInDays}일 (약 ${(babyAgeInDays / 30).floor()}개월 ${babyAgeInDays % 30}일)
- 체중: ${babyWeightKg}kg
- 발달 단계: ${_getDevelopmentStage(babyAgeInDays)}

${ExpertGuidelines.twoMonthDevelopment}

${ExpertGuidelines.getRecommendedFeedingAmount(babyWeightKg)}

**이 아기에게 적합한 조언:**
- 수면 훈련은 아직 이름 (4개월 이후 권장)
- 수면 루틴 확립이 최우선
- 영아 산통이 감소하는 시기
- 낮밤 구분을 돕는 환경 조성 중요
''';
  }

  static String _getDevelopmentStage(int days) {
    if (days < 30) return '신생아기 (낮밤 구분 없음)';
    if (days < 90) return '2-3개월 (낮밤 구분 시작, 사회적 미소)';
    if (days < 180) return '4-6개월 (목 가누기 완성, 뒤집기 시작)';
    return '6개월 이상';
  }
}
