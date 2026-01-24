import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/baby_model.dart';
import '../../../data/services/local_storage_service.dart';
import 'services/insight_generator.dart';

/// 📊 Analysis Screen - 질문 기반 통합 분석 화면
/// 핵심 원칙: "차트가 아닌 답변을 보여준다"
class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final _storage = LocalStorageService();
  final _insightGenerator = InsightGenerator();

  bool _isLoading = true;
  String _selectedPeriod = 'week'; // week, month

  // 분석 데이터
  WeeklySleepInsight? _sleepInsight;
  WeeklyFeedingInsight? _feedingInsight;
  WeeklyWakeUpInsight? _wakeUpInsight;
  PatternInsight? _patternInsight;
  String? _highlightMessage;

  BabyModel? _baby;
  int _babyAgeInDays = 72; // 기본값

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    setState(() => _isLoading = true);

    try {
      // 아기 정보 로드
      _baby = await _storage.getBaby();
      if (_baby != null) {
        final birthDate = DateTime.parse(_baby!.birthDate);
        _babyAgeInDays = DateTime.now().difference(birthDate).inDays;
      }

      // 활동 데이터 로드
      final activities = await _storage.getActivities();

      // 기간 필터링
      final now = DateTime.now();
      final periodDays = _selectedPeriod == 'week' ? 7 : 30;
      final startDate = now.subtract(Duration(days: periodDays));

      final filteredActivities = activities.where((a) {
        final date = DateTime.parse(a.timestamp);
        return date.isAfter(startDate);
      }).toList();

      // 지난 기간 데이터 (비교용)
      final prevStartDate = startDate.subtract(Duration(days: periodDays));
      final prevActivities = activities.where((a) {
        final date = DateTime.parse(a.timestamp);
        return date.isAfter(prevStartDate) && date.isBefore(startDate);
      }).toList();

      // 인사이트 생성
      _sleepInsight = _insightGenerator.generateSleepInsight(
        activities: filteredActivities,
        prevActivities: prevActivities,
        babyAgeInDays: _babyAgeInDays,
      );

      _feedingInsight = _insightGenerator.generateFeedingInsight(
        activities: filteredActivities,
        prevActivities: prevActivities,
        babyWeightKg: _baby?.weightKg ?? 5.0,
      );

      _wakeUpInsight = _insightGenerator.generateWakeUpInsight(
        activities: filteredActivities,
        prevActivities: prevActivities,
        babyAgeInDays: _babyAgeInDays,
      );

      _patternInsight = _insightGenerator.generatePatternInsight(
        activities: filteredActivities,
      );

      // 하이라이트 메시지 생성
      _highlightMessage = _generateHighlight();

    } catch (e) {
      debugPrint('Analysis load error: $e');
    }

    setState(() => _isLoading = false);
  }

  String _generateHighlight() {
    // 가장 긍정적인 변화를 하이라이트로
    if (_sleepInsight != null && _sleepInsight!.diffMinutes > 0) {
      return '🎉 밤잠이 ${_sleepInsight!.diffMinutes}분 늘었어요!';
    }
    if (_wakeUpInsight != null && _wakeUpInsight!.diffCount < 0) {
      return '🎉 밤에 깨는 횟수가 ${-_wakeUpInsight!.diffCount}회 줄었어요!';
    }
    if (_feedingInsight != null && _feedingInsight!.status == InsightStatus.good) {
      return '✅ 수유량이 적절해요!';
    }
    return '📊 이번 주 아기의 패턴을 분석했어요';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        title: Text(
          l10n.translate('analysis') ?? '분석',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // 기간 선택 드롭다운
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPeriod,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary, size: 20),
                dropdownColor: AppTheme.surfaceCard,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                items: [
                  DropdownMenuItem(
                    value: 'week',
                    child: Text(l10n.translate('this_week') ?? '이번 주'),
                  ),
                  DropdownMenuItem(
                    value: 'month',
                    child: Text(l10n.translate('this_month') ?? '이번 달'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedPeriod = value);
                    _loadAnalysis();
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.lavenderMist))
          : RefreshIndicator(
              onRefresh: _loadAnalysis,
              color: AppTheme.lavenderMist,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🎉 하이라이트 카드
                    if (_highlightMessage != null)
                      _buildHighlightCard(),

                    const SizedBox(height: 24),

                    // ❓ 수면 인사이트
                    _buildSleepInsightCard(l10n),

                    const SizedBox(height: 16),

                    // ❓ 야간 기상 인사이트
                    _buildWakeUpInsightCard(l10n),

                    const SizedBox(height: 16),

                    // ❓ 수유 인사이트
                    _buildFeedingInsightCard(l10n),

                    const SizedBox(height: 16),

                    // ❓ 패턴 인사이트
                    _buildPatternInsightCard(l10n),

                    const SizedBox(height: 24),

                    // 📋 PDF 리포트 섹션
                    _buildPdfReportSection(l10n),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHighlightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lavenderMist.withOpacity(0.3),
            AppTheme.primaryDark.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.lavenderMist.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이번 주 하이라이트',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _highlightMessage!,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          if (_sleepInsight != null && _sleepInsight!.diffMinutes != 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  _formatHours(_sleepInsight!.avgMinutes),
                  style: const TextStyle(
                    color: AppTheme.lavenderMist,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(지난 주 ${_formatHours(_sleepInsight!.avgMinutes - _sleepInsight!.diffMinutes)})',
                  style: const TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSleepInsightCard(AppLocalizations l10n) {
    if (_sleepInsight == null) return const SizedBox.shrink();

    final status = _sleepInsight!.status;
    final statusIcon = status == InsightStatus.good ? '✅'
        : status == InsightStatus.warning ? '⚠️'
        : 'ℹ️';
    final statusText = status == InsightStatus.good
        ? (l10n.translate('sleeping_well') ?? '네, 잘 자고 있어요!')
        : status == InsightStatus.warning
            ? (l10n.translate('needs_attention') ?? '조금 관심이 필요해요')
            : (l10n.translate('normal') ?? '정상 범위입니다');

    return _QAInsightCard(
      question: l10n.translate('q_sleeping_well') ?? '우리 아기 요즘 잘 자고 있나요?',
      statusIcon: statusIcon,
      statusText: statusText,
      status: status,
      children: [
        const SizedBox(height: 12),
        _buildMetricRow(
          label: l10n.translate('avg_night_sleep') ?? '평균 밤잠',
          value: _formatHours(_sleepInsight!.avgMinutes),
          diff: _sleepInsight!.diffMinutes.toDouble(),
        ),
        const SizedBox(height: 8),
        _buildComparisonBar(
          current: _sleepInsight!.avgMinutes.toDouble(),
          min: _sleepInsight!.recommendedMinMinutes.toDouble(),
          max: _sleepInsight!.recommendedMaxMinutes.toDouble(),
          label: '${_babyAgeInDays ~/ 30}개월 아기 권장',
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          label: l10n.translate('view_sleep_chart') ?? '📈 수면 차트 보기',
          onTap: () {
            // TODO: 수면 차트 상세 화면
          },
        ),
      ],
    );
  }

  Widget _buildWakeUpInsightCard(AppLocalizations l10n) {
    if (_wakeUpInsight == null) return const SizedBox.shrink();

    final status = _wakeUpInsight!.status;
    final statusIcon = status == InsightStatus.good ? '✅'
        : status == InsightStatus.warning ? '⚠️'
        : 'ℹ️';
    final statusText = status == InsightStatus.good
        ? (l10n.translate('normal_wakeups') ?? '정상 범위예요')
        : (l10n.translate('slightly_high') ?? '조금 많은 편이에요');

    return _QAInsightCard(
      question: l10n.translate('q_night_wakeups') ?? '밤에 깨는 횟수는 정상인가요?',
      statusIcon: statusIcon,
      statusText: statusText,
      status: status,
      children: [
        const SizedBox(height: 12),
        _buildMetricRow(
          label: l10n.translate('avg_wakeups') ?? '이번 주 평균',
          value: '${_wakeUpInsight!.avgCount.toStringAsFixed(1)}회/밤',
          diff: _wakeUpInsight!.diffCount.toDouble(),
          isLowerBetter: true,
        ),
        const SizedBox(height: 4),
        Text(
          '${_babyAgeInDays ~/ 30}개월 아기 평균: ${_wakeUpInsight!.peerAvgCount.toStringAsFixed(1)}회/밤',
          style: const TextStyle(
            color: AppTheme.textTertiary,
            fontSize: 13,
          ),
        ),
        if (status == InsightStatus.warning) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warningSoft.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.translate('tip_reduce_wakeups') ??
                        'Tip: 마지막 수유량을 10-20ml 늘려보세요',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFeedingInsightCard(AppLocalizations l10n) {
    if (_feedingInsight == null) return const SizedBox.shrink();

    final status = _feedingInsight!.status;
    final statusIcon = status == InsightStatus.good ? '✅'
        : status == InsightStatus.warning ? '⚠️'
        : 'ℹ️';
    final statusText = status == InsightStatus.good
        ? (l10n.translate('adequate') ?? '적절합니다')
        : (l10n.translate('check_needed') ?? '확인이 필요해요');

    return _QAInsightCard(
      question: l10n.translate('q_feeding_amount') ?? '수유량은 충분한가요?',
      statusIcon: statusIcon,
      statusText: statusText,
      status: status,
      children: [
        const SizedBox(height: 12),
        _buildMetricRow(
          label: l10n.translate('daily_avg') ?? '일 평균',
          value: '${_feedingInsight!.avgDailyMl.toInt()}ml',
          diff: _feedingInsight!.diffMl,
        ),
        const SizedBox(height: 8),
        _buildComparisonBar(
          current: _feedingInsight!.avgDailyMl,
          min: _feedingInsight!.recommendedMinMl,
          max: _feedingInsight!.recommendedMaxMl,
          label: '체중 기준 권장',
        ),
      ],
    );
  }

  Widget _buildPatternInsightCard(AppLocalizations l10n) {
    if (_patternInsight == null) return const SizedBox.shrink();

    final hasGoodPattern = _patternInsight!.eatPlaySleepRate > 0.6;
    final statusIcon = hasGoodPattern ? '✅' : '📊';
    final statusText = hasGoodPattern
        ? (l10n.translate('good_pattern') ?? '좋은 패턴이에요!')
        : (l10n.translate('needs_improvement') ?? '개선이 필요해요');

    return _QAInsightCard(
      question: l10n.translate('q_eat_play_sleep') ?? '먹-놀-잠 패턴은 어떤가요?',
      statusIcon: statusIcon,
      statusText: statusText,
      status: hasGoodPattern ? InsightStatus.good : InsightStatus.info,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('🍼→🎮→😴', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${(_patternInsight!.eatPlaySleepRate * 100).toInt()}% 준수',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (!hasGoodPattern) ...[
          const SizedBox(height: 8),
          Text(
            '수유 후 바로 잠든 횟수: ${_patternInsight!.feedToSleepCount}회/${_patternInsight!.totalDays}일',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '→ 수유 후 10-15분 놀이 시간을 가져보세요',
            style: TextStyle(
              color: AppTheme.lavenderMist,
              fontSize: 13,
            ),
          ),
        ],
        const SizedBox(height: 12),
        _buildActionButton(
          label: l10n.translate('view_24h_rhythm') ?? '🕐 24시간 리듬 보기',
          onTap: () {
            // TODO: 24시간 리듬 차트
          },
        ),
      ],
    );
  }

  Widget _buildPdfReportSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📋', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                l10n.translate('pediatric_report') ?? '소아과 방문용 리포트',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.translate('report_description') ??
                '이번 주 데이터를 PDF로 정리해서 의사 선생님께 보여드리세요',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _generatePdfReport,
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: Text(l10n.translate('generate_pdf') ?? 'PDF 생성하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lavenderMist,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required String label,
    required String value,
    double? diff,
    bool isLowerBetter = false,
  }) {
    String? diffText;
    Color? diffColor;

    if (diff != null && diff != 0) {
      final isPositive = isLowerBetter ? diff < 0 : diff > 0;
      diffColor = isPositive ? AppTheme.successSoft : AppTheme.warningSoft;
      final sign = diff > 0 ? '+' : '';

      if (diff.abs() >= 60) {
        diffText = '$sign${(diff / 60).toStringAsFixed(1)}h';
      } else {
        diffText = '$sign${diff.toInt()}';
        if (!label.contains('회')) diffText += 'm';
      }
    }

    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (diffText != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: diffColor?.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              diffText,
              style: TextStyle(
                color: diffColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildComparisonBar({
    required double current,
    required double min,
    required double max,
    required String label,
  }) {
    final isInRange = current >= min && current <= max;
    final position = ((current - min) / (max - min)).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            // 배경 바
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.glassBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // 정상 범위 표시
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: isInRange
                    ? AppTheme.successSoft.withOpacity(0.5)
                    : AppTheme.warningSoft.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // 현재 위치 마커
            Positioned(
              left: position * (MediaQuery.of(context).size.width - 80) * 0.8,
              child: Container(
                width: 12,
                height: 12,
                transform: Matrix4.translationValues(0, -2, 0),
                decoration: BoxDecoration(
                  color: isInRange ? AppTheme.successSoft : AppTheme.warningSoft,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatValue(min),
              style: const TextStyle(color: AppTheme.textTertiary, fontSize: 11),
            ),
            Text(
              '[$label]',
              style: TextStyle(
                color: isInRange ? AppTheme.successSoft : AppTheme.warningSoft,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _formatValue(max),
              style: const TextStyle(color: AppTheme.textTertiary, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.lavenderMist,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatHours(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '$hours시간';
    return '$hours시간 $mins분';
  }

  String _formatValue(double value) {
    if (value >= 60) {
      return _formatHours(value.toInt());
    }
    return '${value.toInt()}ml';
  }

  Future<void> _generatePdfReport() async {
    HapticFeedback.mediumImpact();

    // TODO: PDF 생성 로직
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📄 PDF 리포트 생성 중...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Q&A 형식 인사이트 카드
class _QAInsightCard extends StatelessWidget {
  final String question;
  final String statusIcon;
  final String statusText;
  final InsightStatus status;
  final List<Widget> children;

  const _QAInsightCard({
    required this.question,
    required this.statusIcon,
    required this.statusText,
    required this.status,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 질문
          Row(
            children: [
              const Text('❓', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 답변 상태
          Row(
            children: [
              Text(statusIcon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: status == InsightStatus.good
                        ? AppTheme.successSoft
                        : status == InsightStatus.warning
                            ? AppTheme.warningSoft
                            : AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // 상세 내용
          ...children,
        ],
      ),
    );
  }
}
