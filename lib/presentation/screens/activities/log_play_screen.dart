import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/insight_calculator.dart';
import '../../../core/utils/smart_cta_decider.dart';
import '../../../data/models/play_activity_model.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/services/widget_service.dart';
import '../../widgets/log_screen_template.dart';
import '../../widgets/lulu_time_picker.dart';
import '../../widgets/feedback/celebration_feedback.dart';
import '../../providers/baby_provider.dart';

/// 놀이 활동 기록 화면
class LogPlayScreen extends StatefulWidget {
  final PlayActivityType? preselectedType;

  const LogPlayScreen({
    super.key,
    this.preselectedType,
  });

  @override
  State<LogPlayScreen> createState() => _LogPlayScreenState();
}

class _LogPlayScreenState extends State<LogPlayScreen> {
  final _storage = LocalStorageService();
  final _widgetService = WidgetService();
  static const Color _themeColor = Color(0xFF5FB37B); // Teal green for play

  PlayActivityType? _selectedType;
  DateTime _startTime = DateTime.now();
  int? _durationMinutes;
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.preselectedType;
    if (_selectedType != null) {
      _durationMinutes = _selectedType!.recommendedDurationMinutes;
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
      title: l10n.translate('log_play_activity') ?? '놀이 활동',
      subtitle: l10n.translate('play_track_developmental') ?? '발달에 도움이 되는 놀이를 기록하세요',
      icon: Icons.sports_esports_rounded,
      themeColor: _themeColor,
      contextHint: _buildContextHint(),
      inputSection: _buildInputSection(),
      saveButtonText: l10n.translate('save_activity') ?? '활동 저장',
      onSave: _saveActivity,
      isLoading: _isLoading,
    );
  }

  Widget _buildContextHint() {
    final l10n = AppLocalizations.of(context);
    return Text(
      l10n.translate('play_context_hint') ?? 'Select age-appropriate play activities.\nRegular play helps baby\'s physical and cognitive development.',
      style: const TextStyle(
        fontSize: 14,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildInputSection() {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Activity Type Selection
        _buildSectionLabel(l10n.translate('select_activity') ?? '활동 선택'),
        const SizedBox(height: 8),
        _buildActivityTypeGrid(),

        const SizedBox(height: 16),

        // Selected Activity Info
        if (_selectedType != null) ...[
          _buildSelectedActivityCard(),
          const SizedBox(height: 16),
        ],

        // Start Time
        _buildSectionLabel(l10n.translate('start_time')),
        const SizedBox(height: 8),
        _buildTimeSelector(),

        const SizedBox(height: 16),

        // Duration
        _buildSectionLabel(l10n.translate('duration')),
        const SizedBox(height: 8),
        _buildDurationSelector(),

        const SizedBox(height: 16),

        // Notes
        _buildSectionLabel(l10n.translate('notes_optional')),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: l10n.translate('activity_notes_hint') ?? '활동 메모 추가...',
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

  Widget _buildActivityTypeGrid() {
    final l10n = AppLocalizations.of(context);
    const activities = PlayActivityType.values;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final isSelected = _selectedType == activity;
        final isRecommended = activity.isRecommendedFor72Days;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedType = activity;
              _durationMinutes = activity.recommendedDurationMinutes;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? _themeColor.withOpacity(0.2)
                  : const Color(0xFF1A2332),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? _themeColor : Colors.white.withOpacity(0.1),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        activity.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.translate('activity_${activity.name}') ?? activity.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? _themeColor : Colors.white70,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isRecommended)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _themeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '⭐',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedActivityCard() {
    final l10n = AppLocalizations.of(context);
    final activity = _selectedType!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _themeColor.withOpacity(0.15),
            _themeColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _themeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                activity.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.translate('activity_${activity.name}') ?? activity.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.translate('development_benefits') ?? '발달 효과:',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: activity.developmentTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _themeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${tag.emoji} ${l10n.translate('dev_tag_${tag.name}') ?? tag.name}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _themeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector() {
    return GestureDetector(
      onTap: () async {
        final selectedTime = await LuluTimePicker.show(
          context: context,
          initialTime: _startTime,
          dateRangeDays: 7,
          allowFutureTime: false,
        );

        if (selectedTime != null) {
          setState(() {
            _startTime = selectedTime;
          });
        }
      },
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
              '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Icon(Icons.edit_rounded, color: Colors.grey[600], size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    final l10n = AppLocalizations.of(context);
    final durations = [5, 10, 15, 20, 30, 45, 60];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: durations.map((duration) {
        final isSelected = _durationMinutes == duration;
        return LogOptionButton(
          label: l10n.locale.languageCode == 'ko' ? '$duration분' : '${duration}min',
          isSelected: isSelected,
          themeColor: _themeColor,
          onTap: () {
            setState(() {
              _durationMinutes = duration;
            });
          },
        );
      }).toList(),
    );
  }

  Future<void> _saveActivity() async {
    final l10n = AppLocalizations.of(context);
    if (_selectedType == null || _durationMinutes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('play_select_time') ?? '활동과 시간을 선택해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      final babyId = babyProvider.currentBaby?.id ?? 'unknown';

      final activity = ActivityModel.play(
        id: const Uuid().v4(),
        babyId: babyId,
        startTime: _startTime,
        endTime: _startTime.add(Duration(minutes: _durationMinutes!)),
        durationMinutes: _durationMinutes,
        playActivityType: _selectedType!.name,
        developmentTags: _selectedType!.developmentTags.map((tag) => tag.name).toList(),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await _storage.saveActivity(activity);
      await _widgetService.updateAllWidgets();

      if (mounted) {
        setState(() => _isLoading = false);

        // 🎉 캐시 무효화
        InsightCalculator.invalidateCache();

        // InsightCalculator로 오늘의 인사이트 계산
        final insightCalc = InsightCalculator(_storage);
        final todayData = await insightCalc.calculateTodayInsight();
        final insightMessage = insightCalc.generateInsightMessage(
          ActivityType.play,
          todayData,
        );

        // SmartCTA 결정
        final smartCTA = SmartCTADecider.decide(
          lastActivity: ActivityType.play,
          todayData: todayData,
        );

        // CelebrationFeedback 표시
        await CelebrationFeedback.show(
          context: context,
          activityType: ActivityType.play,
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
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.translate('sleep_save_failed')?.replaceAll('{error}', e.toString()) ?? '저장 실패: $e')),
        );
      }
    }
  }

  Future<int> _calculateTodayPlayCount() async {
    final activities = await _storage.getActivities();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return activities
        .where((a) {
          if (a.type != ActivityType.play) return false;
          final time = DateTime.parse(a.timestamp);
          return time.isAfter(today);
        })
        .length;
  }
}
