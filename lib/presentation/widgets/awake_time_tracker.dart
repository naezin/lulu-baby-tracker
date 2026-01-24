import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/awake_time_calculator.dart';

/// ⏰ Awake Time Tracker Widget
/// 실시간 깨시 추적 및 알림
class AwakeTimeTracker extends StatefulWidget {
  final DateTime lastWakeUpTime;
  final int ageInMonths;
  final VoidCallback? onSleepSuggested;

  const AwakeTimeTracker({
    Key? key,
    required this.lastWakeUpTime,
    required this.ageInMonths,
    this.onSleepSuggested,
  }) : super(key: key);

  @override
  State<AwakeTimeTracker> createState() => _AwakeTimeTrackerState();
}

class _AwakeTimeTrackerState extends State<AwakeTimeTracker>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AwakeTimeResult _result;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _calculateAwakeTime();

    // 1초마다 업데이트
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _calculateAwakeTime();
      });
    });

    // Pulse animation for overtired state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _calculateAwakeTime() {
    _result = AwakeTimeCalculator.calculateAwakeTime(
      lastWakeUpTime: widget.lastWakeUpTime,
      ageInMonths: widget.ageInMonths,
    );

    // 과자극 상태면 알림
    if (_result.status == AwakeTimeStatus.overtired) {
      widget.onSleepSuggested?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Widget card = Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _result.statusColor.withOpacity(0.15),
            _result.statusColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _result.statusColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Status Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _result.statusColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _result.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translate('awake_time_tracker') ?? 'Awake Time',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textTertiary,
                            fontSize: 12,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _result.userFriendlyMessage,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Time Display
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimeInfo(
                  context,
                  l10n,
                  icon: Icons.access_time_rounded,
                  label: l10n.translate('awake_time_current') ?? 'Current',
                  value: _formatMinutes(_result.awakeMinutes),
                  color: _result.statusColor,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.softBlue.withOpacity(0.3),
                ),
                _buildTimeInfo(
                  context,
                  l10n,
                  icon: Icons.psychology_outlined,
                  label: l10n.translate('awake_time_optimal') ?? 'Optimal',
                  value: _formatMinutes(_result.range.optimal),
                  color: AppTheme.successSoft,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _result.progress,
              backgroundColor: AppTheme.surfaceElevated,
              valueColor: AlwaysStoppedAnimation<Color>(_result.statusColor),
              minHeight: 8,
            ),
          ),

          const SizedBox(height: 12),

          // Status Message
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_result.awakeMinutes}분 경과',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
              ),
              if (_result.status != AwakeTimeStatus.overtired)
                Text(
                  _result.status == AwakeTimeStatus.tooEarly
                      ? '최적까지 ${_result.minutesUntilOptimal}분'
                      : '최대까지 ${_result.minutesUntilMax}분',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.errorSoft.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bedtime_rounded,
                        size: 14,
                        color: AppTheme.errorSoft,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.translate('awake_time_sleep_now') ?? 'Sleep now',
                        style: TextStyle(
                          color: AppTheme.errorSoft,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    // Pulse effect for overtired state
    if (_result.status == AwakeTimeStatus.overtired) {
      return ScaleTransition(
        scale: _pulseAnimation,
        child: card,
      );
    }

    return card;
  }

  Widget _buildTimeInfo(
    BuildContext context,
    AppLocalizations l10n, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textTertiary,
                fontSize: 11,
              ),
        ),
      ],
    );
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }
}
