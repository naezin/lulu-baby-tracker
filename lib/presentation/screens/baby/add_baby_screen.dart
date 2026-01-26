import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/baby_model.dart';
import '../../providers/baby_provider.dart';

/// 아기 추가 화면 (설정에서 접근)
class AddBabyScreen extends StatefulWidget {
  const AddBabyScreen({super.key});

  @override
  State<AddBabyScreen> createState() => _AddBabyScreenState();
}

class _AddBabyScreenState extends State<AddBabyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();

  DateTime _birthDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime? _dueDate;
  bool _isPremature = false;
  String _gender = 'female';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: Text(l10n.translate('add_baby') ?? '아기 추가'),
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 아기 이름
            _buildTextField(
              controller: _nameController,
              label: l10n.translate('baby_name') ?? '아기 이름',
              hint: l10n.translate('baby_name_hint') ?? '아기 이름을 입력하세요',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.translate('baby_name_required') ?? '아기 이름을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // 생년월일
            _buildDatePicker(
              context,
              label: l10n.translate('birth_date') ?? '생년월일',
              date: _birthDate,
              onDateSelected: (date) => setState(() => _birthDate = date),
            ),
            const SizedBox(height: 20),

            // 성별
            _buildGenderSelector(l10n),
            const SizedBox(height: 20),

            // 출생 시 체중
            _buildTextField(
              controller: _weightController,
              label: l10n.translate('birth_weight') ?? '출생 시 체중 (kg)',
              hint: '3.5',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return null;
                final weight = double.tryParse(value);
                if (weight == null || weight <= 0 || weight > 10) {
                  return '유효한 체중을 입력해주세요 (0-10kg)';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // 조산아 여부
            SwitchListTile(
              title: Text(
                l10n.translate('is_premature') ?? '조산아',
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                l10n.translate('is_premature_hint') ?? '37주 이전 출생',
                style: const TextStyle(color: Colors.white54),
              ),
              value: _isPremature,
              activeColor: AppTheme.lavenderMist,
              onChanged: (value) => setState(() => _isPremature = value),
            ),

            // 예정일 (조산아인 경우)
            if (_isPremature) ...[
              const SizedBox(height: 20),
              _buildDatePicker(
                context,
                label: l10n.translate('due_date') ?? '출산 예정일',
                date: _dueDate ?? _birthDate.add(const Duration(days: 60)),
                onDateSelected: (date) => setState(() => _dueDate = date),
              ),
            ],

            const SizedBox(height: 40),

            // 저장 버튼
            ElevatedButton(
              onPressed: _isLoading ? null : _saveBaby,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lavenderMist,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n.translate('save') ?? '저장',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: AppTheme.surfaceCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.surfaceCard),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.lavenderMist),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDatePicker(
    BuildContext context, {
    required String label,
    required DateTime date,
    required Function(DateTime) onDateSelected,
  }) {
    return InkWell(
      onTap: () => _selectDate(context, date, onDateSelected),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
            Row(
              children: [
                Text(
                  DateFormat('yyyy-MM-dd').format(date),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.calendar_today,
                  color: AppTheme.lavenderMist,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime initialDate,
    Function(DateTime) onDateSelected,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.lavenderMist,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceCard,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }

  Widget _buildGenderSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('gender') ?? '성별',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(
                value: 'female',
                icon: Icons.girl,
                label: l10n.translate('female') ?? '여아',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderOption(
                value: 'male',
                icon: Icons.boy,
                label: l10n.translate('male') ?? '남아',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption({
    required String value,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _gender == value;
    return InkWell(
      onTap: () => setState(() => _gender = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.lavenderMist.withOpacity(0.2) : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.lavenderMist : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.lavenderMist : Colors.white54,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.lavenderMist : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveBaby() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final babyProvider = context.read<BabyProvider>();
      final weightKg = double.tryParse(_weightController.text.trim());

      final baby = BabyModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'anonymous', // TODO: 실제 userId 사용
        name: _nameController.text.trim(),
        birthDate: _birthDate.toIso8601String(),
        dueDate: _isPremature ? _dueDate?.toIso8601String() : null,
        isPremature: _isPremature,
        gender: _gender,
        birthWeightKg: weightKg,
        weightUnit: 'kg',
        sleepGoals: SleepGoals(
          nightSleepHours: 10,
          napCount: 3,
          totalDailySleepHours: 14,
        ),
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      await babyProvider.addBaby(baby, 'anonymous');

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${baby.name}이(가) 추가되었어요! 🎉'),
            backgroundColor: AppTheme.successSoft,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
