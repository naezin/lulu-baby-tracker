import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/constants/who_growth_data.dart';
import '../../../data/services/growth_percentile_service.dart';
import '../../design_system/tokens/colors.dart';
import '../../design_system/tokens/spacing.dart';

/// 성장 데이터 포인트
class GrowthDataPoint {
  final int ageInMonths;
  final double value;
  final DateTime dateTime;

  GrowthDataPoint({
    required this.ageInMonths,
    required this.value,
    required this.dateTime,
  });
}

/// WHO 성장 곡선 차트
///
/// WHO 표준 백분위수 곡선(p3, p15, p50, p85, p97)과
/// 아기의 실제 성장 데이터를 함께 표시합니다.
///
/// 디자인: Glassmorphism 카드 스타일
/// - Midnight Blue 배경
/// - Champagne Gold (#D4AF6A) - 아기 데이터 라인
/// - Lavender Mist (#9D8CD6) - p50 기준선
class GrowthCurveChart extends StatefulWidget {
  final List<GrowthDataPoint> babyData;
  final GrowthMetric metric;
  final Gender gender;
  final String title;
  final String unit;
  final double? height;

  const GrowthCurveChart({
    Key? key,
    required this.babyData,
    required this.metric,
    required this.gender,
    required this.title,
    required this.unit,
    this.height,
  }) : super(key: key);

  @override
  State<GrowthCurveChart> createState() => _GrowthCurveChartState();
}

