import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/play_activity_model.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/services/widget_service.dart';

/// 🎯 Log Play Activity Screen
/// 놀이 활동 기록 화면 (BabyTime-style Quick Log)
class LogPlayScreen extends StatefulWidget {
  final PlayActivityType? preselectedType;

  const LogPlayScreen({
    Key? key,
    this.preselectedType,
  }) : super(key: key);

  @override
  State<LogPlayScreen> createState() => _LogPlayScreenState();
}

class _LogPlayScreenState extends State<LogPlayScreen>
    with SingleTickerProviderStateMixin {
  PlayActivityType? _selectedType;
  DateTime _startTime = DateTime.now();
  int? _durationMinutes;
  String _notes = '';
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.preselectedType;

    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: Text(l10n.translate('log_play_activity') ?? 'Log Play'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Activity Type Selection
              _buildSectionTitle(context, l10n, l10n.translate('select_activity')),
              const SizedBox(height: 16),
              _buildActivityTypeGrid(context, l10n),

              const SizedBox(height: 32),

              // Selected Activity Info
              if (_selectedType != null) ...[
                _buildSelectedActivityCard(context, l10n),
                const SizedBox(height: 32),
              ],

              // Time Selection
              _buildSectionTitle(context, l10n, l10n.translate('start_time')),
              const SizedBox(height: 16),
              _buildTimeSelector(context, l10n),

              const SizedBox(height: 32),

              // Duration
              _buildSectionTitle(context, l10n, l10n.translate('duration')),
              const SizedBox(height: 16),
              _buildDurationSelector(context, l10n),

              const SizedBox(height: 32),

              // Notes (Optional)
              _buildSectionTitle(context, l10n, l10n.translate('notes_optional')),
              const SizedBox(height: 16),
              _buildNotesInput(context, l10n),

              const SizedBox(height: 40),

              // Save Button
              _buildSaveButton(context, l10n),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    AppLocalizations l10n,
    String title,
  ) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildActivityTypeGrid(BuildContext context, AppLocalizations l10n) {
    final activities = PlayActivityType.values;

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
            HapticFeedback.lightImpact();
            setState(() {
              _selectedType = activity;
              _durationMinutes = activity.recommendedDurationMinutes;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF5FB37B).withOpacity(0.2)
                  : AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF5FB37B)
                    : AppTheme.softBlue.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                // Main content
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
                          color: isSelected
                              ? const Color(0xFF5FB37B)
                              : AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Recommended badge
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
                        color: const Color(0xFF5FB37B),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '⭐',
                        style: const TextStyle(fontSize: 10),
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

  Widget _buildSelectedActivityCard(BuildContext context, AppLocalizations l10n) {
    final activity = _selectedType!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF5FB37B).withOpacity(0.15),
            const Color(0xFF5FB37B).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF5FB37B).withOpacity(0.3),
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.translate('development_benefits') ?? 'Development Benefits:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: activity.developmentTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF5FB37B).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tag.emoji} ${l10n.translate('dev_tag_${tag.name}') ?? tag.name}',
                  style: TextStyle(
                    color: const Color(0xFF5FB37B),
                    fontSize: 12,
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

  Widget _buildTimeSelector(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_startTime),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                timePickerTheme: TimePickerThemeData(
                  backgroundColor: AppTheme.surfaceCard,
                  dialBackgroundColor: AppTheme.surfaceElevated,
                  hourMinuteTextColor: AppTheme.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );

        if (time != null) {
          setState(() {
            _startTime = DateTime(
              _startTime.year,
              _startTime.month,
              _startTime.day,
              time.hour,
              time.minute,
            );
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.softBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: AppTheme.lavenderMist,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppTheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelector(BuildContext context, AppLocalizations l10n) {
    final durations = [5, 10, 15, 20, 30, 45, 60];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: durations.map((duration) {
        final isSelected = _durationMinutes == duration;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _durationMinutes = duration;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF5FB37B).withOpacity(0.2)
                  : AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF5FB37B)
                    : AppTheme.softBlue.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              l10n.locale.languageCode == 'ko' ? '${duration}분' : '${duration}min',
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF5FB37B)
                    : AppTheme.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesInput(BuildContext context, AppLocalizations l10n) {
    return TextField(
      maxLines: 4,
      style: TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: l10n.translate('activity_notes_hint') ?? 'Add notes...',
        filled: true,
        fillColor: AppTheme.surfaceCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        _notes = value;
      },
    );
  }

  Widget _buildSaveButton(BuildContext context, AppLocalizations l10n) {
    final canSave = _selectedType != null && _durationMinutes != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canSave
            ? () {
                HapticFeedback.mediumImpact();
                _saveActivity(context);
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canSave
              ? const Color(0xFF5FB37B)
              : AppTheme.softBlue.withOpacity(0.3),
          foregroundColor: canSave
              ? AppTheme.midnightNavy
              : AppTheme.textTertiary,
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
        child: Text(
          l10n.translate('save_activity') ?? 'Save Activity',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _saveActivity(BuildContext context) async {
    if (_selectedType == null || _durationMinutes == null) return;

    final activity = ActivityModel.play(
      id: const Uuid().v4(),
      startTime: _startTime,
      endTime: _startTime.add(Duration(minutes: _durationMinutes!)),
      durationMinutes: _durationMinutes,
      playActivityType: _selectedType!.name,
      developmentTags: _selectedType!.developmentTags.map((tag) => tag.name).toList(),
      notes: _notes.isEmpty ? null : _notes,
    );

    await LocalStorageService().saveActivity(activity);
    await WidgetService().updateAllWidgets();

    if (!context.mounted) return;

    Navigator.pop(context, true);

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.locale.languageCode == 'ko' ? '활동이 기록되었습니다! 🎉' : 'Activity logged successfully! 🎉'),
        backgroundColor: const Color(0xFF5FB37B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
