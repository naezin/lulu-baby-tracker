import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/services/widget_service.dart';
import '../../../core/localization/app_localizations.dart';

/// 배변 기록 화면
class LogDiaperScreen extends StatefulWidget {
  const LogDiaperScreen({Key? key}) : super(key: key);

  @override
  State<LogDiaperScreen> createState() => _LogDiaperScreenState();
}

class _LogDiaperScreenState extends State<LogDiaperScreen> {
  final _storage = LocalStorageService();
  final _widgetService = WidgetService();

  DateTime _diaperTime = DateTime.now();
  String _diaperType = 'wet';
  final _notesController = TextEditingController();

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
        title: Text(l10n.translate('log_diaper')),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.baby_changing_station, size: 32, color: Colors.green),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.translate('record_diaper_change'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            l10n.translate('track_diaper_types'),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Diaper Time
            _buildSectionTitle(l10n.translate('diaper_change_time')),
            SizedBox(height: 8),
            _buildTimeSelector(),

            SizedBox(height: 24),

            // Diaper Type
            _buildSectionTitle(l10n.translate('diaper_type')),
            SizedBox(height: 16),
            Column(
              children: [
                _buildTypeCard('wet', '💧', l10n.translate('wet_desc'), l10n.translate('urineOnly')),
                SizedBox(height: 12),
                _buildTypeCard('dirty', '💩', l10n.translate('dirty_desc'), l10n.translate('bowelMovement')),
                SizedBox(height: 12),
                _buildTypeCard('both', '💧💩', l10n.translate('both_desc'), l10n.translate('wet_and_dirty')),
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
                hintText: l10n.translate('observations_hint_diaper'),
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
                onPressed: _saveDiaper,
                icon: Icon(Icons.check),
                label: Text(
                  l10n.translate('save_diaper_record'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
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

  Widget _buildTimeSelector() {
    return InkWell(
      onTap: _selectTime,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: Colors.green),
            SizedBox(width: 16),
            Text(
              DateFormat('MMM d, yyyy  h:mm a').format(_diaperTime),
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

  Widget _buildTypeCard(String value, String emoji, String title, String subtitle) {
    final isSelected = _diaperType == value;

    return InkWell(
      onTap: () {
        setState(() {
          _diaperType = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? Colors.green[100] : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: TextStyle(fontSize: 24)),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.green[900] : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.green, size: 28),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _diaperTime,
      firstDate: DateTime.now().subtract(Duration(days: 7)),
      lastDate: DateTime.now().add(Duration(days: 1)),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_diaperTime),
    );

    if (time == null) return;

    setState(() {
      _diaperTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _saveDiaper() async {
    final activity = ActivityModel.diaper(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      time: _diaperTime,
      diaperType: _diaperType,
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
          content: Text(l10n.translate('diaper_recorded_success')),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }
}
