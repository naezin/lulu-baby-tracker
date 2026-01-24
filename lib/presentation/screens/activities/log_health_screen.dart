import '../../../data/services/firestore_stub.dart';
import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/models/baby_model.dart';
import '../../../core/utils/medication_calculator.dart';
import '../../../core/localization/app_localizations.dart';

/// 체온 및 투약 기록 화면
class LogHealthScreen extends StatefulWidget {
  const LogHealthScreen({super.key});

  @override
  State<LogHealthScreen> createState() => _LogHealthScreenState();
}

class _LogHealthScreenState extends State<LogHealthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('health_record')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.thermostat), text: l10n.translate('temperature')),
            Tab(icon: const Icon(Icons.medication), text: l10n.translate('medication')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TemperatureTab(),
          _MedicationTab(),
        ],
      ),
    );
  }
}

/// 체온 기록 탭
class _TemperatureTab extends StatefulWidget {
  @override
  State<_TemperatureTab> createState() => _TemperatureTabState();
}

class _TemperatureTabState extends State<_TemperatureTab> {
  final _temperatureController = TextEditingController();
  String _selectedUnit = 'celsius';
  DateTime _selectedTime = DateTime.now();
  final _notesController = TextEditingController();
  bool _isSaving = false;
  BabyModel? _babyProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadBabyProfile();
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadBabyProfile() async {
    try {
      const userId = 'demo-user';
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('babies')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        if (mounted) {
          setState(() {
            _babyProfile = BabyModel.fromJson({
              'id': snapshot.docs.first.id,
              ...snapshot.docs.first.data(),
            });
            _isLoadingProfile = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoadingProfile = false);
        }
      }
    } catch (e) {
      print('Error loading baby profile: $e');
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  double? get _temperature {
    final text = _temperatureController.text;
    return double.tryParse(text);
  }

  bool get _isFever {
    final temp = _temperature;
    if (temp == null) return false;

    if (_selectedUnit == 'celsius') {
      return temp >= 38.0;
    } else {
      return temp >= 100.4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Unit Toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('temperature_unit'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'celsius',
                        label: Text(l10n.translate('celsius')),
                      ),
                      ButtonSegment(
                        value: 'fahrenheit',
                        label: Text(l10n.translate('fahrenheit')),
                      ),
                    ],
                    selected: {_selectedUnit},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedUnit = newSelection.first;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Temperature Input
          Card(
            color: _isFever ? Colors.red[50] : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.thermostat,
                        color: _isFever ? Colors.red : Colors.blue,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.translate('temperature'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isFever ? Colors.red : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _temperatureController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _isFever ? Colors.red : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: _selectedUnit == 'celsius' ? '36.5' : '97.7',
                      suffix: Text(
                        _selectedUnit == 'celsius' ? '℃' : '℉',
                        style: const TextStyle(fontSize: 24, color: Colors.grey),
                      ),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  if (_isFever) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.highFever,
                              style: TextStyle(
                                color: Colors.red[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Show fever advice if baby profile is loaded
                  if (_temperature != null && _babyProfile != null && !_isLoadingProfile) ...[
                    const SizedBox(height: 12),
                    _buildFeverAdviceCard(),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Time Picker
          Card(
            child: ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(l10n.translate('time')),
              subtitle: Text(
                '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: TextButton(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_selectedTime),
                  );
                  if (time != null) {
                    setState(() {
                      _selectedTime = DateTime(
                        _selectedTime.year,
                        _selectedTime.month,
                        _selectedTime.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                },
                child: Text(l10n.translate('change')),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notes
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.translate('notes_optional'),
                  hintText: l10n.additionalObservationsHint,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Save Button
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveTemperature,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(_isSaving ? l10n.saving : l10n.saveTemperature),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: _isFever ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeverAdviceCard() {
    final l10n = AppLocalizations.of(context);
    final temp = _temperature;
    if (temp == null || _babyProfile == null) return const SizedBox.shrink();

    // Convert to Celsius for fever guidelines
    double tempCelsius = temp;
    if (_selectedUnit == 'fahrenheit') {
      tempCelsius = (temp - 32) * 5 / 9;
    }

    final advice = FeverGuidelines.getAdvice(tempCelsius, _babyProfile!.ageInMonths);

    // Show emergency dialog for infants < 3 months with fever >= 38°C
    if (advice.needsUrgentCare) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showEmergencyDialog(advice);
      });
    }

    Color cardColor;
    Color textColor;
    IconData icon;

    switch (advice.severity) {
      case FeverSeverity.emergency:
        cardColor = Colors.red[100]!;
        textColor = Colors.red[900]!;
        icon = Icons.emergency;
        break;
      case FeverSeverity.high:
        cardColor = Colors.orange[100]!;
        textColor = Colors.orange[900]!;
        icon = Icons.warning;
        break;
      case FeverSeverity.moderate:
        cardColor = Colors.yellow[100]!;
        textColor = Colors.orange[800]!;
        icon = Icons.info;
        break;
      default:
        cardColor = Colors.blue[50]!;
        textColor = Colors.blue[900]!;
        icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: advice.needsUrgentCare ? Colors.red : Colors.grey[300]!,
          width: advice.needsUrgentCare ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: textColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${l10n.feverAdviceWithMonths} (${_babyProfile!.ageInMonths}${l10n.monthsOld})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...advice.actions.map((action) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $action',
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                ),
              )),
          if (advice.tips.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 4),
            Text(
              l10n.tips,
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor)
            ),
            const SizedBox(height: 4),
            ...advice.tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    tip,
                    style: TextStyle(color: textColor, fontSize: 12),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  void _showEmergencyDialog(FeverAdvice advice) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red[50],
        icon: const Icon(Icons.emergency, color: Colors.red, size: 48),
        title: Text(
          l10n.emergencyWarning,
          style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.emergencyFeverMessage(
                _temperature!.toStringAsFixed(1),
                _selectedUnit == 'celsius' ? 'C' : 'F',
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.immediateEvaluation,
                    style: TextStyle(
                      color: Colors.red[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.actionsToTakeNow,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...advice.actions.map((action) => Padding(
                        padding: const EdgeInsets.only(top: 4, left: 8),
                        child: Text('• $action'),
                      )),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.phone, color: Colors.green),
            label: Text(l10n.callPediatrician),
            style: TextButton.styleFrom(
              backgroundColor: Colors.green[50],
              foregroundColor: Colors.green[900],
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.local_hospital, color: Colors.red),
            label: Text(l10n.goToER),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red[100],
              foregroundColor: Colors.red[900],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTemperature() async {
    final l10n = AppLocalizations.of(context);
    final temp = _temperature;
    if (temp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterValidTemperature)),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      const userId = 'demo-user';
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('activities')
          .doc();

      final activity = ActivityModel.temperature(
        id: docRef.id,
        time: _selectedTime,
        temperature: temp,
        unit: _selectedUnit,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await docRef.set(activity.toJson());

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.temperatureRecorded)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithMessage(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

/// 투약 기록 탭
class _MedicationTab extends StatefulWidget {
  @override
  State<_MedicationTab> createState() => _MedicationTabState();
}

class _MedicationTabState extends State<_MedicationTab> {
  String _medicationType = 'fever_reducer';
  String? _selectedMedication;
  final _dosageController = TextEditingController();
  String _dosageUnit = 'ml';
  DateTime _selectedTime = DateTime.now();
  int _hoursUntilNext = 4;
  final _notesController = TextEditingController();
  bool _isSaving = false;
  BabyModel? _babyProfile;
  bool _isLoadingProfile = true;

  Map<String, List<String>> _getMedicationsByType(AppLocalizations l10n) {
    return {
      'fever_reducer': [
        l10n.translate('acetaminophen_tylenol'),
        l10n.translate('ibuprofen_advil'),
        l10n.translate('other'),
      ],
      'antibiotic': [
        l10n.translate('amoxicillin'),
        l10n.translate('azithromycin'),
        l10n.translate('cefdinir'),
        l10n.translate('other'),
      ],
      'other': [l10n.translate('other')],
    };
  }

  @override
  void initState() {
    super.initState();
    _loadBabyProfile();
  }

  @override
  void dispose() {
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadBabyProfile() async {
    try {
      const userId = 'demo-user';
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('babies')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        if (mounted) {
          setState(() {
            _babyProfile = BabyModel.fromJson({
              'id': snapshot.docs.first.id,
              ...snapshot.docs.first.data(),
            });
            _isLoadingProfile = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoadingProfile = false);
        }
      }
    } catch (e) {
      print('Error loading baby profile: $e');
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Medication Type
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('medication_type'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(l10n.feverReducer),
                        selected: _medicationType == 'fever_reducer',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _medicationType = 'fever_reducer';
                              _selectedMedication = null;
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: Text(l10n.antibiotic),
                        selected: _medicationType == 'antibiotic',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _medicationType = 'antibiotic';
                              _selectedMedication = null;
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: Text(l10n.medicationOther),
                        selected: _medicationType == 'other',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _medicationType = 'other';
                              _selectedMedication = null;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Medication Name Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.medicationName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _getMedicationsByType(l10n)[_medicationType]!.map((med) {
                      return FilterChip(
                        label: Text(med),
                        selected: _selectedMedication == med,
                        onSelected: (selected) {
                          setState(() {
                            _selectedMedication = selected ? med : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Dosage Calculator (if applicable)
          if (_medicationType == 'fever_reducer' &&
              _selectedMedication != null &&
              _selectedMedication != l10n.translate('other') &&
              _babyProfile?.weightKg != null &&
              !_isLoadingProfile) ...[
            _buildDosageCalculatorCard(),
            const SizedBox(height: 16),
          ],

          // Dosage
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dosage,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _dosageController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            hintText: '5.0',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _dosageUnit,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: ['ml', 'mg', 'tablet'].map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _dosageUnit = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Safety Timer
          if (_medicationType == 'fever_reducer') ...[
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          l10n.safetyTimer,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.nextDoseAvailableIn),
                    const SizedBox(height: 8),
                    SegmentedButton<int>(
                      segments: [
                        ButtonSegment(value: 4, label: Text(l10n.fourHours)),
                        ButtonSegment(value: 6, label: Text(l10n.sixHours)),
                        ButtonSegment(value: 8, label: Text(l10n.eightHours)),
                      ],
                      selected: {_hoursUntilNext},
                      onSelectionChanged: (Set<int> newSelection) {
                        setState(() {
                          _hoursUntilNext = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.translate('next_dose').replaceAll('{time}', '${_selectedTime.add(Duration(hours: _hoursUntilNext)).hour.toString().padLeft(2, '0')}:${_selectedTime.add(Duration(hours: _hoursUntilNext)).minute.toString().padLeft(2, '0')}'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[900],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Time
          Card(
            child: ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(l10n.timeGiven),
              subtitle: Text(
                '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: TextButton(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_selectedTime),
                  );
                  if (time != null) {
                    setState(() {
                      _selectedTime = DateTime(
                        _selectedTime.year,
                        _selectedTime.month,
                        _selectedTime.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                },
                child: Text(l10n.translate('change')),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notes
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.translate('notes_optional'),
                  hintText: l10n.reasonForMedicationHint,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Save Button
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveMedication,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(_isSaving ? l10n.saving : l10n.saveMedication),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDosageCalculatorCard() {
    final l10n = AppLocalizations.of(context);
    if (_babyProfile?.weightKg == null || _selectedMedication == null) {
      return const SizedBox.shrink();
    }

    DosageRecommendation? dosage;

    if (_selectedMedication == l10n.translate('acetaminophen_tylenol')) {
      dosage = MedicationCalculator.calculateAcetaminophen(_babyProfile!.weightKg!);
    } else if (_selectedMedication == l10n.translate('ibuprofen_advil')) {
      dosage = MedicationCalculator.calculateIbuprofen(
        _babyProfile!.weightKg!,
        _babyProfile!.ageInMonths,
      );
    }

    if (dosage == null) {
      // Ibuprofen not allowed for < 6 months
      return Card(
        color: Colors.red[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.block, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.ibuprofenWarning,
                  style: TextStyle(
                    color: Colors.red[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: Colors.blue[900]),
                const SizedBox(width: 8),
                Text(
                  l10n.dosageCalculator,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.medicationLabel(dosage.medicationName),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.babyWeightLabel(dosage.weightKg.toStringAsFixed(1)),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const Divider(height: 24),
                  Text(
                    l10n.recommendedDosage,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.straighten, size: 20, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        dosage.dosageRangeMg,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.water_drop, size: 20, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        dosage.dosageRangeMl,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.frequencyEveryHours(int.parse(dosage.frequencyHours)),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    l10n.maxDailyMg(dosage.maxDailyMg.toStringAsFixed(0)),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    l10n.concentrationLabel(dosage.concentration),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            if (dosage.warnings.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange[900], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n.safetyWarnings,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...dosage.warnings.map((warning) => Padding(
                          padding: const EdgeInsets.only(bottom: 4, left: 4),
                          child: Text(
                            '• $warning',
                            style: TextStyle(
                              color: Colors.orange[900],
                              fontSize: 13,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.guidelineDisclaimer,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
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

  Future<void> _saveMedication() async {
    final l10n = AppLocalizations.of(context);
    if (_selectedMedication == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectMedication)),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      const userId = 'demo-user';
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('activities')
          .doc();

      final activity = ActivityModel.medication(
        id: docRef.id,
        time: _selectedTime,
        medicationType: _medicationType,
        medicationName: _selectedMedication,
        dosageAmount: double.tryParse(_dosageController.text),
        dosageUnit: _dosageUnit,
        hoursUntilNextDose: _medicationType == 'fever_reducer' ? _hoursUntilNext : null,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await docRef.set(activity.toJson());

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _medicationType == 'fever_reducer'
                  ? l10n.medicationRecordedNextDose(_hoursUntilNext)
                  : l10n.medicationRecorded,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithMessage(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
