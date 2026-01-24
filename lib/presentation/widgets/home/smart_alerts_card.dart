import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

/// 🔔 Smart Alerts Card
/// AI 기반 실시간 알림 카드
/// - 긴급도에 따라 스타일 변경
/// - 탭하면 상세 정보 표시
enum AlertPriority {
  urgent,    // 빨강 - 즉시 조치 필요
  warning,   // 노랑 - 주의 필요
  info,      // 파랑 - 정보성
}

/// Smart Alert 타입 (인사이트 기반)
enum AlertType {
  warning,  // ⚠️ 주의 필요
  insight,  // 💡 인사이트
  success,  // 🎉 칭찬/성취
  tip,      // 💬 팁
}

class SmartAlert {
  final String id;
  final String title;
  final String message;
  final AlertPriority priority;
  final IconData icon;
  final DateTime timestamp;
  final VoidCallback? onTap;

  // 새로운 인사이트 기반 필드
  final AlertType? type;
  final String? emoji;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? color;

  SmartAlert({
    String? id,
    required this.title,
    String? message,
    AlertPriority? priority,
    IconData? icon,
    DateTime? timestamp,
    this.onTap,
    this.type,
    this.emoji,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.color,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        message = message ?? subtitle ?? '',
        priority = priority ?? _getPriorityFromType(type),
        icon = icon ?? _getIconFromType(type),
        timestamp = timestamp ?? DateTime.now();

  static AlertPriority _getPriorityFromType(AlertType? type) {
    if (type == null) return AlertPriority.info;
    switch (type) {
      case AlertType.warning:
        return AlertPriority.urgent;
      case AlertType.insight:
        return AlertPriority.info;
      case AlertType.success:
        return AlertPriority.info;
      case AlertType.tip:
        return AlertPriority.warning;
    }
  }

  static IconData _getIconFromType(AlertType? type) {
    if (type == null) return Icons.notifications;
    switch (type) {
      case AlertType.warning:
        return Icons.warning_amber_rounded;
      case AlertType.insight:
        return Icons.lightbulb_outline;
      case AlertType.success:
        return Icons.celebration;
      case AlertType.tip:
        return Icons.tips_and_updates;
    }
  }

  static Color _getDefaultColor(AlertType type) {
    switch (type) {
      case AlertType.warning:
        return Colors.orange;
      case AlertType.insight:
        return Colors.blue;
      case AlertType.success:
        return Colors.green;
      case AlertType.tip:
        return Colors.purple;
    }
  }

  /// 팩토리 메서드: 밤 깬 횟수 경고
  factory SmartAlert.nightWakings({
    required int count,
    required int avgCount,
  }) {
    final diff = count - avgCount;
    if (diff > 0) {
      return SmartAlert(
        type: AlertType.warning,
        emoji: '⚠️',
        title: '어젯밤 깬 횟수가 평소보다 많아요',
        subtitle: '$count회 (평소 $avgCount회 대비 +$diff회)',
        actionLabel: '원인 분석',
        color: Colors.orange,
      );
    }
    return SmartAlert(
      type: AlertType.success,
      emoji: '🎉',
      title: '어젯밤 깬 횟수가 줄었어요!',
      subtitle: '$count회 (평소 $avgCount회 대비 ${diff.abs()}회↓)',
      color: Colors.green,
    );
  }

  /// 팩토리 메서드: 수유량 변화
  factory SmartAlert.feedingChange({
    required int todayMl,
    required int avgMl,
  }) {
    final diff = todayMl - avgMl;
    final percent = avgMl > 0 ? ((diff / avgMl) * 100).abs().toInt() : 0;

    if (diff > 50) {
      return SmartAlert(
        type: AlertType.insight,
        emoji: '💡',
        title: '수유량이 늘었어요 (+$percent%)',
        subtitle: '성장기 신호일 수 있어요',
        color: Colors.blue,
      );
    }
    if (diff < -50) {
      return SmartAlert(
        type: AlertType.warning,
        emoji: '⚠️',
        title: '수유량이 줄었어요 (-$percent%)',
        subtitle: '컨디션을 체크해보세요',
        actionLabel: '건강 기록',
        color: Colors.orange,
      );
    }
    return SmartAlert(
      type: AlertType.success,
      emoji: '✅',
      title: '수유량이 안정적이에요',
      subtitle: '오늘 ${todayMl}ml (평균 ${avgMl}ml)',
      color: Colors.green,
    );
  }

  /// 팩토리 메서드: 활동 목표 달성
  factory SmartAlert.activityGoal({
    required int currentMinutes,
    required int goalMinutes,
    required String activityName,
  }) {
    final remaining = goalMinutes - currentMinutes;
    final percent = ((currentMinutes / goalMinutes) * 100).toInt();

    if (remaining <= 0) {
      return SmartAlert(
        type: AlertType.success,
        emoji: '🏆',
        title: '$activityName 목표 달성!',
        subtitle: '오늘 $currentMinutes분 완료',
        color: Colors.green,
      );
    }
    if (percent >= 70) {
      return SmartAlert(
        type: AlertType.tip,
        emoji: '💪',
        title: '$activityName $remaining분 더 하면 목표 달성!',
        subtitle: '현재 $percent% 완료',
        actionLabel: '기록하기',
        color: Colors.purple,
      );
    }
    return SmartAlert(
      type: AlertType.tip,
      emoji: '🎯',
      title: '$activityName 목표까지 $remaining분 남았어요',
      subtitle: '현재 $percent% 완료',
      color: Colors.purple,
    );
  }

  /// 팩토리 메서드: 최장 수면 기록
  factory SmartAlert.longestSleep({
    required int minutes,
    required int previousRecord,
  }) {
    if (minutes > previousRecord) {
      return SmartAlert(
        type: AlertType.success,
        emoji: '🌟',
        title: '이번 주 최장 밤잠 기록 갱신!',
        subtitle: '${minutes ~/ 60}시간 ${minutes % 60}분 연속 수면',
        color: Colors.green,
      );
    }
    return SmartAlert(
      type: AlertType.insight,
      emoji: '📊',
      title: '이번 주 가장 긴 밤잠',
      subtitle: '${previousRecord ~/ 60}시간 ${previousRecord % 60}분',
      color: Colors.blue,
    );
  }
}

class SmartAlertsCard extends StatelessWidget {
  final List<SmartAlert> alerts;
  final VoidCallback? onViewAll;

  const SmartAlertsCard({
    super.key,
    required this.alerts,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.notifications_active_outlined,
                    color: AppTheme.lavenderMist,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '스마트 알림',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (onViewAll != null && alerts.length > 1)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text(
                    '전체 보기',
                    style: TextStyle(
                      color: AppTheme.lavenderGlow,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Alert List (show up to 3)
          ...alerts.take(3).map((alert) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildAlertItem(alert),
              )),
        ],
      ),
    );
  }

  Widget _buildAlertItem(SmartAlert alert) {
    final color = _getColorForPriority(alert.priority);
    final backgroundColor = _getBackgroundColorForPriority(alert.priority);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        alert.onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                alert.icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.message,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Chevron
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.textTertiary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForPriority(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.urgent:
        return AppTheme.errorSoft;
      case AlertPriority.warning:
        return AppTheme.warningSoft;
      case AlertPriority.info:
        return AppTheme.lavenderMist;
    }
  }

  Color _getBackgroundColorForPriority(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.urgent:
        return AppTheme.errorSoft.withValues(alpha: 0.1);
      case AlertPriority.warning:
        return AppTheme.warningSoft.withValues(alpha: 0.1);
      case AlertPriority.info:
        return AppTheme.lavenderMist.withValues(alpha: 0.1);
    }
  }
}
