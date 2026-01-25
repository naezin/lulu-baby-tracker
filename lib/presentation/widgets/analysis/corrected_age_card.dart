import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/baby_model.dart';
import '../../../core/utils/premature_baby_calculator.dart';

/// 교정 나이 카드
class CorrectedAgeCard extends StatelessWidget {
  final BabyModel baby;

  const CorrectedAgeCard({
    super.key,
    required this.baby,
  });

  @override
  Widget build(BuildContext context) {
    final actualMonths = baby.ageInMonths;
    final correctedMonths = PrematureBabyCalculator.calculateCorrectedAgeInMonths(baby);
    final gapWeeks = PrematureBabyCalculator.getAgeGapInWeeks(baby);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lavenderMist.withOpacity(0.2),
            AppTheme.lavenderMist.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.lavenderMist.withOpacity(0.3),
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
                  color: AppTheme.lavenderMist.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: AppTheme.lavenderMist,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '교정 나이',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '예정일 기준 발달 추적',
                      style: const TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 교정 나이 vs 실제 나이
          Row(
            children: [
              Expanded(
                child: _buildAgeDisplay(
                  label: '교정 나이',
                  months: correctedMonths,
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 1,
                height: 60,
                color: AppTheme.glassBorder,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAgeDisplay(
                  label: '실제 나이',
                  months: actualMonths,
                  isPrimary: false,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 조산 정보
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppTheme.lavenderMist,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$gapWeeks주 일찍 태어남 • 예정일: ${_formatDueDate()}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 설명
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.infoSoft.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '예정일보다 일찍 태어난 아기는 예정일 기준 "교정 나이"로 발달을 평가합니다. 만 2세까지는 교정 나이를 사용하세요.',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
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

  Widget _buildAgeDisplay({
    required String label,
    required int months,
    required bool isPrimary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          months < 0 ? '-' : '$months개월',
          style: TextStyle(
            color: isPrimary ? AppTheme.lavenderMist : AppTheme.textSecondary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  String _formatDueDate() {
    if (baby.dueDate == null) return '';

    final dueDate = DateTime.parse(baby.dueDate!);
    return '${dueDate.year}.${dueDate.month}.${dueDate.day}';
  }
}
