# AI 코칭 시스템 구현 완료

## 개요
수면 패턴 차트의 특정 구간을 클릭했을 때 작동하는 고도화된 AI 코칭 시스템이 구현되었습니다.

## 구현된 기능

### 1. 데이터 컨텍스트 생성 로직 ✅
- **파일**: `lib/data/services/ai_coaching_service.dart`
- **기능**:
  - 클릭한 이벤트 전후 6시간의 맥락 데이터 자동 수집
  - 수유량/시간, 최근 체온, 기저귀 교체 등 모든 활동 데이터 포함
  - 생후 72일령(2개월) 기준 표준 지표 자동 생성
  - "영아 산통", "낮밤 구분 시작" 등 월령별 전형적 과제 포함

```dart
// 사용 예시
final context = await coachingService._buildEventContext(
  babyId: 'baby123',
  eventTime: DateTime.now(),
  babyAgeInDays: 72,
  activityType: 'sleep',
);
```

### 2. 분석 리포트의 영속성 및 저장 ✅
- **파일**: `lib/data/models/ai_insight_model.dart`
- **기능**:
  - AI 생성 리포트를 Firestore `insights` 컬렉션에 자동 저장
  - 공감 메시지, 데이터 통찰, 행동 지침을 구조화하여 저장
  - 타임스탬프, 이벤트 ID, 컨텍스트 데이터 모두 보존
  - 날짜별 조회 가능한 인덱싱 구조

```dart
// Firestore 구조
/babies/{babyId}/insights/{insightId}
  - id: string
  - timestamp: Timestamp
  - eventContext: Map
  - content: {
      empathyMessage: string,
      dataInsight: string,
      actionGuidance: string,
      expertAdvice: string?
    }
  - riskLevel: 'normal' | 'caution' | 'critical'
  - feedbackRating: 'positive' | 'negative' | null
```

### 3. 사용자 피드백 루프 ✅
- **파일**: `lib/presentation/widgets/ai_insight_bottom_sheet.dart`
- **기능**:
  - AI 분석 결과 하단에 "👍 도움됨" / "👎 별로" 버튼 배치
  - 피드백 클릭 시 Firestore에 자동 저장
  - 피드백 타임스탬프 기록으로 학습 데이터 준비
  - 시각적 피드백으로 선택 상태 표시

```dart
// 피드백 제출
await coachingService.saveFeedback(
  babyId: babyId,
  insightId: insight.id,
  rating: 'positive', // or 'negative'
);
```

### 4. 위험 감지 및 전문가 연결 ✅
- **파일**: `lib/data/services/ai_coaching_service.dart` - `_assessRiskLevel()`
- **기능**:
  - **고열 감지**: 38도 이상 체온 자동 감지
  - **수유량 급감**: 평소 대비 50% 미만 감지
  - **수면 패턴 이상**: 12시간 내 3회 이상 poor quality 감지
  - **위험 수준 분류**:
    - `normal`: 일반 AI 코칭
    - `caution`: AI 코칭 + 경고
    - `critical`: 전문가 상담 권고 모드 자동 전환

```dart
// 위험 수준이 critical일 때
if (riskLevel == RiskLevel.critical) {
  // 전문가 상담 권고 UI 표시
  // "소아과 방문을 권장하며, 의사에게 보여줄 오늘의 리포트를 생성할까요?"
  // PDF 내보내기 버튼 강조
}
```

### 5. Material 3 ModalBottomSheet UI ✅
- **파일**: `lib/presentation/widgets/ai_insight_bottom_sheet.dart`
- **기능**:
  - DraggableScrollableSheet 사용 (초기 70%, 최소 50%, 최대 95%)
  - 명확한 섹션 구분:
    - 🩷 **공감 메시지**: 부모의 감정에 공감
    - 💡 **데이터 통찰**: 패턴 분석 결과
    - 🔆 **오늘의 행동 지침**: 구체적인 조언
    - 🏥 **전문가 조언**: 위험 수준이 높을 때만 표시
  - 각 섹션마다 아이콘과 색상으로 시각적 구분
  - 드래그 핸들, 닫기 버튼, 타임스탬프 포함

