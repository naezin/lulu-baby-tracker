import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/knowledge/who_growth_standards.dart';

/// WHO 성장 곡선 위젯
class WHOGrowthChart extends StatelessWidget {
  final double currentWeight; // kg
  final int ageInMonths;
  final bool isBoy;
  final String babyName;

  const WHOGrowthChart({
    super.key,
    required this.currentWeight,
    required this.ageInMonths,
    required this.isBoy,
    required this.babyName,
  });

  @override
  Widget build(BuildContext context) {
    final percentile = WHOGrowthStandards.calculatePercentile(
      currentValue: currentWeight,
      ageInMonths: ageInMonths,
      isBoy: isBoy,
      isWeight: true,
    );

    final status = WHOGrowthStandards.getGrowthStatus(percentile);
    final message = WHOGrowthStandards.getPercentileMessage(
      percentile: percentile,
      isWeight: true,
      babyName: babyName,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.show_chart,
                  color: _getStatusColor(status),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WHO 성장 곡선',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '또래 비교',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textTertiary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 백분위 바
          _buildPercentileBar(percentile, status),

          const SizedBox(height: 16),

          // 메시지
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  _getStatusEmoji(status),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 상세 정보
          _buildDetailInfo(),
        ],
      ),
    );
  }

  Widget _buildPercentileBar(int percentile, WHOGrowthStatus status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '또래 대비',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${percentile}%',
              style: TextStyle(
                color: _getStatusColor(status),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 백분위 바
        Stack(
          children: [
            // 배경 바
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // 채워진 바
            FractionallySizedBox(
              widthFactor: percentile / 100,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getStatusColor(status).withOpacity(0.7),
                      _getStatusColor(status),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // 범위 표시
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0%',
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 11,
              ),
            ),
            Text(
              '50% (평균)',
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 11,
              ),
            ),
            Text(
              '100%',
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: AppTheme.lavenderMist,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'WHO 2006 성장 기준 사용',
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(WHOGrowthStatus status) {
    switch (status) {
      case WHOGrowthStatus.severeMalnutrition:
        return AppTheme.errorSoft;
      case WHOGrowthStatus.underweight:
        return AppTheme.warningSoft;
      case WHOGrowthStatus.normal:
        return AppTheme.successSoft;
      case WHOGrowthStatus.overweight:
        return AppTheme.infoSoft;
    }
  }

  String _getStatusEmoji(WHOGrowthStatus status) {
    switch (status) {
      case WHOGrowthStatus.severeMalnutrition:
        return '⚠️';
      case WHOGrowthStatus.underweight:
        return '💙';
      case WHOGrowthStatus.normal:
        return '✅';
      case WHOGrowthStatus.overweight:
        return '💪';
    }
  }
}
