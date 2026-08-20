// profile_screen.dart
// User details, fitness goal selection, achievements, settings entry, and
// logout. Goal and body stats read/write UserProfile directly - the same
// record onboarding fills and Nox reads - so a change here immediately
// carries through to Nox's context and personalization.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/page_transitions.dart';
import '../widgets/vexon_card.dart';
import '../widgets/achievement_badge.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, String> _account = {};
  UserProfile _userProfile = UserProfile.empty;
  int _streak = 0;
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final account = await StorageService.getProfile();
    final userProfile = await StorageService.getUserProfile();
    final streak = await StorageService.getStreak();
    final completed = await StorageService.getCompletedIds();
    if (!mounted) return;
    setState(() {
      _account = account;
      _userProfile = userProfile;
      _streak = streak;
      _completedCount = completed.length;
    });
  }

  Future<void> _setGoal(String goal) async {
    final updated = _userProfile.copyWith(goal: goal);
    await StorageService.saveUserProfile(updated);
    if (mounted) setState(() => _userProfile = updated);
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_account.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.accentBlue));
    }

    return Material(
      color: Colors.transparent,
      child: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          Text('Profile', style: AppTextStyles.heading1()),
          const SizedBox(height: 20),

          VexonCard(
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _account['name']!.isNotEmpty
                        ? _account['name']![0].toUpperCase()
                        : 'V',
                    style: AppTextStyles.heading1(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_account['name']!,
                          style: AppTextStyles.heading3(
                              color: AppColors.textPrimaryDark)),
                      Text('@${_account['username']}',
                          style: AppTextStyles.bodySmall()),
                    ],
                  ),
                ),
                Column(
                  children: [
                    const Icon(Icons.local_fire_department_rounded,
                        color: AppColors.primaryBlue, size: 20),
                    Text('$_streak',
                        style: AppTextStyles.bodySmall(
                            color: AppColors.textPrimaryDark)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          Text('Fitness Goal', style: AppTextStyles.heading3()),
          const SizedBox(height: 10),
          Row(
            children: kOnboardingGoals.map((goal) {
              final selected = _userProfile.goal == goal;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _setGoal(goal),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryBlue : AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? AppColors.primaryBlue : AppColors.divider,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      goal,
                      style: AppTextStyles.body(
                              color: selected ? Colors.white : AppColors.textSecondary)
                          .copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),

          Text('Details', style: AppTextStyles.heading3()),
          const SizedBox(height: 10),
          VexonCard(
            child: Column(
              children: [
                _detailRow('Age', _userProfile.age > 0 ? '${_userProfile.age}' : '-'),
                const Divider(height: 20),
                _detailRow('Height',
                    _userProfile.heightCm > 0 ? '${_userProfile.heightCm.toStringAsFixed(0)} cm' : '-'),
                const Divider(height: 20),
                _detailRow('Weight',
                    _userProfile.weightKg > 0 ? '${_userProfile.weightKg.toStringAsFixed(1)} kg' : '-'),
                const Divider(height: 20),
                _detailRow('Experience',
                    _userProfile.experience.isNotEmpty ? _userProfile.experience : '-'),
                const Divider(height: 20),
                _detailRow('Country', _account['country']!),
              ],
            ),
          ),
          const SizedBox(height: 22),

          Text('Achievements', style: AppTextStyles.heading3()),
          const SizedBox(height: 10),
          AchievementList(streak: _streak, completedCount: _completedCount),
          const SizedBox(height: 12),

          VexonCard(
            onTap: () => Navigator.of(context)
                .push(vexonRoute(const SettingsScreen()))
                .then((_) => _load()),
            child: Row(
              children: [
                const Icon(Icons.settings_rounded, color: AppColors.primaryBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Settings',
                      style: AppTextStyles.body(color: AppColors.textPrimaryDark)
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 12),
          VexonCard(
            onTap: _logout,
            child: const Row(
              children: [
                Icon(Icons.logout_rounded, color: AppColors.danger),
                SizedBox(width: 12),
                Text('Logout',
                    style: TextStyle(
                        color: AppColors.danger, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall()),
        Text(value,
            style: AppTextStyles.body(color: AppColors.textPrimaryDark)
                .copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
