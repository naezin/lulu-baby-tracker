import '../../../data/services/firestore_stub.dart';
import '../../../data/services/widget_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/models/baby_model.dart';
import '../../../core/localization/app_localizations.dart';
import '../../providers/baby_provider.dart';
import '../../widgets/lulu_time_picker.dart';

/// 체온 및 투약 기록 화면
class LogHealthScreen extends StatefulWidget {
  const LogHealthScreen({super.key});

  @override
  State<LogHealthScreen> createState() => _LogHealthScreenState();
}

class _LogHealthScreenState extends State<LogHealthScreen> with SingleTickerProviderStateMixin {
  static const Color _themeColor = Color(0xFFEF9A9A); // Pink/red for health
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      backgroundColor: const Color(0xFF0D1321),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.translate('health_record')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _themeColor,
          labelColor: _themeColor,
          unselectedLabelColor: Colors.grey[600],
          tabs: [
            Tab(icon: const Icon(Icons.thermostat_rounded), text: l10n.translate('temperature')),
            Tab(icon: const Icon(Icons.medication_rounded), text: l10n.translate('medication')),
            Tab(icon: Icon(Icons.trending_up_rounded), text: l10n.translate('growth_record_title') ?? '성장 기록'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TemperatureTab(),
          _MedicationTab(),
          _GrowthTab(),
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
  static const Color _themeColor = Color(0xFFEF9A9A);
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _themeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _themeColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _themeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.thermostat_rounded, color: _themeColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.translate('temperature'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.translate('temperature_record_baby') ?? 'Record baby\'s temperature',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Context Hint
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x33FFFFFF)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber[300], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.translate('temperature_normal_range') ?? 'Normal range: 36.5-37.5°C (97.7-99.5°F)\n38°C or higher is considered fever.',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Input Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x33FFFFFF)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unit Toggle
                _buildSectionLabel(l10n.translate('temperature_unit')),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LogOptionButton(
                        label: l10n.translate('celsius'),
                        isSelected: _selectedUnit == 'celsius',
                        themeColor: _themeColor,
                        onTap: () => setState(() => _selectedUnit = 'celsius'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LogOptionButton(
                        label: l10n.translate('fahrenheit'),
                        isSelected: _selectedUnit == 'fahrenheit',
                        themeColor: _themeColor,
                        onTap: () => setState(() => _selectedUnit = 'fahrenheit'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Temperature Input
                _buildSectionLabel(l10n.translate('temperature')),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isFever ? Colors.red[900]!.withOpacity(0.2) : const Color(0xFF1A2332),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isFever ? Colors.red : Colors.white.withOpacity(0.1),
                      width: _isFever ? 2 : 1,
                    ),
                  ),
                  child: TextField(
                    controller: _temperatureController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _isFever ? Colors.red : _themeColor,
                    ),
                    decoration: InputDecoration(
                      hintText: _selectedUnit == 'celsius' ? '36.5' : '97.7',
                      hintStyle: TextStyle(color: Colors.grey[700]),
                      suffixText: _selectedUnit == 'celsius' ? '°C' : '°F',
                      suffixStyle: TextStyle(fontSize: 24, color: Colors.grey[600]),
                      border: InputBorder.none,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),

                if (_isFever) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[900]!.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_rounded, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.highFever,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Time
                _buildSectionLabel(l10n.translate('time')),
                const SizedBox(height: 8),
                _buildTimeSelector(),

                const SizedBox(height: 16),

                // Notes
                _buildSectionLabel(l10n.translate('notes_optional')),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: l10n.additionalObservationsHint,
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
            ),
          ),

          const SizedBox(height: 24),

          // Save Button
          Container(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFever ? Colors.red : _themeColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: !_isSaving ? _saveTemperature : null,
              child: _isSaving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      l10n.saveTemperature,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
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
      onTap: () async {
        final selectedTime = await LuluTimePicker.show(
          context: context,
          initialTime: _selectedTime,
          dateRangeDays: 7,
          allowFutureTime: false,
        );
        if (selectedTime != null) {
          setState(() {
            _selectedTime = selectedTime;
          });
        }
      },
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
              '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Icon(Icons.edit_rounded, color: Colors.grey[600], size: 18),
          ],
        ),
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

      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      final babyId = babyProvider.currentBaby?.id ?? 'unknown';

