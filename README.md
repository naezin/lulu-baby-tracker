# Lulu - AI Sleep Education App

미국 시장을 타겟으로 한 AI 기반 수면 교육 앱입니다.

## 📁 프로젝트 구조 보기

```bash
# 전체 구조 확인
tree lulu/

# 또는 간단하게
ls -R lulu/
```

### 현재 구현된 파일들

```
lulu/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── lulu_persona.dart           ← Lulu AI 페르소나 설정
│   │   └── utils/
│   │       ├── sweet_spot_calculator.dart  ← Sweet Spot 예측 로직 ⭐
│   │       └── sweet_spot_example.dart     ← 사용 예제
│   │
│   ├── data/
│   │   ├── models/
│   │   │   └── baby_model.dart             ← 아기 데이터 모델
│   │   └── services/
│   │       └── openai_service.dart         ← OpenAI API 서비스 ⭐
│   │
│   └── presentation/
│       ├── providers/
│       │   ├── chat_provider.dart          ← 채팅 상태 관리
│       │   └── sweet_spot_provider.dart    ← Sweet Spot 상태 관리
│       │
│       ├── screens/
│       │   └── chat/
│       │       ├── chat_screen.dart        ← 채팅 화면 ⭐
│       │       └── chat_example.dart       ← 통합 예제
│       │
│       └── widgets/
│           ├── chat/
│           │   ├── chat_bubble.dart        ← 말풍선 UI
│           │   ├── chat_input.dart         ← 입력 필드
│           │   ├── typing_indicator.dart   ← 타이핑 애니메이션
│           │   └── quick_questions_bar.dart← 빠른 질문
│           │
│           └── sweet_spot_card.dart        ← Sweet Spot 카드 UI
│
├── test/
│   └── unit/
│       └── utils/
│           └── sweet_spot_calculator_test.dart  ← 단위 테스트
│
├── CHAT_INTEGRATION_GUIDE.md              ← 채팅 통합 가이드
└── README.md                               ← 이 파일
```

## 🔍 파일 보는 방법

### 1. Visual Studio Code로 보기 (권장)

```bash
# 프로젝트 폴더 열기
cd /Users/naezin/Desktop/클로드앱플젝
code lulu/
```

### 2. 터미널에서 파일 내용 보기

```bash
# Sweet Spot 계산기 보기
cat lulu/lib/core/utils/sweet_spot_calculator.dart

# Lulu 페르소나 설정 보기
cat lulu/lib/core/constants/lulu_persona.dart

# 채팅 화면 보기
cat lulu/lib/presentation/screens/chat/chat_screen.dart
```

### 3. 특정 파일만 빠르게 확인

```bash
# Sweet Spot 예제 실행해보기
cat lulu/lib/core/utils/sweet_spot_example.dart

# 채팅 통합 가이드 읽기
cat lulu/CHAT_INTEGRATION_GUIDE.md
```

## 🚀 핵심 파일 설명

### ⭐ 1. Sweet Spot Calculator
**파일**: `lib/core/utils/sweet_spot_calculator.dart`

아기의 최적 낮잠 시간을 예측하는 핵심 로직입니다.

```dart
// 사용 예시
final sweetSpot = SweetSpotCalculator.calculate(
  ageInMonths: 6,
  lastWakeUpTime: DateTime.now().subtract(Duration(hours: 2)),
  napNumber: 2,
);

print(sweetSpot.getFormattedTimeRange()); // "2:30 PM - 3:15 PM"
```

**보는 방법**:
```bash
cat lulu/lib/core/utils/sweet_spot_calculator.dart
# 또는
open -a "Visual Studio Code" lulu/lib/core/utils/sweet_spot_calculator.dart
```

### ⭐ 2. OpenAI Service
**파일**: `lib/data/services/openai_service.dart`

Lulu AI와 대화하기 위한 OpenAI API 연동입니다.

```dart
// 사용 예시
final response = await openAIService.sendMessage(
  messages: [ChatMessage.user("Baby keeps waking at night")],
);
```

**보는 방법**:
```bash
cat lulu/lib/data/services/openai_service.dart
```

### ⭐ 3. Chat Screen
**파일**: `lib/presentation/screens/chat/chat_screen.dart`

부모와 Lulu가 대화하는 채팅 UI입니다.

**보는 방법**:
```bash
cat lulu/lib/presentation/screens/chat/chat_screen.dart
```

## 🧪 예제 코드 실행해보기

### Sweet Spot 예제 실행

```bash
# 예제 코드 보기
cat lulu/lib/core/utils/sweet_spot_example.dart

# Dart로 직접 실행 (Flutter 없이)
cd lulu
dart run lib/core/utils/sweet_spot_example.dart
```

### 테스트 실행

```bash
# 단위 테스트 실행
cd lulu
flutter test test/unit/utils/sweet_spot_calculator_test.dart
```

## 📊 데이터베이스 스키마 확인

데이터베이스 설계는 첫 번째 답변에 JSON 형식으로 제공되었습니다:

- **Users Collection**: 사용자 정보
- **Babies Collection**: 아기 정보
- **Activities Collection**: 수면/수유/배변 기록
- **Growth Records**: 성장 기록
- **AI Insights**: AI 분석 결과

## 🎯 다음 단계

### 1. 프로젝트 초기화 (아직 안했다면)

```bash
cd lulu
flutter pub get
```

### 2. 주요 기능 확인

```bash
# 1. Sweet Spot 로직 확인
cat lib/core/utils/sweet_spot_calculator.dart | less

# 2. Lulu 페르소나 확인
cat lib/core/constants/lulu_persona.dart | less

# 3. 채팅 UI 확인
cat lib/presentation/screens/chat/chat_screen.dart | less
```

### 3. 실제 앱 실행 준비

현재는 **코드만 작성된 상태**입니다. 실제 앱으로 실행하려면:

1. `pubspec.yaml` 생성
2. `main.dart` 생성
3. Firebase 설정
4. OpenAI API 키 설정

## 💡 추천 보는 순서

```bash
# 1단계: 개요 파악
cat CHAT_INTEGRATION_GUIDE.md

# 2단계: 핵심 로직 이해
cat lib/core/utils/sweet_spot_calculator.dart

# 3단계: AI 페르소나 확인
cat lib/core/constants/lulu_persona.dart

# 4단계: UI 구조 파악
cat lib/presentation/screens/chat/chat_screen.dart

# 5단계: 예제로 이해
cat lib/core/utils/sweet_spot_example.dart
```

## 📝 요약

현재 상태:
- ✅ Sweet Spot 예측 로직 완성
- ✅ OpenAI 채팅 서비스 완성
- ✅ 채팅 UI 컴포넌트 완성
- ✅ Lulu AI 페르소나 설정 완성
- ✅ 데이터 모델 설계 완성
- ❌ 실제 Flutter 앱 미구성 (main.dart, pubspec.yaml 필요)
- ❌ Firebase 연동 미완성

## 🔧 파일 편집기 추천

- **VS Code**: `code lulu/`
- **Android Studio**: File → Open → lulu 폴더 선택
- **Vim/Nano**: 터미널에서 직접 편집

문의사항이 있으시면 언제든지 물어보세요!
