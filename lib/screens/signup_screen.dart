// signup_screen.dart
// Vexon signup screen. Reuses AuthService.register() for account creation.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_logo.dart';
import '../widgets/primary_button.dart';
import '../widgets/error_feedback.dart';
import '../services/auth_service.dart';
import 'onboarding_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await AuthService.register(
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result != null) {
      setState(() => _error = result);
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  Widget _field(String label, TextEditingController controller,
      {String? hint, bool obscure = false, Widget? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall(color: Colors.white)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: AppTextStyles.body(),
          decoration: InputDecoration(hintText: hint, suffixIcon: suffix),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Spacer(),
                  const AppLogo(size: 40),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 12),
              Text('Create your account', style: AppTextStyles.heading1()),
              const SizedBox(height: 6),
              Text(
                'Start training with Nox and build the plan that fits you.',
                style: AppTextStyles.body(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              if (_error != null) InlineFormError(message: _error!),
              _field('Full Name', _nameController, hint: 'John Carter'),
              _field('Username', _usernameController, hint: 'johncarter'),
              _field('Email', _emailController, hint: 'john@example.com'),
              _field(
                'Password',
                _passwordController,
                hint: 'At least 6 characters',
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Create Account',
                loading: _loading,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.body(color: AppColors.textSecondary),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Sign In',
                          style: AppTextStyles.body(color: AppColors.accentBlue)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
