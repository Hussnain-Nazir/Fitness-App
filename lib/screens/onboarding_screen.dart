// onboarding_screen.dart
// Multi-step onboarding: age, height, weight, fitness goal, experience
// level. Saved via StorageService.saveUserProfile() and used to
// personalize the dashboard, workout suggestions, and Nox's responses.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_logo.dart';
import '../widgets/primary_button.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import 'home_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _step = 0;
  static const _totalSteps = 4;

  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _goal;
  String? _experience;
  bool _saving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    switch (_step) {
      case 0:
        return int.tryParse(_ageController.text) != null;
      case 1:
        return double.tryParse(_heightController.text) != null;
      case 2:
        return double.tryParse(_weightController.text) != null;
      case 3:
        return _goal != null && _experience != null;
      default:
        return false;
    }
  }

  Future<void> _next() async {
    if (!_canContinue) return;
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    } else {
      await _finish();
    }
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step--);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish() async {
    setState(() => _saving = true);

    final profile = UserProfile(
      age: int.parse(_ageController.text),
      heightCm: double.parse(_heightController.text),
      weightKg: double.parse(_weightController.text),
      goal: _goal!,
      experience: _experience!,
    );

    await StorageService.saveUserProfile(profile);
    await StorageService.setOnboardingComplete(true);

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  if (_step > 0)
                    IconButton(
                      onPressed: _back,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  const AppLogo(size: 32),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: List.generate(_totalSteps, (i) {
                  final active = i <= _step;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: EdgeInsets.only(right: i == _totalSteps - 1 ? 0 : 6),
                      height: 4,
                      decoration: BoxDecoration(
                        color: active ? AppColors.primaryBlue : AppColors.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StepScaffold(
                    title: 'How old are you?',
                    subtitle: 'This helps Nox calibrate your training load.',
                    child: _NumberField(
                      controller: _ageController,
                      hint: 'Age in years',
                      suffix: 'yrs',
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  _StepScaffold(
                    title: "What's your height?",
                    subtitle: 'Used to personalize calorie targets.',
                    child: _NumberField(
                      controller: _heightController,
                      hint: 'Height in cm',
                      suffix: 'cm',
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  _StepScaffold(
                    title: "What's your weight?",
                    subtitle: 'We will track progress from here.',
                    child: _NumberField(
                      controller: _weightController,
                      hint: 'Weight in kg',
                      suffix: 'kg',
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  _StepScaffold(
                    title: 'Set your direction',
                    subtitle: 'Nox will tailor every plan around this.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fitness Goal',
                            style: AppTextStyles.bodySmall(color: Colors.white)),
                        const SizedBox(height: 10),
                        _OptionRow(
                          options: kOnboardingGoals,
                          selected: _goal,
                          onSelect: (v) => setState(() => _goal = v),
                        ),
                        const SizedBox(height: 22),
                        Text('Experience Level',
                            style: AppTextStyles.bodySmall(color: Colors.white)),
                        const SizedBox(height: 10),
                        _OptionRow(
                          options: kOnboardingExperience,
                          selected: _experience,
                          onSelect: (v) => setState(() => _experience = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: PrimaryButton(
                label: _step == _totalSteps - 1 ? 'Finish Setup' : 'Continue',
                loading: _saving,
                onPressed: _canContinue ? _next : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _StepScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.heading1()),
          const SizedBox(height: 6),
          Text(subtitle, style: AppTextStyles.body(color: AppColors.textSecondary)),
          const SizedBox(height: 28),
          child,
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String suffix;
  final ValueChanged<String> onChanged;

  const _NumberField({
    required this.controller,
    required this.hint,
    required this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: AppTextStyles.stat(),
      decoration: InputDecoration(
        hintText: hint,
        suffixText: suffix,
        suffixStyle: AppTextStyles.body(color: AppColors.textSecondary),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _OptionRow({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((o) {
        final active = o == selected;
        return GestureDetector(
          onTap: () => onSelect(o),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: active ? AppColors.primaryBlue : AppColors.darkSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: active ? AppColors.primaryBlue : AppColors.divider),
            ),
            child: Text(
              o,
              style: AppTextStyles.body(color: active ? Colors.white : Colors.white)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        );
      }).toList(),
    );
  }
}
