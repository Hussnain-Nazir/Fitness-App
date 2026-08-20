// home_screen.dart
// Home tab: dashboard + coach interface. Greeting, today's mission,
// streak, quick actions, and a one-line smart suggestion from Nox.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/page_transitions.dart';
import '../widgets/app_logo.dart';
import '../widgets/vexon_card.dart';
import '../widgets/section_header.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/animated_progress.dart';
import '../services/storage_service.dart';
import '../services/tab_navigation.dart';
import '../models/workout.dart';
import 'workout_detail_screen.dart';
import 'nox_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _name = 'Alex';
  int _streak = 0;
  int _calorieTarget = 2600;
  int _caloriesLogged = 0;
  int _workoutsTarget = 1;
  int _workoutsDone = 0;
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await StorageService.getProfile();
    final streak = await StorageService.getStreak();
    final target = await StorageService.getCalorieTarget();
    final logged = await StorageService.getCaloriesLoggedToday();
    final completed = await StorageService.getCompletedIds();

    if (!mounted) return;
    setState(() {
      _name = profile['name'] ?? 'Alex';
      _streak = streak;
      _calorieTarget = target;
      _caloriesLogged = logged;
      _workoutsDone = completed.isNotEmpty ? 1 : 0;
      _completedCount = completed.length;
    });
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_caloriesLogged / _calorieTarget).clamp(0.0, 1.0);
    final missionDone = _workoutsDone >= _workoutsTarget;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.accentBlue,
        backgroundColor: AppColors.darkSurface,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_greeting, style: AppTextStyles.bodySmall()),
                      Text(_name, style: AppTextStyles.heading1()),
                    ],
                  ),
                ),
                const AppLogo(size: 32),
              ],
            ),
            const SizedBox(height: 22),

            // Today's Mission
            VexonCard(
              color: AppColors.primaryBlue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Today's Mission",
                          style: AppTextStyles.heading3(color: Colors.white)),
                      Icon(
                        missionDone ? Icons.check_circle : Icons.flag_rounded,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    missionDone
                        ? 'Workout complete. Keep the calorie target in range.'
                        : 'Complete 1 workout and stay within your calorie target.',
                    style: AppTextStyles.bodySmall(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedLinearProgress(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_caloriesLogged / $_calorieTarget kcal',
                    style: AppTextStyles.bodySmall(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Streak
            VexonCard(
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_fire_department_rounded,
                        color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$_streak day streak',
                            style: AppTextStyles.heading3(
                                color: AppColors.textPrimaryDark)),
                        Text('Show up tomorrow to keep it alive',
                            style: AppTextStyles.bodySmall()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Quick Actions
            const SectionHeader(title: 'Quick Actions'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.play_arrow_rounded,
                    label: 'Start Workout',
                    onTap: TabNavigation.goToWorkouts,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.restaurant_menu_rounded,
                    label: 'Log Meal',
                    onTap: TabNavigation.goToNutrition,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.bar_chart_rounded,
                    label: 'View Progress',
                    onTap: TabNavigation.goToProgress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            const SectionHeader(title: 'Achievements'),
            const SizedBox(height: 12),
            AchievementStrip(streak: _streak, completedCount: _completedCount),
            const SizedBox(height: 22),

            // Smart Suggestion
            VexonDarkCard(
              onTap: () => Navigator.of(context).push(vexonRoute(const NoxChatScreen())),
              child: Row(
                children: [
                  const Icon(Icons.smart_toy_rounded,
                      color: AppColors.accentBlue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Nox: Prioritize protein today, it is a training day.',
                      style: AppTextStyles.bodySmall(color: Colors.white))
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 22),

            SectionHeader(
              title: 'Suggested for You',
              actionLabel: 'See all',
              onAction: TabNavigation.goToWorkouts,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: kAllWorkouts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final w = kAllWorkouts[index];
                  return GestureDetector(
                    onTap: () => Navigator.of(context).push(vexonRoute(WorkoutDetailScreen(workout: w))
                    ),
                    child: Container(
                      width: 160,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Color(int.parse(
                                w.colorHex.replaceFirst('#', '0xFF')))
                            .withOpacity(0.9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(w.category,
                              style: AppTextStyles.bodySmall(color: Colors.white70)),
                          Text(w.title,
                              style: AppTextStyles.heading3(color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          Text('${w.duration} - ${w.difficulty}',
                              style: AppTextStyles.bodySmall(color: Colors.white70)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return VexonCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(color: AppColors.textPrimaryDark)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
