import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

/// 타임라인 헤더
class TimelineHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllTap;

  const TimelineHeader({
    Key? key,
    required this.title,
    this.onSeeAllTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 제목
          Row(
            children: [
              Text(
                '📅',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // 전체보기 버튼
          if (onSeeAllTap != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onSeeAllTap!();
              },
              child: Text(
                '전체보기',
                style: TextStyle(
                  color: AppTheme.lavenderMist,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
