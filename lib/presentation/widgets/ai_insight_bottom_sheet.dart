import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/models/ai_insight_model.dart';
import '../../data/services/ai_coaching_service.dart';
import 'dart:io' show Platform;

/// AI 인사이트 바텀시트
class AIInsightBottomSheet extends StatefulWidget {
  final AIInsightModel insight;
  final String babyId;
  final VoidCallback? onExportPDF;

  const AIInsightBottomSheet({
    Key? key,
    required this.insight,
    required this.babyId,
    this.onExportPDF,
  }) : super(key: key);

  @override
  State<AIInsightBottomSheet> createState() => _AIInsightBottomSheetState();

  /// 바텀시트 표시
  static Future<void> show({
    required BuildContext context,
    required AIInsightModel insight,
    required String babyId,
    VoidCallback? onExportPDF,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AIInsightBottomSheet(
        insight: insight,
        babyId: babyId,
        onExportPDF: onExportPDF,
      ),
    );
  }
}

class _AIInsightBottomSheetState extends State<AIInsightBottomSheet> {
  String? _feedbackRating;

  @override
  void initState() {
    super.initState();
    _feedbackRating = widget.insight.feedbackRating;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isRiskCritical = widget.insight.riskLevel == RiskLevel.critical;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
                  children: [
                    // Header
                    _buildHeader(theme, l10n, isRiskCritical),

                    SizedBox(height: 24),

                    // 위험 수준이 높으면 전문가 상담 권고
                    if (isRiskCritical) ...[
                      _buildCriticalWarningCard(theme, l10n),
                      SizedBox(height: 24),
                    ],

                    // 공감 메시지
                    _buildSection(
                      theme: theme,
                      icon: Icons.favorite_outline,
                      iconColor: Colors.pink,
                      title: l10n.aiCoachingEmpathy,
                      content: widget.insight.content.empathyMessage,
                    ),

                    SizedBox(height: 20),

                    // 데이터 통찰
                    _buildSection(
                      theme: theme,
                      icon: Icons.insights_outlined,
                      iconColor: Colors.blue,
                      title: l10n.aiCoachingInsight,
                      content: widget.insight.content.dataInsight,
                    ),

                    SizedBox(height: 20),

                    // 오늘의 행동 지침
                    _buildSection(
                      theme: theme,
                      icon: Icons.lightbulb_outline,
                      iconColor: Colors.orange,
                      title: l10n.aiCoachingAction,
                      content: widget.insight.content.actionGuidance,
                    ),

                    // 전문가 조언 (있는 경우)
                    if (widget.insight.content.expertAdvice != null) ...[
                      SizedBox(height: 20),
                      _buildSection(
                        theme: theme,
                        icon: Icons.medical_services_outlined,
                        iconColor: Colors.red,
                        title: l10n.aiCoachingExpert,
                        content: widget.insight.content.expertAdvice!,
                      ),
                    ],

                    SizedBox(height: 32),

                    // 피드백 섹션
                    _buildFeedbackSection(theme, l10n),

                    SizedBox(height: 16),

                    // 타임스탬프
                    _buildTimestamp(theme),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 헤더
  Widget _buildHeader(ThemeData theme, AppLocalizations l10n, bool isRiskCritical) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isRiskCritical
                ? Colors.red.withOpacity(0.1)
                : theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            isRiskCritical ? Icons.warning_amber_rounded : Icons.psychology_outlined,
            color: isRiskCritical
                ? Colors.red
                : theme.colorScheme.primary,
            size: 28,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isRiskCritical ? l10n.criticalAlertTitle : l10n.aiCoachingTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                isRiskCritical
                    ? '즉시 확인이 필요합니다'
                    : l10n.aiCoachingAnalyzing,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  /// 위험 경고 카드
  Widget _buildCriticalWarningCard(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.shade300,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_hospital,
                color: Colors.red,
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.criticalAlertTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            l10n.criticalAlertMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.red.shade800,
              height: 1.5,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: widget.onExportPDF,
              icon: Icon(Icons.picture_as_pdf),
              label: Text(l10n.generatePDFReport),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 섹션 빌더
  Widget _buildSection({
    required ThemeData theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            content,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  /// 피드백 섹션
  Widget _buildFeedbackSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 32),
        Text(
          l10n.aiCoachingFeedbackQuestion,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFeedbackButton(
              theme: theme,
              l10n: l10n,
              rating: 'positive',
              icon: Icons.thumb_up,
              label: l10n.aiCoachingFeedbackPositive,
              isSelected: _feedbackRating == 'positive',
            ),
            SizedBox(width: 16),
            _buildFeedbackButton(
              theme: theme,
              l10n: l10n,
              rating: 'negative',
              icon: Icons.thumb_down,
              label: l10n.aiCoachingFeedbackNegative,
              isSelected: _feedbackRating == 'negative',
            ),
          ],
        ),
        if (_feedbackRating != null) ...[
          SizedBox(height: 12),
          Center(
            child: Text(
              l10n.aiCoachingFeedbackThanks,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  /// 피드백 버튼
  Widget _buildFeedbackButton({
    required ThemeData theme,
    required AppLocalizations l10n,
    required String rating,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () => _submitFeedback(rating),
        icon: Icon(
          icon,
          size: 20,
        ),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          backgroundColor: isSelected
              ? theme.colorScheme.primaryContainer
              : null,
          foregroundColor: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
      ),
    );
  }

  /// 피드백 제출
  Future<void> _submitFeedback(String rating) async {
    setState(() {
      _feedbackRating = rating;
    });

    try {
      final coachingService = Provider.of<AICoachingService>(context, listen: false);
      await coachingService.saveFeedback(
        babyId: widget.babyId,
        insightId: widget.insight.id,
        rating: rating,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('피드백이 저장되었습니다'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('피드백 저장 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 타임스탬프
  Widget _buildTimestamp(ThemeData theme) {
    final timestamp = widget.insight.timestamp;
    final formattedTime = '${timestamp.year}년 ${timestamp.month}월 ${timestamp.day}일 ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';

    return Center(
      child: Text(
        formattedTime,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
