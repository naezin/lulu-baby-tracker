import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/sleep_pattern_insight.dart';

/// 히트맵 해석 카드
/// 수면 패턴 인사이트를 시각적으로 표시
class HeatmapInterpretationCard extends StatelessWidget {
  final SleepPatternInsight insight;
  final bool isKorean;

  const HeatmapInterpretationCard({
    Key? key,
    required this.insight,
    this.isKorean = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradientColors(),
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getBorderColor(),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _getBorderColor().withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildDivider(),
          _buildContent(),
        ],
      ),
    );
  }

  /// 헤더 (타입 + 이모지 + 패턴 강도)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                insight.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isKorean ? '수면 패턴 분석' : 'Sleep Pattern Analysis',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insight.getStrengthMessage(isKorean: isKorean),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _buildPatternStrengthBadge(),
            ],
          ),
        ],
      ),
    );
  }

  /// 패턴 강도 배지
  Widget _buildPatternStrengthBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_graph,
            size: 16,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(width: 4),
          Text(
            '${insight.patternStrength.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// 구분선
  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0),
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0),
          ],
        ),
      ),
    );
  }

  /// 컨텐츠 (발견사항 + 조언)
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 주요 발견사항
          _buildSection(
            icon: Icons.insights,
            title: isKorean ? '주요 발견' : 'Main Finding',
            content: insight.mainFinding,
          ),

          // 긍정적인 패턴
          if (insight.positivePattern != null) ...[
            const SizedBox(height: 16),
            _buildSection(
              icon: Icons.check_circle_outline,
              title: isKorean ? '잘하고 있어요' : "What's Working",
              content: insight.positivePattern!,
              color: AppTheme.successSoft,
            ),
          ],

          // 개선이 필요한 영역
          if (insight.improvementArea != null) ...[
            const SizedBox(height: 16),
            _buildSection(
              icon: Icons.lightbulb_outline,
              title: isKorean ? '개선 포인트' : 'Improvement Area',
              content: insight.improvementArea!,
              color: AppTheme.warningSoft,
            ),
          ],

          const SizedBox(height: 16),

          // 실용적인 조언
          _buildActionAdvice(),

          // 추가 정보
          if (insight.optimalSleepHour != null ||
              insight.consistentPeriod != null) ...[
            const SizedBox(height: 16),
            _buildAdditionalInfo(),
          ],

          // 추가 메모
          if (insight.additionalNote != null) ...[
            const SizedBox(height: 16),
            _buildAdditionalNote(),
          ],
        ],
      ),
    );
  }

  /// 섹션 빌더
  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    Color? color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? Colors.white).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color ?? Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 실용적인 조언 (강조)
  Widget _buildActionAdvice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lavenderMist.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lavenderMist.withOpacity(0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.lavenderMist,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.tips_and_updates,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isKorean ? '실천 가이드' : 'Action Guide',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.lavenderMist,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.actionableAdvice,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 추가 정보 (최적 시간, 일관성 기간)
  Widget _buildAdditionalInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          if (insight.optimalSleepHour != null)
            _buildInfoRow(
              icon: Icons.bedtime,
              label: isKorean ? '최적 취침 시간' : 'Optimal Bedtime',
              value: insight.getOptimalTimeFormatted(isKorean: isKorean)!,
            ),
          if (insight.optimalSleepHour != null &&
              insight.consistentPeriod != null)
            const SizedBox(height: 12),
          if (insight.consistentPeriod != null)
            _buildInfoRow(
              icon: Icons.schedule,
              label: isKorean ? '일관된 수면 시간' : 'Consistent Period',
              value: insight.consistentPeriod!,
            ),
        ],
      ),
    );
  }

  /// 정보 행
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.white.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 추가 메모
  Widget _buildAdditionalNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.infoSoft.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: AppTheme.infoSoft,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              insight.additionalNote!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 그라데이션 색상
  List<Color> _getGradientColors() {
    switch (insight.type) {
      case InsightType.excellent:
        return [
          AppTheme.successSoft.withOpacity(0.3),
          AppTheme.primaryDark.withOpacity(0.9),
        ];
      case InsightType.good:
        return [
          AppTheme.infoSoft.withOpacity(0.3),
          AppTheme.primaryDark.withOpacity(0.9),
        ];
      case InsightType.needsImprovement:
        return [
          AppTheme.warningSoft.withOpacity(0.3),
          AppTheme.primaryDark.withOpacity(0.9),
        ];
      case InsightType.concerning:
        return [
          AppTheme.errorSoft.withOpacity(0.3),
          AppTheme.primaryDark.withOpacity(0.9),
        ];
    }
  }

  /// 테두리 색상
  Color _getBorderColor() {
    switch (insight.type) {
      case InsightType.excellent:
        return AppTheme.successSoft;
      case InsightType.good:
        return AppTheme.infoSoft;
      case InsightType.needsImprovement:
        return AppTheme.warningSoft;
      case InsightType.concerning:
        return AppTheme.errorSoft;
    }
  }
}
