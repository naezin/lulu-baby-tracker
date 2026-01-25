import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/premature_baby_calculator.dart';

/// 저체중아 특별 케어 가이드 카드
class LowBirthWeightCareCard extends StatelessWidget {
  final List<CareGuide> guides;
  final LowBirthWeightCategory category;

  const LowBirthWeightCareCard({
    super.key,
    required this.guides,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCategoryColor().withOpacity(0.1),
            _getCategoryColor().withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getCategoryColor().withOpacity(0.3),
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
                  color: _getCategoryColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.favorite,
                  color: _getCategoryColor(),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '저체중아 특별 케어',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getCategoryLabel(),
                      style: TextStyle(
                        color: _getCategoryColor(),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 케어 가이드 리스트
          ...guides.map((guide) => _buildGuideItem(guide)),

          const SizedBox(height: 12),

          // 경고 메시지
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warningSoft.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.warningSoft.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '위 가이드는 참고용이며, 정확한 진단과 치료는 소아과 전문의와 상담하세요.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem(CareGuide guide) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getPriorityColor(guide.priority).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                guide.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        guide.title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (guide.priority == CareGuidePriority.critical)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.errorSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '필수',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  guide.description,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
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

  Color _getCategoryColor() {
    switch (category) {
      case LowBirthWeightCategory.extremelyLow:
        return AppTheme.errorSoft;
      case LowBirthWeightCategory.veryLow:
        return const Color(0xFFE87878);
      case LowBirthWeightCategory.low:
        return AppTheme.warningSoft;
      case LowBirthWeightCategory.normal:
        return AppTheme.successSoft;
    }
  }

  String _getCategoryLabel() {
    switch (category) {
      case LowBirthWeightCategory.extremelyLow:
        return '초극소 저체중아 (<1.0kg)';
      case LowBirthWeightCategory.veryLow:
        return '극소 저체중아 (1.0-1.5kg)';
      case LowBirthWeightCategory.low:
        return '저체중아 (1.5-2.5kg)';
      case LowBirthWeightCategory.normal:
        return '정상 체중';
    }
  }

  Color _getPriorityColor(CareGuidePriority priority) {
    switch (priority) {
      case CareGuidePriority.critical:
        return AppTheme.errorSoft;
      case CareGuidePriority.high:
        return AppTheme.warningSoft;
      case CareGuidePriority.normal:
        return AppTheme.infoSoft;
    }
  }
}
