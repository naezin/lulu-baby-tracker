import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/services/csv_import_service.dart';

/// 데이터 가져오기 화면
class ImportDataScreen extends StatefulWidget {
  const ImportDataScreen({Key? key}) : super(key: key);

  @override
  State<ImportDataScreen> createState() => _ImportDataScreenState();
}

class _ImportDataScreenState extends State<ImportDataScreen> {
  final _csvService = CsvImportService();

  bool _isImporting = false;
  double _progress = 0.0;
  String _statusMessage = '';
  File? _selectedFile;
  ImportResult? _importResult;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('import_title')),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Header Card
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.file_upload, size: 48, color: Colors.blue),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.translate('import_your_baby_log'),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          l10n.translate('import_upload_csv_description'),
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // File Picker
          if (!_isImporting && _importResult == null) ...[
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_selectedFile == null) ...[
                      Icon(
                        Icons.upload_file,
                        size: 64,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 16),
                      Text(
                        l10n.translate('import_select_csv_file'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        l10n.translate('import_choose_csv_description'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _pickFile,
                          icon: Icon(Icons.folder_open),
                          label: Text(l10n.translate('import_choose_file')),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.check_circle,
                        size: 64,
                        color: Colors.green,
                      ),
                      SizedBox(height: 16),
                      Text(
                        l10n.translate('import_file_selected'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.description, color: Colors.blue),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedFile!.path.split('/').last,
                                style: TextStyle(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedFile = null;
                                });
                              },
                              icon: Icon(Icons.cancel),
                              label: Text(l10n.translate('cancel')),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _importData,
                              icon: Icon(Icons.upload),
                              label: Text(l10n.translate('import_start')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],

          // Progress Indicator
          if (_isImporting) ...[
            Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 6,
                      backgroundColor: Colors.grey[200],
                    ),
                    SizedBox(height: 16),
                    Text(
                      l10n.translate('import_progress_percentage').replaceAll('{percentage}', '${(_progress * 100).toInt()}'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
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

          // Import Result
          if (_importResult != null) ...[
            SizedBox(height: 24),
            Text(
              l10n.translate('import_summary'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildResultRow(
                      l10n,
                      icon: Icons.check_circle,
                      label: l10n.translate('import_total_records'),
                      value: '${_importResult!.totalImported}',
                      color: Colors.green,
                    ),
                    Divider(),
                    _buildResultRow(
                      l10n,
                      icon: Icons.nightlight,
                      label: l10n.translate('import_sleep_records'),
                      value: '${_importResult!.sleepRecordsImported}',
                      color: Colors.purple,
                    ),
                    Divider(),
                    _buildResultRow(
                      l10n,
                      icon: Icons.restaurant,
                      label: l10n.translate('import_feeding_records'),
                      value: '${_importResult!.feedingRecordsImported}',
                      color: Colors.orange,
                    ),
                    Divider(),
                    _buildResultRow(
                      l10n,
                      icon: Icons.baby_changing_station,
                      label: l10n.translate('import_diaper_records'),
                      value: '${_importResult!.diaperRecordsImported}',
                      color: Colors.green,
                    ),
                    if (_importResult!.duplicatesSkipped > 0) ...[
                      Divider(),
                      _buildResultRow(
                        l10n,
                        icon: Icons.info,
                        label: l10n.translate('import_duplicates_skipped'),
                        value: '${_importResult!.duplicatesSkipped}',
                        color: Colors.grey,
                      ),
                    ],
                    if (_importResult!.errorsEncountered > 0) ...[
                      Divider(),
                      _buildResultRow(
                        l10n,
                        icon: Icons.error,
                        label: l10n.translate('import_errors'),
                        value: '${_importResult!.errorsEncountered}',
                        color: Colors.red,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedFile = null;
                    _importResult = null;
                  });
                },
                icon: Icon(Icons.refresh),
                label: Text(l10n.translate('import_another_file')),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.done),
                label: Text(l10n.translate('done')),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],

          SizedBox(height: 24),

          // Info Card
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        l10n.translate('import_csv_format_guide'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    l10n.translate('import_csv_format_details'),
                    style: TextStyle(color: Colors.blue[800]),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Supported Headers Card
          Card(
            color: Colors.purple[50],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.list_alt, color: Colors.purple),
                      SizedBox(width: 8),
                      Text(
                        l10n.translate('import_recognized_headers'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[900],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    l10n.translate('import_headers_details'),
                    style: TextStyle(
                      color: Colors.purple[800],
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(
    AppLocalizations l10n, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      _showErrorDialog(l10n.translate('import_failed_to_pick').replaceAll('{error}', e.toString()));
    }
  }

  Future<void> _importData() async {
    if (_selectedFile == null) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isImporting = true;
      _progress = 0.0;
      _statusMessage = l10n.translate('import_starting');
    });

    try {
      // Using demo user ID for now
      const userId = 'demo_user';

      // Import data with progress callback
      final result = await _csvService.importFromCsv(
        userId: userId,
        csvFile: _selectedFile!,
        onProgress: (progress, message) {
          setState(() {
            _progress = progress;
            _statusMessage = message;
          });
        },
      );

      setState(() {
        _isImporting = false;
        _importResult = result;
      });

      // Show success dialog
      _showSuccessDialog(result);
    } catch (e) {
      setState(() {
        _isImporting = false;
      });

      _showErrorDialog(e.toString());
    }
  }

  void _showSuccessDialog(ImportResult result) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text(l10n.translate('import_complete')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.translate('import_complete_message').replaceAll('{count}', '${result.totalImported}'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(l10n.translate('import_sleep_emoji').replaceAll('{count}', '${result.sleepRecordsImported}')),
            Text(l10n.translate('import_feeding_emoji').replaceAll('{count}', '${result.feedingRecordsImported}')),
            Text(l10n.translate('import_diaper_emoji').replaceAll('{count}', '${result.diaperRecordsImported}')),
            if (result.duplicatesSkipped > 0) ...[
              SizedBox(height: 12),
              Text(
                l10n.translate('import_duplicates_warning').replaceAll('{count}', '${result.duplicatesSkipped}'),
                style: TextStyle(color: Colors.orange),
              ),
            ],
            if (result.errorsEncountered > 0) ...[
              SizedBox(height: 12),
              Text(
                l10n.translate('import_errors_warning').replaceAll('{count}', '${result.errorsEncountered}'),
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('ok')),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text(l10n.translate('import_failed')),
          ],
        ),
        content: Text(l10n.translate('import_failed_message').replaceAll('{error}', error)),
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
