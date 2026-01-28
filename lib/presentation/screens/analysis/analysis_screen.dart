import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/baby_model.dart';
import '../../../data/services/local_storage_service.dart';
import '../../providers/baby_provider.dart';
import '../../../core/utils/premature_baby_calculator.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/services/growth_percentile_service.dart';
import '../../widgets/analysis/who_growth_chart.dart';
import '../../widgets/analysis/corrected_age_card.dart';
import '../../widgets/analysis/low_birth_weight_care_card.dart';
import '../../widgets/charts/growth_curve_chart.dart';
import '../../widgets/charts/sleep_heatmap.dart';
import '../../widgets/growth_share_card.dart';
import 'services/insight_generator.dart';
import '../profile/baby_profile_screen.dart';
import '../../../data/services/sleep_pattern_analyzer.dart';  // 🆕 Day 4
import '../../widgets/analysis/heatmap_interpretation_card.dart';  // 🆕 Day 4
import '../../widgets/common/medical_disclaimer.dart';  // 🆕 Day 2 - Legal Compliance

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
  final _patternAnalyzer = SleepPatternAnalyzer();  // 🆕 Day 4

  bool _isLoading = true;
  String _selectedPeriod = 'week'; // week, month
  String? _errorMessage; // ✅ 에러 메시지 상태 추가
  GrowthPeriod _selectedGrowthPeriod = GrowthPeriod.all; // 🆕 성장 차트 기간 선택

  // 분석 데이터
  WeeklySleepInsight? _sleepInsight;
  WeeklyFeedingInsight? _feedingInsight;
  WeeklyWakeUpInsight? _wakeUpInsight;
  PatternInsight? _patternInsight;
  String? _highlightMessage;

  BabyModel? _baby;
  int? _babyAgeInDays; // ✅ nullable로 변경, 기본값 제거
  double? _birthWeight; // 출생 체중 (저체중아 판단용)
  double? _currentWeight; // 최신 체중 (건강 기록에서)

  @override
  void initState() {
    super.initState();

    // BabyProvider 초기화를 기다린 후 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalysis();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadAnalysis() async {
    setState(() => _isLoading = true);

    try {
      // 현재 아기 정보 로드
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);

      // BabyProvider가 아직 초기화되지 않았으면 LocalStorage에서 직접 로드
      if (babyProvider.currentBaby == null) {
        debugPrint('⏳ [AnalysisScreen] BabyProvider not initialized, loading from LocalStorage...');
        final babies = await _storage.getAllBabies();
        _baby = babies.isNotEmpty ? babies.first : null;
      } else {
        _baby = babyProvider.currentBaby;
      }

      debugPrint('📊 [AnalysisScreen] _loadAnalysis called');
      debugPrint('   currentBaby: ${_baby?.name ?? "null"}');
      debugPrint('   babyId: ${_baby?.id ?? "null"}');

      // ✅ 아기가 없으면 분석 불가 상태로 처리
      if (_baby == null) {
        debugPrint('⚠️ [AnalysisScreen] No baby found - showing Empty State');
        setState(() {
          _isLoading = false;
          _errorMessage = 'no_baby_registered'; // i18n key
        });
        return;
      }

      debugPrint('✅ [AnalysisScreen] Baby loaded successfully: ${_baby!.name}');

      // ✅ 실제 아기 나이 계산
      final birthDate = DateTime.parse(_baby!.birthDate);
      _babyAgeInDays = DateTime.now().difference(birthDate).inDays;
      _birthWeight = _baby!.birthWeightKg;

      // 활동 데이터 로드 (현재 아기만 필터링)
      final allActivities = await _storage.getActivities();
      final currentBabyId = _baby?.id;

      final activities = allActivities.where((a) {
        return currentBabyId == null || a.babyId == currentBabyId;
      }).toList();

      // 최신 체중 가져오기 (건강 기록에서)
      final weightRecords = activities
          .where((a) => a.type == ActivityType.health && a.weightKg != null)
          .toList()
        ..sort((a, b) => DateTime.parse(b.timestamp).compareTo(DateTime.parse(a.timestamp)));
      _currentWeight = weightRecords.isNotEmpty ? weightRecords.first.weightKg : _birthWeight;

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
        babyAgeInDays: _babyAgeInDays ?? 0, // ✅ null이면 0 (Empty State가 이미 처리됨)
      );

      _feedingInsight = _insightGenerator.generateFeedingInsight(
        activities: filteredActivities,
        prevActivities: prevActivities,
        babyWeightKg: _currentWeight ?? 5.0,
      );

      _wakeUpInsight = _insightGenerator.generateWakeUpInsight(
        activities: filteredActivities,
        prevActivities: prevActivities,
        babyAgeInDays: _babyAgeInDays ?? 0, // ✅ null이면 0 (Empty State가 이미 처리됨)
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
    final babyName = _baby?.name ?? '아기';

    // 가장 긍정적인 변화를 하이라이트로
    if (_sleepInsight != null && _sleepInsight!.diffMinutes > 0) {
      return '🌙 우리 $babyName가 지난주보다 ${_sleepInsight!.diffMinutes}분 더 푹 잤어요!';
    }
    if (_wakeUpInsight != null && _wakeUpInsight!.diffCount < 0) {
      return '✨ $babyName가 밤에 ${-_wakeUpInsight!.diffCount}번 덜 깼어요. 잘하고 있어요!';
    }
    if (_feedingInsight != null && _feedingInsight!.status == InsightStatus.good) {
      return '🍼 $babyName가 충분한 영양을 섭취하고 있어요!';
    }
    if (_sleepInsight != null && _sleepInsight!.diffMinutes == 0) {
      return '💙 $babyName의 수면 패턴이 안정적이에요';
    }
    return '📊 이번 주 $babyName의 성장 여정을 함께 살펴봐요';
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
          // 프로필 편집 버튼
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BabyProfileScreen(existingBaby: _baby),
                ),
              );

              // 프로필이 수정되었으면 데이터 새로고침
              if (result == true) {
                _loadAnalysis();
              }
            },
            tooltip: '프로필 편집',
          ),
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
      body: _buildBody(context, l10n),
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
            '✨ 이번 주 가장 좋았던 순간',
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
    final babyName = _baby?.name ?? '아기';
    final statusText = status == InsightStatus.good
        ? '네, $babyName가 푹 쉬고 있어요! 👏'
        : status == InsightStatus.warning
            ? '조금만 더 신경써주세요 💙'
            : '$babyName의 수면, 정상 범위예요';

    return _QAInsightCard(
      question: '우리 $babyName, 요즘 잘 자고 있나요?',
      statusIcon: statusIcon,
      statusText: statusText,
      status: status,
      children: [
        const SizedBox(height: 12),
        _buildMetricRow(
          label: '하루 평균 밤잠',
          value: _formatHours(_sleepInsight!.avgMinutes),
          diff: _sleepInsight!.diffMinutes.toDouble(),
        ),
        const SizedBox(height: 8),
        _buildComparisonBar(
          current: _sleepInsight!.avgMinutes.toDouble(),
          min: _sleepInsight!.recommendedMinMinutes.toDouble(),
          max: _sleepInsight!.recommendedMaxMinutes.toDouble(),
          label: '${(_babyAgeInDays ?? 0) ~/ 30}개월 아기 권장',
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          label: '📈 수면 기록 자세히 보기',
          onTap: () {
            // TODO: 수면 차트 상세 화면
          },
        ),
      ],
    );
  }

  Widget _buildWakeUpInsightCard(AppLocalizations l10n) {
    if (_wakeUpInsight == null) return const SizedBox.shrink();

    final babyName = _baby?.name ?? '아기';
    final status = _wakeUpInsight!.status;
    final statusIcon = status == InsightStatus.good ? '✅'
        : status == InsightStatus.warning ? '⚠️'
        : 'ℹ️';
    final statusText = status == InsightStatus.good
        ? '$babyName, 밤에 잘 자고 있어요! 👏'
        : '밤잠이 조금 불안정해요 💙';

    return _QAInsightCard(
      question: '$babyName는 밤에 몇 번이나 깨나요?',
      statusIcon: statusIcon,
      statusText: statusText,
      status: status,
      children: [
        const SizedBox(height: 12),
        _buildMetricRow(
          label: '하루 밤 평균',
          value: '${_wakeUpInsight!.avgCount.toStringAsFixed(1)}회',
          diff: _wakeUpInsight!.diffCount.toDouble(),
          isLowerBetter: true,
        ),
        const SizedBox(height: 4),
        Text(
          '또래 ${(_babyAgeInDays ?? 0) ~/ 30}개월 아기들은 평균 ${_wakeUpInsight!.peerAvgCount.toStringAsFixed(1)}번 깨요',
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
                    '💡 Tip: 자기 전 수유량을 10-20ml 늘리면 푹 잘 수 있어요',
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

    final babyName = _baby?.name ?? '아기';
    final status = _feedingInsight!.status;
    final statusIcon = status == InsightStatus.good ? '✅'
        : status == InsightStatus.warning ? '⚠️'
        : 'ℹ️';
    final statusText = status == InsightStatus.good
        ? '$babyName가 충분히 먹고 있어요! 🍼'
        : '수유량을 조금 확인해주세요 💙';

    return _QAInsightCard(
      question: '$babyName는 충분히 먹고 있나요?',
      statusIcon: statusIcon,
      statusText: statusText,
      status: status,
      children: [
        const SizedBox(height: 12),
        _buildMetricRow(
          label: '하루 평균',
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

    final babyName = _baby?.name ?? '아기';
    final hasGoodPattern = _patternInsight!.eatPlaySleepRate > 0.6;
    final statusIcon = hasGoodPattern ? '✅' : '📊';
    final statusText = hasGoodPattern
        ? '$babyName, 건강한 리듬으로 생활하고 있어요! 👏'
        : '리듬을 조금씩 만들어가고 있어요';

    return _QAInsightCard(
      question: '$babyName의 먹-놀-잠 패턴은 어떤가요?',
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
            '수유 후 바로 잠든 날: ${_patternInsight!.feedToSleepCount}일 / ${_patternInsight!.totalDays}일',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '💡 수유 후 10-15분 함께 놀아주면 더 건강한 리듬을 만들 수 있어요',
            style: TextStyle(
              color: AppTheme.lavenderMist,
              fontSize: 13,
            ),
          ),
        ],
        const SizedBox(height: 12),
        _buildActionButton(
          label: '🕐 24시간 생활 리듬 보기',
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
              const Text(
                '소아과 선생님께 보여드릴 리포트',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '이번 주 아기의 기록을 PDF로 정리해서 의사 선생님과 함께 살펴보세요',
            style: TextStyle(
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
              label: const Text('PDF로 저장하기'),
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

  Widget _buildLowBirthWeightCare() {
    if (_birthWeight == null || _baby == null) {
      return const SizedBox.shrink();
    }

    final category = PrematureBabyCalculator.getLowBirthWeightCategory(_birthWeight!);
    if (category == LowBirthWeightCategory.normal) {
      return const SizedBox.shrink();
    }

    final guides = PrematureBabyCalculator.getCareGuides(_baby!, _birthWeight!);

    return LowBirthWeightCareCard(
      guides: guides,
      category: category,
    );
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

  /// 😴 수면 히트맵 섹션
  Widget _buildSleepHeatmapSection(AppLocalizations l10n) {
    return FutureBuilder<List<ActivityModel>>(
      future: _storage.getActivitiesByType(ActivityType.sleep),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('😴', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '수면 패턴 히트맵',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '지난 7일간의 수면 패턴을 한눈에 확인하세요',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 400, // 고정 높이 지정
                child: SleepHeatmap(
                  sleepData: _convertToSleepDataPoints(snapshot.data!),
                  height: 400,
                  onCellTap: (date, hour) {
                    // AI 분석 콜백
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${date.month}/${date.day} ${hour}시 수면',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // 🆕 Day 4: 히트맵 해석 카드
              HeatmapInterpretationCard(
                insight: _patternAnalyzer.analyzePattern(
                  sleepActivities: snapshot.data!,
                  isKorean: l10n.locale.languageCode == 'ko',
                  babyAgeInMonths: _baby?.ageInMonths,
                ),
                isKorean: l10n.locale.languageCode == 'ko',
              ),
            ],
          ),
        );
      },
    );
  }

  /// 📊 성장 곡선 차트 섹션
  Widget _buildGrowthCurveSection(AppLocalizations l10n) {
    if (_baby == null || _baby!.gender == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<ActivityModel>>(
      future: _storage.getActivitiesByType(ActivityType.health),
      builder: (context, snapshot) {
        // 체중 기록이 있는 건강 활동만 필터링
        final healthRecords = snapshot.data?.where((a) => a.weightKg != null).toList() ?? [];

        // 출생 체중 포함
        final growthDataPoints = <GrowthDataPoint>[];
        final birthDate = DateTime.parse(_baby!.birthDate);

        if (_baby!.birthWeightKg != null) {
          growthDataPoints.add(GrowthDataPoint(
            ageInMonths: 0,
            value: _baby!.birthWeightKg!,
            dateTime: birthDate,
          ));
        }

        // 건강 기록의 체중 추가
        for (final record in healthRecords) {
          final recordDate = DateTime.parse(record.timestamp);
          final ageInMonths = recordDate.difference(birthDate).inDays ~/ 30;

          growthDataPoints.add(GrowthDataPoint(
            ageInMonths: ageInMonths,
            value: record.weightKg!,
            dateTime: recordDate,
          ));
        }

        // 데이터가 없을 때 플레이스홀더 표시
        if (growthDataPoints.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('📈', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'WHO 성장 곡선',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.glassBorder,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.monitor_weight_outlined,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '체중 기록이 없습니다',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '건강 기록에서 체중을 추가해주세요',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('📈', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      const Text(
                        'WHO 성장 곡선',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // SNS 공유 버튼
                  IconButton(
                    icon: const Icon(Icons.share_rounded, color: AppTheme.lavenderMist),
                    onPressed: () => _showShareDialog(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${_baby!.name}의 성장을 WHO 표준과 비교해보세요',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 400,
                child: GrowthCurveChart(
                  metric: GrowthMetric.weight,
                  gender: _baby!.gender == 'male' ? Gender.male : Gender.female,
                  babyData: growthDataPoints,
                  title: l10n.locale.languageCode == 'ko' ? '체중' : 'Weight',
                  unit: 'kg',
                  isKorean: l10n.locale.languageCode == 'ko',
                  selectedPeriod: _selectedGrowthPeriod,
                  onPeriodChanged: (period) {
                    setState(() {
                      _selectedGrowthPeriod = period;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              const GrowthChartDisclaimer(),
            ],
          ),
        );
      },
    );
  }

  /// ActivityModel을 SleepDataPoint로 변환
  List<SleepDataPoint> _convertToSleepDataPoints(List<ActivityModel> activities) {
    final dataPoints = <SleepDataPoint>[];

    for (final activity in activities) {
      if (activity.endTime == null) continue; // 진행 중인 수면은 제외

      final startTime = DateTime.parse(activity.timestamp);
      final endTime = DateTime.parse(activity.endTime!);

      // 시작 시간부터 종료 시간까지 시간 단위로 데이터 포인트 생성
      var current = startTime;
      while (current.isBefore(endTime)) {
        final nextHour = DateTime(current.year, current.month, current.day, current.hour + 1);
        final minutesInThisHour = endTime.isBefore(nextHour)
            ? endTime.difference(current).inMinutes
            : nextHour.difference(current).inMinutes;

        if (minutesInThisHour > 0) {
          dataPoints.add(SleepDataPoint(
            date: DateTime(current.year, current.month, current.day),
            hour: current.hour,
            minutes: minutesInThisHour.clamp(0, 60),
          ));
        }

        current = nextHour;
      }
    }

    return dataPoints;
  }

  /// SNS 공유 다이얼로그
  void _showShareDialog() {
    if (_baby == null || _currentWeight == null) return;

    final ageInMonths = _baby!.isPremature
        ? PrematureBabyCalculator.calculateCorrectedAgeInMonths(_baby!)
        : _baby!.ageInMonths;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GrowthShareCard(
          babyName: _baby!.name,
          ageText: '$ageInMonths개월',
          gender: _baby!.gender ?? 'male',
          weightKg: _currentWeight,
          weightPercentile: 50, // TODO: 실제 백분위수 계산
          measurementDate: DateTime.now(),
        ),
      ),
    );
  }

  /// 📊 Body 분리: 로딩/Empty State/정상 UI 관리
  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    // 1. 로딩 중
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.lavenderMist,
        ),
      );
    }

    // 2. 아기 미등록 (Empty State)
    if (_baby == null) {
      return _buildNoBabyState(context);
    }

    // 3. 정상 UI
    return RefreshIndicator(
      onRefresh: _loadAnalysis,
      color: AppTheme.lavenderMist,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎉 하이라이트 카드
            if (_highlightMessage != null) _buildHighlightCard(),

            const SizedBox(height: 24),

            // 📅 조산아 교정 나이 카드
            if (_baby != null && _baby!.isPremature && _baby!.dueDate != null)
              CorrectedAgeCard(baby: _baby!),

            if (_baby != null && _baby!.isPremature && _baby!.dueDate != null)
              const SizedBox(height: 16),

            // 💗 저체중아 특별 케어 카드
            if (_birthWeight != null && _birthWeight! < 2.5)
              _buildLowBirthWeightCare(),

            if (_birthWeight != null && _birthWeight! < 2.5)
              const SizedBox(height: 16),

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

            // 😴 수면 히트맵 - 7일 또는 30일
            _buildSleepHeatmapSection(l10n),

            const SizedBox(height: 24),

            // 📈 WHO 성장 곡선 (교정 나이 사용)
            if (_baby != null && _currentWeight != null && _baby!.gender != null)
              WHOGrowthChart(
                currentWeight: _currentWeight!,
                ageInMonths: _baby!.ageInMonths,
                isBoy: _baby!.gender == 'male',
                babyName: _baby!.name,
              ),

            const SizedBox(height: 24),

            // 📊 성장 곡선 차트 (fl_chart 버전)
            _buildGrowthCurveSection(l10n),

            const SizedBox(height: 24),

            // 📋 PDF 리포트 섹션
            _buildPdfReportSection(l10n),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  /// 🚫 Empty State: 아기 미등록 시 표시
  Widget _buildNoBabyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.lavenderMist.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.baby_changing_station_outlined,
                size: 64,
                color: AppTheme.lavenderMist.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 24),

            // 제목
            Text(
              l10n.translate('analysis_no_baby_title') ?? '등록된 아기가 없어요',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // 설명
            Text(
              l10n.translate('analysis_no_baby_subtitle') ??
                  '온보딩을 완료하면 아기의 분석 결과를 볼 수 있어요',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // CTA 버튼
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/onboarding');
              },
              icon: const Icon(Icons.add_circle_outline),
              label: Text(
                l10n.translate('start_onboarding') ?? '시작하기',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lavenderMist,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
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
