import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/auth_service.dart';
import 'onboarding/baby_setup_screen.dart';

/// 📝 Sign Up Screen
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D0F1E),
                  Color(0xFF1A1F3A),
                  Color(0xFF2D3351),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Title
                    Text(
                      l10n.translate('create_account') ?? 'Create Account',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.translate('signup_subtitle') ??
                          'Join the Lulu family and start tracking',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Sign up form
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Name field
                            _buildTextField(
                              controller: _nameController,
                              label: l10n.translate('name') ?? 'Name',
                              hint:
                                  l10n.translate('enter_name') ?? 'Enter your name',
                              prefixIcon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.translate('name_required') ??
                                      'Name is required';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Email field
                            _buildTextField(
                              controller: _emailController,
                              label: l10n.translate('email') ?? 'Email',
                              hint:
                                  l10n.translate('enter_email') ?? 'Enter your email',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.translate('email_required') ??
                                      'Email is required';
                                }
                                if (!value.contains('@')) {
                                  return l10n.translate('email_invalid') ??
                                      'Invalid email';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Password field
                            _buildTextField(
                              controller: _passwordController,
                              label: l10n.translate('password') ?? 'Password',
                              hint: l10n.translate('enter_password') ??
                                  'Enter your password',
                              obscureText: _obscurePassword,
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                onPressed: () {
                                  setState(
                                      () => _obscurePassword = !_obscurePassword);
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.translate('password_required') ??
                                      'Password is required';
                                }
                                if (value.length < 6) {
                                  return l10n.translate('password_too_short') ??
                                      'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Confirm password field
                            _buildTextField(
                              controller: _confirmPasswordController,
                              label: l10n.translate('confirm_password') ??
                                  'Confirm Password',
                              hint: l10n.translate('confirm_password_hint') ??
                                  'Re-enter your password',
                              obscureText: _obscureConfirmPassword,
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                onPressed: () {
                                  setState(() => _obscureConfirmPassword =
                                      !_obscureConfirmPassword);
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.translate('confirm_password_required') ??
                                      'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return l10n.translate('passwords_dont_match') ??
                                      'Passwords do not match';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Terms checkbox
                            Row(
                              children: [
                                Checkbox(
                                  value: _agreeToTerms,
                                  onChanged: (value) {
                                    setState(() => _agreeToTerms = value ?? false);
                                  },
                                  fillColor: WidgetStateProperty.all(
                                    _agreeToTerms
                                        ? AppTheme.lavenderMist
                                        : Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      text: l10n.translate('agree_to') ??
                                          'I agree to the ',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: l10n.translate('terms_of_service') ??
                                              'Terms of Service',
                                          style: const TextStyle(
                                            color: AppTheme.lavenderMist,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                        TextSpan(
                                          text: l10n.translate('and') ?? ' and ',
                                        ),
                                        TextSpan(
                                          text: l10n.translate('privacy_policy') ??
                                              'Privacy Policy',
                                          style: const TextStyle(
                                            color: AppTheme.lavenderMist,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Sign up button
                            ElevatedButton(
                              onPressed: _agreeToTerms ? _handleSignUp : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.lavenderMist,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor:
                                    Colors.white.withOpacity(0.1),
                              ),
                              child: Text(
                                l10n.translate('sign_up') ?? 'Sign Up',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Already have account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.translate('already_have_account') ??
                              'Already have an account?',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            l10n.translate('sign_in') ?? 'Sign In',
                            style: const TextStyle(
                              color: AppTheme.lavenderMist,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppTheme.lavenderMist),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Colors.white.withOpacity(0.5))
            : null,
        suffixIcon: suffixIcon,
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
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.lavenderMist,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.errorSoft,
            width: 1,
          ),
        ),
      ),
      validator: validator,
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authService.signUpWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result.success) {
      // Navigate to baby setup
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const BabySetupScreen()),
      );
    } else {
      _showError(result.error ?? 'Sign up failed');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorSoft,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
