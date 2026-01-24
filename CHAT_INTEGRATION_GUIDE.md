# Lulu AI Chat Integration Guide

## 📋 Overview

Lulu는 AAP(American Academy of Pediatrics) Safe Sleep Guidelines를 따르는 따뜻하고 전문적인 AI 수면 상담 어시스턴트입니다.

## 🎭 Persona 특징

- **이름**: Lulu 🌙
- **역할**: AI Sleep Consultant
- **성격**: 따뜻하고 공감 능력이 뛰어나며, 전문적이고 신중함
- **원칙**: AAP Safe Sleep Guidelines 엄격 준수
- **대화 스타일**: Empathy First → Data-Driven Solutions

## 🚀 Quick Start

### 1. Dependencies 추가 (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  http: ^1.1.0
  intl: ^0.18.1

flutter:
  uses-material-design: true
```

### 2. OpenAI API Key 설정

#### 방법 A: 환경 변수 사용 (권장)

```bash
# Run with environment variable
flutter run --dart-define=OPENAI_API_KEY=your_api_key_here
```

#### 방법 B: .env 파일 사용

```
# .env
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxx
```

### 3. 기본 통합

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lulu/data/services/openai_service.dart';
import 'package:lulu/presentation/providers/chat_provider.dart';
import 'package:lulu/presentation/screens/chat/chat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lulu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: ChangeNotifierProvider(
        create: (_) => ChatProvider(
          openAIService: OpenAIService(
            apiKey: const String.fromEnvironment('OPENAI_API_KEY'),
            model: 'gpt-4o-mini', // Use gpt-4o for better quality
          ),
        ),
        child: const ChatScreen(),
      ),
    );
  }
}
```

## 📊 아기 컨텍스트 전달

Lulu는 아기의 수면 데이터를 기반으로 개인화된 조언을 제공합니다.

```dart
// ChatProvider에 아기 정보 설정
final chatProvider = context.read<ChatProvider>();

chatProvider.setBabyContext(
  BabyContext(
    name: 'Emma',
    ageInMonths: 6,
    ageInWeeks: 26,
    isPremature: false,
    correctedAgeInMonths: null,

    // 최근 수면 패턴 (Activity 데이터에서 추출)
    recentSleepPattern: 'Waking 3-4 times per night, naps 3 times/day',

    // Sweet Spot 정보
    currentSweetSpot: '10:30 AM - 11:15 AM',

    // 통계 데이터
    averageNightWakings: 3,
    averageNapDuration: 45, // minutes
  ),
);
```

## 💬 대화 예시

### 예시 1: 밤잠 문제

**부모**: "My baby keeps waking up crying at night"

**Lulu**:
```
I can hear how exhausted you must be. Frequent night wakings are incredibly
draining, and the fact that you're here seeking support shows how dedicated
you are to Emma's wellbeing.

Night wakings are actually very normal, especially at 6 months. Babies have
shorter sleep cycles than adults (45-60 minutes vs. 90 minutes), so they
naturally wake more often.

Let me ask a few questions to help better:
- Is Emma sleeping on her back on a firm, flat surface with nothing else in the crib?
- What does the room environment look like (temperature, darkness, noise)?
- Have there been any recent changes (growth spurt, teething, illness)?

In the meantime, here are some evidence-based strategies:

1. **Safety Check**: Ensure Emma is on her back, on a firm mattress, with no
   loose blankets or toys. This is crucial for safe sleep.

2. **Optimize Wake Windows**: Based on Emma's age (6 months), her optimal wake
   window is 2.25-3 hours. I see her current Sweet Spot is 10:30-11:15 AM -
   this looks great!

3. **Consistent Bedtime Routine**: A predictable 20-30 minute routine signals
   sleep time.

4. **Room Environment**: Keep the room cool (68-72°F), very dark, and consider
   white noise.

Remember, sleep is developmental—it gets better with time. You're doing
everything right by tracking patterns and seeking information.
```

## 🎨 UI 커스터마이징

### 색상 변경

