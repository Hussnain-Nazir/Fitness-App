// nutrition_screen.dart
// Daily calorie tracking, Breakfast/Lunch/Dinner sections, high-protein
// suggestions, and water tracking.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/vexon_card.dart';
import '../widgets/section_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/animated_progress.dart';
import '../models/meal.dart';
import '../services/storage_service.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  List<Meal> _meals = [];
  int _target = 2600;
  int _logged = 0;
  int _waterCups = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final meals = await StorageService.getMealsToday();
    final target = await StorageService.getCalorieTarget();
    final logged = await StorageService.getCaloriesLoggedToday();
    final water = await StorageService.getWaterCups();

    if (!mounted) return;
    setState(() {
      _meals = meals;
      _target = target;
      _logged = logged;
      _waterCups = water;
    });
  }

  Future<void> _toggleMeal(Meal meal) async {
    final updated = _meals
        .map((m) => m.id == meal.id ? m.copyWith(logged: !m.logged) : m)
        .toList();
    setState(() => _meals = updated);
    await StorageService.saveMealsToday(updated);

    if (!meal.logged) {
      await StorageService.addCaloriesLogged(meal.calories);
      final logged = await StorageService.getCaloriesLoggedToday();
      if (mounted) setState(() => _logged = logged);
    }
  }

  Future<void> _setWater(int cups) async {
    setState(() => _waterCups = cups);
    await StorageService.setWaterCups(cups);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_logged / _target).clamp(0.0, 1.0);

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
            Text('Nutrition', style: AppTextStyles.heading1()),
            const SizedBox(height: 4),
            Text('Fuel the work you put in', style: AppTextStyles.bodySmall()),
            const SizedBox(height: 20),

            if (_logged == 0) ...[
              VexonDarkCard(
                child: EmptyState(
                  icon: Icons.restaurant_menu_outlined,
                  title: 'Nothing logged today',
                  message: 'Tap a meal below once you eat it to track calories '
                      'and protein automatically.',
                  actionLabel: _meals.isEmpty ? null : 'Log First Meal',
                  onAction: _meals.isEmpty
                      ? null
                      : () => _toggleMeal(_meals.first),
                ),
              ),
              const SizedBox(height: 22),
            ],

            VexonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Calories Today',
                          style: AppTextStyles.heading3(
                              color: AppColors.textPrimaryDark)),
                      Text('$_logged / $_target kcal',
                          style: AppTextStyles.bodySmall()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedLinearProgress(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: AppColors.cardBorderLight,
                      valueColor: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            for (final slot in kMealSlots) ...[
              SectionHeader(title: slot),
              const SizedBox(height: 10),
              ..._meals.where((m) => m.slot == slot).map(
                    (m) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: VexonCard(
                        onTap: () => _toggleMeal(m),
                        child: Row(
                          children: [
                            Icon(
                              m.logged
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: m.logged
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m.name,
                                      style: AppTextStyles.heading3(
                                          color: AppColors.textPrimaryDark)),
                                  Text(
                                    '${m.calories} kcal - ${m.proteinGrams}g protein',
                                    style: AppTextStyles.bodySmall(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 12),
            ],

            const SectionHeader(title: 'High-Protein Suggestions'),
            const SizedBox(height: 10),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: kProteinSuggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final s = kProteinSuggestions[i];
                  return Container(
                    width: 150,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(s['name']!,
                            style: AppTextStyles.body(color: Colors.white),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        Text(s['protein']!,
                            style:
                                AppTextStyles.bodySmall(color: AppColors.accentBlue)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),

            const SectionHeader(title: 'Water Intake'),
            const SizedBox(height: 10),
            VexonCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$_waterCups / ${StorageService.kWaterTargetCups} cups',
                      style: AppTextStyles.heading3(
                          color: AppColors.textPrimaryDark)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _waterCups > 0
                            ? () => _setWater(_waterCups - 1)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline,
                            color: AppColors.primaryBlue),
                      ),
                      IconButton(
                        onPressed: _waterCups < StorageService.kWaterTargetCups
                            ? () => _setWater(_waterCups + 1)
                            : null,
                        icon: const Icon(Icons.add_circle,
                            color: AppColors.primaryBlue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
