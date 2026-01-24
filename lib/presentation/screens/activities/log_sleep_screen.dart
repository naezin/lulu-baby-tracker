import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/services/widget_service.dart';
import '../../../core/localization/app_localizations.dart';

/// 수면 기록 화면
class LogSleepScreen extends StatefulWidget {
  const LogSleepScreen({Key? key}) : super(key: key);

  @override
  State<LogSleepScreen> createState() => _LogSleepScreenState();
}

class _LogSleepScreenState extends State<LogSleepScreen> {
  final _storage = LocalStorageService();
  final _widgetService = WidgetService();

  DateTime _startTime = DateTime.now().subtract(Duration(hours: 2));
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('log_sleep')),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sleep Status
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.bedtime, size: 32, color: Colors.purple),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isOngoing ? l10n.translate('sleep_in_progress') : l10n.translate('record_past_sleep'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
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

            SizedBox(height: 24),

            // Start Time
            _buildSectionTitle(l10n.translate('start_time')),
            SizedBox(height: 8),
            _buildTimeSelector(
              time: _startTime,
              onTap: () => _selectTime(isStartTime: true),
            ),

            SizedBox(height: 24),

            // End Time
            if (!_isOngoing) ...[
              _buildSectionTitle(l10n.translate('end_time_wake_up')),
              SizedBox(height: 8),
              _buildTimeSelector(
                time: _endTime!,
                onTap: () => _selectTime(isStartTime: false),
              ),
              SizedBox(height: 16),
              _buildDurationDisplay(),
              SizedBox(height: 24),
            ],

            // Location
            _buildSectionTitle(l10n.translate('sleep_location')),
            SizedBox(height: 8),
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

            SizedBox(height: 24),

            // Quality
            _buildSectionTitle(l10n.translate('sleep_quality')),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildQualityChip('good', '😊', l10n.translate('sleep_quality_good')),
                _buildQualityChip('fair', '😐', l10n.translate('sleep_quality_fair')),
                _buildQualityChip('poor', '😔', l10n.translate('sleep_quality_poor')),
              ],
            ),

            SizedBox(height: 24),

            // Notes
            _buildSectionTitle(l10n.translate('notes_optional')),
            SizedBox(height: 8),
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

            SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveSleep,
                icon: Icon(Icons.check),
                label: Text(
                  _isOngoing ? l10n.translate('start_sleep_timer') : l10n.translate('save_sleep_record'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTimeSelector({required DateTime time, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: Colors.purple),
            SizedBox(width: 16),
            Text(
              DateFormat('MMM d, yyyy  h:mm a').format(time),
              style: TextStyle(
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
    if (_endTime == null) return SizedBox.shrink();

    final duration = _endTime!.difference(_startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer, color: Colors.purple),
          SizedBox(width: 8),
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
          SizedBox(width: 4),
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
          SizedBox(width: 4),
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
      firstDate: DateTime.now().subtract(Duration(days: 7)),
      lastDate: DateTime.now().add(Duration(days: 1)),
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('sleep_recorded_success')),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // true = data was saved
    }
  }
}
