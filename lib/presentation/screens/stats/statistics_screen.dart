import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../core/localization/app_localizations.dart';

/// 통계 대시보드 화면
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _storage = LocalStorageService();
  bool _isWeekly = true; // true: 주간, false: 월간
  bool _isLoading = true;

  Map<DateTime, double> _sleepData = {};
  Map<DateTime, double> _feedingData = {};
  double _avgSleepHours = 0;
  String _lastDiaperTime = '-';
  int _todayFeedings = 0;
  int _todaySleeps = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    final activities = await _storage.getActivities();
    final now = DateTime.now();
    final daysToShow = _isWeekly ? 7 : 30;

    // 수면 데이터 계산
    _sleepData = {};
    for (int i = 0; i < daysToShow; i++) {
      final date = now.subtract(Duration(days: daysToShow - 1 - i));
      final dayActivities = activities.where((a) {
        final actDate = DateTime.parse(a.timestamp);
        return _isSameDay(actDate, date) && a.type == ActivityType.sleep;
      }).toList();

      double totalMinutes = 0;
      for (var activity in dayActivities) {
        if (activity.durationMinutes != null) {
          totalMinutes += activity.durationMinutes!;
        }
      }

      _sleepData[date] = totalMinutes / 60; // 시간 단위로 변환
    }

    // 수유 데이터 계산
    _feedingData = {};
    for (int i = 0; i < daysToShow; i++) {
      final date = now.subtract(Duration(days: daysToShow - 1 - i));
      final dayActivities = activities.where((a) {
        final actDate = DateTime.parse(a.timestamp);
        return _isSameDay(actDate, date) && a.type == ActivityType.feeding;
      }).toList();

      double totalMl = 0;
      for (var activity in dayActivities) {
        if (activity.amountMl != null) {
          totalMl += activity.amountMl!;
        }
      }

      _feedingData[date] = totalMl;
    }

    // 평균 수면 시간 계산
    final avgMinutes = _sleepData.values.isEmpty
        ? 0.0
        : _sleepData.values.reduce((a, b) => a + b) / _sleepData.values.length;
    _avgSleepHours = avgMinutes;

    // 마지막 배변 시간
    final diaperActivities = activities
        .where((a) => a.type == ActivityType.diaper)
        .toList()
      ..sort((a, b) =>
          DateTime.parse(b.timestamp).compareTo(DateTime.parse(a.timestamp)));

    if (diaperActivities.isNotEmpty) {
      final lastDiaper = DateTime.parse(diaperActivities.first.timestamp);
      final diff = now.difference(lastDiaper);
      if (diff.inHours > 0) {
        _lastDiaperTime = '${diff.inHours}h ago';
      } else {
        _lastDiaperTime = '${diff.inMinutes}m ago';
      }
    }

    // 오늘의 수유/수면 횟수
    _todayFeedings = activities
        .where((a) =>
            a.type == ActivityType.feeding && _isSameDay(DateTime.parse(a.timestamp), now))
        .length;

    _todaySleeps = activities
        .where((a) =>
            a.type == ActivityType.sleep && _isSameDay(DateTime.parse(a.timestamp), now))
        .length;

    setState(() => _isLoading = false);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('statistics')),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toggle Button
                    Center(
                      child: SegmentedButton<bool>(
                        segments: [
                          ButtonSegment(
                            value: true,
                            label: Text(l10n.translate('weekly')),
                            icon: Icon(Icons.calendar_view_week),
                          ),
                          ButtonSegment(
                            value: false,
                            label: Text(l10n.translate('monthly')),
                            icon: Icon(Icons.calendar_month),
                          ),
                        ],
                        selected: {_isWeekly},
                        onSelectionChanged: (Set<bool> newSelection) {
                          setState(() {
                            _isWeekly = newSelection.first;
                          });
                          _loadStatistics();
                        },
                      ),
                    ),

                    SizedBox(height: 24),

                    // 핵심 지표 카드
                    _buildKeyMetrics(),

                    SizedBox(height: 24),

                    // 수면 그래프
                    _buildSleepChart(),

                    SizedBox(height: 24),

                    // 수유 그래프
                    _buildFeedingChart(),

                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildKeyMetrics() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('key_metrics'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.bedtime,
                title: l10n.translate('avg_sleep'),
                value: '${_avgSleepHours.toStringAsFixed(1)}h',
                subtitle: l10n.translate('per_day'),
                color: Colors.purple,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.baby_changing_station,
                title: l10n.translate('last_diaper'),
                value: _lastDiaperTime,
                subtitle: l10n.translate('elapsed'),
                color: Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.restaurant,
                title: l10n.translate('today_feedings'),
                value: '$_todayFeedings',
                subtitle: l10n.translate('times'),
                color: Colors.orange,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.hotel,
                title: l10n.translate('today_sleeps'),
                value: '$_todaySleeps',
                subtitle: l10n.translate('times'),
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepChart() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bedtime, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  l10n.translate('daily_sleep_hours'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: _sleepData.isEmpty
                  ? Center(child: Text(l10n.translate('no_sleep_data')))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 16,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()}h',
                                    style: TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final dates = _sleepData.keys.toList();
                                if (value.toInt() >= dates.length) return Text('');
                                final date = dates[value.toInt()];
                                return Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    DateFormat('M/d').format(date),
                                    style: TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(show: true, drawVerticalLine: false),
                        borderData: FlBorderData(show: false),
                        barGroups: _sleepData.entries
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.value,
                                color: Colors.purple,
                                width: 16,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedingChart() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  l10n.translate('daily_feeding_amount'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: _feedingData.isEmpty
                  ? Center(child: Text(l10n.translate('no_feeding_data')))
                  : LineChart(
                      LineChartData(
                        maxY: _feedingData.values.isEmpty
                            ? 100
                            : _feedingData.values.reduce((a, b) => a > b ? a : b) * 1.2,
                        minY: 0,
                        lineTouchData: LineTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()}ml',
                                    style: TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final dates = _feedingData.keys.toList();
                                if (value.toInt() >= dates.length) return Text('');
                                final date = dates[value.toInt()];
                                return Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    DateFormat('M/d').format(date),
                                    style: TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(show: true, drawVerticalLine: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _feedingData.entries
                                .toList()
                                .asMap()
                                .entries
                                .map((entry) {
                              return FlSpot(
                                entry.key.toDouble(),
                                entry.value.value,
                              );
                            }).toList(),
                            isCurved: true,
                            color: Colors.orange,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.orange.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
