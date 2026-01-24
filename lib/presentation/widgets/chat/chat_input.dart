import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';

/// 채팅 입력 필드
class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final bool enabled;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button (future feature)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: enabled ? () {} : null,
              color: Colors.grey[600],
              tooltip: l10n.translate('chat_button_tooltip_add_context'),
            ),

            // Text input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: enabled
                        ? l10n.translate('chat_hint_ask_lulu_about_sleep')
                        : l10n.translate('chat_hint_lulu_typing'),
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: enabled
                      ? (value) {
                          if (value.trim().isNotEmpty) {
                            onSend(value);
                          }
                        }
                      : null,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            Container(
              decoration: BoxDecoration(
                color: enabled
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded),
                color: Colors.white,
                onPressed: enabled
                    ? () {
                        final text = controller.text.trim();
                        if (text.isNotEmpty) {
                          onSend(text);
                        }
                      }
                    : null,
                tooltip: l10n.translate('chat_button_tooltip_send'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
