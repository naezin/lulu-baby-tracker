import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat/chat_bubble.dart';
import '../../widgets/chat/chat_input.dart';
import '../../widgets/chat/quick_questions_bar.dart';
import '../../widgets/chat/typing_indicator.dart';

/// AI 상담 채팅 화면
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().addWelcomeMessage(context);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage(String message) async {
    _textController.clear();
    await context.read<ChatProvider>().sendMessageStream(message);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '🌙',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.aiSleepConsultant,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ChatProvider>().clearChat();
              context.read<ChatProvider>().addWelcomeMessage(context);
            },
            tooltip: l10n.newConversation,
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Questions Bar
          QuickQuestionsBar(
            onQuestionSelected: (question) {
              _sendMessage(question.prompt);
            },
          ),

          // Chat Messages
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                if (provider.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '🌙',
                          style: TextStyle(fontSize: 64),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.startConversation,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.messages.length + (provider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.messages.length) {
                      return const TypingIndicator();
                    }

                    final message = provider.messages[index];
                    return ChatBubble(
                      message: message.content,
                      isUser: message.role == 'user',
                      timestamp: message.timestamp,
                    );
                  },
                );
              },
            ),
          ),

          // Error Message
          Consumer<ChatProvider>(
            builder: (context, provider, child) {
              if (provider.error != null) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.red.shade50,
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.chatError,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Input Field
          ChatInput(
            controller: _textController,
            onSend: _sendMessage,
            enabled: !context.watch<ChatProvider>().isLoading,
          ),
        ],
      ),
    );
  }
}
