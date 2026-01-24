import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/lulu_persona.dart';
import '../../core/utils/environment_validator.dart';

/// OpenAI GPT API Service
class OpenAIService {
  final String? _apiKey;
  final String model;
  static const String baseUrl = 'https://api.openai.com/v1';

  OpenAIService({
    String? apiKey,
    this.model = 'gpt-4o-mini',
  }) : _apiKey = apiKey ?? EnvironmentValidator.openAIApiKey;

  /// API Key 유효성 확인
  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty && _apiKey != 'demo-mode';

  /// 안전한 API Key 접근
  String get apiKey {
    if (!isConfigured) {
      throw OpenAINotConfiguredException(
        'OpenAI API Key가 설정되지 않았습니다. '
        '--dart-define=OPENAI_API_KEY=xxx 옵션으로 실행해주세요.',
      );
    }
    return _apiKey!;
  }

  /// 채팅 메시지 전송
  ///
  /// [messages]: 대화 히스토리
  /// [babyContext]: 아기 정보 컨텍스트 (선택사항)
  /// [useShortPrompt]: 짧은 시스템 프롬프트 사용 (토큰 절약)
  Future<ChatResponse> sendMessage({
    required List<ChatMessage> messages,
    BabyContext? babyContext,
    bool useShortPrompt = false,
  }) async {
    if (!isConfigured) {
      throw OpenAINotConfiguredException(
        'OpenAI API Key가 설정되지 않았습니다. '
        '--dart-define=OPENAI_API_KEY=xxx 옵션으로 실행해주세요.',
      );
    }

    try {
      // 시스템 프롬프트 구성
      final systemPrompt = _buildSystemPrompt(
        babyContext: babyContext,
        useShortPrompt: useShortPrompt,
      );

      // API 요청 메시지 구성
      final apiMessages = [
        {'role': 'system', 'content': systemPrompt},
        ...messages.map((msg) => msg.toJson()),
      ];

      // API 호출
      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': apiMessages,
          'temperature': 0.7,
          'max_tokens': 1000,
          'top_p': 1.0,
          'frequency_penalty': 0.0,
          'presence_penalty': 0.0,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatResponse.fromJson(data);
      } else {
        throw OpenAIException(
          statusCode: response.statusCode,
          message: response.body,
        );
      }
    } catch (e) {
      throw OpenAIException(
        statusCode: -1,
        message: e.toString(),
      );
    }
  }

  /// 스트리밍 응답 (실시간 타이핑 효과)
  Stream<String> sendMessageStream({
    required List<ChatMessage> messages,
    BabyContext? babyContext,
    bool useShortPrompt = false,
  }) async* {
    if (!isConfigured) {
      throw OpenAINotConfiguredException(
        'OpenAI API Key가 설정되지 않았습니다. '
        '--dart-define=OPENAI_API_KEY=xxx 옵션으로 실행해주세요.',
      );
    }

    try {
      final systemPrompt = _buildSystemPrompt(
        babyContext: babyContext,
        useShortPrompt: useShortPrompt,
      );

      final apiMessages = [
        {'role': 'system', 'content': systemPrompt},
        ...messages.map((msg) => msg.toJson()),
      ];

      final request = http.Request(
        'POST',
        Uri.parse('$baseUrl/chat/completions'),
      );

      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      });

      request.body = jsonEncode({
        'model': model,
        'messages': apiMessages,
        'temperature': 0.7,
        'max_tokens': 1000,
        'stream': true,
      });

      final streamedResponse = await request.send();

      await for (var chunk in streamedResponse.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');
        for (var line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data.trim() == '[DONE]') continue;

            try {
              final json = jsonDecode(data);
              final content = json['choices'][0]['delta']['content'];
              if (content != null) {
                yield content as String;
              }
            } catch (_) {
              // Skip invalid JSON
            }
          }
        }
      }
    } catch (e) {
      throw OpenAIException(
        statusCode: -1,
        message: e.toString(),
      );
    }
  }

  /// 시스템 프롬프트 구성
  String _buildSystemPrompt({
    BabyContext? babyContext,
    bool useShortPrompt = false,
  }) {
    String basePrompt = useShortPrompt
        ? LuluPersona.systemPromptShort
        : LuluPersona.systemPrompt;

    if (babyContext != null) {
      basePrompt += '\n\n## Current Baby Context:\n${babyContext.toString()}';
    }

    return basePrompt;
  }
}

/// 채팅 메시지 모델
class ChatMessage {
  final String role; // 'user', 'assistant', 'system'
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.user(String content) {
    return ChatMessage(role: 'user', content: content);
  }

  factory ChatMessage.assistant(String content) {
    return ChatMessage(role: 'assistant', content: content);
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}

/// 채팅 응답 모델
class ChatResponse {
  final String id;
  final String content;
  final String model;
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  ChatResponse({
    required this.id,
    required this.content,
    required this.model,
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      id: json['id'] as String,
      content: json['choices'][0]['message']['content'] as String,
      model: json['model'] as String,
      promptTokens: json['usage']['prompt_tokens'] as int,
      completionTokens: json['usage']['completion_tokens'] as int,
      totalTokens: json['usage']['total_tokens'] as int,
    );
  }
}

/// 아기 컨텍스트 정보
class BabyContext {
  final String name;
  final int ageInMonths;
  final int ageInWeeks;
  final bool isPremature;
  final int? correctedAgeInMonths;
  final String? recentSleepPattern;
  final String? currentSweetSpot;
  final int? averageNightWakings;
  final int? averageNapDuration;

  BabyContext({
    required this.name,
    required this.ageInMonths,
    required this.ageInWeeks,
    this.isPremature = false,
    this.correctedAgeInMonths,
    this.recentSleepPattern,
    this.currentSweetSpot,
    this.averageNightWakings,
    this.averageNapDuration,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('- Baby Name: $name');
    buffer.writeln('- Chronological Age: $ageInMonths months ($ageInWeeks weeks)');

    if (isPremature && correctedAgeInMonths != null) {
      buffer.writeln('- Corrected Age: $correctedAgeInMonths months (premature baby)');
    }

    if (recentSleepPattern != null) {
      buffer.writeln('- Recent Sleep Pattern: $recentSleepPattern');
    }

    if (currentSweetSpot != null) {
      buffer.writeln('- Current Sweet Spot: $currentSweetSpot');
    }

    if (averageNightWakings != null) {
      buffer.writeln('- Average Night Wakings: $averageNightWakings times/night');
    }

    if (averageNapDuration != null) {
      buffer.writeln('- Average Nap Duration: $averageNapDuration minutes');
    }

    return buffer.toString();
  }
}

/// OpenAI 예외 처리
class OpenAIException implements Exception {
  final int statusCode;
  final String message;

  OpenAIException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() {
    return 'OpenAIException (Status: $statusCode): $message';
  }
}

/// OpenAI 설정 예외
class OpenAINotConfiguredException implements Exception {
  final String message;
  OpenAINotConfiguredException(this.message);

  @override
  String toString() => message;
}
