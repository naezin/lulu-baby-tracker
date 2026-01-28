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

/// 성장 차트 기간 선택
enum GrowthPeriod {
  threeMonths,  // 최근 3개월
  sixMonths,    // 최근 6개월
  oneYear,      // 최근 1년
  twoYears,     // 최근 2년
  all,          // 전체
}

extension GrowthPeriodExtension on GrowthPeriod {
  String displayName(bool isKorean) {
    switch (this) {
      case GrowthPeriod.threeMonths:
        return isKorean ? '3개월' : '3 Months';
      case GrowthPeriod.sixMonths:
        return isKorean ? '6개월' : '6 Months';
      case GrowthPeriod.oneYear:
        return isKorean ? '1년' : '1 Year';
      case GrowthPeriod.twoYears:
        return isKorean ? '2년' : '2 Years';
      case GrowthPeriod.all:
        return isKorean ? '전체' : 'All';
    }
  }

  int get monthsRange {
    switch (this) {
      case GrowthPeriod.threeMonths:
        return 3;
      case GrowthPeriod.sixMonths:
        return 6;
      case GrowthPeriod.oneYear:
        return 12;
      case GrowthPeriod.twoYears:
        return 24;
      case GrowthPeriod.all:
        return 999; // 모든 데이터
    }
  }
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
  final bool isKorean;
  final GrowthPeriod selectedPeriod;
  final Function(GrowthPeriod)? onPeriodChanged;

  const GrowthCurveChart({
    Key? key,
    required this.babyData,
    required this.metric,
    required this.gender,
    required this.title,
    required this.unit,
    this.height,
    this.isKorean = true,
    this.selectedPeriod = GrowthPeriod.all,
    this.onPeriodChanged,
  }) : super(key: key);

  @override
  State<GrowthCurveChart> createState() => _GrowthCurveChartState();
}

class _GrowthCurveChartState extends State<GrowthCurveChart> {
  int? _touchedIndex;

  /// 기간에 따라 필터링된 아기 데이터
  List<GrowthDataPoint> get _filteredBabyData {
    if (widget.selectedPeriod == GrowthPeriod.all) {
      return widget.babyData;
    }

    final now = DateTime.now();
    final cutoffDate = DateTime(
      now.year,
      now.month - widget.selectedPeriod.monthsRange,
      now.day,
    );

    return widget.babyData
        .where((dataPoint) => dataPoint.dateTime.isAfter(cutoffDate))
        .toList();
  }

  /// 차트 X축 범위 (월령)
  double get _maxX {
    if (widget.babyData.isEmpty) return 24;

    final latestAge = widget.babyData
        .map((d) => d.ageInMonths)
        .reduce((a, b) => a > b ? a : b);

    switch (widget.selectedPeriod) {
      case GrowthPeriod.threeMonths:
        return (latestAge + 1).toDouble();
      case GrowthPeriod.sixMonths:
        return (latestAge + 1).toDouble();
      case GrowthPeriod.oneYear:
        return (latestAge + 1).toDouble();
      case GrowthPeriod.twoYears:
        return 24;
      case GrowthPeriod.all:
        return (latestAge + 3).toDouble().clamp(12, 24);
    }
  }

  double get _minX {
    if (_filteredBabyData.isEmpty) return 0;

    final oldestAge = _filteredBabyData
        .map((d) => d.ageInMonths)
        .reduce((a, b) => a < b ? a : b);

    return (oldestAge - 1).toDouble().clamp(0, double.infinity);
  }

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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
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
                    widget.isKorean ? 'WHO 표준 성장 곡선' : 'WHO Growth Standards',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (widget.onPeriodChanged != null) ...[
          SizedBox(height: LuluSpacing.md),
          _buildPeriodSelector(),
        ],
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: GrowthPeriod.values.map((period) {
        final isSelected = period == widget.selectedPeriod;
        return GestureDetector(
          onTap: () => widget.onPeriodChanged?.call(period),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? Color(0xFF9D8CD6).withOpacity(0.3)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Color(0xFF9D8CD6)
                    : Colors.white.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              period.displayName(widget.isKorean),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Color(0xFF9D8CD6)
                    : Colors.white.withOpacity(0.8),
              ),
            ),
          ),
        );
      }).toList(),
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
        minX: _minX,
        maxX: _maxX,
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
              final dataPoint = _filteredBabyData[touchedSpot.spotIndex];
              final service = GrowthPercentileService();
              final percentile = service.calculatePercentile(
                ageInMonths: dataPoint.ageInMonths,
                value: dataPoint.value,
                metric: widget.metric,
                gender: widget.gender,
              );

              final monthsText = widget.isKorean ? '개월' : ' mo';
              final percentileText = widget.isKorean ? '백분위' : 'th %ile';

              return LineTooltipItem(
                '${dataPoint.ageInMonths}$monthsText\n'
                '${dataPoint.value.toStringAsFixed(1)}${widget.unit}\n'
                '${percentile != null ? "${percentile.toStringAsFixed(1)}$percentileText" : ""}',
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
    final spots = _filteredBabyData.map((dataPoint) {
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
