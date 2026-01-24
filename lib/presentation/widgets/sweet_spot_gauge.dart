import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../../core/utils/sweet_spot_calculator.dart';
import '../providers/sweet_spot_provider.dart';
import '../../core/localization/app_localizations.dart';

/// Semi-circle gauge widget showing time until next sleep
class SweetSpotGauge extends StatelessWidget {
  const SweetSpotGauge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SweetSpotProvider>(
      builder: (context, provider, child) {
        final sweetSpot = provider.currentSweetSpot;

        if (sweetSpot == null) {
          return _buildEmptyState(context);
        }

        return _buildGaugeContent(context, sweetSpot);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.bedtime_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.translate('empty_state_track_sleep_sweet_spot'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.translate('empty_state_log_wake_up_hint'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGaugeContent(BuildContext context, SweetSpotResult sweetSpot) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final totalWindow = sweetSpot.sweetSpotEnd.difference(sweetSpot.lastWakeUpTime).inMinutes;
    final elapsed = now.difference(sweetSpot.lastWakeUpTime).inMinutes;
    final progress = (elapsed / totalWindow).clamp(0.0, 1.0);

    final urgency = sweetSpot.urgencyLevel;
    final colorScheme = _getColorScheme(urgency);

    // Calculate minutes remaining or elapsed
    int timeValue;
    String timeLabel;

    if (!sweetSpot.isActive) {
      // Before sweet spot
      timeValue = sweetSpot.minutesUntilSweetSpot;
      timeLabel = l10n.translate('sweet_spot_label_until');
    } else if (sweetSpot.minutesUntilSweetSpotEnd > 0) {
      // During sweet spot
      timeValue = sweetSpot.minutesUntilSweetSpotEnd;
      timeLabel = l10n.translate('sweet_spot_label_remaining');
    } else {
      // After sweet spot
      timeValue = sweetSpot.minutesSinceWakeUp;
      timeLabel = l10n.translate('sweet_spot_label_time_awake');
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.backgroundColor,
            colorScheme.backgroundColor.withOpacity(0.7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.accentColor.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                urgency.emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                urgency.displayName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Semi-circle gauge
          SizedBox(
            height: 140,
            child: CustomPaint(
              size: const Size(double.infinity, 140),
              painter: _SemiCircleGaugePainter(
                progress: progress,
                color: colorScheme.accentColor,
                urgency: urgency,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTime(timeValue),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.accentColor,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Time range display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      sweetSpot.getFormattedTimeRange(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  sweetSpot.userFriendlyMessage,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Quick stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickStat(
                context,
                icon: Icons.timer_outlined,
                value: sweetSpot.wakeWindowData.displayRange,
                label: l10n.translate('sweet_spot_stat_wake_window'),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.grey[300],
              ),
              _buildQuickStat(
                context,
                icon: Icons.child_care,
                value: '${sweetSpot.ageInMonths} mo',
                label: l10n.translate('sweet_spot_stat_baby_age'),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.grey[300],
              ),
              _buildQuickStat(
                context,
                icon: Icons.hotel,
                value: '${sweetSpot.napNumber ?? '-'}/${sweetSpot.wakeWindowData.recommendedNaps}',
                label: l10n.translate('sweet_spot_stat_nap_today'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatTime(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) {
        return '${hours}h';
      }
      return '${hours}h ${mins}m';
    }
  }

  _ColorScheme _getColorScheme(UrgencyLevel urgency) {
    switch (urgency) {
      case UrgencyLevel.tooEarly:
        return _ColorScheme(
          accentColor: const Color(0xFF2196F3), // Blue
          backgroundColor: const Color(0xFFE3F2FD),
        );
      case UrgencyLevel.approaching:
        return _ColorScheme(
          accentColor: const Color(0xFFFFA726), // Orange
          backgroundColor: const Color(0xFFFFF3E0),
        );
      case UrgencyLevel.optimal:
        return _ColorScheme(
          accentColor: const Color(0xFF66BB6A), // Green
          backgroundColor: const Color(0xFFE8F5E9),
        );
      case UrgencyLevel.overtired:
        return _ColorScheme(
          accentColor: const Color(0xFFEF5350), // Red
          backgroundColor: const Color(0xFFFFEBEE),
        );
    }
  }
}

/// Custom painter for semi-circle gauge
class _SemiCircleGaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final UrgencyLevel urgency;

  _SemiCircleGaugePainter({
    required this.progress,
    required this.color,
    required this.urgency,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.75);
    final radius = size.width * 0.38;
    const strokeWidth = 16.0;

    // Background arc (light gray)
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, // Start from left (180 degrees)
      math.pi, // Draw semicircle (180 degrees)
      false,
      backgroundPaint,
    );

    // Progress arc (colored)
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(0.7),
          color,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, // Start from left
      math.pi * progress, // Progress portion
      false,
      progressPaint,
    );

    // Draw tick marks for sweet spot zone (if optimal)
    if (urgency == UrgencyLevel.optimal) {
      _drawTickMarks(canvas, center, radius, strokeWidth);
    }

    // Draw indicator dot
    if (progress > 0 && progress < 1) {
      final angle = math.pi + (math.pi * progress);
      final indicatorX = center.dx + radius * math.cos(angle);
      final indicatorY = center.dy + radius * math.sin(angle);

      // Outer glow
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(
        Offset(indicatorX, indicatorY),
        12,
        glowPaint,
      );

      // Main dot
      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(indicatorX, indicatorY),
        8,
        dotPaint,
      );

      // Inner dot
      final innerDotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(indicatorX, indicatorY),
        5,
        innerDotPaint,
      );
    }
  }

  void _drawTickMarks(Canvas canvas, Offset center, double radius, double strokeWidth) {
    final tickPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw 3 small tick marks in the optimal zone
    for (int i = 0; i < 3; i++) {
      final angle = math.pi + (math.pi * 0.4) + (i * math.pi * 0.1);
      final innerRadius = radius - strokeWidth / 2 - 4;
      final outerRadius = radius + strokeWidth / 2 + 4;

      final x1 = center.dx + innerRadius * math.cos(angle);
      final y1 = center.dy + innerRadius * math.sin(angle);
      final x2 = center.dx + outerRadius * math.cos(angle);
      final y2 = center.dy + outerRadius * math.sin(angle);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
    }
  }

  @override
  bool shouldRepaint(_SemiCircleGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.urgency != urgency;
  }
}

class _ColorScheme {
  final Color accentColor;
  final Color backgroundColor;

  _ColorScheme({
    required this.accentColor,
    required this.backgroundColor,
  });
}
