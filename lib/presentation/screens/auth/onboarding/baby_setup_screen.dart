import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Temporarily disabled for web
import '../../../../data/services/firestore_stub.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/baby_model.dart';
import '../../../../data/services/local_storage_service.dart';
import '../../../../data/services/widget_service.dart';

/// 👶 Baby Setup Screen (Onboarding)
/// Collect baby information with special care mode for low birth weight
class BabySetupScreen extends StatefulWidget {
  const BabySetupScreen({Key? key}) : super(key: key);

  @override
  State<BabySetupScreen> createState() => _BabySetupScreenState();
}

class _BabySetupScreenState extends State<BabySetupScreen> {
  final _storage = LocalStorageService();
  final _widgetService = WidgetService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();

  DateTime _birthDate = DateTime.now().subtract(const Duration(days: 72));
  String _gender = 'female';
  bool _isLowBirthWeight = false;
  bool _showSpecialCarePrompt = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0D0F1E),
              const Color(0xFF1A1F3A),
              const Color(0xFF2D3351),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              _buildProgressBar(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: _buildCurrentStep(l10n),
                ),
              ),

              // Navigation buttons
              _buildNavigationButtons(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(
          3,
          (index) => Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: index <= _currentStep
                    ? AppTheme.lavenderMist
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(AppLocalizations l10n) {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep(l10n);
      case 1:
        return _buildBabyInfoStep(l10n);
      case 2:
        return _buildSpecialCareStep(l10n);
      default:
        return Container();
    }
  }

  Widget _buildWelcomeStep(AppLocalizations l10n) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(
          Icons.child_care_rounded,
          size: 80,
          color: AppTheme.lavenderMist,
        ),
        const SizedBox(height: 32),
        Text(
          l10n.translate('welcome_to_lulu') ?? 'Welcome to Lulu!',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.translate('onboarding_intro') ??
              "Let's get to know your precious baby.\nThis helps us provide personalized care recommendations.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.lavenderMist.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.lavenderMist.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              _buildFeatureItem(
                Icons.insights,
                l10n.translate('feature_ai_insights') ?? 'AI-Powered Insights',
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                Icons.access_time,
                l10n.translate('feature_sweet_spot') ?? 'Sweet Spot Predictions',
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                Icons.favorite,
                l10n.translate('feature_personalized') ?? 'Personalized Care',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.lavenderMist, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBabyInfoStep(AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('tell_us_about_baby') ?? "Tell us about your baby",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),

          // Baby name
          _buildInputLabel(l10n.translate('baby_name') ?? "Baby's name"),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: _buildInputDecoration(
              l10n.translate('enter_baby_name') ?? 'Enter name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.translate('name_required') ?? 'Name is required';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Birth date
          _buildInputLabel(l10n.translate('birth_date') ?? 'Date of birth'),
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectBirthDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AppTheme.lavenderMist,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('MMM dd, yyyy').format(_birthDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _getAgeText(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Gender
          _buildInputLabel(l10n.translate('gender') ?? 'Gender'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildGenderButton(
                  'female',
                  '👧',
                  l10n.translate('girl') ?? 'Girl',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGenderButton(
                  'male',
                  '👦',
                  l10n.translate('boy') ?? 'Boy',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Birth weight
          _buildInputLabel(l10n.translate('birth_weight') ?? 'Birth weight (kg)'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _weightController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: _buildInputDecoration(
              l10n.translate('enter_weight') ?? 'e.g., 2.46',
            ),
            onChanged: _checkLowBirthWeight,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.translate('weight_required') ?? 'Weight is required';
              }
              final weight = double.tryParse(value);
              if (weight == null || weight <= 0) {
                return l10n.translate('weight_invalid') ?? 'Invalid weight';
              }
              return null;
            },
          ),

          // Low birth weight notice
          if (_showSpecialCarePrompt)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warningSoft.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.warningSoft.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.warningSoft,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.translate('low_birth_weight_notice') ??
                          'We noticed your baby was born with a lower birth weight. We can provide specialized care recommendations.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpecialCareStep(AppLocalizations l10n) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.lavenderMist.withOpacity(0.2),
                AppTheme.lavenderGlow.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.lavenderMist.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.favorite,
                size: 64,
                color: AppTheme.lavenderMist,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.translate('special_care_title') ??
                    'Special Care for Your Precious Baby',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.translate('special_care_message') ??
                    'Babies born with lower birth weights need a little extra care and attention. Would you like us to enable specialized growth monitoring and personalized feeding recommendations?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _isLowBirthWeight = false);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(l10n.translate('no_thanks') ?? 'No, thanks'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _isLowBirthWeight = true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lavenderMist,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(l10n.translate('enable_special_care') ??
                          'Yes, enable'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.9),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppTheme.lavenderMist,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildGenderButton(String value, String emoji, String label) {
    final isSelected = _gender == value;
    return InkWell(
      onTap: () => setState(() => _gender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lavenderMist.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.lavenderMist
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.lavenderMist : Colors.white,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _currentStep--);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(l10n.translate('back') ?? 'Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: _currentStep > 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lavenderMist,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _currentStep == 2
                    ? (l10n.translate('finish') ?? 'Finish')
                    : (l10n.translate('next') ?? 'Next'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getAgeText() {
    final days = DateTime.now().difference(_birthDate).inDays;
    if (days < 30) return '$days days old';
    if (days < 365) return '${(days / 30).floor()} months old';
    return '${(days / 365).floor()} years old';
  }

  void _checkLowBirthWeight(String value) {
    final weight = double.tryParse(value);
    if (weight != null && weight < 2.5) {
      setState(() => _showSpecialCarePrompt = true);
    } else {
      setState(() => _showSpecialCarePrompt = false);
    }
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.lavenderMist,
              onPrimary: Colors.white,
              surface: const Color(0xFF1A1F3A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  void _handleNext() {
    if (_currentStep == 0) {
      setState(() => _currentStep++);
    } else if (_currentStep == 1) {
      if (_formKey.currentState!.validate()) {
        if (_showSpecialCarePrompt) {
          setState(() => _currentStep++);
        } else {
          _finishSetup();
        }
      }
    } else {
      _finishSetup();
    }
  }

  Future<void> _finishSetup() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: AppTheme.lavenderMist,
        ),
      ),
    );

    try {
      // Get current user ID (or use 'anonymous' if not logged in)
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

      // Parse weight
      final weightKg = double.tryParse(_weightController.text.trim()) ?? 0.0;

      // Determine if premature based on user input or low birth weight
      final isPremature = weightKg < 2.5;

      // Create baby model
      final baby = BabyModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        name: _nameController.text.trim(),
        birthDate: _birthDate.toIso8601String(),
        dueDate: null, // Could be added in future
        isPremature: isPremature,
        gender: _gender,
        photoUrl: null, // Could be added in future
        weightKg: weightKg,
        weightUnit: 'kg',
        sleepGoals: _isLowBirthWeight
            ? SleepGoals(
                nightSleepHours: 10,
                napCount: 4,
                totalDailySleepHours: 16,
              )
            : SleepGoals(
                nightSleepHours: 10,
                napCount: 3,
                totalDailySleepHours: 14,
              ),
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      // Save baby data to local storage
      await _storage.saveBaby(baby);

      // Update all widgets with new baby data
      await _widgetService.updateAllWidgets();

      // Dismiss loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to home screen
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      // Dismiss loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving baby data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
