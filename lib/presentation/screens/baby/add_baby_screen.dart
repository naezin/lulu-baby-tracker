import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/baby_model.dart';
import '../../../data/services/local_storage_service.dart';
import '../../providers/baby_provider.dart';
import '../../widgets/log_screen_template.dart';

/// 아기 추가 화면 (설정에서 접근)
class AddBabyScreen extends StatefulWidget {
  const AddBabyScreen({super.key});

  @override
  State<AddBabyScreen> createState() => _AddBabyScreenState();
}

class _AddBabyScreenState extends State<AddBabyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthWeightController = TextEditingController();
  final _birthHeightController = TextEditingController();
  final _birthHeadCircumferenceController = TextEditingController();

  DateTime? _selectedBirthDate;
  DateTime? _selectedDueDate;
  String? _selectedGender;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _birthWeightController.dispose();
    _birthHeightController.dispose();
    _birthHeadCircumferenceController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
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

    if (date != null) {
      setState(() {
        _selectedBirthDate = date;
      });
    }
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
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

    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  Future<void> _saveBabyProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('생년월일을 선택해주세요'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('성별을 선택해주세요'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final babyProvider = context.read<BabyProvider>();
      final now = DateTime.now().toIso8601String();

      // 조산아 여부 자동 파악: 예정일이 생년월일보다 나중이면 조산아
      final isPremature = _selectedDueDate != null &&
          _selectedDueDate!.isAfter(_selectedBirthDate!);

      final baby = BabyModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'anonymous',
        name: _nameController.text.trim(),
        birthDate: _selectedBirthDate!.toIso8601String(),
        dueDate: _selectedDueDate?.toIso8601String(),
        isPremature: isPremature,
        gender: _selectedGender,
        birthWeightKg: _birthWeightController.text.isNotEmpty
            ? double.tryParse(_birthWeightController.text)
            : null,
        birthHeightCm: _birthHeightController.text.isNotEmpty
            ? double.tryParse(_birthHeightController.text)
            : null,
        birthHeadCircumferenceCm: _birthHeadCircumferenceController.text.isNotEmpty
            ? double.tryParse(_birthHeadCircumferenceController.text)
            : null,
        weightUnit: 'kg',
        createdAt: now,
        updatedAt: now,
      );

      // 단일 아기로 설정
      babyProvider.setCurrentBaby(baby);

      // 로컬 스토리지에 저장
      final storage = LocalStorageService();
      await storage.addBaby(baby);

      if (mounted) {
        HapticFeedback.heavyImpact();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${baby.name}이(가) 추가되었어요! 🎉'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LogScreenTemplate(
      title: '아기 추가',
      subtitle: '새로운 아기의 기본 정보를 입력해주세요',
      icon: Icons.child_care_rounded,
      themeColor: AppTheme.lavenderMist,
      saveButtonText: '저장하기',
      onSave: _saveBabyProfile,
      isLoading: _isLoading,
      contextHint: const Text(
        '정확한 정보를 입력하면 더 정확한 성장 분석을 받을 수 있어요',
        style: TextStyle(
          fontSize: 14,
          color: AppTheme.textSecondary,
        ),
      ),
      inputSection: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이름
            const Text(
              '이름',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: '예: 민지',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: AppTheme.surfaceCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.lavenderMist, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '이름을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // 생년월일
            const Text(
              '생년월일',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectBirthDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedBirthDate != null
                          ? '${_selectedBirthDate!.year}년 ${_selectedBirthDate!.month}월 ${_selectedBirthDate!.day}일'
                          : '날짜 선택',
                      style: TextStyle(
                        color: _selectedBirthDate != null
                            ? AppTheme.textPrimary
                            : Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const Icon(Icons.calendar_today, color: AppTheme.lavenderMist, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 성별
            const Text(
              '성별',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LogOptionButton(
                    label: '남아',
                    icon: Icons.boy,
                    isSelected: _selectedGender == 'male',
                    themeColor: AppTheme.lavenderMist,
                    onTap: () {
                      setState(() {
                        _selectedGender = 'male';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LogOptionButton(
                    label: '여아',
                    icon: Icons.girl,
                    isSelected: _selectedGender == 'female',
                    themeColor: AppTheme.lavenderMist,
                    onTap: () {
                      setState(() {
                        _selectedGender = 'female';
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 예정일 (선택사항)
            const Text(
              '예정일 (선택사항)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '예정일을 입력하면 교정나이 기준 분석을 제공합니다',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDueDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDueDate != null
                          ? '${_selectedDueDate!.year}년 ${_selectedDueDate!.month}월 ${_selectedDueDate!.day}일'
                          : '날짜 선택 (필요시)',
                      style: TextStyle(
                        color: _selectedDueDate != null
                            ? AppTheme.textPrimary
                            : Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const Icon(Icons.calendar_today, color: AppTheme.lavenderMist, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 출생 시 신체 정보
            const Text(
              '출생 시 신체 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '출생 시 정보를 입력하면 성장 추이를 확인할 수 있어요',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),

            // 출생 체중
            const Text(
              '출생 체중',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _birthWeightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: '예: 3.2',
                hintStyle: TextStyle(color: Colors.grey[600]),
                suffixText: 'kg',
                suffixStyle: const TextStyle(color: AppTheme.lavenderMist),
                filled: true,
                fillColor: AppTheme.surfaceCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.lavenderMist, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '출생 체중을 입력해주세요';
                }
                final weight = double.tryParse(value);
                if (weight == null || weight <= 0 || weight > 10) {
                  return '올바른 체중을 입력해주세요 (0~10kg)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 출생 키
            const Text(
              '출생 키',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _birthHeightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: '예: 50',
                hintStyle: TextStyle(color: Colors.grey[600]),
                suffixText: 'cm',
                suffixStyle: const TextStyle(color: AppTheme.lavenderMist),
                filled: true,
                fillColor: AppTheme.surfaceCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.lavenderMist, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '출생 키를 입력해주세요';
                }
                final height = double.tryParse(value);
                if (height == null || height <= 0 || height > 100) {
                  return '올바른 키를 입력해주세요 (0~100cm)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 출생 머리둘레
            const Text(
              '출생 머리둘레',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _birthHeadCircumferenceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: '예: 34',
                hintStyle: TextStyle(color: Colors.grey[600]),
                suffixText: 'cm',
                suffixStyle: const TextStyle(color: AppTheme.lavenderMist),
                filled: true,
                fillColor: AppTheme.surfaceCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.lavenderMist, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '출생 머리둘레를 입력해주세요';
                }
                final headCircumference = double.tryParse(value);
                if (headCircumference == null || headCircumference <= 0 || headCircumference > 60) {
                  return '올바른 머리둘레를 입력해주세요 (0~60cm)';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
