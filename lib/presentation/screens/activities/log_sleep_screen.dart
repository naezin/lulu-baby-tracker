import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/services/widget_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../widgets/log/context_hint_card.dart';
import '../../widgets/log/post_record_feedback.dart';

/// 수면 기록 화면
class LogSleepScreen extends StatefulWidget {
  const LogSleepScreen({super.key});

  @override
  State<LogSleepScreen> createState() => _LogSleepScreenState();
}

class _LogSleepScreenState extends State<LogSleepScreen> {
  final _storage = LocalStorageService();
  final _widgetService = WidgetService();

  DateTime _startTime = DateTime.now().subtract(const Duration(hours: 2));
  DateTime? _endTime = DateTime.now();
  String _location = 'crib'; // Internal key - translation happens in UI
  String _quality = 'good'; // Internal key - translation happens in UI
  final _notesController = TextEditingController();

  bool _isOngoing = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('log_sleep')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Context Hint
            FutureBuilder<ContextHintData>(
              future: _buildContextHint(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final data = snapshot.data!;
                return ContextHintCard(
                  title: '수면 기록 전 참고하세요',
                  hints: data.hints,
                  status: data.status,
                );
              },
            ),

            const SizedBox(height: 16),

            // Sleep Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.bedtime, size: 32, color: Colors.purple),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isOngoing ? l10n.translate('sleep_in_progress') : l10n.translate('record_past_sleep'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isOngoing
                                ? l10n.translate('sleep_timer_running')
                                : l10n.translate('log_completed_sleep'),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isOngoing,
                      onChanged: (value) {
                        setState(() {
                          _isOngoing = value;
                          if (value) {
                            _endTime = null;
                          } else {
                            _endTime = DateTime.now();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Start Time
            _buildSectionTitle(l10n.translate('start_time')),
            const SizedBox(height: 8),
            _buildTimeSelector(
              time: _startTime,
              onTap: () => _selectTime(isStartTime: true),
            ),

            const SizedBox(height: 24),

            // End Time
            if (!_isOngoing) ...[
              _buildSectionTitle(l10n.translate('end_time_wake_up')),
              const SizedBox(height: 8),
              _buildTimeSelector(
                time: _endTime!,
                onTap: () => _selectTime(isStartTime: false),
              ),
              const SizedBox(height: 16),
              _buildDurationDisplay(),
              const SizedBox(height: 24),
            ],

            // Location
            _buildSectionTitle(l10n.translate('sleep_location')),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildLocationChip('crib', '🛏️', l10n.translate('sleep_crib')),
                _buildLocationChip('bed', '🛌', l10n.translate('sleep_bed')),
                _buildLocationChip('stroller', '🚼', l10n.translate('sleep_stroller')),
                _buildLocationChip('car', '🚗', l10n.translate('sleep_car')),
                _buildLocationChip('arms', '🤱', l10n.translate('sleep_arms')),
              ],
            ),

            const SizedBox(height: 24),

            // Quality
            _buildSectionTitle(l10n.translate('sleep_quality')),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildQualityChip('good', '😊', l10n.translate('sleep_quality_good')),
                _buildQualityChip('fair', '😐', l10n.translate('sleep_quality_fair')),
                _buildQualityChip('poor', '😔', l10n.translate('sleep_quality_poor')),
              ],
            ),

            const SizedBox(height: 24),

            // Notes
            _buildSectionTitle(l10n.translate('notes_optional')),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.translate('observations_hint_sleep'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveSleep,
                icon: const Icon(Icons.check),
                label: Text(
                  _isOngoing ? l10n.translate('start_sleep_timer') : l10n.translate('save_sleep_record'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTimeSelector({required DateTime time, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.purple),
            const SizedBox(width: 16),
            Text(
              DateFormat('MMM d, yyyy  h:mm a').format(time),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationDisplay() {
    if (_endTime == null) return const SizedBox.shrink();

    final duration = _endTime!.difference(_startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer, color: Colors.purple),
          const SizedBox(width: 8),
          Text(
            l10n.translate('duration_format').replaceAll('{hours}', hours.toString()).replaceAll('{minutes}', minutes.toString()),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.purple[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationChip(String value, String emoji, String label) {
    final isSelected = _location == value;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _location = value;
        });
      },
      selectedColor: Colors.purple[100],
    );
  }

  Widget _buildQualityChip(String value, String emoji, String label) {
    final isSelected = _quality == value;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _quality = value;
        });
      },
      selectedColor: Colors.blue[100],
    );
  }

