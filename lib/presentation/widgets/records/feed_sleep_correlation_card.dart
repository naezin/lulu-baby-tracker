import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/feed_sleep_correlation.dart';
import '../../providers/feed_sleep_provider.dart';
import '../../providers/baby_provider.dart';

/// 🌙🍼 막수-밤잠 상관관계 카드
/// Phase 2: 데이터 기반 막수 가이드
class FeedSleepCorrelationCard extends StatefulWidget {
  const FeedSleepCorrelationCard({super.key});

  @override
  State<FeedSleepCorrelationCard> createState() => _FeedSleepCorrelationCardState();
}

class _FeedSleepCorrelationCardState extends State<FeedSleepCorrelationCard> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadCorrelation();
  }

  Future<void> _loadCorrelation() async {
    final feedSleepProvider = context.read<FeedSleepProvider>();
    final babyProvider = context.read<BabyProvider>();
    final babyId = babyProvider.currentBaby?.id;

    if (babyId != null && !feedSleepProvider.hasData) {
      await feedSleepProvider.analyze(babyId: babyId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedSleepProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingCard();
        }

        if (provider.error != null) {
          return _buildErrorCard(provider.error!);
        }

        if (!provider.hasData) {
          return _buildNoDataCard();
        }

        final correlation = provider.correlation!;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.lavenderMist.withOpacity(0.2),
                AppTheme.sleepColor.withOpacity(0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: provider.isReliable
                  ? AppTheme.lavenderMist.withOpacity(0.5)
                  : AppTheme.glassBorder,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lavenderMist.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(correlation, provider.isReliable),
              const SizedBox(height: 16),
              _buildRecommendations(correlation),
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                _buildDetailedAnalysis(correlation),
              ],
              const SizedBox(height: 12),
              _buildExpandButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: const Row(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lavenderMist),
          ),
          SizedBox(width: 16),
          Text(
            '막수 패턴 분석 중...',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.errorSoft.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.errorSoft.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_rounded, color: AppTheme.errorSoft),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '분석 실패: $error',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        children: [
          const Text('🌙', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 12),
          const Text(
            '막수 데이터가 부족해요',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '최소 3일간의 막수와 밤잠 데이터가 필요합니다',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(FeedSleepCorrelation correlation, bool isReliable) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.feedingColor.withOpacity(0.8),
                AppTheme.sleepColor.withOpacity(0.8),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('🍼→😴', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '막수 패턴 분석',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    '${correlation.dataPoints}일 분석',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildConfidenceBadge(correlation.confidence, isReliable),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceBadge(double confidence, bool isReliable) {
    final percentage = (confidence * 100).toInt();
    final color = isReliable ? AppTheme.successSoft : AppTheme.textTertiary;
    final label = isReliable ? '신뢰도 높음' : '신뢰도 보통';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        '$label $percentage%',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRecommendations(FeedSleepCorrelation correlation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('💡', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text(
                '최적 막수 가이드',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRecommendationItem(
            icon: '🍼',
            label: '권장 수유량',
            value: '${correlation.optimalAmountMl.toInt()}ml',
            description: '밤잠을 잘 자는 수유량',
          ),
          const SizedBox(height: 8),
          _buildRecommendationItem(
            icon: '⏰',
            label: '권장 간격',
            value: '${correlation.optimalGapMinutes}분',
            description: '수유 후 재우기까지 시간',
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem({
    required String icon,
    required String label,
    required String value,
    required String description,
  }) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppTheme.lavenderMist,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedAnalysis(FeedSleepCorrelation correlation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.glassBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📊', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text(
                '상세 분석',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCorrelationRow(
            label: '수유량 ↔ 첫 수면 구간',
            value: correlation.amountCorrelation,
          ),
          const SizedBox(height: 8),
          _buildCorrelationRow(
            label: '간격 ↔ 야간 깸 횟수',
            value: correlation.gapCorrelation,
          ),
          const SizedBox(height: 12),
          _buildInterpretation(correlation),
        ],
      ),
    );
  }

  Widget _buildCorrelationRow({required String label, required double value}) {
    final absValue = value.abs();
    final color = absValue > 0.5
        ? AppTheme.successSoft
        : absValue > 0.3
            ? AppTheme.lavenderMist
            : AppTheme.textTertiary;

    String interpretation;
    if (absValue > 0.5) {
      interpretation = '강한 상관관계';
    } else if (absValue > 0.3) {
      interpretation = '중간 상관관계';
    } else {
      interpretation = '약한 상관관계';
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            interpretation,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInterpretation(FeedSleepCorrelation correlation) {
    String message;
    IconData icon;
    Color color;

    if (correlation.isReliable) {
      message = '데이터가 충분해 신뢰할 수 있는 패턴입니다. 위 가이드를 따라 막수를 주세요!';
      icon = Icons.check_circle_outline;
      color = AppTheme.successSoft;
    } else if (correlation.hasEnoughData) {
      message = '패턴은 발견되었지만 더 많은 데이터가 필요합니다. 며칠 더 기록해주세요.';
      icon = Icons.info_outline;
      color = AppTheme.lavenderMist;
    } else {
      message = '아직 패턴을 찾기 어렵습니다. 최소 3일간의 데이터가 필요합니다.';
      icon = Icons.warning_amber_outlined;
      color = AppTheme.textTertiary;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isExpanded ? '접기' : '자세히 보기',
              style: const TextStyle(
                color: AppTheme.lavenderMist,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppTheme.lavenderMist,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
