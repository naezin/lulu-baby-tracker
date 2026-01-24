import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/services/openai_service.dart';

/// 채팅 상태 관리 Provider
class ChatProvider extends ChangeNotifier {
  final OpenAIService _openAIService;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  BabyContext? _babyContext;

  ChatProvider({required OpenAIService openAIService})
      : _openAIService = openAIService;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 아기 컨텍스트 설정
  void setBabyContext(BabyContext context) {
    _babyContext = context;
    notifyListeners();
  }

  /// 메시지 전송
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // 사용자 메시지 추가
    final userMessage = ChatMessage.user(content);
    _messages.add(userMessage);
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      // OpenAI API 호출
      final response = await _openAIService.sendMessage(
        messages: _messages,
        babyContext: _babyContext,
        useShortPrompt: false,
      );

      // 어시스턴트 응답 추가
      final assistantMessage = ChatMessage.assistant(response.content);
      _messages.add(assistantMessage);
    } catch (e) {
      _error = e.toString();
      // 에러 발생 시 사용자 메시지 제거
      _messages.remove(userMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 스트리밍 메시지 전송 (실시간 타이핑 효과)
  Future<void> sendMessageStream(String content) async {
    if (content.trim().isEmpty) return;

    // 사용자 메시지 추가
    final userMessage = ChatMessage.user(content);
    _messages.add(userMessage);
    _error = null;
    _isLoading = true;
    notifyListeners();

    // 빈 어시스턴트 메시지 추가 (스트리밍으로 채워질 예정)
    final assistantMessage = ChatMessage.assistant('');
    _messages.add(assistantMessage);
    notifyListeners();

    try {
      final stream = _openAIService.sendMessageStream(
        messages: [userMessage], // 마지막 사용자 메시지만 전송
        babyContext: _babyContext,
        useShortPrompt: false,
      );

      String fullContent = '';
      await for (var chunk in stream) {
        fullContent += chunk;
        // 마지막 메시지 업데이트
        _messages[_messages.length - 1] = ChatMessage.assistant(fullContent);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      // 에러 발생 시 사용자 메시지와 빈 어시스턴트 메시지 제거
      _messages.remove(userMessage);
      _messages.remove(assistantMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 대화 초기화
  void clearChat() {
    _messages.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// 초기 인사 메시지 추가
  void addWelcomeMessage(BuildContext context) {
    if (_messages.isEmpty) {
      final l10n = AppLocalizations.of(context);
      final welcomeMessage = ChatMessage.assistant(
        "${l10n.translate('chat_welcome_greeting')}\n\n"
        "${l10n.translate('chat_welcome_description')}\n\n"
        "${l10n.translate('chat_welcome_question')}",
      );
      _messages.add(welcomeMessage);
      notifyListeners();
    }
  }

  /// 빠른 질문 템플릿 전송
  Future<void> sendQuickQuestion(String template) async {
    await sendMessage(template);
  }
}

/// 빠른 질문 템플릿
class QuickQuestions {
  static List<QuickQuestion> getTemplates(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return [
      QuickQuestion(
        icon: '🌙',
        text: l10n.quickQuestionBabyWaking,
        prompt: l10n.quickQuestionBabyWaking,
      ),
      QuickQuestion(
        icon: '😴',
        text: l10n.quickQuestionWontSleep,
        prompt: l10n.quickQuestionWontSleep,
      ),
      QuickQuestion(
        icon: '⏰',
        text: l10n.quickQuestionShortNaps,
        prompt: l10n.quickQuestionShortNaps,
      ),
      QuickQuestion(
        icon: '🌅',
        text: l10n.quickQuestionEarlyWaking,
        prompt: l10n.quickQuestionEarlyWaking,
      ),
      QuickQuestion(
        icon: '🛏️',
        text: l10n.quickQuestionSleepEnvironment,
        prompt: l10n.quickQuestionSleepEnvironment,
      ),
      QuickQuestion(
        icon: '📊',
        text: l10n.quickQuestionAnalyzePatterns,
        prompt: l10n.quickQuestionAnalyzePatterns,
      ),
    ];
  }
}

class QuickQuestion {
  final String icon;
  final String text;
  final String prompt;

  const QuickQuestion({
    required this.icon,
    required this.text,
    required this.prompt,
  });
}
