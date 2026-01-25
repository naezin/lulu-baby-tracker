import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/coaching_message.dart';
import '../../../core/theme/app_theme.dart';

/// 코칭 팁 카드
class CoachingTipCard extends StatelessWidget {
  final CoachingMessage message;
  final VoidCallback? onDismiss;
  final VoidCallback? onActionTap;

  const CoachingTipCard({
    Key? key,
    required this.message,
    this.onDismiss,
    this.onActionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getBackgroundColor().withOpacity(0.15),
            _getBackgroundColor().withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getBackgroundColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (제목 + 닫기 버튼)
          Row(
            children: [
              Text(
                message.emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message.title,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (onDismiss != null)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onDismiss!();
                  },
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: AppTheme.textTertiary,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // 본문
          Text(
            message.body,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),

          // 액션 버튼 (있으면)
          if (message.actionLabel != null && onActionTap != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                onActionTap!();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getBackgroundColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.actionLabel!,
                      style: TextStyle(
                        color: _getBackgroundColor(),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: _getBackgroundColor(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (message.type) {
      case CoachingMessageType.tip:
        return AppTheme.infoSoft;
      case CoachingMessageType.encouragement:
        return AppTheme.successSoft;
      case CoachingMessageType.celebration:
        return AppTheme.warningSoft;
      case CoachingMessageType.reminder:
        return AppTheme.lavenderMist;
      case CoachingMessageType.insight:
        return AppTheme.primaryDark;
    }
  }
}
