import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/services/csv_export_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../di/injection_container.dart';

/// 데이터 내보내기 화면
class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  final _csvService = sl<CsvExportService>();

  bool _isExporting = false;
  double _progress = 0.0;
  String _statusMessage = '';
  Map<String, dynamic>? _summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('export_data')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.file_download, size: 48, color: Colors.green),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.translate('export_your_baby_log'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.translate('download_data_as_csv'),
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Export Button
          if (!_isExporting) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.cloud_download,
                      size: 64,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.translate('ready_to_export'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.translate('export_description'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _exportData,
                        icon: const Icon(Icons.download),
                        label: Text(l10n.translate('export_to_csv')),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Progress Indicator
          if (_isExporting) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 6,
                      backgroundColor: Colors.grey[200],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${(_progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.grey[200],
                      minHeight: 8,
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Summary (after export)
          if (_summary != null) ...[
            const SizedBox(height: 24),
            Text(
              l10n.translate('export_summary'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      icon: Icons.nightlight,
                      label: l10n.translate('sleep_records'),
                      value: '${_summary!['total_sleep_records']}',
                      color: Colors.purple,
                    ),
                    const Divider(),
                    _buildSummaryRow(
                      icon: Icons.schedule,
                      label: l10n.translate('total_sleep_hours'),
                      value: l10n.translate('hours_value').replaceAll('{value}', '${_summary!['total_sleep_hours']}'),
                      color: Colors.blue,
                    ),
                    const Divider(),
                    _buildSummaryRow(
                      icon: Icons.restaurant,
                      label: l10n.translate('feeding_records'),
                      value: '${_summary!['total_feedings']}',
                      color: Colors.orange,
                    ),
                    const Divider(),
                    _buildSummaryRow(
                      icon: Icons.baby_changing_station,
                      label: l10n.translate('diaper_changes'),
                      value: '${_summary!['total_diapers']}',
                      color: Colors.green,
                    ),
                    const Divider(),
                    _buildSummaryRow(
                      icon: Icons.date_range,
                      label: l10n.translate('date_range'),
                      value: _getDateRangeString(),
                      color: Colors.pink,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _exportData,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.translate('export_again')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Info Card
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        l10n.translate('about_csv_export'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.translate('csv_export_info'),
                    style: TextStyle(color: Colors.blue[800]),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sharing Options Card
          Card(
            color: Colors.purple[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.share, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                        l10n.translate('share_options'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.translate('share_options_info'),
                    style: TextStyle(color: Colors.purple[800]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _getDateRangeString() {
    if (_summary == null) return '';

    final start = _summary!['date_range_start'] as DateTime?;
    final end = _summary!['date_range_end'] as DateTime?;

    if (start == null || end == null) {
      final l10n = AppLocalizations.of(context);
      return l10n.translate('not_available');
    }

    final format = DateFormat('MMM d');
    return '${format.format(start)} - ${format.format(end)}';
  }

  Future<void> _exportData() async {
    final l10n = AppLocalizations.of(context);

    setState(() {
      _isExporting = true;
      _progress = 0.0;
      _statusMessage = l10n.translate('starting_export');
      _summary = null;
    });

    try {
      // Using demo user ID for now
      const userId = 'demo_user';

      // Get localization
      final l10n = AppLocalizations.of(context);

      // Export data with progress callback
      final csvFile = await _csvService.exportAllDataToCsv(
        babyId: userId,
        l10n: l10n,
        onProgress: (progress, message) {
          setState(() {
            _progress = progress;
            _statusMessage = message;
          });
        },
      );

      // Generate summary
      // Note: We need to fetch data again for summary
      // In production, optimize by reusing fetched data
      final sleepRecords = await _csvService.fetchSleepRecords(userId, l10n);
      final feedingRecords = await _csvService.fetchFeedingRecords(userId, l10n);
      final diaperRecords = await _csvService.fetchDiaperRecords(userId, l10n);

      final summary = _csvService.generateSummary(
        sleepRecords: sleepRecords,
        feedingRecords: feedingRecords,
        diaperRecords: diaperRecords,
        l10n: l10n,
      );

      setState(() {
        _isExporting = false;
        _summary = summary;
      });

      // Show success and share options
      _showExportSuccessDialog(csvFile);
    } catch (e) {
      setState(() {
        _isExporting = false;
      });

      _showErrorDialog(e.toString());
    }
  }

  void _showExportSuccessDialog(File csvFile) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(width: 12),
            Text(l10n.translate('export_complete')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.translate('export_success_message')),
            const SizedBox(height: 16),
            Text(
              l10n.translate('file_label').replaceAll('{filename}', csvFile.path.split('/').last),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('close')),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final l10nContext = AppLocalizations.of(context);
              Navigator.pop(context);
              await _csvService.shareCsvFile(csvFile, l10nContext);
            },
            icon: const Icon(Icons.share),
            label: Text(l10n.translate('share')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 32),
            const SizedBox(width: 12),
            Text(l10n.translate('export_failed')),
          ],
        ),
        content: Text(l10n.translate('export_error_message').replaceAll('{error}', error)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('close')),
          ),
        ],
      ),
    );
  }
}
