import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// 현재 시점 구분선
class TimelineDivider extends StatelessWidget {
  final bool isKorean;

  const TimelineDivider({
    Key? key,
    required this.isKorean,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          // 시간 영역 공백
          const SizedBox(width: 70),

          // 현재 시점 점
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppTheme.lavenderMist,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lavenderMist.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // 구분선
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.lavenderMist,
                    AppTheme.lavenderMist.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // "지금" 라벨
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.lavenderMist.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isKorean ? '지금' : 'Now',
              style: TextStyle(
                color: AppTheme.lavenderMist,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