  Future<void> _selectTime({required bool isStartTime}) async {
    final currentTime = isStartTime ? _startTime : _endTime!;

    final date = await showDatePicker(
      context: context,
      initialDate: currentTime,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentTime),
    );

    if (time == null) return;

    final newDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStartTime) {
        _startTime = newDateTime;
      } else {
        _endTime = newDateTime;
      }
    });
  }

  Future<void> _saveSleep() async {
    final activity = ActivityModel.sleep(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: _startTime,
      endTime: _endTime,
      location: _location,
      quality: _quality,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    await _storage.saveActivity(activity);

    // Update widgets with new data
    await _widgetService.updateAllWidgets();

    if (mounted) {
      // Post-Record Feedback 표시
      final totalToday = await _calculateTodaySleepTotal();
      final yesterdayTotal = await _calculateYesterdaySleepTotal();
      final diff = totalToday - yesterdayTotal;

      await PostRecordFeedback.show(
        context,
        title: '수면 기록 완료! 😴',
        items: [
          FeedbackItem(
            emoji: '⏱️',
            label: '오늘 총 수면',
            value: '${totalToday ~/ 60}시간 ${totalToday % 60}분',
            trend: diff > 0 ? '+$diff분' : diff < 0 ? '$diff분' : '평균',
            color: Colors.purple,
            trendColor: diff >= 0 ? Colors.green : Colors.orange,
          ),
          FeedbackItem(
            emoji: '🎯',
            label: '방금 기록한 수면',
            value: _endTime != null
                ? '${_endTime!.difference(_startTime).inMinutes}분'
                : '진행 중',
            color: Colors.blue,
          ),
        ],
        nextAction: '인사이트 보기',
        onNextActionTap: () {
          Navigator.pop(context);
          // TODO: Navigate to insights
        },
      );

      Navigator.pop(context, true); // true = data was saved
    }
  }

  /// Context Hint 데이터 생성
  Future<ContextHintData> _buildContextHint() async {
    final activities = await _storage.getActivities();
    final now = DateTime.now();

    // 마지막 수면 찾기
    final lastSleep = activities
        .where((a) => a.type == ActivityType.sleep)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final hints = <ContextHintItem>[];
    ContextStatus status = ContextStatus.neutral;

    if (lastSleep.isNotEmpty) {
      final lastSleepTime = DateTime.parse(lastSleep.first.timestamp);
      final awakeMinutes = now.difference(lastSleepTime).inMinutes;
      final lastDuration = lastSleep.first.durationMinutes ?? 0;

      hints.add(ContextHintItem(
        emoji: '⏰',
        text: '마지막 수면: ${_formatTimeAgo(awakeMinutes)} ($lastDuration분간)',
      ));

      // 월령 기반 권장 깨어있는 시간 (예: 2개월 = 60-90분)
      const recommendedAwake = 90; // TODO: 월령에 따라 계산

      hints.add(const ContextHintItem(
        emoji: '📊',
        text: '권장 깨어있는 시간: ${recommendedAwake ~/ 60}시간 ${recommendedAwake % 60}분',
      ));

      if (awakeMinutes >= recommendedAwake - 15 && awakeMinutes <= recommendedAwake + 30) {
        status = ContextStatus.good;
        hints.add(const ContextHintItem(
          emoji: '✅',
          text: '지금 재우기 좋은 타이밍이에요!',
        ));
      } else if (awakeMinutes > recommendedAwake + 30) {
        status = ContextStatus.caution;
        hints.add(const ContextHintItem(
          emoji: '⚠️',
          text: '깨어있는 시간이 길어졌어요. 피로 누적 주의!',
        ));
      }
    } else {
      hints.add(const ContextHintItem(
        emoji: '📝',
        text: '첫 수면 기록이에요! 시작 시간을 선택해주세요.',
      ));
    }

    return ContextHintData(hints: hints, status: status);
  }

  String _formatTimeAgo(int minutes) {
    if (minutes < 60) return '$minutes분 전';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '$hours시간 $mins분 전';
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

/// Context Hint 데이터
class ContextHintData {
  final List<ContextHintItem> hints;
  final ContextStatus status;

  ContextHintData({required this.hints, required this.status});
}
