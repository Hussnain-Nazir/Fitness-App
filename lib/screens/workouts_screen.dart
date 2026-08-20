// workouts_screen.dart
// Category-based workout browser with Beginner/Intermediate/Advanced
// filters, plus quick access to the AI workout generator and calendar.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/page_transitions.dart';
import '../widgets/vexon_card.dart';
import '../widgets/empty_state.dart';
import '../models/workout.dart';
import 'workout_detail_screen.dart';
import 'workout_generator_screen.dart';
import 'calendar_screen.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  String _category = 'All';
  String? _difficulty;

  List<Workout> get _filtered {
    return kAllWorkouts.where((w) {
      final categoryMatch = _category == 'All' || w.category == _category;
      final difficultyMatch = _difficulty == null || w.difficulty == _difficulty;
      return categoryMatch && difficultyMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Workouts', style: AppTextStyles.heading1()),
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Schedule',
                      onPressed: () => Navigator.of(context).push(vexonRoute(const CalendarScreen())),
                      icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
                    ),
                    IconButton(
                      tooltip: 'AI Generator',
                      onPressed: () => Navigator.of(context)
                          .push(vexonRoute(const WorkoutGeneratorScreen())),
                      icon: const Icon(Icons.auto_awesome_rounded,
                          color: AppColors.accentBlue),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _categoryChip('All'),
                ...kWorkoutCategories.map(_categoryChip),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _difficultyChip(null, 'All Levels'),
                ...kWorkoutDifficulties.map((d) => _difficultyChip(d, d)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: EmptyState(
                      icon: Icons.filter_alt_off_rounded,
                      title: 'No workouts match',
                      message: 'Try a different category or difficulty filter.',
                      actionLabel: 'Clear Filters',
                      onAction: () => setState(() {
                        _category = 'All';
                        _difficulty = null;
                      }))
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final w = _filtered[index];
                      return _WorkoutCard(workout: w);
                    },
                  ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _categoryChip(String label) {
    final selected = _category == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _category = label),
        backgroundColor: AppColors.darkSurface,
        selectedColor: AppColors.primaryBlue,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: selected ? AppColors.primaryBlue : AppColors.divider),
        ),
      ),
    );
  }

  Widget _difficultyChip(String? value, String label) {
    final selected = _difficulty == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _difficulty = value),
        backgroundColor: Colors.transparent,
        selectedColor: AppColors.accentBlue.withOpacity(0.15),
        labelStyle: TextStyle(
          color: selected ? AppColors.accentBlue : AppColors.textSecondary,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
              color: selected ? AppColors.accentBlue : AppColors.divider),
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final Workout workout;
  const _WorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(workout.colorHex.replaceFirst('#', '0xFF')));

    return VexonCard(
      onTap: () => Navigator.of(context)
          .push(vexonRoute(WorkoutDetailScreen(workout: workout))),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fitness_center_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workout.title,
                    style: AppTextStyles.heading3(color: AppColors.textPrimaryDark)),
                const SizedBox(height: 4),
                Text('${workout.category} - ${workout.duration}',
                    style: AppTextStyles.bodySmall()),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              workout.difficulty,
              style: AppTextStyles.bodySmall(color: AppColors.primaryBlue)
                  .copyWith(fontWeight: FontWeight.w600))
          ),
        ],
      ),
    );
  }
}