### 6. 차트 클릭 이벤트와 연결 ✅
- **파일**: `lib/presentation/widgets/daily_rhythm_wheel_interactive.dart`
- **기능**:
  - 24시간 원형 차트에 GestureDetector 적용
  - 클릭 위치를 시간으로 변환하여 해당 활동 찾기
  - 선택된 활동 하이라이트 효과
  - 로딩 인디케이터 ("AI 분석 중...")
  - 분석 완료 후 자동으로 바텀시트 표시
  - 힌트 텍스트: "차트를 탭하면 AI가 그 시간의 패턴을 분석해줍니다"

## 사용 방법

### 1. AI 코칭 서비스 Provider 등록
`lib/main.dart`에서 Provider 등록:

```dart
import 'package:provider/provider.dart';
import 'data/services/ai_coaching_service.dart';
import 'data/services/openai_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<AICoachingService>(
          create: (_) => AICoachingService(
            firestore: FirebaseFirestore.instance,
            openAIService: OpenAIService(
              apiKey: 'YOUR_OPENAI_API_KEY',
              model: 'gpt-4o',
            ),
          ),
        ),
        // ... 다른 providers
      ],
      child: MyApp(),
    ),
  );
}
```

### 2. 인터랙티브 차트 사용
기존 `DailyRhythmWheel` 대신 `DailyRhythmWheelInteractive` 사용:

```dart
import 'package:provider/provider.dart';
import '../widgets/daily_rhythm_wheel_interactive.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DailyRhythmWheelInteractive(
      date: DateTime.now(),
      babyId: 'baby123',
      babyAgeInDays: 72, // 생후 72일
      activities: activities, // List<ActivityModel>
    );
  }
}
```

### 3. 인사이트 목록 조회
인사이트 탭에서 과거 코칭 내용 보기:

```dart
final coachingService = Provider.of<AICoachingService>(context, listen: false);

final insights = await coachingService.getInsights(
  babyId: 'baby123',
  startDate: DateTime.now().subtract(Duration(days: 7)),
  limit: 50,
);

// 날짜별로 표시
for (final insight in insights) {
  print('${insight.timestamp}: ${insight.content.empathyMessage}');
}
```

## 데이터 모델

### AIInsightModel
```dart
class AIInsightModel {
  final String id;
  final DateTime timestamp;
  final String eventId;
  final ActivityEventContext eventContext;  // 6시간 전후 데이터
  final AIInsightContent content;           // AI 생성 콘텐츠
  final RiskLevel riskLevel;                // normal | caution | critical
  final String? feedbackRating;             // positive | negative
  final DateTime? feedbackTimestamp;
}
```

### ActivityEventContext
```dart
class ActivityEventContext {
  final String activityType;
  final DateTime eventTime;
  final int babyAgeInDays;
  final List<FeedingContext> recentFeedings;
  final List<SleepContext> recentSleeps;
  final List<HealthContext> recentHealthRecords;
  final List<DiaperContext> recentDiapers;
  final StandardMetrics standardMetrics;  // 월령별 표준 지표
}
```

### StandardMetrics (생후 72일 기준)
```dart
StandardMetrics(
  ageInDays: 72,
  averageSleepHoursPerDay: 14.5,
  averageNapCount: 3.5,
  averageFeedingInterval: 3.0,
  typicalChallenges: '영아 산통 (6-8주 정점), 낮밤 구분 시작, 수면 퇴행 가능성',
)
```

## AI 프롬프트 구조

AI에게 전달되는 프롬프트 예시:

