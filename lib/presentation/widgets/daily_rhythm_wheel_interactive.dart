import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/activity_model.dart';
import '../../data/models/ai_insight_model.dart';
import '../../data/services/ai_coaching_service.dart';
import 'ai_insight_bottom_sheet.dart';

/// 인터랙티브 Daily Rhythm Wheel (클릭 가능)
class DailyRhythmWheelInteractive extends StatefulWidget {
  final DateTime date;
  final String babyId;
  final int babyAgeInDays;
  final List<ActivityModel> activities;

  const DailyRhythmWheelInteractive({
    Key? key,
    required this.date,
    required this.babyId,
    required this.babyAgeInDays,
    required this.activities,
  }) : super(key: key);

  @override
  State<DailyRhythmWheelInteractive> createState() =>
      _DailyRhythmWheelInteractiveState();
}

class _DailyRhythmWheelInteractiveState
    extends State<DailyRhythmWheelInteractive> {
  bool _isAnalyzing = false;
  ActivityModel? _selectedActivity;

  @override
  Widget build(BuildContext context) {
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
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('EEEE, MMM d').format(widget.date),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.lavenderMist.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.psychology_outlined,
                      size: 16,
                      color: AppTheme.lavenderMist,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'AI 분석 가능',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lavenderMist,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Interactive Chart
          AspectRatio(
            aspectRatio: 1,
            child: GestureDetector(
              onTapDown: (details) => _handleTap(details, context),
              child: Stack(
                children: [
                  CustomPaint(
                    painter: _DailyRhythmPainter(
                      activities: _convertToSegments(),
                      selectedActivity: _selectedActivity,
                    ),
                    size: Size.infinite,
                  ),
                  if (_isAnalyzing)
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text(
                              'AI 분석 중...',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),
          _buildLegend(),
          SizedBox(height: 16),
          _buildLongestStretch(),
          SizedBox(height: 12),
          _buildHintText(),
        ],
      ),
    );
  }

  /// 탭 이벤트 처리
  void _handleTap(TapDownDetails details, BuildContext context) async {
    // 로딩 중이면 무시
    if (_isAnalyzing) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final center = Offset(size.width / 2, size.height / 2);
    final tapPosition = details.localPosition;

    // 중심에서의 거리와 각도 계산
    final dx = tapPosition.dx - center.dx;
    final dy = tapPosition.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final radius = size.width / 2 - 20;

    // 링 영역 내부인지 확인
    if (distance < radius - 50 || distance > radius + 20) {
      return; // 링 외부 클릭은 무시
    }

    // 각도 계산 (12시 방향을 0도로)
    var angle = math.atan2(dy, dx) + math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;

    // 시간 계산
    final hour = (angle / (2 * math.pi)) * 24;

    // 해당 시간의 활동 찾기
    final clickedActivity = widget.activities.firstWhere(
      (activity) {
        final startTime = DateTime.parse(activity.timestamp);
        final endTime = activity.endTime != null
            ? DateTime.parse(activity.endTime!)
            : startTime.add(Duration(minutes: 30));

        final startHour = startTime.hour + startTime.minute / 60;
        final endHour = endTime.hour + endTime.minute / 60;

        return hour >= startHour && hour <= endHour;
      },
      orElse: () => widget.activities.first, // 기본값
    );

    // 선택된 활동 업데이트
    setState(() {
      _selectedActivity = clickedActivity;
    });

    // AI 분석 시작
    await _analyzeActivity(context, clickedActivity);
  }

  /// AI 분석 실행
  Future<void> _analyzeActivity(
    BuildContext context,
    ActivityModel activity,
  ) async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      final coachingService = Provider.of<AICoachingService>(context, listen: false);

      final insight = await coachingService.analyzeEventContext(
        babyId: widget.babyId,
        clickedEvent: activity,
        babyAgeInDays: widget.babyAgeInDays,
      );

      setState(() {
        _isAnalyzing = false;
        _selectedActivity = null;
      });

      // 인사이트 바텀시트 표시
      if (mounted) {
        await AIInsightBottomSheet.show(
          context: context,
          insight: insight,
          babyId: widget.babyId,
          onExportPDF: () => _exportPDF(context, insight),
        );
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _selectedActivity = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('분석 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// PDF 내보내기
  void _exportPDF(BuildContext context, AIInsightModel insight) {
    // PDF export feature - to be implemented
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF 내보내기 기능은 곧 추가될 예정입니다'),
      ),
    );
  }

  /// 활동을 세그먼트로 변환
  List<_ActivitySegment> _convertToSegments() {
    return widget.activities.map((activity) {
      final startTime = DateTime.parse(activity.timestamp);
      final endTime = activity.endTime != null
          ? DateTime.parse(activity.endTime!)
          : startTime.add(Duration(minutes: 30));

      final startHour = startTime.hour + startTime.minute / 60;
      final endHour = endTime.hour + endTime.minute / 60;

      Color color;
      switch (activity.type) {
        case ActivityType.sleep:
          color = AppTheme.infoSoft;
          break;
        case ActivityType.feeding:
          color = AppTheme.warningSoft;
          break;
        case ActivityType.play:
          color = AppTheme.successSoft;
          break;
        case ActivityType.health:
          color = AppTheme.lavenderGlow;
          break;
        default:
          color = Colors.grey;
      }

      return _ActivitySegment(
        startHour: startHour,
        endHour: endHour,
        color: color,
        activity: activity,
      );
    }).toList();
  }

  Widget _buildLegend() {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem(l10n.translate('sleep'), AppTheme.infoSoft),
        _buildLegendItem(l10n.translate('feed'), AppTheme.warningSoft),
        _buildLegendItem(l10n.translate('play'), AppTheme.successSoft),
        _buildLegendItem(l10n.translate('health'), AppTheme.lavenderGlow),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLongestStretch() {
    final l10n = AppLocalizations.of(context)!;
    final sleeps = widget.activities
        .where((a) => a.type == ActivityType.sleep && a.durationMinutes != null)
        .toList();

    if (sleeps.isEmpty) {
      return SizedBox.shrink();
    }

    final longest = sleeps.reduce((a, b) =>
        (a.durationMinutes ?? 0) > (b.durationMinutes ?? 0) ? a : b);

    final startTime = DateTime.parse(longest.timestamp);
    final endTime = longest.endTime != null
        ? DateTime.parse(longest.endTime!)
        : startTime;

    final hours = (longest.durationMinutes ?? 0) / 60;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.successSoft.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.successSoft.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star,
            color: AppTheme.successSoft,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate('longest_sleep_stretch'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.successSoft,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '${hours.toStringAsFixed(1)} hours (${DateFormat('h:mm a').format(startTime)} - ${DateFormat('h:mm a').format(endTime)})',
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

  Widget _buildHintText() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.touch_app,
          size: 14,
          color: Colors.grey[500],
        ),
        SizedBox(width: 6),
        Flexible(
          child: Text(
            l10n.tapChartForAnalysis,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _ActivitySegment {
  final double startHour;
  final double endHour;
  final Color color;
  final ActivityModel activity;

  _ActivitySegment({
    required this.startHour,
    required this.endHour,
    required this.color,
    required this.activity,
  });
}

class _DailyRhythmPainter extends CustomPainter {
  final List<_ActivitySegment> activities;
  final ActivityModel? selectedActivity;

  _DailyRhythmPainter({
    required this.activities,
    this.selectedActivity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Draw background circle
    final bgPaint = Paint()
      ..color = Colors.grey[100]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40;

    canvas.drawCircle(center, radius, bgPaint);

    // Draw hour markers
    _drawHourMarkers(canvas, center, radius);

    // Draw activities
    for (final activity in activities) {
      _drawActivity(canvas, center, radius, activity);
    }

    // Highlight selected activity
    if (selectedActivity != null) {
      final selectedSegment = activities.firstWhere(
        (seg) => seg.activity.id == selectedActivity!.id,
        orElse: () => activities.first,
      );
      _drawSelectedActivity(canvas, center, radius, selectedSegment);
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius - 50, centerPaint);

    // Draw clock icon in center
    final textPainter = TextPainter(
      text: TextSpan(
        text: '24h',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawHourMarkers(Canvas canvas, Offset center, double radius) {
    final markerPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;

    for (int hour = 0; hour < 24; hour += 3) {
      final angle = (hour / 24) * 2 * math.pi - math.pi / 2;
      final x = center.dx + (radius + 10) * math.cos(angle);
      final y = center.dy + (radius + 10) * math.sin(angle);

      // Draw hour text
      final textPainter = TextPainter(
        text: TextSpan(
          text: hour == 0 ? '12' : hour.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  void _drawActivity(
    Canvas canvas,
    Offset center,
    double radius,
    _ActivitySegment activity,
  ) {
    final startAngle = (activity.startHour / 24) * 2 * math.pi - math.pi / 2;
    final sweepAngle =
        ((activity.endHour - activity.startHour) / 24) * 2 * math.pi;

    final paint = Paint()
      ..color = activity.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  void _drawSelectedActivity(
    Canvas canvas,
    Offset center,
    double radius,
    _ActivitySegment activity,
  ) {
    final startAngle = (activity.startHour / 24) * 2 * math.pi - math.pi / 2;
    final sweepAngle =
        ((activity.endHour - activity.startHour) / 24) * 2 * math.pi;

    // Draw highlight
    final highlightPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 46
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      highlightPaint,
    );

    // Draw selection border
    final borderPaint = Paint()
      ..color = activity.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 44
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(_DailyRhythmPainter oldDelegate) {
    return oldDelegate.selectedActivity != selectedActivity;
  }
}
