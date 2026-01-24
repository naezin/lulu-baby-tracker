import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';

class DailyRhythmWheel extends StatelessWidget {
  final DateTime date;

  const DailyRhythmWheel({
    Key? key,
    required this.date,
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
        children: [
          Text(
            DateFormat('EEEE, MMM d').format(date),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: _DailyRhythmPainter(
                activities: _getDemoActivities(),
              ),
            ),
          ),
          SizedBox(height: 24),
          _buildLegend(l10n),
          SizedBox(height: 16),
          _buildLongestStretch(l10n),
        ],
      ),
    );
  }

  Widget _buildLegend(AppLocalizations l10n) {
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

  Widget _buildLongestStretch(AppLocalizations l10n) {
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
                  '5.5 hours (10:00 PM - 3:30 AM)',
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

  List<_ActivitySegment> _getDemoActivities() {
    // Demo data - in production, fetch from Firebase
    return [
      _ActivitySegment(0, 2, AppTheme.infoSoft), // 12am-2am Sleep
      _ActivitySegment(2, 2.5, AppTheme.warningSoft), // 2am-2:30am Feed
      _ActivitySegment(2.5, 7, AppTheme.infoSoft), // 2:30am-7am Sleep
      _ActivitySegment(7, 7.5, AppTheme.warningSoft), // 7am-7:30am Feed
      _ActivitySegment(7.5, 9, AppTheme.successSoft), // 7:30am-9am Play
      _ActivitySegment(9, 11, AppTheme.infoSoft), // 9am-11am Sleep
      _ActivitySegment(11, 11.5, AppTheme.warningSoft), // 11am Feed
      _ActivitySegment(11.5, 13, AppTheme.successSoft), // Play
      _ActivitySegment(13, 15, AppTheme.infoSoft), // 1pm-3pm Sleep
      _ActivitySegment(15, 15.5, AppTheme.warningSoft), // 3pm Feed
      _ActivitySegment(15.5, 17, AppTheme.successSoft), // Play
      _ActivitySegment(17, 18.5, AppTheme.infoSoft), // 5pm-6:30pm Sleep
      _ActivitySegment(18.5, 19, AppTheme.warningSoft), // Feed
      _ActivitySegment(19, 20, AppTheme.successSoft), // Play
      _ActivitySegment(20, 20.5, AppTheme.warningSoft), // Feed
      _ActivitySegment(20.5, 24, AppTheme.infoSoft), // 8:30pm-12am Sleep
    ];
  }
}

class _ActivitySegment {
  final double startHour;
  final double endHour;
  final Color color;

  _ActivitySegment(this.startHour, this.endHour, this.color);
}

class _DailyRhythmPainter extends CustomPainter {
  final List<_ActivitySegment> activities;

  _DailyRhythmPainter({required this.activities});

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

  @override
  bool shouldRepaint(_DailyRhythmPainter oldDelegate) {
    return true;
  }
}
