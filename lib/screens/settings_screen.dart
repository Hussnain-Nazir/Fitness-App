// settings_screen.dart
// Editable account + body/goal fields, persisted through StorageService.
// Age, height, weight, goal, and experience all live in UserProfile - the
// same record onboarding writes to and Nox reads from - so an edit here
// is immediately reflected in Nox's context and the calorie target.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/primary_button.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;
  bool _saving = false;

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _calorieTargetController = TextEditingController();

  String _country = 'Pakistan';
  String _goal = 'Muscle Gain';
  String _experience = 'Beginner';
  Map<String, bool> _notifyPrefs = {'workout': true, 'water': true, 'meal': false};

  final List<String> _countries = const [
    'Pakistan',
    'Australia',
    'United States',
    'United Kingdom',
    'Canada',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _calorieTargetController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final profile = await StorageService.getProfile();
    final userProfile = await StorageService.getUserProfile();
    final target = await StorageService.getCalorieTarget();
    final prefs = await StorageService.getNotificationPrefs();

    if (!mounted) return;
    setState(() {
      _nameController.text = profile['name']!;
      _usernameController.text = profile['username']!;
      _country = profile['country']!;

      _ageController.text = userProfile.age > 0 ? '${userProfile.age}' : '';
      _heightController.text = userProfile.heightCm > 0 ? '${userProfile.heightCm}' : '';
      _weightController.text = userProfile.weightKg > 0 ? '${userProfile.weightKg}' : '';
      if (kOnboardingGoals.contains(userProfile.goal)) _goal = userProfile.goal;
      if (kOnboardingExperience.contains(userProfile.experience)) {
        _experience = userProfile.experience;
      }

      _calorieTargetController.text = '$target';
      _notifyPrefs = prefs;
      _isLoading = false;
    });
  }

  Future<void> _toggleNotification(String key, bool value) async {
    setState(() => _notifyPrefs[key] = value);
    await StorageService.setNotificationPref(key, value);

    switch (key) {
      case 'workout':
        value
            ? await NotificationService.scheduleWorkoutReminder()
            : await NotificationService.cancelWorkoutReminder();
        break;
      case 'water':
        value
            ? await NotificationService.scheduleWaterReminder()
            : await NotificationService.cancelWaterReminder();
        break;
      case 'meal':
        value
            ? await NotificationService.scheduleMealReminder()
            : await NotificationService.cancelMealReminder();
        break;
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    await StorageService.saveProfile(
      name: _nameController.text,
      username: _usernameController.text,
      country: _country,
    );

    final age = int.tryParse(_ageController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;
    await StorageService.saveUserProfile(UserProfile(
      age: age,
      heightCm: height,
      weightKg: weight,
      goal: _goal,
      experience: _experience,
    ));

    final target = int.tryParse(_calorieTargetController.text);
    if (target != null && target > 0) {
      await StorageService.setCalorieTarget(target);
    }

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        content: Text('Settings saved'),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller,
      {TextInputType? keyboardType, String? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall(color: Colors.white)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.body(),
          decoration: InputDecoration(suffixText: suffix),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _chipRow(String label, List<String> options, String selected,
      ValueChanged<String> onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall(color: Colors.white)),
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
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(title: Text('Settings', style: AppTextStyles.heading3())),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentBlue))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account', style: AppTextStyles.heading3()),
                    const SizedBox(height: 12),
                    _field('Full Name', _nameController),
                    _field('Username', _usernameController),
                    Text('Country', style: AppTextStyles.bodySmall(color: Colors.white)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _country,
                      dropdownColor: AppColors.darkSurface,
                      style: AppTextStyles.body(),
                      items: _countries
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _country = v ?? _country),
                    ),

                    const SizedBox(height: 28),
                    Text('Body & Goal', style: AppTextStyles.heading3()),
                    const SizedBox(height: 4),
                    Text(
                      'Feeds Nox, the workout generator, and your calorie target.',
                      style: AppTextStyles.bodySmall(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _field('Age', _ageController,
                              keyboardType: TextInputType.number, suffix: 'yrs'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field('Height', _heightController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              suffix: 'cm'),
                        ),
                      ],
                    ),
                    _field('Weight', _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        suffix: 'kg'),
                    _chipRow('Fitness Goal', kOnboardingGoals, _goal,
                        (v) => setState(() => _goal = v)),
                    _chipRow('Experience Level', kOnboardingExperience, _experience,
                        (v) => setState(() => _experience = v)),
                    _field('Daily Calorie Target', _calorieTargetController,
                        keyboardType: TextInputType.number, suffix: 'kcal'),

                    const SizedBox(height: 12),
                    Text('Reminders', style: AppTextStyles.heading3()),
                    const SizedBox(height: 4),
                    Text(
                      'Local notifications, no account or backend needed.',
                      style: AppTextStyles.bodySmall(),
                    ),
                    const SizedBox(height: 12),
                    _reminderSwitch(
                      icon: Icons.fitness_center_rounded,
                      title: 'Workout Reminder',
                      subtitle: 'Daily at 6:00 PM',
                      value: _notifyPrefs['workout'] ?? false,
                      onChanged: (v) => _toggleNotification('workout', v),
                    ),
                    _reminderSwitch(
                      icon: Icons.water_drop_rounded,
                      title: 'Water Reminder',
                      subtitle: 'Daily at 2:00 PM',
                      value: _notifyPrefs['water'] ?? false,
                      onChanged: (v) => _toggleNotification('water', v),
                    ),
                    _reminderSwitch(
                      icon: Icons.restaurant_rounded,
                      title: 'Meal Reminder',
                      subtitle: 'Daily at 12:30 PM',
                      value: _notifyPrefs['meal'] ?? false,
                      onChanged: (v) => _toggleNotification('meal', v),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Save Changes',
                      loading: _saving,
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _reminderSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body(color: Colors.white)),
                Text(subtitle, style: AppTextStyles.bodySmall()),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }
}
