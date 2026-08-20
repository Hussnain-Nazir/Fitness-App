// workout_generator_screen.dart
// User inputs goal, time available, and experience level. Nox (via
// GeminiService) generates a structured workout plan.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/vexon_card.dart';
import '../widgets/primary_button.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';

class WorkoutGeneratorScreen extends StatefulWidget {
  const WorkoutGeneratorScreen({super.key});

  @override
  State<WorkoutGeneratorScreen> createState() => _WorkoutGeneratorScreenState();
}

class _WorkoutGeneratorScreenState extends State<WorkoutGeneratorScreen> {
  String _goal = 'Build Muscle';
  String _time = '30 min';
  String _experience = 'Beginner';
  bool _loading = false;
  String? _plan;
  String? _error;

  static const _goals = ['Build Muscle', 'Lose Fat', 'General Fitness'];
  static const _times = ['15 min', '30 min', '45 min', '60 min'];
  static const _levels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    _prefillFromProfile();
  }

  Future<void> _prefillFromProfile() async {
    final profile = await StorageService.getUserProfile();
    if (!mounted || !profile.isComplete) return;
    setState(() {
      _goal = profile.goal == 'Fat Loss' ? 'Lose Fat' : 'Build Muscle';
      if (_levels.contains(profile.experience)) {
        _experience = profile.experience;
      }
    });
  }

  Future<void> _generate() async {
    setState(() {
      _loading = true;
      _error = null;
      _plan = null;
    });

    try {
      final plan = await GeminiService.generateWorkoutPlan(
        goal: _goal,
        timeAvailable: _time,
        experienceLevel: _experience,
      );
      if (!mounted) return;
      setState(() => _plan = plan);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error =
          'Could not generate a plan. Check that GEMINI_API_KEY is set in .env.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _selector(String title, List<String> options, String selected,
      void Function(String) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.bodySmall(color: Colors.white)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((o) {
            final active = o == selected;
            return GestureDetector(
              onTap: () => onSelect(o),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: active ? AppColors.primaryBlue : AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: active ? AppColors.primaryBlue : AppColors.divider),
                ),
                child: Text(
                  o,
                  style: AppTextStyles.bodySmall(
                      color: active ? Colors.white : AppColors.textSecondary),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text('AI Workout Generator', style: AppTextStyles.heading3()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nox will build a structured session based on your inputs.',
                style: AppTextStyles.body(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              _selector('Goal', _goals, _goal, (v) => setState(() => _goal = v)),
              _selector('Time Available', _times, _time, (v) => setState(() => _time = v)),
              _selector('Experience Level', _levels, _experience,
                  (v) => setState(() => _experience = v)),
              PrimaryButton(
                label: 'Generate Plan',
                icon: Icons.auto_awesome_rounded,
                loading: _loading,
                onPressed: _generate,
              ),
              const SizedBox(height: 20),
              if (_error != null)
                VexonDarkCard(
                  child: Text(_error!,
                      style: AppTextStyles.body(color: AppColors.danger)),
                ),
              if (_plan != null)
                VexonCard(
                  child: Text(
                    _plan!,
                    style: AppTextStyles.body(color: AppColors.textPrimaryDark),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
