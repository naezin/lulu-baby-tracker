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

/// 배변 기록 화면
class LogDiaperScreen extends StatefulWidget {
  const LogDiaperScreen({super.key});

  @override
  State<LogDiaperScreen> createState() => _LogDiaperScreenState();
}

class _LogDiaperScreenState extends State<LogDiaperScreen> {
  final _storage = LocalStorageService();
  final _widgetService = WidgetService();
  static const Color _themeColor = Color(0xFF81C784); // Green for diaper

  DateTime _diaperTime = DateTime.now();
  String _diaperType = 'wet';
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
      title: l10n.translate('log_diaper'),
      subtitle: l10n.translate('track_diaper_types') ?? '기저귀 유형을 기록하세요',
      icon: Icons.child_care_rounded,
      themeColor: _themeColor,
      contextHint: _buildContextHint(),
      inputSection: _buildInputSection(),
      saveButtonText: l10n.translate('save_diaper_record'),
      onSave: _saveDiaper,
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

    final lastDiaper = activities
        .where((a) => a.type == ActivityType.diaper)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (lastDiaper.isNotEmpty) {
      final lastTime = DateTime.parse(lastDiaper.first.timestamp);
      final timeSince = now.difference(lastTime);
      final hours = timeSince.inHours;
      final minutes = timeSince.inMinutes % 60;
      final timeAgo = hours > 0 ? '${hours}시간 ${minutes}분' : '${minutes}분';

      return l10n.translate('diaper_last_change')?.replaceAll('{time}', timeAgo)
          ?? 'Last diaper change: $timeAgo ago\n${l10n.translate('diaper_recommended_interval') ?? 'Recommended change interval: 2-3 hours'}';
    }

    return l10n.translate('diaper_first_record') ?? 'First diaper record! Please select the diaper status.';
  }

  Widget _buildInputSection() {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Diaper Time
        _buildSectionLabel(l10n.translate('diaper_change_time')),
        const SizedBox(height: 8),
        _buildTimeSelector(),

        const SizedBox(height: 16),

        // Diaper Type
        _buildSectionLabel(l10n.translate('diaper_type')),
        const SizedBox(height: 8),
        Column(
          children: [
            _buildDiaperTypeCard(
              value: 'wet',
              emoji: '💧',
              title: l10n.translate('wet_desc') ?? '젖음',
              subtitle: l10n.translate('urineOnly') ?? '소변만',
            ),
            const SizedBox(height: 8),
            _buildDiaperTypeCard(
              value: 'dirty',
              emoji: '💩',
              title: l10n.translate('dirty_desc') ?? '배변',
              subtitle: l10n.translate('bowelMovement') ?? '대변',
            ),
            const SizedBox(height: 8),
            _buildDiaperTypeCard(
              value: 'both',
              emoji: '💧💩',
              title: l10n.translate('both_desc') ?? '둘 다',
              subtitle: l10n.translate('wet_and_dirty') ?? '소변과 대변',
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Notes
        _buildSectionLabel(l10n.translate('notes_optional')),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: l10n.translate('observations_hint_diaper'),
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
              DateFormat('MMM d, yyyy  h:mm a').format(_diaperTime),
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

  Widget _buildDiaperTypeCard({
    required String value,
    required String emoji,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _diaperType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _diaperType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? _themeColor.withOpacity(0.3)
                    : Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? _themeColor : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: _themeColor, size: 28),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final selectedTime = await LuluTimePicker.show(
      context: context,
      initialTime: _diaperTime,
      dateRangeDays: 7,
      allowFutureTime: false,
    );

    if (selectedTime == null) return;

    setState(() {
      _diaperTime = selectedTime;
    });
  }

  Future<void> _saveDiaper() async {
    setState(() => _isLoading = true);

    try {
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      final babyId = babyProvider.currentBaby?.id ?? 'unknown';

      final activity = ActivityModel.diaper(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        babyId: babyId,
        time: _diaperTime,
        diaperType: _diaperType,
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
        if (babyId != null) {
          await homeDataProvider.refreshDailySummary(babyId);
          print('✅ [LogDiaperScreen] HomeDataProvider daily summary refreshed');
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);

        // Calculate feedback data
        final todayCount = await _calculateTodayDiaperCount();

        final l10n = AppLocalizations.of(context);
        final insights = [
          l10n.translate('diaper_today_count')?.replaceAll('{count}', todayCount.toString())
              ?? '🧷 Today\'s changes: $todayCount',
          if (_diaperType == 'wet')
            l10n.translate('diaper_wet_only') ?? '💧 Wet only',
          if (_diaperType == 'dirty')
            l10n.translate('diaper_dirty_only') ?? '💩 Dirty',
          if (_diaperType == 'both')
            l10n.translate('diaper_both') ?? '💧💩 Wet and dirty',
        ];

        showPostRecordFeedback(
          context: context,
          title: l10n.translate('diaper_record_complete') ?? 'Diaper Record Complete!',
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

  Future<int> _calculateTodayDiaperCount() async {
    final activities = await _storage.getActivities();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return activities
        .where((a) {
          if (a.type != ActivityType.diaper) return false;
          final time = DateTime.parse(a.timestamp);
          return time.isAfter(today);
        })
        .length;
  }
}