```dart
// lib/presentation/widgets/chat/chat_bubble.dart
Container(
  decoration: BoxDecoration(
    color: isUser
        ? Colors.blue,        // 사용자 메시지 색상
        : Colors.grey[200],   // Lulu 메시지 색상
    // ...
  ),
)
```

### 아바타 변경

```dart
// lib/presentation/widgets/chat/chat_bubble.dart
child: Text(
  isUser ? '👤' : '🌙',  // 이모지 변경 가능
  style: const TextStyle(fontSize: 16),
),
```

## 🔧 고급 기능

### 1. 스트리밍 응답 (실시간 타이핑)

```dart
// 이미 ChatProvider에 구현되어 있음
await context.read<ChatProvider>().sendMessageStream(message);
```

### 2. 빠른 질문 템플릿

```dart
// lib/presentation/providers/chat_provider.dart
class QuickQuestions {
  static const List<QuickQuestion> templates = [
    QuickQuestion(
      icon: '🌙',
      text: 'Baby keeps waking at night',
      prompt: 'My baby keeps waking up crying at night. What can I do?',
    ),
    // 추가 템플릿...
  ];
}
```

### 3. 대화 히스토리 저장

```dart
// Firestore에 저장
Future<void> saveChatHistory(List<ChatMessage> messages) async {
  final collection = FirebaseFirestore.instance.collection('chat_history');

  for (var message in messages) {
    await collection.add({
      'role': message.role,
      'content': message.content,
      'timestamp': message.timestamp.toIso8601String(),
    });
  }
}
```

## 💰 비용 최적화

### 모델 선택

```dart
// 비용 효율적: gpt-4o-mini
OpenAIService(apiKey: apiKey, model: 'gpt-4o-mini')

// 고품질: gpt-4o
OpenAIService(apiKey: apiKey, model: 'gpt-4o')
```

### 짧은 시스템 프롬프트 사용

```dart
final response = await service.sendMessage(
  messages: messages,
  useShortPrompt: true,  // 토큰 절약
);
```

### 예상 비용 (2026년 1월 기준)

**GPT-4o-mini**:
- Input: $0.15 / 1M tokens
- Output: $0.60 / 1M tokens
- 평균 대화 1회: ~$0.002 (2,000 tokens)

**GPT-4o**:
- Input: $2.50 / 1M tokens
- Output: $10.00 / 1M tokens
- 평균 대화 1회: ~$0.025 (2,000 tokens)

## 🛡️ 안전 가이드라인

### Lulu가 절대 하지 않는 것:

1. ❌ 의학적 진단
2. ❌ AAP Safe Sleep Guidelines 위반 권장
3. ❌ 부모 비난 또는 판단
4. ❌ 불확실한 정보 제공

### Red Flags (즉시 소아과 의사 추천):

- 호흡 곤란 또는 헐떡임
- 청색증 (피부가 파랗거나 회색)
- 극도의 무기력
- 생후 3개월 미만 고열
- 발달 지연 우려

## 📝 System Prompt 수정

```dart
// lib/core/constants/lulu_persona.dart
static const String systemPrompt = '''
You are Lulu, a warm, empathetic, and professional AI sleep consultant...

// 여기서 Lulu의 페르소나와 규칙 수정 가능
''';
```

## 🧪 테스트

```dart
// test/services/openai_service_test.dart
void main() {
  test('should send message successfully', () async {
    final service = OpenAIService(apiKey: 'test-key');

    final response = await service.sendMessage(
      messages: [ChatMessage.user('Hello')],
    );

    expect(response.content, isNotEmpty);
  });
}
```

## 📞 지원

문제가 발생하면:
1. API 키가 올바른지 확인
2. 인터넷 연결 확인
3. OpenAI API 상태 확인: https://status.openai.com

## 🎯 다음 단계

- [ ] Firebase에 채팅 히스토리 저장
- [ ] 음성 입력 기능 추가
- [ ] 다국어 지원 (한국어)
- [ ] 수면 데이터 자동 분석 및 인사이트 제공
- [ ] 푸시 알림 (Sweet Spot 알림)
