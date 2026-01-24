import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// 💬 QA Insight Card
/// 질문-답변 형식의 인사이트 카드
/// "이게 정상인가요?" 스타일의 UX
class QAInsightCard extends StatelessWidget {
  final String question;
  final InsightAnswer answer;
  final List<InsightMetric> metrics;
  final String? actionLabel;
  final VoidCallback? onAction;

  const QAInsightCard({
    Key? key,
    required this.question,
    required this.answer,
    required this.metrics,
    this.actionLabel,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: answer.color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Row(
            children: [
              Icon(
                Icons.help_outline_rounded,
                color: AppTheme.lavenderMist,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Answer Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: answer.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      answer.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            answer.title,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                          ),
                          if (answer.subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              answer.subtitle!,
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Metrics List
          ...metrics.map((metric) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    // Dot indicator
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: metric.color ?? AppTheme.lavenderMist,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Label
                    Expanded(
                      child: Text(
                        metric.label,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    // Value with trend
                    Row(
                      children: [
                        Text(
                          metric.value,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (metric.trend != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: (metric.trendColor ?? Colors.grey)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              metric.trend!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: metric.trendColor ?? Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              )),

          // Action Button
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAction,
                icon: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppTheme.lavenderGlow,
                ),
                label: Text(
                  actionLabel!,
                  style: TextStyle(
                    color: AppTheme.lavenderGlow,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: AppTheme.lavenderGlow.withOpacity(0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Insight Answer 모델
class InsightAnswer {
  final String emoji;
  final String title;
  final String? subtitle;
  final Color color;

  const InsightAnswer({
    required this.emoji,
    required this.title,
    this.subtitle,
    required this.color,
  });

  /// 긍정적인 답변 (초록색)
  factory InsightAnswer.positive({
    required String title,
    String? subtitle,
  }) {
    return InsightAnswer(
      emoji: '✅',
      title: title,
      subtitle: subtitle,
      color: Colors.green,
    );
  }

  /// 주의 필요 (주황색)
  factory InsightAnswer.caution({
    required String title,
    String? subtitle,
  }) {
    return InsightAnswer(
      emoji: '⚠️',
      title: title,
      subtitle: subtitle,
      color: Colors.orange,
    );
  }

  /// 중립적 답변 (파란색)
  factory InsightAnswer.neutral({
    required String title,
    String? subtitle,
  }) {
    return InsightAnswer(
      emoji: '💡',
      title: title,
      subtitle: subtitle,
      color: Colors.blue,
    );
  }

  /// 성공/칭찬 (초록색, 다른 이모지)
  factory InsightAnswer.success({
    required String title,
    String? subtitle,
  }) {
    return InsightAnswer(
      emoji: '🎉',
      title: title,
      subtitle: subtitle,
      color: Colors.green,
    );
  }

  /// 팁 제공 (보라색)
  factory InsightAnswer.tip({
    required String title,
    String? subtitle,
  }) {
    return InsightAnswer(
      emoji: '💬',
      title: title,
      subtitle: subtitle,
      color: Colors.purple,
    );
  }
}

/// Insight Metric (지표 표시용)
class InsightMetric {
  final String label;
  final String value;
  final String? trend; // "+2회", "↑30분" 등
  final Color? color; // 점 색상
  final Color? trendColor; // 트렌드 색상

  const InsightMetric({
    required this.label,
    required this.value,
    this.trend,
    this.color,
    this.trendColor,
  });
}
