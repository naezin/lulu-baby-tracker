import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/timeline_item.dart';
import '../../../core/theme/app_theme.dart';

/// 타임라인 아이템 카드
class TimelineItemCard extends StatelessWidget {
  final TimelineItem item;
  final bool isKorean;
  final VoidCallback? onTap;

  const TimelineItemCard({
    Key? key,
    required this.item,
    required this.isKorean,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPast = item.type == TimelineItemType.past;
    final isPredicted = item.type == TimelineItemType.predicted;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            // 시간
            SizedBox(
              width: 70,
              child: Text(
                item.getFormattedTime(isKorean: isKorean),
                style: TextStyle(
                  color: isPast
                      ? AppTheme.textTertiary
                      : AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // 타임라인 도트
            _buildTimelineDot(isPast, isPredicted),

            const SizedBox(width: 12),

            // 아이템 내용
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isPredicted
                      ? item.categoryColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isPredicted
                      ? Border.all(
                          color: item.categoryColor.withOpacity(0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    // 이모지
                    Text(
                      item.categoryEmoji,
                      style: TextStyle(
                        fontSize: 18,
                        color: isPast
                            ? AppTheme.textTertiary.withOpacity(0.7)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // 제목 + 서브타이틀
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              color: isPast
                                  ? AppTheme.textTertiary
                                  : AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              decoration: isPast && item.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          if (item.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle!,
                              style: TextStyle(
                                color: AppTheme.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // 알림 아이콘 (예정 아이템만)
                    if (isPredicted && item.hasAlert)
                      Icon(
                        Icons.notifications_active,
                        size: 16,
                        color: item.categoryColor.withOpacity(0.8),
                      ),

                    // 완료 체크 (과거 아이템만)
                    if (isPast && item.isCompleted)
                      Icon(
                        Icons.check_circle,
                        size: 18,
                        color: AppTheme.successSoft,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineDot(bool isPast, bool isPredicted) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isPast
                ? AppTheme.textTertiary.withOpacity(0.5)
                : item.categoryColor,
            shape: BoxShape.circle,
            border: isPredicted
                ? Border.all(color: item.categoryColor, width: 2)
                : null,
          ),
          child: isPast && item.isCompleted
              ? Icon(
                  Icons.check,
                  size: 8,
                  color: Colors.white,
                )
              : null,
        ),
      ],
    );
  }
}
