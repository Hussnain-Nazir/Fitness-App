// splash_screen.dart
// Placeholder splash screen: centered logo + app name. The empty container
// below the logo is reserved for a future loading animation - intentionally
// not implemented yet per spec.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_logo.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'home_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    // Demo-simple session check: presence of a saved profile username
    // that isn't the default acts as a "logged in" signal for returning
    // users. New installs land on Login.
    final profile = await StorageService.getProfile();
    final hasSession = profile['username'] != 'alexlifts';
    final onboarded = await StorageService.isOnboardingComplete();

    Widget destination;
    if (!hasSession) {
      destination = const LoginScreen();
    } else if (!onboarded) {
      destination = const OnboardingScreen();
    } else {
      destination = const HomeShell();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 88),
            const SizedBox(height: 24),
            Text('VEXON',
                style: AppTextStyles.heading1().copyWith(letterSpacing: 4)),
            const SizedBox(height: 6),
            Text(
              'Strength. Discipline. Performance.',
              style: AppTextStyles.bodySmall(),
            ),
            // Reserved for future loading animation.
            const SizedBox(height: 48, width: double.infinity),
          ],
        ),
      ),
    );
  }
}
