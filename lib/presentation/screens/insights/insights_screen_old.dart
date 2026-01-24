import '../../../data/services/firestore_stub.dart';
import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/activity_model.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String _selectedPeriod = 'week'; // 'week', 'month'

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navInsights),
        actions: [
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'week', label: Text(l10n.translate('week'))),
              ButtonSegment(value: 'month', label: Text(l10n.translate('month'))),
            ],
            selected: {_selectedPeriod},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _selectedPeriod = newSelection.first;
              });
            },
          ),
          SizedBox(width: 16),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getActivitiesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(l10n.translate('error_message').replaceAll('{error}', snapshot.error.toString())));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(l10n);
          }

          final activities = snapshot.data!.docs
              .map((doc) => ActivityModel.fromJson({
                    'id': doc.id,
                    ...doc.data() as Map<String, dynamic>,
                  }))
              .toList();

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(activities, l10n),
                SizedBox(height: 24),
                _buildTemperatureChart(activities, l10n),
                SizedBox(height: 24),
                _buildSleepChart(activities, l10n),
                SizedBox(height: 24),
                _buildActivityBreakdown(activities, l10n),
              ],
            ),
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getActivitiesStream() {
    const userId = 'demo-user';
    final now = DateTime.now();
    final startDate = _selectedPeriod == 'week'
        ? now.subtract(Duration(days: 7))
        : now.subtract(Duration(days: 30));

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('activities')
        .where('timestamp', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insights_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            l10n.translate('empty_state_no_data_yet'),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            l10n.translate('empty_state_start_tracking_insights'),
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(List<ActivityModel> activities, AppLocalizations l10n) {
    final sleeps = activities.where((a) => a.type == ActivityType.sleep).toList();
    final feedings = activities.where((a) => a.type == ActivityType.feeding).toList();
    final diapers = activities.where((a) => a.type == ActivityType.diaper).toList();

    final totalSleepMinutes = sleeps.fold<int>(
      0,
      (sum, sleep) => sum + (sleep.durationMinutes ?? 0),
    );
    final avgSleepMinutes = sleeps.isEmpty ? 0 : totalSleepMinutes ~/ sleeps.length;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.bedtime,
            color: Colors.purple,
            title: l10n.translate('insights_card_title_avg_sleep'),
            value: '${avgSleepMinutes ~/ 60}h ${avgSleepMinutes % 60}m',
            subtitle: '${sleeps.length} records',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.restaurant,
            color: Colors.orange,
            title: l10n.translate('insights_card_title_feedings'),
            value: '${feedings.length}',
            subtitle: _selectedPeriod == 'week' ? 'this week' : 'this month',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.baby_changing_station,
            color: Colors.green,
            title: l10n.translate('insights_card_title_diapers'),
            value: '${diapers.length}',
            subtitle: _selectedPeriod == 'week' ? 'this week' : 'this month',
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepChart(List<ActivityModel> activities, AppLocalizations l10n) {
    final sleeps = activities.where((a) => a.type == ActivityType.sleep).toList();

    if (sleeps.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              l10n.translate('chart_no_sleep_data_available'),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    // Group by date
    final Map<String, int> sleepByDate = {};
    for (var sleep in sleeps) {
      final date = DateTime.parse(sleep.timestamp);
      final dateStr = DateFormat('MM/dd').format(date);
      sleepByDate[dateStr] = (sleepByDate[dateStr] ?? 0) + (sleep.durationMinutes ?? 0);
    }

    final spots = <FlSpot>[];
    final dates = sleepByDate.keys.toList();
    for (var i = 0; i < dates.length; i++) {
      final hours = sleepByDate[dates[i]]! / 60;
      spots.add(FlSpot(i.toDouble(), hours));
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.translate('chart_title_sleep_pattern'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
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
                          if (value.toInt() >= 0 && value.toInt() < dates.length) {
                            return Text(dates[value.toInt()],
                                style: TextStyle(fontSize: 10));
                          }
                          return Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.purple,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.purple.withOpacity(0.1),
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

  Widget _buildTemperatureChart(List<ActivityModel> activities, AppLocalizations l10n) {
    final temps = activities
        .where((a) => a.type == ActivityType.health && a.temperatureCelsius != null)
        .toList();

    if (temps.isEmpty) {
      return SizedBox.shrink();
    }

    // Group by date
    final Map<String, List<double>> tempsByDate = {};
    for (var temp in temps) {
      final date = DateTime.parse(temp.timestamp);
      final dateStr = DateFormat('MM/dd').format(date);
      if (!tempsByDate.containsKey(dateStr)) {
        tempsByDate[dateStr] = [];
      }
      tempsByDate[dateStr]!.add(temp.temperatureCelsius!);
    }

    // Calculate average per day
    final Map<String, double> avgTemps = {};
    tempsByDate.forEach((date, temps) {
      avgTemps[date] = temps.reduce((a, b) => a + b) / temps.length;
    });

    final spots = <FlSpot>[];
    final dates = avgTemps.keys.toList();
    for (var i = 0; i < dates.length; i++) {
      spots.add(FlSpot(i.toDouble(), avgTemps[dates[i]]!));
    }

    // Find fever readings
    final hasFever = avgTemps.values.any((temp) => temp >= 38.0);

    return Card(
      color: hasFever ? Colors.red[50] : null,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.thermostat, color: hasFever ? Colors.red : Colors.blue),
                SizedBox(width: 8),
                Text(
                  l10n.translate('chart_title_temperature_trend'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: hasFever ? Colors.red : null,
                  ),
                ),
              ],
            ),
            if (hasFever) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Text(
                      l10n.translate('alert_fever_detected_period'),
                      style: TextStyle(
                        color: Colors.red[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}°C',
                              style: TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < dates.length) {
                            return Text(dates[value.toInt()],
                                style: TextStyle(fontSize: 10));
                          }
                          return Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: 35,
                  maxY: 40,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: hasFever ? Colors.red : Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: (hasFever ? Colors.red : Colors.blue).withOpacity(0.1),
                      ),
                    ),
                  ],
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: 38.0,
                        color: Colors.red.withOpacity(0.5),
                        strokeWidth: 2,
                        dashArray: [5, 5],
                        label: HorizontalLineLabel(
                          show: true,
                          labelResolver: (line) => 'Fever (38°C)',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityBreakdown(List<ActivityModel> activities, AppLocalizations l10n) {
    final sleepCount = activities.where((a) => a.type == ActivityType.sleep).length;
    final feedingCount = activities.where((a) => a.type == ActivityType.feeding).length;
    final diaperCount = activities.where((a) => a.type == ActivityType.diaper).length;
    final total = sleepCount + feedingCount + diaperCount;

    if (total == 0) return SizedBox.shrink();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.translate('insights_section_activity_breakdown'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildBreakdownItem(
              icon: Icons.bedtime,
              color: Colors.purple,
              label: l10n.translate('pie_chart_label_sleep'),
              count: sleepCount,
              total: total,
            ),
            SizedBox(height: 12),
            _buildBreakdownItem(
              icon: Icons.restaurant,
              color: Colors.orange,
              label: l10n.translate('pie_chart_label_feeding'),
              count: feedingCount,
              total: total,
            ),
            SizedBox(height: 12),
            _buildBreakdownItem(
              icon: Icons.baby_changing_station,
              color: Colors.green,
              label: l10n.translate('pie_chart_label_diaper'),
              count: diaperCount,
              total: total,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem({
    required IconData icon,
    required Color color,
    required String label,
    required int count,
    required int total,
  }) {
    final percentage = (count / total * 100).toStringAsFixed(0);

    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('$count ($percentage%)',
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
              SizedBox(height: 4),
              LinearProgressIndicator(
                value: count / total,
                backgroundColor: Colors.grey[200],
                color: color,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
