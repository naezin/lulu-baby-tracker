import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';

class WeeklySleepChart extends StatelessWidget {
  final int weekOffset;

  const WeeklySleepChart({
    Key? key,
    this.weekOffset = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          _buildHeader(l10n),
          SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 1.5,
            child: BarChart(
              _createBarChartData(l10n),
            ),
          ),
          SizedBox(height: 20),
          _buildWeekComparisonCard(l10n),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.translate('sleep_trends'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              l10n.translate('last_7_days'),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left, size: 20),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.chevron_right, size: 20),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekComparisonCard(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.successSoft.withOpacity(0.1),
            AppTheme.successSoft.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.successSoft.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.successSoft.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.trending_up,
              color: AppTheme.successSoft,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate('great_progress'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successSoft,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  l10n.translate('baby_slept_more_this_week').replaceAll('{minutes}', '30'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BarChartData _createBarChartData(AppLocalizations l10n) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 16,
      minY: 0,
      groupsSpace: 12,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final day = _getDayLabel(group.x.toInt(), l10n);
            if (rodIndex == 0) {
              return BarTooltipItem(
                '$day\n${l10n.translate('hours_sleep').replaceAll('{hours}', rod.toY.toStringAsFixed(1))}',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            } else {
              return BarTooltipItem(
                l10n.translate('wake_ups_count').replaceAll('{count}', rod.toY.toInt().toString()),
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  _getDayLabel(value.toInt(), l10n),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              if (value % 4 == 0) {
                return Text(
                  '${value.toInt()}h',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                );
              }
              return SizedBox();
            },
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              if (value % 2 == 0 && value <= 6) {
                return Text(
                  '${value.toInt()}x',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                );
              }
              return SizedBox();
            },
          ),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[200]!,
            strokeWidth: 1,
          );
        },
      ),
      borderData: FlBorderData(show: false),
      barGroups: _createBarGroups(),
    );
  }

  List<BarChartGroupData> _createBarGroups() {
    // Demo data - total sleep hours and night wake-ups
    final weekData = [
      (13.5, 4), // Mon
      (14.0, 3), // Tue
      (13.8, 5), // Wed
      (14.5, 2), // Thu
      (14.2, 3), // Fri
      (14.8, 2), // Sat
      (15.0, 2), // Sun
    ];

    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          // Sleep hours bar
          BarChartRodData(
            toY: weekData[index].$1,
            color: AppTheme.infoSoft,
            width: 16,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(4),
            ),
          ),
          // Wake-ups bar (scaled to fit chart)
          BarChartRodData(
            toY: weekData[index].$2.toDouble() * 2.5,
            color: AppTheme.warningSoft.withOpacity(0.6),
            width: 16,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  String _getDayLabel(int index, AppLocalizations l10n) {
    final days = [
      l10n.translate('mon'),
      l10n.translate('tue'),
      l10n.translate('wed'),
      l10n.translate('thu'),
      l10n.translate('fri'),
      l10n.translate('sat'),
      l10n.translate('sun'),
    ];
    return days[index];
  }
}
