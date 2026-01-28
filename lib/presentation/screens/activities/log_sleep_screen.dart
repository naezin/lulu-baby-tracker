import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/services/widget_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/insight_calculator.dart';
import '../../../core/utils/smart_cta_decider.dart';
import '../../widgets/log_screen_template.dart';
import '../../widgets/lulu_time_picker.dart';
import '../../widgets/feedback/celebration_feedback.dart';
import '../../providers/home_data_provider.dart';
import '../../providers/sweet_spot_provider.dart';
import '../../providers/baby_provider.dart';
import '../../providers/smart_coach_provider.dart';
import '../../providers/ongoing_sleep_provider.dart';

/// 수면 기록 모드
enum SleepRecordMode {
  /// 새 수면 기록 (과거 기록) - 기존 _isOngoing = false
  newRecord,

  /// 진행 중인 수면 종료 - 기존 _isOngoing = true + OngoingSleepProvider 연동
  endOngoing,
}

/// 수면 기록 화면
class LogSleepScreen extends StatefulWidget {
  /// 수면 기록 모드
  final SleepRecordMode mode;

  /// 진행 중인 수면 데이터 - endOngoing 모드에서 사용
  final ActivityModel? ongoingSleep;

  const LogSleepScreen({
    super.key,
    this.mode = SleepRecordMode.newRecord, // 기본값: 새 기록
    this.ongoingSleep,
  });

  @override
  State<LogSleepScreen> createState() => _LogSleepScreenState();
}

class _LogSleepScreenState extends State<LogSleepScreen> {
  final _storage = LocalStorageService();
  final _widgetService = WidgetService();
  static const Color _themeColor = Color(0xFFB39DDB); // Purple/Lavender for sleep

  DateTime _startTime = DateTime.now().subtract(const Duration(hours: 2));
  DateTime? _endTime = DateTime.now();
  String _location = 'crib';
  String _quality = 'good';
  final _notesController = TextEditingController();
  bool _isOngoing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // 모드에 따른 초기화
    if (widget.mode == SleepRecordMode.endOngoing) {
      _isOngoing = true; // 기존 플래그 활용

      if (widget.ongoingSleep != null) {
        // 진행 중인 수면의 시작 시간 설정 (읽기 전용)
        _startTime = DateTime.parse(widget.ongoingSleep!.timestamp);
        // 종료 시간 기본값: 현재 시간
        _endTime = DateTime.now();
      }
    } else {
      _isOngoing = false;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LogScreenTemplate(
      title: l10n.translate('log_sleep'),
      subtitle: l10n.translate('track_sleep_patterns') ?? '수면 패턴을 기록하세요',
      icon: Icons.bedtime_rounded,
      themeColor: _themeColor,
      contextHint: _buildContextHint(),
      inputSection: _buildInputSection(),
      saveButtonText: _isOngoing
          ? l10n.translate('start_sleep_timer')
          : l10n.translate('save_sleep_record'),
      onSave: _saveSleep,
      isLoading: _isLoading,
    );
  }

  Widget _buildContextHint() {
    return FutureBuilder<String>(
      future: _getContextHintText(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        return Text(
          snapshot.data!,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        );
      },
    );
  }

  Future<String> _getContextHintText() async {
    final l10n = AppLocalizations.of(context);
    final activities = await _storage.getActivities();
    final now = DateTime.now();

    final lastSleep = activities
        .where((a) => a.type == ActivityType.sleep)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (lastSleep.isNotEmpty) {
      final lastSleepTime = DateTime.parse(lastSleep.first.timestamp);
      final awakeMinutes = now.difference(lastSleepTime).inMinutes;
      final lastDuration = lastSleep.first.durationMinutes ?? 0;
      final timeAgo = _formatTimeAgo(awakeMinutes);

      return l10n.translate('sleep_last_sleep')
          ?.replaceAll('{time}', timeAgo)
          .replaceAll('{duration}', lastDuration.toString())
          ?? 'Last sleep: $timeAgo ($lastDuration min)\n${l10n.translate('sleep_recommended_wake_time') ?? 'Recommended wake time: 1 hour 30 min'}';
    }

    return l10n.translate('sleep_first_record') ?? 'First sleep record! Please select the start time.';
  }

