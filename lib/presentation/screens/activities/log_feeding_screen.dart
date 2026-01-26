import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/services/widget_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../providers/home_data_provider.dart';
import '../../providers/baby_provider.dart';
import '../../widgets/log_screen_template.dart';
import '../../widgets/lulu_time_picker.dart';

/// 수유 기록 화면
class LogFeedingScreen extends StatefulWidget {
  const LogFeedingScreen({super.key});

  @override
  State<LogFeedingScreen> createState() => _LogFeedingScreenState();
}

class _LogFeedingScreenState extends State<LogFeedingScreen> {
  final _storage = LocalStorageService();
  final _widgetService = WidgetService();
  static const Color _themeColor = Color(0xFFE8B87E); // Warm orange for feeding

  DateTime _feedingTime = DateTime.now();
  String _feedingType = 'bottle';
  double _amountMl = 120.0;
  String _breastSide = 'both';
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LogScreenTemplate(
      title: l10n.translate('log_feeding'),
      subtitle: l10n.translate('track_feeding_types') ?? '다양한 수유 방법을 기록하세요',
      icon: Icons.restaurant_rounded,
      themeColor: _themeColor,
      contextHint: _buildContextHint(),
      inputSection: _buildInputSection(),
      saveButtonText: l10n.translate('save_feeding_record'),
      onSave: _saveFeeding,
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

    final lastFeeding = activities
        .where((a) => a.type == ActivityType.feeding)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (lastFeeding.isNotEmpty) {
      final lastTime = DateTime.parse(lastFeeding.first.timestamp);
      final timeSince = now.difference(lastTime);
      final hours = timeSince.inHours;
      final minutes = timeSince.inMinutes % 60;
      final timeAgo = hours > 0 ? '${hours}시간 ${minutes}분' : '${minutes}분';

      return l10n.translate('feeding_last_time')?.replaceAll('{time}', timeAgo)
          ?? 'Last feeding: $timeAgo ago\n${l10n.translate('feeding_recommended_interval') ?? 'Recommended interval: 2-3 hours'}';
    }

    return l10n.translate('feeding_first_record') ?? 'First feeding record! Please enter feeding information.';
  }

