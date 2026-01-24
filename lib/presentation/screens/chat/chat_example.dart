/// OpenAI Chat 사용 예제
///
/// 실제 앱에서 ChatScreen을 사용하는 방법

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/openai_service.dart';
import '../../providers/chat_provider.dart';
import 'chat_screen.dart';

class ChatExample extends StatelessWidget {
  const ChatExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // OpenAI API Key 설정 (실제로는 환경변수나 secure storage에서 가져오기)
    const apiKey = 'YOUR_OPENAI_API_KEY';

    return ChangeNotifierProvider(
      create: (_) => ChatProvider(
        openAIService: OpenAIService(
          apiKey: apiKey,
          model: 'gpt-4o', // or 'gpt-4o-mini' for lower cost
        ),
      ),
      child: const ChatScreen(),
    );
  }
}

/// 아기 컨텍스트와 함께 사용하는 예제
class ChatWithContextExample extends StatelessWidget {
  const ChatWithContextExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const apiKey = 'YOUR_OPENAI_API_KEY';

    return ChangeNotifierProvider(
      create: (_) {
        final provider = ChatProvider(
          openAIService: OpenAIService(apiKey: apiKey),
        );

        // 아기 컨텍스트 설정
        provider.setBabyContext(
          BabyContext(
            name: 'Emma',
            ageInMonths: 6,
            ageInWeeks: 26,
            isPremature: false,
            recentSleepPattern: 'Waking 3-4 times per night',
            currentSweetSpot: '10:30 AM - 11:15 AM',
            averageNightWakings: 3,
            averageNapDuration: 45,
          ),
        );

        return provider;
      },
      child: const ChatScreen(),
    );
  }
}

/// Provider 설정 없이 독립적으로 OpenAI 호출하는 예제
void standaloneExample() async {
  const apiKey = 'YOUR_OPENAI_API_KEY';
  final service = OpenAIService(apiKey: apiKey);

  // 단일 메시지 전송
  try {
    final response = await service.sendMessage(
      messages: [
        ChatMessage.user('My baby keeps waking up at night. What can I do?'),
      ],
      babyContext: BabyContext(
        name: 'Emma',
        ageInMonths: 6,
        ageInWeeks: 26,
      ),
    );

    print('Lulu: ${response.content}');
    print('Tokens used: ${response.totalTokens}');
  } catch (e) {
    print('Error: $e');
  }
}

/// 스트리밍 예제
void streamingExample() async {
  const apiKey = 'YOUR_OPENAI_API_KEY';
  final service = OpenAIService(apiKey: apiKey);

  try {
    final stream = service.sendMessageStream(
      messages: [
        ChatMessage.user('Tell me about safe sleep guidelines.'),
      ],
    );

    print('Lulu: ', end: '');
    await for (var chunk in stream) {
      print(chunk, end: '');
    }
    print(''); // New line
  } catch (e) {
    print('Error: $e');
  }
}

/// 대화 히스토리와 함께 사용하는 예제
void conversationExample() async {
  const apiKey = 'YOUR_OPENAI_API_KEY';
  final service = OpenAIService(apiKey: apiKey);

  final conversationHistory = <ChatMessage>[
    ChatMessage.user('My baby is 4 months old and wakes up every 2 hours at night.'),
    ChatMessage.assistant(
      'I can hear how exhausted you must be. Frequent wakings every 2 hours are incredibly draining...',
    ),
    ChatMessage.user('Yes, exactly! What should I try first?'),
  ];

  try {
    final response = await service.sendMessage(
      messages: conversationHistory,
      babyContext: BabyContext(
        name: 'Oliver',
        ageInMonths: 4,
        ageInWeeks: 16,
        averageNightWakings: 6,
      ),
    );

    print('Lulu: ${response.content}');
  } catch (e) {
    print('Error: $e');
  }
}

/// 실제 앱 통합 예제 (main.dart에서 사용)
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lulu - AI Sleep Consultant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ChatProvider(
              openAIService: OpenAIService(
                apiKey: const String.fromEnvironment('OPENAI_API_KEY'),
                model: 'gpt-4o',
              ),
            ),
          ),
        ],
        child: const ChatScreen(),
      ),
    );
  }
}