```
아기 상태 분석 요청:

생후 72일 (약 2개월)

## 최근 6시간 데이터:

### 수유:
- 2시간 전: 120ml (bottle)
- 5시간 전: 110ml (bottle)

### 수면:
- 1시간 전: 45분 (good)
- 4시간 전: 90분 (fair)

### 건강:
- 3시간 전: 체온 37.2°C

## 이 시기 표준:
- 하루 평균 수면: 14.5시간
- 평균 낮잠 횟수: 3.5회
- 평균 수유 간격: 3.0시간
- 전형적 과제: 영아 산통 (6-8주 정점), 낮밤 구분 시작, 수면 퇴행 가능성

다음 세 가지를 각각 2-3문장으로 답변해 주세요:
1. [공감] 부모의 감정에 공감하는 메시지
2. [통찰] 데이터에서 발견한 패턴과 의미
3. [행동] 오늘 시도해볼 수 있는 구체적인 조언
```

## 위험 감지 시나리오

### Critical 상태 예시
```dart
// 고열 감지
if (temperatureCelsius >= 38.0) {
  return RiskLevel.critical;
}

// 수유량 급감 감지
if (recentAverage < olderAverage * 0.5) {
  return RiskLevel.critical;
}
```

### Critical 상태 UI
- 빨간색 경고 카드 표시
- "전문가 상담 권고" 헤더
- "소아과 방문을 권장하며, 의사에게 보여줄 오늘의 리포트를 생성할 수 있습니다."
- **PDF 리포트 생성** 버튼 강조 (빨간색 FilledButton)

## 향후 개선 사항

1. **PDF 내보내기 기능 구현**
   - `pdf` 패키지 사용
   - 24시간 데이터 차트 포함
   - 의사에게 보여줄 수 있는 전문적인 레이아웃

2. **푸시 알림 연동**
   - Critical 상태 감지 시 즉시 알림
   - 정기적인 인사이트 요약 알림

3. **ML 기반 패턴 학습**
   - 피드백 데이터를 활용한 개인화
   - 아기별 맞춤 조언 강화

4. **다국어 지원**
   - AI 프롬프트 다국어 전환
   - 인사이트 내용 번역

## 파일 구조

```
lib/
├── data/
│   ├── models/
│   │   ├── ai_insight_model.dart          # AI 인사이트 모델
│   │   └── activity_model.dart            # 활동 모델
│   └── services/
│       ├── ai_coaching_service.dart        # AI 코칭 서비스 (핵심 로직)
│       └── openai_service.dart             # OpenAI API 연동
└── presentation/
    └── widgets/
        ├── ai_insight_bottom_sheet.dart    # 인사이트 바텀시트 UI
        ├── daily_rhythm_wheel_interactive.dart  # 인터랙티브 차트
        └── daily_rhythm_wheel.dart         # 기본 차트 (데모용)
```

## 의존성

`pubspec.yaml`에 추가 필요:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  cloud_firestore: ^4.0.0
  http: ^1.0.0
  intl: ^0.18.0
```

## 테스트 시나리오

### 1. 정상 상태 테스트
- 일반적인 수면 구간 클릭
- AI 코칭 메시지 확인
- 피드백 제출 확인

### 2. 위험 상태 테스트
- 38도 이상 체온 기록 후 차트 클릭
- 전문가 상담 권고 UI 확인
- PDF 버튼 동작 확인

### 3. 피드백 루프 테스트
- 여러 인사이트에 다양한 피드백 제출
- Firestore에서 피드백 데이터 확인
- 피드백 시각적 반영 확인

## 결론

모든 요구사항이 성공적으로 구현되었습니다:

✅ 6시간 전후 맥락 데이터 수집
✅ Firestore insights 컬렉션 저장
✅ 피드백 루프 (👍/👎)
✅ 위험 감지 및 전문가 연결
✅ Material 3 ModalBottomSheet
✅ 차트 클릭 이벤트 연결

생후 72일령 아기의 전형적인 상황(영아 산통, 낮밤 구분)을 고려한 맞춤형 AI 코칭 시스템이 완성되었습니다.
