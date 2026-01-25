import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

/// "더 궁금해요" 버튼 - 챗봇 연결
class AskCoachButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isKorean;

  const AskCoachButton({
    Key? key,
    required this.onTap,
    required this.isKorean,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.lavenderMist.withOpacity(0.2),
              AppTheme.lavenderGlow.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.lavenderMist.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lulu 아이콘
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.lavenderMist.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '🦉',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 텍스트
            Text(
              isKorean ? '더 궁금한 게 있어요' : 'I have more questions',
              style: TextStyle(
                color: AppTheme.lavenderMist,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: 8),

            // 화살표
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppTheme.lavenderMist.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }
}
