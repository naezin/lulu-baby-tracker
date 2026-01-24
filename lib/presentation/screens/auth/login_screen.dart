import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/auth_service.dart';
import 'signup_screen.dart';
import 'onboarding/baby_setup_screen.dart';

/// 🌙 Login Screen with Midnight Blue Theme
/// Calming design for tired parents
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _stardustController;

  @override
  void initState() {
    super.initState();
    _stardustController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _stardustController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Midnight Blue gradient background
          _buildBackground(),

          // Star dust effect
          _buildStarDust(),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // Logo and Welcome
                    _buildHeader(context, l10n),

                    const SizedBox(height: 48),

                    // Glassmorphism login card
                    _buildLoginCard(context, l10n),

                    const SizedBox(height: 24),

                    // Social login buttons
                    _buildSocialLogin(context, l10n),

                    const SizedBox(height: 32),

                    // Sign up link
                    _buildSignUpLink(context, l10n),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D0F1E), // Darker Midnight Blue
            Color(0xFF1A1F3A),
            Color(0xFF2D3351),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildStarDust() {
    return AnimatedBuilder(
      animation: _stardustController,
      builder: (context, child) {
        return CustomPaint(
          painter: StarDustPainter(_stardustController.value),
          child: Container(),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        // App icon with glow effect
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppTheme.lavenderMist.withOpacity(0.3),
                AppTheme.lavenderMist.withOpacity(0.0),
              ],
            ),
          ),
          child: const Icon(
            Icons.bedtime_rounded,
            size: 64,
            color: AppTheme.lavenderMist,
          ),
        ),
        const SizedBox(height: 24),

        // Welcome text
        Text(
          l10n.translate('welcome_to_lulu') ?? 'Welcome to Lulu',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.translate('tagline_peaceful_nights') ??
              'For peaceful nights and happy days',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email field
            _buildTextField(
              controller: _emailController,
              label: l10n.translate('email') ?? 'Email',
              hint: l10n.translate('enter_email') ?? 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.translate('email_required') ?? 'Email is required';
                }
                if (!value.contains('@')) {
                  return l10n.translate('email_invalid') ?? 'Invalid email';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Password field
            _buildTextField(
              controller: _passwordController,
              label: l10n.translate('password') ?? 'Password',
              hint: l10n.translate('enter_password') ?? 'Enter your password',
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white.withOpacity(0.5),
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.translate('password_required') ??
                      'Password is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 8),

            // Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _handleForgotPassword,
                child: Text(
                  l10n.translate('forgot_password') ?? 'Forgot password?',
                  style: const TextStyle(
                    color: AppTheme.lavenderMist,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Login button
            ElevatedButton(
              onPressed: _handleEmailLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lavenderMist,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.translate('sign_in') ?? 'Sign In',
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

  Widget _buildSocialLogin(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        // Divider with text
        Row(
          children: [
            Expanded(
              child: Divider(color: Colors.white.withOpacity(0.2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.translate('or_continue_with') ?? 'Or continue with',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: Colors.white.withOpacity(0.2)),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Social buttons
        Row(
          children: [
            // Apple Sign In
            Expanded(
              child: _buildSocialButton(
                icon: Icons.apple,
                label: 'Apple',
                onPressed: _handleAppleLogin,
              ),
            ),
            const SizedBox(width: 12),

            // Google Sign In
            Expanded(
              child: _buildSocialButton(
                icon: Icons.g_mobiledata,
                label: 'Google',
                onPressed: _handleGoogleLogin,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSignUpLink(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.translate('dont_have_account') ?? "Don't have an account?",
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignUpScreen()),
            );
          },
          child: Text(
            l10n.translate('sign_up') ?? 'Sign Up',
            style: const TextStyle(
              color: AppTheme.lavenderMist,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F3A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppTheme.lavenderMist),
              ),
              const SizedBox(height: 16),
              Text(
                'Signing in...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Event handlers
  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authService.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result.success) {
      _navigateToHome();
    } else {
      _showError(result.error ?? 'Login failed');
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    final result = await _authService.signInWithGoogle();

    setState(() => _isLoading = false);

    if (result.success) {
      if (result.isNewUser) {
        _navigateToOnboarding();
      } else {
        _navigateToHome();
      }
    } else {
      _showError(result.error ?? 'Google sign-in failed');
    }
  }

  Future<void> _handleAppleLogin() async {
    setState(() => _isLoading = true);

    final result = await _authService.signInWithApple();

    setState(() => _isLoading = false);

    if (result.success) {
      if (result.isNewUser) {
        _navigateToOnboarding();
      } else {
        _navigateToHome();
      }
    } else {
      _showError(result.error ?? 'Apple sign-in failed');
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Please enter your email first');
      return;
    }

    final result = await _authService.sendPasswordResetEmail(email);

    if (result.success) {
      _showSuccess('Password reset email sent!');
    } else {
      _showError(result.error ?? 'Failed to send reset email');
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _navigateToOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const BabySetupScreen()),
    );
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successSoft,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Star Dust Painter for ambient effect
class StarDustPainter extends CustomPainter {
  final double animation;

  StarDustPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.3);

    // Draw random stars
    final random = math.Random(42); // Fixed seed for consistent positions
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final offset = (animation + i * 0.02) % 1.0;
      final opacity = (math.sin(offset * math.pi * 2) + 1) / 2;

      paint.color = Colors.white.withOpacity(opacity * 0.3);
      canvas.drawCircle(
        Offset(x, y),
        1.5 + opacity,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(StarDustPainter oldDelegate) =>
      animation != oldDelegate.animation;
}
