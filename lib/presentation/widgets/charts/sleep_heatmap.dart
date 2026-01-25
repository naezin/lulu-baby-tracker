import 'package:flutter/material.dart';
import '../../design_system/tokens/colors.dart';
import '../../design_system/tokens/spacing.dart';

/// 수면 데이터 포인트 (특정 날짜, 특정 시간대의 수면 시간)
class SleepDataPoint {
  final DateTime date;
  final int hour; // 0-23
  final int minutes; // 해당 시간대에 잔 분 (0-60)

  SleepDataPoint({
    required this.date,
    required this.hour,
    required this.minutes,
  });
}

/// 24시간 수면 히트맵
///
/// 7일 또는 30일 동안의 수면 패턴을 24시간 그리드로 시각화합니다.
/// - 행(row): 날짜 (최근 7일/30일)
/// - 열(column): 시간대 (0-23시)
/// - 색상: 수면 분 수에 따라 그라데이션
///
/// 디자인: Glassmorphism 카드 스타일
class SleepHeatmap extends StatefulWidget {
  final List<SleepDataPoint> sleepData;
  final Function(DateTime date, int hour)? onCellTap;
  final double? height;

  const SleepHeatmap({
    Key? key,
    required this.sleepData,
    this.onCellTap,
    this.height,
  }) : super(key: key);

  @override
  State<SleepHeatmap> createState() => _SleepHeatmapState();
}

class _SleepHeatmapState extends State<SleepHeatmap> {
  int _selectedDays = 7; // 7일 또는 30일

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      margin: EdgeInsets.all(LuluSpacing.md),
      padding: EdgeInsets.all(LuluSpacing.lg),
      decoration: BoxDecoration(
        // Glassmorphism effect
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1B3D).withOpacity(0.7), // Midnight Blue
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
          _buildDayToggle(),
          SizedBox(height: LuluSpacing.lg),
          Expanded(
            child: _buildHeatmapGrid(),
          ),
          SizedBox(height: LuluSpacing.lg),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '수면 패턴 히트맵',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: LuluSpacing.xs),
        Text(
          '24시간 수면 분포',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDayToggle() {
    return Row(
      children: [
        _buildToggleButton(
          label: '7일',
          isSelected: _selectedDays == 7,
          onTap: () {
            setState(() {
              _selectedDays = 7;
            });
          },
        ),
        SizedBox(width: LuluSpacing.sm),
        _buildToggleButton(
          label: '30일',
          isSelected: _selectedDays == 30,
          onTap: () {
            setState(() {
              _selectedDays = 30;
            });
          },
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: LuluSpacing.md,
          vertical: LuluSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? LuluActivityColors.sleep.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(LuluSpacing.borderRadiusSm),
          border: Border.all(
            color: isSelected
                ? LuluActivityColors.sleep.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? LuluActivityColors.sleep
                : Colors.white.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildHeatmapGrid() {
    final heatmapData = _prepareHeatmapData();
    final dates = heatmapData.keys.toList()..sort();

    if (dates.isEmpty) {
      return Center(
        child: Text(
          '수면 데이터가 없습니다',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // 시간 헤더 (0-23시)
          _buildHourHeader(),
          SizedBox(height: LuluSpacing.sm),
          // 히트맵 그리드
          ...dates.map((date) => _buildHeatmapRow(date, heatmapData[date]!)),
        ],
      ),
    );
  }

  Widget _buildHourHeader() {
    return Row(
      children: [
        // 날짜 레이블 공간
        SizedBox(width: 60),
        // 시간 레이블 (0, 6, 12, 18)
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHourLabel('0'),
              _buildHourLabel('6'),
              _buildHourLabel('12'),
              _buildHourLabel('18'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHourLabel(String hour) {
    return Text(
      hour,
      style: TextStyle(
        fontSize: 11,
        color: Colors.white.withOpacity(0.5),
      ),
    );
  }

  Widget _buildHeatmapRow(DateTime date, Map<int, int> hourlyData) {
    return Padding(
      padding: EdgeInsets.only(bottom: LuluSpacing.xs),
      child: Row(
        children: [
          // 날짜 레이블
          SizedBox(
            width: 60,
            child: Text(
              '${date.month}/${date.day}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          // 24시간 셀
          Expanded(
            child: Row(
              children: List.generate(24, (hour) {
                final minutes = hourlyData[hour] ?? 0;
                return Expanded(
                  child: _buildHeatmapCell(date, hour, minutes),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapCell(DateTime date, int hour, int minutes) {
    final color = _getSleepColor(minutes);

    return GestureDetector(
      onTap: () {
        if (widget.onCellTap != null && minutes > 0) {
          widget.onCellTap!(date, hour);
        }
      },
      child: Container(
        height: 20,
        margin: EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '수면 분 수',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: LuluSpacing.sm),
        Wrap(
          spacing: LuluSpacing.sm,
          runSpacing: LuluSpacing.xs,
          children: [
            _buildLegendItem(0, '0분'),
            _buildLegendItem(15, '15분'),
            _buildLegendItem(30, '30분'),
            _buildLegendItem(45, '45분'),
            _buildLegendItem(60, '60분'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(int minutes, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: _getSleepColor(minutes),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 0.5,
            ),
          ),
        ),
        SizedBox(width: LuluSpacing.xs),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  // ==================== Data Processing ====================

  /// 수면 데이터를 히트맵 형식으로 변환
  /// Map<날짜, Map<시간, 분>>
  Map<DateTime, Map<int, int>> _prepareHeatmapData() {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: _selectedDays - 1));

    // 날짜를 정규화 (시간, 분, 초 제거)
    DateTime normalizeDate(DateTime date) {
      return DateTime(date.year, date.month, date.day);
    }

    // 결과 맵 초기화
    final Map<DateTime, Map<int, int>> heatmapData = {};

    // _selectedDays 일 동안의 날짜 생성
    for (int i = 0; i < _selectedDays; i++) {
      final date = normalizeDate(startDate.add(Duration(days: i)));
      heatmapData[date] = {};

      // 각 시간대 초기화 (0-23시)
      for (int hour = 0; hour < 24; hour++) {
        heatmapData[date]![hour] = 0;
      }
    }

    // 수면 데이터를 히트맵에 채우기
    for (final dataPoint in widget.sleepData) {
      final normalizedDate = normalizeDate(dataPoint.date);

      // 선택한 기간 내의 데이터만 포함
      if (heatmapData.containsKey(normalizedDate)) {
        if (dataPoint.hour >= 0 && dataPoint.hour < 24) {
          heatmapData[normalizedDate]![dataPoint.hour] = dataPoint.minutes;
        }
      }
    }

    return heatmapData;
  }

  /// 수면 분 수에 따른 색상 반환 (그라데이션)
  Color _getSleepColor(int minutes) {
    if (minutes == 0) {
      return Colors.white.withOpacity(0.05); // 수면 없음
    }

    // 수면 색상 그라데이션 (연보라 -> 진보라)
    final baseColor = LuluActivityColors.sleep; // #8B5CF6

    // 0-60분 범위를 0-1로 정규화
    final intensity = (minutes / 60.0).clamp(0.0, 1.0);

    // 투명도와 채도를 조절하여 그라데이션 효과
    return Color.lerp(
      baseColor.withOpacity(0.2),
      baseColor.withOpacity(0.9),
      intensity,
    )!;
  }
}
