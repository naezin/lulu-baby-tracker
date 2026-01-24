import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/activity_model.dart';

/// 💡 Activity Insight Card
/// 각 활동 기록에 대한 인사이트 카드
/// "이게 정상인가요?" 질문에 답하는 카드
class ActivityInsightCard extends StatelessWidget {
  final ActivityModel activity;
  final String? insight;
  final InsightType type;

  const ActivityInsightCard({
    super.key,
    required this.activity,
    this.insight,
    this.type = InsightType.neutral,
  });

  @override
  Widget build(BuildContext context) {
    if (insight == null || insight!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _getIcon(),
            color: _getIconColor(),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              insight!,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case InsightType.positive:
        return AppTheme.successSoft.withValues(alpha: 0.1);
      case InsightType.warning:
        return AppTheme.warningSoft.withValues(alpha: 0.1);
      case InsightType.concern:
        return AppTheme.errorSoft.withValues(alpha: 0.1);
      case InsightType.neutral:
        return AppTheme.lavenderMist.withValues(alpha: 0.1);
    }
  }

  Color _getBorderColor() {
    switch (type) {
      case InsightType.positive:
        return AppTheme.successSoft.withValues(alpha: 0.3);
      case InsightType.warning:
        return AppTheme.warningSoft.withValues(alpha: 0.3);
      case InsightType.concern:
        return AppTheme.errorSoft.withValues(alpha: 0.3);
      case InsightType.neutral:
        return AppTheme.lavenderMist.withValues(alpha: 0.3);
    }
  }

  Color _getIconColor() {
    switch (type) {
      case InsightType.positive:
        return AppTheme.successSoft;
      case InsightType.warning:
        return AppTheme.warningSoft;
      case InsightType.concern:
        return AppTheme.errorSoft;
      case InsightType.neutral:
        return AppTheme.lavenderMist;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case InsightType.positive:
        return Icons.check_circle_outline;
      case InsightType.warning:
        return Icons.info_outline;
      case InsightType.concern:
        return Icons.warning_amber_rounded;
      case InsightType.neutral:
        return Icons.lightbulb_outline;
    }
  }
}

enum InsightType {
  positive,   // 초록색 - 좋음
  warning,    // 노란색 - 주의
  concern,    // 빨간색 - 우려
  neutral,    // 파란색 - 정보
}
