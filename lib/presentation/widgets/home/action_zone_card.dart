import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/sweet_spot_calculator.dart';

/// 🎯 Action Zone Card
/// "지금 어떻게 해야 해?" 질문에 답하는 핵심 카드
/// Hot reload test - 시뮬레이터에서 확인하세요!
class ActionZoneCard extends StatelessWidget {
  final SweetSpotResult? sweetSpot;
  final VoidCallback? onSleepNowTap;
  final VoidCallback? onSetAlarmTap;

  const ActionZoneCard({
    super.key,
    this.sweetSpot,
    this.onSleepNowTap,
    this.onSetAlarmTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple,
            AppTheme.primaryPurple.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '지금 뭘 하면 좋을까요?',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMainMessage(context),
            const SizedBox(height: 20),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMessage(BuildContext context) {
    if (sweetSpot == null) {
      return const Text(
        '수면을 기록하면 추천을 받을 수 있어요',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
      );
    }

    final now = DateTime.now();
    final isInWindow = now.isAfter(sweetSpot!.sweetSpotStart) &&
                       now.isBefore(sweetSpot!.sweetSpotEnd);
    final isPastWindow = now.isAfter(sweetSpot!.sweetSpotEnd);

    String message;
    if (isPastWindow) {
      message = '스위트 스팟 지났어요 - 지금 재우세요!';
    } else if (isInWindow) {
      message = '지금이 재우기 딱 좋은 시간이에요!';
    } else {
      message = '이 시간까지 재우면 좋아요';
    }

    return Text(
      message,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              onSleepNowTap?.call();
            },
            icon: const Icon(Icons.bedtime, size: 18),
            label: const Text('지금 재우기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryPurple,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              onSetAlarmTap?.call();
            },
            icon: const Icon(Icons.alarm, size: 18),
            label: const Text('알림 설정'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
