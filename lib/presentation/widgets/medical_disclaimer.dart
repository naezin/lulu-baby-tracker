import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Medical Disclaimer Widget
/// Shows a non-intrusive but visible disclaimer that Lulu is not medical advice
class MedicalDisclaimer extends StatelessWidget {
  final String? customMessage;
  final bool showIcon;

  const MedicalDisclaimer({
    super.key,
    this.customMessage,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final message = customMessage ??
        'Lulu is not a substitute for professional medical advice. Always consult your pediatrician for health concerns.';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.glassBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.info_outline,
              color: AppTheme.textTertiary,
              size: 16,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// High Fever Emergency Disclaimer
/// Special disclaimer for high fever in young babies (<3 months)
class HighFeverDisclaimer extends StatelessWidget {
  const HighFeverDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorSoft.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.errorSoft.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.local_hospital_outlined,
            color: AppTheme.errorSoft,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'High Fever in Young Babies',
                  style: TextStyle(
                    color: AppTheme.errorSoft,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'High fever in babies under 3 months can be serious. Please contact your pediatrician or seek emergency care.',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 12,
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

/// Growth Chart Disclaimer
/// Disclaimer for growth charts and percentiles
class GrowthChartDisclaimer extends StatelessWidget {
  const GrowthChartDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return MedicalDisclaimer(
      customMessage:
          'Growth charts show trends, not diagnoses. Every baby grows at their own pace. Consult your pediatrician for personalized guidance.',
      showIcon: true,
    );
  }
}

/// Sweet Spot Prediction Disclaimer
/// Disclaimer for AI sleep predictions
class SweetSpotDisclaimer extends StatelessWidget {
  const SweetSpotDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return MedicalDisclaimer(
      customMessage:
          'Sweet Spot predictions are based on age averages. Your baby\'s individual needs may vary. You know your baby best.',
      showIcon: true,
    );
  }
}
