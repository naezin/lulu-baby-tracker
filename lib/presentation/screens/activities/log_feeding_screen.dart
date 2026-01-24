import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/services/widget_service.dart';
import '../../../core/localization/app_localizations.dart';

/// 수유 기록 화면
class LogFeedingScreen extends StatefulWidget {
  const LogFeedingScreen({super.key});

  @override
  State<LogFeedingScreen> createState() => _LogFeedingScreenState();
}

class _LogFeedingScreenState extends State<LogFeedingScreen> {
  final _storage = LocalStorageService();
  final _widgetService = WidgetService();

  DateTime _feedingTime = DateTime.now();
  String _feedingType = 'bottle';
  double _amountMl = 120.0;
  String _breastSide = 'both';
  final _notesController = TextEditingController();

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
        title: Text(l10n.translate('log_feeding')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant, size: 32, color: Colors.orange),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.translate('record_feeding'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.translate('track_feeding_types'),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Feeding Time
            _buildSectionTitle(l10n.translate('feeding_time')),
            const SizedBox(height: 8),
            _buildTimeSelector(),

            const SizedBox(height: 24),

            // Feeding Type
            _buildSectionTitle(l10n.translate('feeding_type')),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildTypeChip('bottle', '🍼', l10n.translate('bottle')),
                _buildTypeChip('breast', '🤱', l10n.translate('breast')),
                _buildTypeChip('solid', '🥄', l10n.translate('solid_food')),
              ],
            ),

            const SizedBox(height: 24),

            // Amount (for bottle/solid)
            if (_feedingType != 'breast') ...[
              _buildSectionTitle(l10n.translate('amount')),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text('${_amountMl.toInt()} ml'),
                        Slider(
                          value: _amountMl,
                          min: 0,
                          max: 300,
                          divisions: 30,
                          label: '${_amountMl.toInt()} ml',
                          onChanged: (value) {
                            setState(() {
                              _amountMl = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(_amountMl * 0.033814).toStringAsFixed(1)} oz',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[900],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Breast Side (for breastfeeding)
            if (_feedingType == 'breast') ...[
              _buildSectionTitle(l10n.translate('breast_side')),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildSideChip('left', l10n.translate('left')),
                  _buildSideChip('right', l10n.translate('right')),
                  _buildSideChip('both', l10n.translate('both')),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Notes
            _buildSectionTitle(l10n.translate('notes_optional')),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.translate('observations_hint_feeding'),
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
                onPressed: _saveFeeding,
                icon: const Icon(Icons.check),
                label: Text(
                  l10n.translate('save_feeding_record'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
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

  Widget _buildTimeSelector() {
    return InkWell(
      onTap: _selectTime,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.orange),
            const SizedBox(width: 16),
            Text(
              DateFormat('MMM d, yyyy  h:mm a').format(_feedingTime),
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

  Widget _buildTypeChip(String value, String emoji, String label) {
    final isSelected = _feedingType == value;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _feedingType = value;
        });
      },
      selectedColor: Colors.orange[100],
    );
  }

  Widget _buildSideChip(String value, String label) {
    final isSelected = _breastSide == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _breastSide = value;
        });
      },
      selectedColor: Colors.pink[100],
    );
  }

  Future<void> _selectTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _feedingTime,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_feedingTime),
    );

    if (time == null) return;

    setState(() {
      _feedingTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _saveFeeding() async {
    final activity = ActivityModel.feeding(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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

    // Update widgets with new data
    await _widgetService.updateAllWidgets();

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('feeding_recorded_success')),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }
}
