import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/unit_preferences_provider.dart';
import '../export/export_data_screen.dart';
import '../import/import_data_screen.dart';
import '../activities/activity_history_screen.dart';
import '../demo_setup_screen.dart';
import '../../../data/services/notification_service.dart';
import 'widget_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _notificationService = NotificationService();
  bool _sweetSpotNotificationsEnabled = false;
  bool _marketingNotificationsEnabled = false;
  int _minutesBefore = 15;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final pending = await _notificationService.getPendingNotifications();
      if (mounted) {
        setState(() {
          _sweetSpotNotificationsEnabled = pending.isNotEmpty;
        });
      }
    } catch (e) {
      // Notifications not supported on web
      print('Notifications not available: $e');
      if (mounted) {
        setState(() {
          _sweetSpotNotificationsEnabled = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        children: [
          // Language Settings Section
          _buildSectionHeader(context, l10n.language),
          Consumer<LocaleProvider>(
            builder: (context, localeProvider, child) {
              return Column(
                children: [
                  RadioListTile<String>(
                    title: Text(l10n.languageEnglish),
                    subtitle: Text(l10n.languageEnglishUS),
                    value: 'en',
                    groupValue: localeProvider.locale.languageCode,
                    onChanged: (value) {
                      localeProvider.setEnglish();
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(l10n.languageKorean),
                    subtitle: Text(l10n.languageKoreanKR),
                    value: 'ko',
                    groupValue: localeProvider.locale.languageCode,
                    onChanged: (value) {
                      localeProvider.setKorean();
                    },
                  ),
                ],
              );
            },
          ),
          const Divider(),

          // Unit Settings Section
          _buildSectionHeader(context, l10n.units),
          Consumer<UnitPreferencesProvider>(
            builder: (context, unitPrefs, child) {
              return Column(
                children: [
                  // Temperature Unit
                  ListTile(
                    leading: const Icon(Icons.thermostat),
                    title: Text(l10n.temperature),
                    trailing: SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'celsius',
                          label: Text(l10n.unitCelsius),
                        ),
                        ButtonSegment(
                          value: 'fahrenheit',
                          label: Text(l10n.unitFahrenheit),
                        ),
                      ],
                      selected: {unitPrefs.temperatureUnit},
                      onSelectionChanged: (Set<String> newSelection) {
                        unitPrefs.setTemperatureUnit(newSelection.first);
                      },
                    ),
                  ),

                  // Weight Unit
                  ListTile(
                    leading: const Icon(Icons.monitor_weight),
                    title: Text(l10n.weight),
                    trailing: SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'kg',
                          label: Text(l10n.unitKg),
                        ),
                        ButtonSegment(
                          value: 'lb',
                          label: Text(l10n.unitLb),
                        ),
                      ],
                      selected: {unitPrefs.weightUnit},
                      onSelectionChanged: (Set<String> newSelection) {
                        unitPrefs.setWeightUnit(newSelection.first);
                      },
                    ),
                  ),

                  // Volume Unit
                  ListTile(
                    leading: const Icon(Icons.local_drink),
                    title: Text(l10n.volume),
                    trailing: SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'ml',
                          label: Text(l10n.unitMl),
                        ),
                        ButtonSegment(
                          value: 'oz',
                          label: Text(l10n.unitOz),
                        ),
                      ],
                      selected: {unitPrefs.volumeUnit},
                      onSelectionChanged: (Set<String> newSelection) {
                        unitPrefs.setVolumeUnit(newSelection.first);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          const Divider(),

          // Notification Settings Section
          _buildSectionHeader(context, l10n.notifications),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l10n.sweetSpotAlerts),
                  subtitle: Text(l10n.notifyMeMinutesBefore(_minutesBefore)),
                  value: _sweetSpotNotificationsEnabled,
                  onChanged: (value) async {
                    if (value) {
                      final granted = await _notificationService.requestPermission();
                      if (granted) {
                        setState(() => _sweetSpotNotificationsEnabled = true);
                        _showSnackBar('Sweet Spot notifications enabled!');
                      } else {
                        _showSnackBar(l10n.translate('error_permission_denied'), isError: true);
                      }
                    } else {
                      await _notificationService.cancelAllNotifications();
                      setState(() => _sweetSpotNotificationsEnabled = false);
                      _showSnackBar(l10n.translate('notification_sweet_spot_disabled'));
                    }
                    _loadNotificationSettings();
                  },
                  secondary: const Icon(Icons.bedtime),
                ),
                if (_sweetSpotNotificationsEnabled)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.translate('notification_alert_time_format').replaceAll('{minutes}', '$_minutesBefore'),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        Slider(
                          value: _minutesBefore.toDouble(),
                          min: 5,
                          max: 30,
                          divisions: 5,
                          label: '$_minutesBefore min',
                          onChanged: (value) {
                            setState(() {
                              _minutesBefore = value.toInt();
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.translate('slider_label_5_minutes'), style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                            Text(l10n.translate('slider_label_30_minutes'), style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                          ],
                        ),
                      ],
                    ),
                  ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(l10n.appUpdatesAndTips),
                  subtitle: Text(l10n.receiveHelpfulTips),
                  value: _marketingNotificationsEnabled,
                  onChanged: (value) {
                    setState(() => _marketingNotificationsEnabled = value);
                    _showSnackBar(
                      value ? l10n.translate('notification_updates_enabled') : l10n.translate('notification_updates_disabled'),
                    );
                  },
                  secondary: const Icon(Icons.tips_and_updates),
                ),
              ],
            ),
          ),
          const Divider(),

          // Widget Settings Section
          _buildSectionHeader(context, l10n.translate('widget_settings')),
          ListTile(
            leading: const Icon(Icons.widgets),
            title: Text(l10n.translate('widget_settings')),
            subtitle: Text(l10n.translate('widget_settings_description')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WidgetSettingsScreen()),
              );
            },
          ),
          const Divider(),

          // Data Management Section
          _buildSectionHeader(context, l10n.dataManagement),
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(l10n.activityHistory),
            subtitle: Text(l10n.viewAllRecordedActivities),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ActivityHistoryScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: Text(l10n.exportData),
            subtitle: Text(l10n.exportToCSV),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExportDataScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: Text(l10n.importData),
            subtitle: Text(l10n.importFromCSV),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ImportDataScreen()),
              );
            },
          ),
          const Divider(),

          // Demo & Testing Section
          _buildSectionHeader(context, l10n.translate('demo_and_testing')),
          ListTile(
            leading: const Icon(Icons.play_circle_outline),
            title: Text(l10n.sweetSpotDemo),
            subtitle: Text(l10n.tryAISleepPredictionDemo),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DemoSetupScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
