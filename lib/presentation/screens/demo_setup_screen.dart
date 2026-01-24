import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/baby_model.dart';
import '../providers/sweet_spot_provider.dart';
import '../../core/localization/app_localizations.dart';

/// Sweet Spot 데모를 위한 설정 화면
class DemoSetupScreen extends StatefulWidget {
  const DemoSetupScreen({super.key});

  @override
  State<DemoSetupScreen> createState() => _DemoSetupScreenState();
}

class _DemoSetupScreenState extends State<DemoSetupScreen> {
  int _selectedAgeMonths = 6;
  DateTime _lastWakeUpTime = DateTime.now().subtract(const Duration(hours: 2));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('sweet_spot_demo_title')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              l10n.translate('demo_try_sweet_spot_prediction'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.translate('demo_description'),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),

            // Baby Age Selection
            Text(
              l10n.translate('demo_baby_age'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.translate('demo_months_old').replaceAll('{months}', '$_selectedAgeMonths'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _selectedAgeMonths > 0
                            ? () {
                                setState(() {
                                  _selectedAgeMonths--;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      IconButton(
                        onPressed: _selectedAgeMonths < 24
                            ? () {
                                setState(() {
                                  _selectedAgeMonths++;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Last Wake Up Time
            Text(
              l10n.translate('demo_last_wake_up_time'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildTimeSelector(),
            const SizedBox(height: 32),

            // Calculate Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _calculateSweetSpot,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  l10n.translate('demo_calculate_sweet_spot'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.translate('demo_what_is_sweet_spot'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.translate('demo_sweet_spot_explanation'),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    final l10n = AppLocalizations.of(context);
    final presetTimes = [
      const Duration(minutes: 30),
      const Duration(hours: 1),
      const Duration(hours: 1, minutes: 30),
      const Duration(hours: 2),
      const Duration(hours: 2, minutes: 30),
      const Duration(hours: 3),
    ];

    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presetTimes.map((duration) {
            final time = DateTime.now().subtract(duration);
            final isSelected = _isSameMinute(time, _lastWakeUpTime);

            return ChoiceChip(
              label: Text(_formatDuration(duration, l10n)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _lastWakeUpTime = time;
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(_lastWakeUpTime),
            );
            if (time != null) {
              setState(() {
                final now = DateTime.now();
                _lastWakeUpTime = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  time.hour,
                  time.minute,
                );
              });
            }
          },
          icon: const Icon(Icons.access_time),
          label: Text(l10n.translate('demo_custom_time').replaceAll('{time}', _formatTime(_lastWakeUpTime, l10n))),
        ),
      ],
    );
  }

  bool _isSameMinute(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute;
  }

  String _formatDuration(Duration duration, AppLocalizations l10n) {
    if (duration.inMinutes < 60) {
      return l10n.translate('demo_time_ago_minutes').replaceAll('{minutes}', '${duration.inMinutes}');
    } else {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (minutes == 0) {
        return l10n.translate('demo_time_ago_hours').replaceAll('{hours}', '$hours');
      }
      return l10n.translate('demo_time_ago_hours_minutes')
          .replaceAll('{hours}', '$hours')
          .replaceAll('{minutes}', '$minutes');
    }
  }

  String _formatTime(DateTime time, AppLocalizations l10n) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12
        ? l10n.translate('demo_time_format_pm')
        : l10n.translate('demo_time_format_am');
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  void _calculateSweetSpot() {
    // Create demo baby
    final demoBaby = BabyModel(
      id: 'demo-baby',
      userId: 'demo-user',
      name: 'Demo Baby',
      birthDate: DateTime.now()
          .subtract(Duration(days: _selectedAgeMonths * 30))
          .toIso8601String(),
      isPremature: false,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    // Set baby context
    final provider = context.read<SweetSpotProvider>();
    provider.setBaby(demoBaby);
    provider.updateLastSleepActivity(_lastWakeUpTime);

    // Show result dialog
    showDialog(
      context: context,
      builder: (context) => _buildResultDialog(),
    );
  }

  Widget _buildResultDialog() {
    final l10n = AppLocalizations.of(context);

    return Consumer<SweetSpotProvider>(
      builder: (context, provider, child) {
        final sweetSpot = provider.currentSweetSpot;

        if (sweetSpot == null) {
          return AlertDialog(
            title: Text(l10n.translate('error_title')),
            content: Text(l10n.translate('demo_error_calculate')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.translate('ok')),
              ),
            ],
          );
        }

        return AlertDialog(
          title: Row(
            children: [
              Text(_getUrgencyEmoji(sweetSpot.urgencyLevel)),
              const SizedBox(width: 8),
              Expanded(child: Text(l10n.translate('demo_sweet_spot_result'))),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sweetSpot.getFormattedTimeRange(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                l10n.translate('demo_wake_window'),
                sweetSpot.wakeWindowData.displayRange,
              ),
              _buildInfoRow(
                l10n.translate('demo_age'),
                l10n.translate('demo_months').replaceAll('{months}', '$_selectedAgeMonths'),
              ),
              _buildInfoRow(
                l10n.translate('demo_recommended_naps'),
                l10n.translate('demo_naps_per_day').replaceAll('{naps}', '${sweetSpot.wakeWindowData.recommendedNaps}'),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  sweetSpot.userFriendlyMessage,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.translate('close')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(l10n.translate('demo_view_on_home')),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _getUrgencyEmoji(dynamic urgencyLevel) {
    final levelStr = urgencyLevel.toString();
    if (levelStr.contains('tooEarly')) return '⏰';
    if (levelStr.contains('approaching')) return '⏳';
    if (levelStr.contains('optimal')) return '✨';
    if (levelStr.contains('overtired')) return '⚠️';
    return '🌙';
  }
}