class _GrowthCurveChartState extends State<GrowthCurveChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 400,
      margin: EdgeInsets.all(LuluSpacing.md),
      padding: EdgeInsets.all(LuluSpacing.lg),
      decoration: BoxDecoration(
        // Glassmorphism effect
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1B3D).withOpacity(0.7),  // Midnight Blue
            Color(0xFF0F1029).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(LuluSpacing.borderRadiusLg),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: LuluSpacing.md),
          _buildLegend(),
          SizedBox(height: LuluSpacing.lg),
          Expanded(
            child: _buildChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: LuluSpacing.xs),
        Text(
          'WHO 표준 성장 곡선',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: LuluSpacing.md,
      runSpacing: LuluSpacing.sm,
      children: [
        _buildLegendItem(
          color: Color(0xFFD4AF6A), // Champagne Gold
          label: '아기 성장 데이터',
          isBold: true,
        ),
        _buildLegendItem(
          color: Color(0xFF9D8CD6), // Lavender Mist
          label: 'p50 (중앙값)',
        ),
        _buildLegendItem(
          color: Colors.white.withOpacity(0.3),
          label: 'p3, p15, p85, p97',
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    bool isBold = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: LuluSpacing.xs),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    final standardData = _getStandardData();
    if (standardData.isEmpty) {
      return Center(
        child: Text(
          '성장 데이터를 불러올 수 없습니다',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
      );
    }

    return LineChart(
      LineChartData(
        lineTouchData: _buildTouchData(),
        gridData: _buildGridData(),
        titlesData: _buildTitlesData(),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        minX: 0,
        maxX: 24,
        minY: _calculateMinY(standardData),
        maxY: _calculateMaxY(standardData),
        lineBarsData: [
          ..._buildPercentileLines(standardData),
          _buildBabyDataLine(),
        ],
      ),
    );
  }

  LineTouchData _buildTouchData() {
    return LineTouchData(
      enabled: true,
      touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
        setState(() {
          if (touchResponse == null || touchResponse.lineBarSpots == null) {
            _touchedIndex = null;
            return;
          }
          _touchedIndex = touchResponse.lineBarSpots!.first.spotIndex;
        });
      },
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (LineBarSpot spot) => Color(0xFF1A1B3D),
        tooltipRoundedRadius: 8,
        getTooltipItems: (List<LineBarSpot> touchedSpots) {
          return touchedSpots.map((LineBarSpot touchedSpot) {
            if (touchedSpot.barIndex == 5) { // 아기 데이터 라인
              final dataPoint = widget.babyData[touchedSpot.spotIndex];
              final service = GrowthPercentileService();
              final percentile = service.calculatePercentile(
                ageInMonths: dataPoint.ageInMonths,
                value: dataPoint.value,
                metric: widget.metric,
                gender: widget.gender,
              );

              return LineTooltipItem(
                '${dataPoint.ageInMonths}개월\n'
                '${dataPoint.value.toStringAsFixed(1)}${widget.unit}\n'
                '${percentile != null ? "${percentile.toStringAsFixed(1)}백분위" : ""}',
                TextStyle(
                  color: Color(0xFFD4AF6A),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }
            return null;
          }).toList();
        },
      ),
    );
  }

  FlGridData _buildGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: true,
      horizontalInterval: 1,
      verticalInterval: 3,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.white.withOpacity(0.05),
          strokeWidth: 1,
        );
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: Colors.white.withOpacity(0.05),
          strokeWidth: 1,
        );
      },
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      show: true,
      rightTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: AxisTitles(
        axisNameWidget: Text(
          '월령 (개월)',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 3,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 11,
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        axisNameWidget: Text(
          widget.unit,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toStringAsFixed(0),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
              ),
            );
          },
        ),
      ),
    );
  }

  List<LineChartBarData> _buildPercentileLines(
    Map<int, Map<String, double>> standardData,
  ) {
    final percentileKeys = ['p3', 'p15', 'p50', 'p85', 'p97'];
    final percentileColors = {
      'p3': Colors.white.withOpacity(0.3),
      'p15': Colors.white.withOpacity(0.3),
      'p50': Color(0xFF9D8CD6), // Lavender Mist for p50
      'p85': Colors.white.withOpacity(0.3),
      'p97': Colors.white.withOpacity(0.3),
    };
    final percentileWidths = {
      'p3': 1.5,
      'p15': 1.5,
      'p50': 2.5, // Thicker for p50
      'p85': 1.5,
      'p97': 1.5,
    };

    return percentileKeys.map((key) {
      final spots = standardData.entries.map((entry) {
        return FlSpot(
          entry.key.toDouble(),
          entry.value[key]!,
        );
      }).toList();

      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: percentileColors[key],
        barWidth: percentileWidths[key]!,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      );
    }).toList();
  }

  LineChartBarData _buildBabyDataLine() {
    final spots = widget.babyData.map((dataPoint) {
      return FlSpot(
        dataPoint.ageInMonths.toDouble(),
        dataPoint.value,
      );
    }).toList();

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: Color(0xFFD4AF6A), // Champagne Gold
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: _touchedIndex == index ? 6 : 4,
            color: Color(0xFFD4AF6A),
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFD4AF6A).withOpacity(0.3),
            Color(0xFFD4AF6A).withOpacity(0.0),
          ],
        ),
      ),
    );
  }

  Map<int, Map<String, double>> _getStandardData() {
    switch (widget.metric) {
      case GrowthMetric.weight:
        return widget.gender == Gender.male
            ? WHOGrowthData.weightForAgeBoys
            : WHOGrowthData.weightForAgeGirls;
      case GrowthMetric.length:
        return widget.gender == Gender.male
            ? WHOGrowthData.lengthForAgeBoys
            : WHOGrowthData.lengthForAgeGirls;
      case GrowthMetric.headCircumference:
        return widget.gender == Gender.male
            ? WHOGrowthData.headCircumferenceBoys
            : WHOGrowthData.headCircumferenceGirls;
    }
  }

  double _calculateMinY(Map<int, Map<String, double>> standardData) {
    if (standardData.isEmpty) return 0;
    final allValues = <double>[];

    // WHO 데이터의 p3 값들
    standardData.forEach((month, percentiles) {
      allValues.add(percentiles['p3']!);
    });

    // 아기 데이터 값들
    for (var dataPoint in widget.babyData) {
      allValues.add(dataPoint.value);
    }

    final minValue = allValues.reduce((a, b) => a < b ? a : b);
    return (minValue * 0.9).floorToDouble(); // 10% 여유 공간
  }

  double _calculateMaxY(Map<int, Map<String, double>> standardData) {
    if (standardData.isEmpty) return 100;
    final allValues = <double>[];

    // WHO 데이터의 p97 값들
    standardData.forEach((month, percentiles) {
      allValues.add(percentiles['p97']!);
    });

    // 아기 데이터 값들
    for (var dataPoint in widget.babyData) {
      allValues.add(dataPoint.value);
    }

    final maxValue = allValues.reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.1).ceilToDouble(); // 10% 여유 공간
  }
}
