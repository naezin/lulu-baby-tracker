import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// 💡 Context Hint Card
/// 기록 전 유용한 컨텍스트 정보 제공
class ContextHintCard extends StatelessWidget {
  final String title;
  final List<ContextHintItem> hints;
  final ContextStatus status;

  const ContextHintCard({
    Key? key,
    required this.title,
    required this.hints,
    this.status = ContextStatus.neutral,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: _getIconColor(),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(),
                  ),
                ),
              ),
              _buildStatusBadge(),
            ],
          ),

          const SizedBox(height: 12),

          // Hints
          ...hints.map((hint) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hint.emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hint.text,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    String text;
    Color color;

    switch (status) {
      case ContextStatus.good:
        text = '✅ 적절해요';
        color = Colors.green;
        break;
      case ContextStatus.caution:
        text = '⚠️ 확인해주세요';
        color = Colors.orange;
        break;
      case ContextStatus.neutral:
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case ContextStatus.good:
        return Colors.green.withOpacity(0.05);
      case ContextStatus.caution:
        return Colors.orange.withOpacity(0.05);
      default:
        return Colors.blue.withOpacity(0.05);
    }
  }

  Color _getBorderColor() {
    switch (status) {
      case ContextStatus.good:
        return Colors.green.withOpacity(0.2);
      case ContextStatus.caution:
        return Colors.orange.withOpacity(0.2);
      default:
        return Colors.blue.withOpacity(0.2);
    }
  }

  Color _getIconColor() {
    switch (status) {
      case ContextStatus.good:
        return Colors.green;
      case ContextStatus.caution:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Color _getTextColor() {
    switch (status) {
      case ContextStatus.good:
        return Colors.green[800]!;
      case ContextStatus.caution:
        return Colors.orange[800]!;
      default:
        return Colors.blue[800]!;
    }
  }
}

enum ContextStatus { neutral, good, caution }

class ContextHintItem {
  final String emoji;
  final String text;

  const ContextHintItem({
    required this.emoji,
    required this.text,
  });
}
