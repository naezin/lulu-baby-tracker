import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';

/// ✅ Post-Record Feedback Dialog
/// 기록 저장 후 보여주는 피드백 다이얼로그
class PostRecordFeedback extends StatelessWidget {
  final String title;
  final List<FeedbackItem> items;
  final String? nextAction;
  final VoidCallback? onNextActionTap;
  final VoidCallback onClose;

  const PostRecordFeedback({
    super.key,
    required this.title,
    required this.items,
    this.nextAction,
    this.onNextActionTap,
    required this.onClose,
  });

  /// 다이얼로그로 표시
  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<FeedbackItem> items,
    String? nextAction,
    VoidCallback? onNextActionTap,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => PostRecordFeedback(
        title: title,
        items: items,
        nextAction: nextAction,
        onNextActionTap: onNextActionTap,
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Success Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                // Feedback Items
                ...items.map((item) => _FeedbackRow(item: item)),

                const SizedBox(height: 24),

                // Next Action Button
                if (nextAction != null)
                  OutlinedButton.icon(
                    onPressed: onNextActionTap,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: Text(nextAction!),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // Close Button
                TextButton(
                  onPressed: onClose,
                  child: Text(l10n.translate('close') ?? 'Close'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackRow extends StatelessWidget {
  final FeedbackItem item;

  const _FeedbackRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (item.trend != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.trendColor?.withOpacity(0.1) ?? Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.trend!,
                style: TextStyle(
                  fontSize: 12,
                  color: item.trendColor ?? Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FeedbackItem {
  final String emoji;
  final String label;
  final String value;
  final String? trend;
  final Color color;
  final Color? trendColor;

  const FeedbackItem({
    required this.emoji,
    required this.label,
    required this.value,
    this.trend,
    this.color = Colors.blue,
    this.trendColor,
  });
}
