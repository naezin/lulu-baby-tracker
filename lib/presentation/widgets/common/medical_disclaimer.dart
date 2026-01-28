import 'package:flutter/material.dart';

/// 일반 의료 면책 조항 위젯
///
/// 앱이 의학적 조언을 제공하지 않음을 명시하는 위젯
class MedicalDisclaimer extends StatelessWidget {
  const MedicalDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    // 다국어 지원 확인 (간단한 방식)
    final locale = Localizations.localeOf(context);
    final isKorean = locale.languageCode == 'ko';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB74D).withOpacity(0.1), // Warning soft
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFB74D).withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFFFFB74D),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isKorean
                  ? '이 앱은 의학적 조언을 제공하지 않습니다. 건강 문제가 있다면 소아과 전문의와 상담하세요.'
                  : 'This app does not provide medical advice. Consult a pediatrician for health concerns.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 성장 차트 전용 면책 조항
///
/// WHO 표준 기반 성장 곡선에 대한 면책 조항
class GrowthChartDisclaimer extends StatelessWidget {
  const GrowthChartDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isKorean = locale.languageCode == 'ko';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2140).withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isKorean
            ? '성장 곡선은 WHO 표준을 기반으로 하며 참고용입니다. 아기의 성장은 개인차가 크므로 소아과 전문의와 상담하세요.'
            : 'Growth curves are based on WHO standards and for reference only. Consult a pediatrician as baby growth varies individually.',
        style: TextStyle(
          fontSize: 11,
          color: Colors.white.withOpacity(0.5),
          height: 1.3,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// 고열 경고 면책 조항 (3개월 미만 + 38°C 이상)
///
/// 신생아 고열 시 즉시 의료 조치 필요성을 경고
class HighFeverDisclaimer extends StatelessWidget {
  const HighFeverDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isKorean = locale.languageCode == 'ko';

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isKorean ? '⚠️ 즉시 병원 방문 필요' : '⚠️ Seek Medical Attention',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isKorean
                      ? '3개월 미만 아기의 38°C 이상 발열은 응급 상황입니다. 즉시 소아과 또는 응급실을 방문하세요.'
                      : 'Fever above 38°C in babies under 3 months is an emergency. Visit a pediatrician or ER immediately.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
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
}