  String _formatTimeAgo(int minutes) {
    final l10n = AppLocalizations.of(context);
    if (minutes < 60) {
      return l10n.translate('sleep_time_ago_minutes')?.replaceAll('{minutes}', minutes.toString())
          ?? '$minutes min ago';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return l10n.translate('sleep_time_ago_hours')
        ?.replaceAll('{hours}', hours.toString())
        .replaceAll('{minutes}', mins.toString())
        ?? '$hours hr $mins min ago';
  }

  Widget _buildInputSection() {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sleep Status Toggle
        _buildSectionLabel(l10n.translate('sleep_status') ?? '수면 상태'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LogOptionButton(
                label: l10n.translate('record_past_sleep') ?? '과거 수면 기록',
                icon: Icons.history_rounded,
                isSelected: !_isOngoing,
                themeColor: _themeColor,
                onTap: () {
                  setState(() {
                    _isOngoing = false;
                    _endTime = DateTime.now();
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LogOptionButton(
                label: l10n.translate('sleep_in_progress') ?? '진행 중',
                icon: Icons.nights_stay_rounded,
                isSelected: _isOngoing,
                themeColor: _themeColor,
                onTap: () {
                  setState(() {
                    _isOngoing = true;
                    _endTime = null;
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Start Time
        _buildSectionLabel(l10n.translate('start_time')),
        const SizedBox(height: 12),
        _buildTimeSelector(
          time: _startTime,
          onTap: () => _selectTime(isStartTime: true),
        ),

        const SizedBox(height: 16),

        // End Time (if not ongoing)
        if (!_isOngoing) ...[
          _buildSectionLabel(l10n.translate('end_time_wake_up')),
          const SizedBox(height: 8),
          _buildTimeSelector(
            time: _endTime!,
            onTap: () => _selectTime(isStartTime: false),
          ),
          const SizedBox(height: 8),
          _buildDurationDisplay(),
          const SizedBox(height: 16),
        ],

        // Location
        _buildSectionLabel(l10n.translate('sleep_location')),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            LogOptionButton(
              label: l10n.translate('sleep_crib'),
              isSelected: _location == 'crib',
              themeColor: _themeColor,
              onTap: () => setState(() => _location = 'crib'),
            ),
            LogOptionButton(
              label: l10n.translate('sleep_bed'),
              isSelected: _location == 'bed',
              themeColor: _themeColor,
              onTap: () => setState(() => _location = 'bed'),
            ),
            LogOptionButton(
              label: l10n.translate('sleep_stroller'),
              isSelected: _location == 'stroller',
              themeColor: _themeColor,
              onTap: () => setState(() => _location = 'stroller'),
            ),
            LogOptionButton(
              label: l10n.translate('sleep_car'),
              isSelected: _location == 'car',
              themeColor: _themeColor,
              onTap: () => setState(() => _location = 'car'),
            ),
            LogOptionButton(
              label: l10n.translate('sleep_arms'),
              isSelected: _location == 'arms',
              themeColor: _themeColor,
              onTap: () => setState(() => _location = 'arms'),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Quality
        _buildSectionLabel(l10n.translate('sleep_quality')),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            LogOptionButton(
              label: l10n.translate('sleep_quality_good'),
              isSelected: _quality == 'good',
              themeColor: _themeColor,
              onTap: () => setState(() => _quality = 'good'),
            ),
            LogOptionButton(
              label: l10n.translate('sleep_quality_fair'),
              isSelected: _quality == 'fair',
              themeColor: _themeColor,
              onTap: () => setState(() => _quality = 'fair'),
            ),
            LogOptionButton(
              label: l10n.translate('sleep_quality_poor'),
              isSelected: _quality == 'poor',
              themeColor: _themeColor,
              onTap: () => setState(() => _quality = 'poor'),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Notes
        _buildSectionLabel(l10n.translate('notes_optional')),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: l10n.translate('observations_hint_sleep'),
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: const Color(0xFF1A2332),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _themeColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildTimeSelector({required DateTime time, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_rounded, color: _themeColor, size: 20),
            const SizedBox(width: 12),
            Text(
              DateFormat('MMM d, yyyy  h:mm a').format(time),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.edit_rounded, color: Colors.grey[600], size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationDisplay() {
    if (_endTime == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final duration = _endTime!.difference(_startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _themeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer_rounded, color: _themeColor, size: 18),
          const SizedBox(width: 8),
          Text(
            l10n.translate('sleep_total_duration')
                ?.replaceAll('{hours}', hours.toString())
                .replaceAll('{minutes}', minutes.toString())
                ?? 'Total sleep time: $hours hr $minutes min',
            style: TextStyle(
              fontSize: 14,
              color: _themeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime({required bool isStartTime}) async {
    final currentTime = isStartTime ? _startTime : _endTime!;

    final selectedTime = await LuluTimePicker.show(
      context: context,
      initialTime: currentTime,
      dateRangeDays: 7,
      allowFutureTime: false,
    );

    if (selectedTime == null) return;

    setState(() {
      if (isStartTime) {
        _startTime = selectedTime;
      } else {
        _endTime = selectedTime;
      }
    });
  }

  Future<void> _saveSleep() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      final baby = babyProvider.currentBaby;

      if (baby == null) {
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          final isKorean = l10n.locale.languageCode == 'ko';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isKorean ? '아기 정보를 찾을 수 없습니다' : 'Baby not found'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      ActivityModel activity;

      // 모드별 분기
      if (widget.mode == SleepRecordMode.endOngoing) {
        // ===== 진행 중 수면 종료 모드 =====
        final ongoingSleepProvider = Provider.of<OngoingSleepProvider>(
          context,
          listen: false,
        );

        // OngoingSleepProvider로 종료 (endTime은 내부에서 처리)
        await ongoingSleepProvider.endSleep(
          quality: _quality,
          notes: _notesController.text.trim(),
        );

        // 저장된 활동 가져오기 (Celebration용)
        activity = ongoingSleepProvider.lastCompletedSleep!;
      } else {
        // ===== 새 수면 기록 모드 (기존 로직) =====
        final duration = _endTime != null
            ? _endTime!.difference(_startTime).inMinutes
            : 0;

        activity = ActivityModel.sleep(
          id: 'sleep_${DateTime.now().millisecondsSinceEpoch}',
          babyId: baby.id,
          startTime: _startTime,
          endTime: _endTime,
          location: _location,
          quality: _quality,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

        await _storage.saveActivity(activity);
      }

      // 위젯 업데이트
      await _widgetService.updateAllWidgets();

      // SweetSpotProvider 업데이트 - 수면이 종료된 경우 기상 시각 업데이트
      if (activity.endTime != null && mounted) {
        final provider = Provider.of<SweetSpotProvider>(context, listen: false);
        final wakeTime = DateTime.parse(activity.endTime!);
        provider.onSleepActivityRecorded(wakeUpTime: wakeTime);
      }

      // HomeDataProvider 업데이트 - Today's Snapshot 새로고침
      if (mounted) {
        final homeDataProvider = Provider.of<HomeDataProvider>(context, listen: false);
        await homeDataProvider.refreshDailySummary(baby.id);
      }

      // SmartCoachProvider 업데이트 - 오늘의 일정 새로고침
      if (mounted) {
        final smartCoachProvider = Provider.of<SmartCoachProvider>(context, listen: false);
        await smartCoachProvider.refresh(
          userId: baby.id,
          babyName: baby.name,
          ageInMonths: baby.ageInMonths,
          lastWakeUpTime: activity.endTime != null
              ? DateTime.parse(activity.endTime!)
              : null,
          lastFeedingTime: null,
          isKorean: true,
        );
      }

      if (mounted) {
        setState(() => _isLoading = false);

        // 🎉 캐시 무효화 (새 기록 추가됨)
        InsightCalculator.invalidateCache();

        // InsightCalculator로 오늘의 인사이트 계산
        final insightCalc = InsightCalculator(_storage);
        final todayData = await insightCalc.calculateTodayInsight();
        final insightMessage = insightCalc.generateInsightMessage(
          ActivityType.sleep,
          todayData,
        );

        // SmartCTA 결정
        final smartCTA = SmartCTADecider.decide(
          lastActivity: ActivityType.sleep,
          todayData: todayData,
        );

        // CelebrationFeedback 표시
        await CelebrationFeedback.show(
          context: context,
          activityType: ActivityType.sleep,
          activity: activity,
          insightMessage: insightMessage,
          ctaText: smartCTA?.text,
          onCTAPressed: smartCTA != null
              ? () => Navigator.pushNamed(context, smartCTA.route)
              : null,
        );

        // BottomSheet이 닫힌 후 화면 닫기
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
  }

  Future<int> _calculateTodaySleepTotal() async {
    final activities = await _storage.getActivities();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return activities
        .where((a) {
          if (a.type != ActivityType.sleep) return false;
          final time = DateTime.parse(a.timestamp);
          return time.isAfter(today);
        })
        .fold<int>(0, (sum, a) => sum + (a.durationMinutes ?? 0));
  }

  Future<int> _calculateYesterdaySleepTotal() async {
    final activities = await _storage.getActivities();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    return activities
        .where((a) {
          if (a.type != ActivityType.sleep) return false;
          final time = DateTime.parse(a.timestamp);
          return time.isAfter(yesterday) && time.isBefore(today);
        })
        .fold<int>(0, (sum, a) => sum + (a.durationMinutes ?? 0));
  }
}
