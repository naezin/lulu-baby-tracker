import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/play_activity_model.dart';
import '../../widgets/daily_rhythm_wheel.dart';
import '../../widgets/weekly_sleep_chart.dart';
import '../../widgets/awake_time_tracker.dart';
import '../../widgets/activity_recommendations_card.dart';
import '../../widgets/analytics/weekly_insight_card.dart';
import '../../../data/services/weekly_insight_service.dart';
import '../activities/log_play_screen.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  DateTime _selectedDate = DateTime.now();
  int _selectedWeek = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.insights),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📊 NEW: Weekly Insights Section
            _buildWeeklyInsights(context),
            SizedBox(height: 16),

            // AI Sleep Insight Card
            _buildAIInsightCard(context),
            SizedBox(height: 16),

            // Awake Time Tracker
            AwakeTimeTracker(
              lastWakeUpTime: DateTime.now().subtract(Duration(minutes: 75)),
              ageInMonths: 2,
            ),
            SizedBox(height: 16),

            // Activity Recommendations
            ActivityRecommendationsCard(
              ageInDays: 72,
              onActivitySelected: (activityType) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LogPlayScreen(preselectedType: activityType),
                  ),
                );
              },
            ),
            SizedBox(height: 16),

            // Daily Rhythm Section
            _buildSectionHeader(context, l10n.translate('daily_rhythm_24h')),
            SizedBox(height: 16),
            DailyRhythmWheel(date: _selectedDate),
            SizedBox(height: 24),

            // Weekly Sleep Trends
            _buildSectionHeader(context, l10n.translate('weekly_sleep_trends')),
            SizedBox(height: 16),
            WeeklySleepChart(weekOffset: _selectedWeek),
            SizedBox(height: 24),

            // Eat-Play-Sleep Cycle Analysis
            _buildSectionHeader(context, l10n.translate('eat_play_sleep_cycle')),
            SizedBox(height: 16),
            _buildEatPlaySleepCard(context),
            SizedBox(height: 24),

            // Pattern Analysis
            _buildSectionHeader(context, l10n.translate('pattern_analysis')),
            SizedBox(height: 16),
            _buildPatternAnalysisCard(context),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildAIInsightCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lavenderMist.withOpacity(0.1),
            AppTheme.lavenderGlow.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.lavenderMist.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.lavenderMist.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lightbulb,
                  color: AppTheme.lavenderMist,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                l10n.translate('ai_sleep_insight'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.lavenderMist,
                    ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            l10n.translate('sleep_longer_this_week'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 12),
          Text(
            l10n.translate('nap_deepest_time'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.lavenderMist.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: AppTheme.lavenderMist,
                ),
                SizedBox(width: 6),
                Text(
                  l10n.translate('developmental_stage'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lavenderMist,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEatPlaySleepCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cycleScore = 78; // Demo score

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.translate('consistency_score'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getScoreColor(cycleScore).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$cycleScore/100',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(cycleScore),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: cycleScore / 100,
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(_getScoreColor(cycleScore)),
            ),
          ),
          SizedBox(height: 16),
          _buildCycleRow(
            icon: Icons.restaurant,
            label: l10n.translate('eat'),
            color: AppTheme.warningSoft,
            value: l10n.translate('times_per_day').replaceAll('{count}', '8'),
          ),
          SizedBox(height: 8),
          _buildCycleRow(
            icon: Icons.toys,
            label: l10n.translate('play'),
            color: AppTheme.successSoft,
            value: l10n.translate('avg_minutes').replaceAll('{minutes}', '45'),
          ),
          SizedBox(height: 8),
          _buildCycleRow(
            icon: Icons.bedtime,
            label: l10n.translate('sleep'),
            color: AppTheme.infoSoft,
            value: l10n.translate('hours_per_day').replaceAll('{hours}', '14.5'),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warningSoft.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.warningSoft.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppTheme.warningSoft,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.translate('feed_to_sleep_warning'),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.warningSoft.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleRow({
    required IconData icon,
    required String label,
    required Color color,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPatternAnalysisCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: AppTheme.lavenderMist,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                l10n.translate('your_baby_patterns'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildPatternItem(
            '🌙 ${l10n.translate('longest_sleep_stretch')}',
            '5.5 ${l10n.translate('hours')}',
            l10n.translate('usually_time_range')
                .replaceAll('{start}', '10 PM')
                .replaceAll('{end}', '3:30 AM'),
          ),
          Divider(height: 24),
          _buildPatternItem(
            '☀️ ${l10n.translate('morning_wake_time')}',
            '7:15 AM',
            l10n.translate('consistent_variance').replaceAll('{minutes}', '15'),
          ),
          Divider(height: 24),
          _buildPatternItem(
            '😴 ${l10n.translate('preferred_nap_time')}',
            '2-4 PM',
            l10n.translate('deepest_afternoon_nap'),
          ),
          Divider(height: 24),
          _buildPatternItem(
            '🍼 ${l10n.translate('feeding_interval')}',
            l10n.translate('every_hours').replaceAll('{hours}', '3.2'),
            l10n.translate('well_spaced'),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternItem(String title, String value, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppTheme.successSoft;
    if (score >= 60) return AppTheme.warningSoft;
    return AppTheme.errorSoft;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// 📊 주간 인사이트 섹션
  Widget _buildWeeklyInsights(BuildContext context) {
    final insightService = WeeklyInsightService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '이번 주 인사이트',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        FutureBuilder<List<WeeklyInsightData>>(
          future: insightService.getAllInsights(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '데이터를 기록하면 주간 인사이트를 볼 수 있어요',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return Column(
              children: snapshot.data!
                  .map((insight) => WeeklyInsightCard(
                        title: insight.title,
                        insight: insight.insight,
                        trend: insight.trend,
                        metrics: insight.metrics,
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
