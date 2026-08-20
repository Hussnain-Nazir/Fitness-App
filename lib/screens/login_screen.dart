// login_screen.dart
// Vexon login screen. Reuses AuthService.login() for credential checks.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/page_transitions.dart';
import '../widgets/app_logo.dart';
import '../widgets/primary_button.dart';
import '../widgets/error_feedback.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'signup_screen.dart';
import 'onboarding_screen.dart';
import 'home_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscure = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await AuthService.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result != null) {
      setState(() => _error = result);
      return;
    }

    final onboarded = await StorageService.isOnboardingComplete();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => onboarded ? const HomeShell() : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: const AppLogo(size: 64)),
              const SizedBox(height: 28),
              Text('Welcome back', style: AppTextStyles.heading1()),
              const SizedBox(height: 6),
              Text(
                'Sign in to continue your training with Nox.',
                style: AppTextStyles.body(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),
              if (_error != null) InlineFormError(message: _error!),
              Text('Username', style: AppTextStyles.bodySmall(color: Colors.white)),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                style: AppTextStyles.body(),
                decoration: const InputDecoration(hintText: 'testuser'),
              ),
              const SizedBox(height: 18),
              Text('Password', style: AppTextStyles.bodySmall(color: Colors.white)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                style: AppTextStyles.body(),
                decoration: InputDecoration(
                  hintText: 'password123',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Sign In',
                loading: _loading,
                onPressed: _submit,
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(vexonRoute(const SignupScreen()));
                  },
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.body(color: AppColors.textSecondary),
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: 'Sign Up',
                          style: AppTextStyles.body(color: AppColors.accentBlue)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],))
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