      final activity = ActivityModel.temperature(
        id: docRef.id,
        babyId: babyId,
        time: _selectedTime,
        temperature: temp,
        unit: _selectedUnit,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await docRef.set(activity.toJson());

      // ✅ 위젯 업데이트
      await WidgetService().updateAllWidgets();

      if (mounted) {
        setState(() => _isSaving = false);

        final insights = [
          '🌡️ ${temp.toStringAsFixed(1)}${_selectedUnit == "celsius" ? "°C" : "°F"}',
          if (_isFever)
            l10n.translate('temperature_fever_status') ?? '⚠️ Fever detected'
          else
            l10n.translate('temperature_normal_status') ?? '✅ Normal temperature',
        ];

        showPostRecordFeedback(
          context: context,
          title: l10n.translate('temperature_record_complete') ?? 'Temperature Record Complete!',
          insights: insights,
          themeColor: _themeColor,
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

/// 투약 기록 탭 (simplified version - keeping core functionality)
class _MedicationTab extends StatefulWidget {
  @override
  State<_MedicationTab> createState() => _MedicationTabState();
}

class _MedicationTabState extends State<_MedicationTab> {
  static const Color _themeColor = Color(0xFFEF9A9A);
  String _medicationType = 'fever_reducer';
  String? _selectedMedication;
  final _dosageController = TextEditingController();
  String _dosageUnit = 'ml';
  DateTime _selectedTime = DateTime.now();
  int _hoursUntilNext = 4;
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _themeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _themeColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _themeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.medication_rounded, color: _themeColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.translate('medication'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.translate('medication_record_info') ?? 'Record medication information',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Input Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x33FFFFFF)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel(l10n.translate('medication_type')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    LogOptionButton(
                      label: l10n.feverReducer,
                      isSelected: _medicationType == 'fever_reducer',
                      themeColor: _themeColor,
                      onTap: () => setState(() {
                        _medicationType = 'fever_reducer';
                        _selectedMedication = null;
                      }),
                    ),
                    LogOptionButton(
                      label: l10n.antibiotic,
                      isSelected: _medicationType == 'antibiotic',
                      themeColor: _themeColor,
                      onTap: () => setState(() {
                        _medicationType = 'antibiotic';
                        _selectedMedication = null;
                      }),
                    ),
                    LogOptionButton(
                      label: l10n.medicationOther,
                      isSelected: _medicationType == 'other',
                      themeColor: _themeColor,
                      onTap: () => setState(() {
                        _medicationType = 'other';
                        _selectedMedication = null;
                      }),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _buildSectionLabel(l10n.dosage),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _dosageController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: '5.0',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: const Color(0xFF1A2332),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2332),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: DropdownButton<String>(
                          value: _dosageUnit,
                          dropdownColor: const Color(0xFF1A2332),
                          isExpanded: true,
                          underline: const SizedBox(),
                          style: const TextStyle(color: Colors.white),
                          items: ['ml', 'mg', 'tablet'].map((unit) {
                            return DropdownMenuItem(value: unit, child: Text(unit));
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) setState(() => _dosageUnit = value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _buildSectionLabel(l10n.translate('notes_optional')),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: l10n.reasonForMedicationHint,
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
            ),
          ),

          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _themeColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: !_isSaving ? _saveMedication : null,
              child: _isSaving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      l10n.saveMedication,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
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

  Future<void> _saveMedication() async {
    final l10n = AppLocalizations.of(context);

    setState(() => _isSaving = true);

    try {
      const userId = 'demo-user';
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('activities')
          .doc();

      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      final babyId = babyProvider.currentBaby?.id ?? 'unknown';

      final activity = ActivityModel.medication(
        id: docRef.id,
        babyId: babyId,
        time: _selectedTime,
        medicationType: _medicationType,
        medicationName: _selectedMedication,
        dosageAmount: double.tryParse(_dosageController.text),
        dosageUnit: _dosageUnit,
        hoursUntilNextDose: _medicationType == 'fever_reducer' ? _hoursUntilNext : null,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await docRef.set(activity.toJson());

      // ✅ 위젯 업데이트
      await WidgetService().updateAllWidgets();

      if (mounted) {
        setState(() => _isSaving = false);

        final dosage = _dosageController.text.isNotEmpty
            ? '${_dosageController.text}$_dosageUnit'
            : '';

        final insights = [
          '💊 $_medicationType',
          if (dosage.isNotEmpty) '📊 $dosage',
        ];

        showPostRecordFeedback(
          context: context,
          title: l10n.translate('medication_record_complete') ?? 'Medication Record Complete!',
          insights: insights,
          themeColor: _themeColor,
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

/// 성장 기록 탭 (키, 체중, 머리둘레)
class _GrowthTab extends StatefulWidget {
  @override
  State<_GrowthTab> createState() => _GrowthTabState();
}

class _GrowthTabState extends State<_GrowthTab> {
  static const Color _themeColor = Color(0xFFEF9A9A);
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _headCircumferenceController = TextEditingController();
  DateTime _selectedTime = DateTime.now();
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _headCircumferenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _themeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _themeColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _themeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.trending_up_rounded, color: _themeColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.translate('growth_record_title') ?? '성장 기록',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.translate('growth_record_subtitle') ?? '아기의 키, 체중, 머리둘레를 기록하세요',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Context Hint
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x33FFFFFF)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber[300], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.translate('growth_track_progress') ?? '정기적으로 기록하면 성장 추이를 확인할 수 있어요',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Input Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x33FFFFFF)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 체중
                _buildSectionLabel(l10n.translate('growth_weight_kg') ?? '체중 (kg)'),
                const SizedBox(height: 8),
                TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '예: 5.2',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    suffixText: 'kg',
                    suffixStyle: TextStyle(color: _themeColor),
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

                const SizedBox(height: 16),

                // 키
                _buildSectionLabel(l10n.translate('growth_height_cm') ?? '키 (cm)'),
                const SizedBox(height: 8),
                TextField(
                  controller: _heightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '예: 62.5',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    suffixText: 'cm',
                    suffixStyle: TextStyle(color: _themeColor),
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

                const SizedBox(height: 16),

                // 머리둘레
                _buildSectionLabel(l10n.translate('growth_head_cm') ?? '머리둘레 (cm)'),
                const SizedBox(height: 8),
                TextField(
                  controller: _headCircumferenceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '예: 40.5',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    suffixText: 'cm',
                    suffixStyle: TextStyle(color: _themeColor),
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

                const SizedBox(height: 16),

                // 측정 시간
                _buildSectionLabel(l10n.translate('time')),
                const SizedBox(height: 8),
                _buildTimeSelector(),

                const SizedBox(height: 16),

                // 메모
                _buildSectionLabel(l10n.translate('notes_optional')),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '예: 병원 방문 시 측정',
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
            ),
          ),

          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _themeColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: !_isSaving ? _saveGrowthRecord : null,
              child: _isSaving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      l10n.translate('growth_save_record') ?? '성장 기록 저장',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
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
      onTap: () async {
        final selectedTime = await LuluTimePicker.show(
          context: context,
          initialTime: _selectedTime,
          dateRangeDays: 365,
          allowFutureTime: false,
        );
        if (selectedTime != null) {
          setState(() {
            _selectedTime = selectedTime;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: _themeColor, size: 20),
            const SizedBox(width: 12),
            Text(
              '${_selectedTime.year}년 ${_selectedTime.month}월 ${_selectedTime.day}일',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Icon(Icons.edit_rounded, color: Colors.grey[600], size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _saveGrowthRecord() async {
    final l10n = AppLocalizations.of(context);
    // 적어도 하나의 값은 입력되어야 함
    if (_weightController.text.isEmpty &&
        _heightController.text.isEmpty &&
        _headCircumferenceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('growth_min_one_value') ?? '최소 하나 이상의 측정값을 입력해주세요')),
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

      // 🆕 현재 아기 ID 가져오기
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      final babyId = babyProvider.currentBaby?.id ?? 'unknown';

      final activity = ActivityModel(
        id: docRef.id,
        babyId: babyId, // 🆕
        type: ActivityType.health,
        timestamp: _selectedTime.toIso8601String(),
        weightKg: _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text)
            : null,
        lengthCm: _heightController.text.isNotEmpty
            ? double.tryParse(_heightController.text)
            : null,
        headCircumferenceCm: _headCircumferenceController.text.isNotEmpty
            ? double.tryParse(_headCircumferenceController.text)
            : null,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await docRef.set(activity.toJson());

      // ✅ 위젯 업데이트
      await WidgetService().updateAllWidgets();

      if (mounted) {
        setState(() => _isSaving = false);

        final insights = <String>[];
        if (_weightController.text.isNotEmpty) {
          insights.add('⚖️ 체중: ${_weightController.text}kg');
        }
        if (_heightController.text.isNotEmpty) {
          insights.add('📏 키: ${_heightController.text}cm');
        }
        if (_headCircumferenceController.text.isNotEmpty) {
          insights.add('📐 머리둘레: ${_headCircumferenceController.text}cm');
        }

        showPostRecordFeedback(
          context: context,
          title: l10n.translate('growth_record_complete') ?? '성장 기록 완료!',
          insights: insights,
          themeColor: _themeColor,
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.translate('sleep_save_failed')?.replaceAll('{error}', e.toString()) ?? '저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

// Import LogOptionButton from template
class LogOptionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final Color themeColor;
  final VoidCallback onTap;

  const LogOptionButton({
    Key? key,
    required this.label,
    this.icon,
    required this.isSelected,
    required this.themeColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? themeColor.withOpacity(0.2)
              : const Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? themeColor : const Color(0x33FFFFFF),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: isSelected ? themeColor : Colors.grey[400], size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? themeColor : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showPostRecordFeedback({
  required BuildContext context,
  required String title,
  required List<String> insights,
  required Color themeColor,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A2332),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: themeColor, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              insight,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          )).toList(),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    ),
  );

  Future.delayed(const Duration(seconds: 3), () {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      Navigator.pop(context);
    }
  });
}
