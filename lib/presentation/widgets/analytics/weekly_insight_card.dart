import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// 📈 Weekly Insight Card
/// 주간 패턴 인사이트 카드
/// "이번 주는 어땠나요?" 질문에 답하는 카드
class WeeklyInsightCard extends StatelessWidget {
  final String title;
  final String insight;
  final String? trend; // "improving", "stable", "declining"
  final List<InsightMetric> metrics;
  final VoidCallback? onTap;

  const WeeklyInsightCard({
    super.key,
    required this.title,
    required this.insight,
    this.trend,
    required this.metrics,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.lavenderMist.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (trend != null) _buildTrendIndicator(),
              ],
            ),
            const SizedBox(height: 12),

            // Insight
            Text(
              insight,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Metrics
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: metrics.map((metric) => _buildMetricChip(metric)).toList(),
            ),

            if (onTap != null) ...[
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '자세히 보기',
                    style: TextStyle(
                      color: AppTheme.lavenderGlow,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppTheme.lavenderGlow,
                    size: 12,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrendIndicator() {
    IconData icon;
    Color color;

    switch (trend) {
      case 'improving':
        icon = Icons.trending_up_rounded;
        color = AppTheme.successSoft;
        break;
      case 'declining':
        icon = Icons.trending_down_rounded;
        color = AppTheme.errorSoft;
        break;
      case 'stable':
      default:
        icon = Icons.trending_flat_rounded;
        color = AppTheme.textTertiary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            _getTrendLabel(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getTrendLabel() {
    switch (trend) {
      case 'improving':
        return '개선';
      case 'declining':
        return '주의';
      case 'stable':
      default:
        return '안정';
    }
  }

  Widget _buildMetricChip(InsightMetric metric) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.lavenderMist.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            metric.icon,
            color: AppTheme.lavenderMist,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            metric.label,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            metric.value,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// 인사이트 메트릭 모델
class InsightMetric {
  final IconData icon;
  final String label;
  final String value;

  InsightMetric({
    required this.icon,
    required this.label,
    required this.value,
  });
}
