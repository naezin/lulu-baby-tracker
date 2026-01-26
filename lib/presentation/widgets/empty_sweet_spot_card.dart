import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// 🆕 Empty State - 새 아기 또는 데이터 없을 때 표시
/// CDO 승인 디자인
class EmptySweetSpotCard extends StatelessWidget {
  final String babyName;
  final VoidCallback onRecordSleepTap;

  const EmptySweetSpotCard({
    super.key,
    required this.babyName,
    required this.onRecordSleepTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        // Glassmorphism 효과
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.champagneGold.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 아이콘
          const Text('👶', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),

          // 제목
          Text(
            '$babyName을 환영해요!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // 설명
          Text(
            '첫 번째 활동을 기록하면\nSweet Spot을 예측해 드릴게요 ✨',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // 버튼
          ElevatedButton.icon(
            onPressed: onRecordSleepTap,
            icon: const Text('🌙', style: TextStyle(fontSize: 18)),
            label: Text('$babyName의 첫 수면 기록하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.champagneGold,
              foregroundColor: AppTheme.surfaceDark,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