  Widget _buildInputSection() {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Feeding Time
        _buildSectionLabel(l10n.translate('feeding_time')),
        const SizedBox(height: 8),
        _buildTimeSelector(),

        const SizedBox(height: 16),

        // Feeding Type
        _buildSectionLabel(l10n.translate('feeding_type')),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            LogOptionButton(
              label: l10n.translate('bottle'),
              icon: Icons.baby_changing_station_rounded,
              isSelected: _feedingType == 'bottle',
              themeColor: _themeColor,
              onTap: () => setState(() => _feedingType = 'bottle'),
            ),
            LogOptionButton(
              label: l10n.translate('breast'),
              icon: Icons.pregnant_woman_rounded,
              isSelected: _feedingType == 'breast',
              themeColor: _themeColor,
              onTap: () => setState(() => _feedingType = 'breast'),
            ),
            LogOptionButton(
              label: l10n.translate('solid_food'),
              icon: Icons.restaurant_menu_rounded,
              isSelected: _feedingType == 'solid',
              themeColor: _themeColor,
              onTap: () => setState(() => _feedingType = 'solid'),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Amount (for bottle/solid)
        if (_feedingType != 'breast') ...[
          _buildSectionLabel(l10n.translate('amount')),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2332),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_amountMl.toInt()} ml',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _themeColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _themeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(_amountMl * 0.033814).toStringAsFixed(1)} oz',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _themeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: _themeColor,
                    thumbColor: _themeColor,
                    inactiveTrackColor: _themeColor.withOpacity(0.2),
                    overlayColor: _themeColor.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _amountMl,
                    min: 0,
                    max: 300,
                    divisions: 30,
                    onChanged: (value) {
                      setState(() {
                        _amountMl = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Breast Side (for breastfeeding)
        if (_feedingType == 'breast') ...[
          _buildSectionLabel(l10n.translate('breast_side')),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              LogOptionButton(
                label: l10n.translate('left'),
                isSelected: _breastSide == 'left',
                themeColor: _themeColor,
                onTap: () => setState(() => _breastSide = 'left'),
              ),
              LogOptionButton(
                label: l10n.translate('right'),
                isSelected: _breastSide == 'right',
                themeColor: _themeColor,
                onTap: () => setState(() => _breastSide = 'right'),
              ),
              LogOptionButton(
                label: l10n.translate('both'),
                isSelected: _breastSide == 'both',
                themeColor: _themeColor,
                onTap: () => setState(() => _breastSide = 'both'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Notes
        _buildSectionLabel(l10n.translate('notes_optional')),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: l10n.translate('observations_hint_feeding'),
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

  Widget _buildTimeSelector() {
    return GestureDetector(
      onTap: _selectTime,
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
              DateFormat('MMM d, yyyy  h:mm a').format(_feedingTime),
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

  Future<void> _selectTime() async {
    final selectedTime = await LuluTimePicker.show(
      context: context,
      initialTime: _feedingTime,
      dateRangeDays: 7,
      allowFutureTime: false,
    );

    if (selectedTime == null) return;

    setState(() {
      _feedingTime = selectedTime;
    });
  }

  Future<void> _saveFeeding() async {
    setState(() => _isLoading = true);

    try {
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      final babyId = babyProvider.currentBaby?.id ?? 'unknown';

      final activity = ActivityModel.feeding(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        babyId: babyId,
        time: _feedingTime,
        feedingType: _feedingType,
        amountMl: _feedingType != 'breast' ? _amountMl : null,
        amountOz: _feedingType != 'breast' ? _amountMl * 0.033814 : null,
        breastSide: _feedingType == 'breast' ? _breastSide : null,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await _storage.saveActivity(activity);
      await _widgetService.updateAllWidgets();

      // HomeDataProvider 업데이트 - Today's Snapshot 새로고침
      if (mounted) {
        final homeDataProvider = Provider.of<HomeDataProvider>(context, listen: false);
        final babyProvider = Provider.of<BabyProvider>(context, listen: false);
        final babyId = babyProvider.currentBaby?.id;
        print('🍼 [LogFeedingScreen] Refreshing daily summary with babyId: $babyId');
        if (babyId != null) {
          await homeDataProvider.refreshDailySummary(babyId);
          print('✅ [LogFeedingScreen] HomeDataProvider daily summary refreshed');
        } else {
          print('⚠️ [LogFeedingScreen] babyId is null! Cannot refresh summary');
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);

        // Calculate feedback data
        final todayCount = await _calculateTodayFeedingCount();

        final l10n = AppLocalizations.of(context);
        final insights = [
          l10n.translate('feeding_today_count')?.replaceAll('{count}', todayCount.toString())
              ?? '🍼 Today\'s feedings: $todayCount',
          if (_feedingType == 'bottle')
            l10n.translate('feeding_bottle_amount')
                ?.replaceAll('{ml}', _amountMl.toInt().toString())
                .replaceAll('{oz}', (_amountMl * 0.033814).toStringAsFixed(1))
                ?? '📊 ${_amountMl.toInt()}ml (${(_amountMl * 0.033814).toStringAsFixed(1)}oz)',
          if (_feedingType == 'breast')
            (_breastSide == 'both'
                ? l10n.translate('feeding_breast_both')
                : _breastSide == 'left'
                    ? l10n.translate('feeding_breast_left')
                    : l10n.translate('feeding_breast_right'))
                ?? '🤱 ${_breastSide == "both" ? "Both sides" : _breastSide == "left" ? "Left" : "Right"}',
        ];

        showPostRecordFeedback(
          context: context,
          title: l10n.translate('feeding_record_complete') ?? 'Feeding Record Complete! 🍼',
          insights: insights,
          themeColor: _themeColor,
        );
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

  Future<int> _calculateTodayFeedingCount() async {
    final activities = await _storage.getActivities();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return activities
        .where((a) {
          if (a.type != ActivityType.feeding) return false;
          final time = DateTime.parse(a.timestamp);
          return time.isAfter(today);
        })
        .length;
  }
}
