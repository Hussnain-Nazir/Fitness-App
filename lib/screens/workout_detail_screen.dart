// workout_detail_screen.dart
// Detail view for a single workout, with a Mark Complete action that
// updates the streak and weekly analytics via StorageService.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/primary_button.dart';
import '../models/workout.dart';
import '../services/storage_service.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;
  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  bool _completed = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _checkCompleted();
  }

  Future<void> _checkCompleted() async {
    final ids = await StorageService.getCompletedIds();
    if (mounted) setState(() => _completed = ids.contains(widget.workout.id));
  }

  Future<void> _markComplete() async {
    setState(() => _saving = true);
    await StorageService.markWorkoutComplete(widget.workout.id, title: widget.workout.title);
    if (!mounted) return;
    setState(() {
      _completed = true;
      _saving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        content: Text('Workout logged. Streak updated.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.workout;
    final color = Color(int.parse(w.colorHex.replaceFirst('#', '0xFF')));

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.fitness_center_rounded,
                    color: Colors.white, size: 56),
              ),
              const SizedBox(height: 20),
              Text(w.category.toUpperCase(),
                  style: AppTextStyles.bodySmall(color: AppColors.accentBlue)
                      .copyWith(letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(w.title, style: AppTextStyles.heading1()),
              const SizedBox(height: 16),
              Row(
                children: [
                  _MetaChip(icon: Icons.timer_outlined, label: w.duration),
                  const SizedBox(width: 10),
                  _MetaChip(icon: Icons.bolt_rounded, label: w.difficulty),
                  const SizedBox(width: 10),
                  _MetaChip(
                    icon: Icons.local_fire_department_outlined,
                    label: '${w.caloriesEstimate} kcal',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Overview', style: AppTextStyles.heading3()),
              const SizedBox(height: 8),
              Text(w.description,
                  style: AppTextStyles.body(color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              PrimaryButton(
                label: _completed ? 'Completed Today' : 'Mark as Complete',
                icon: _completed ? Icons.check_circle : Icons.play_arrow_rounded,
                loading: _saving,
                onPressed: _completed ? null : _markComplete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.bodySmall(color: Colors.white)),
        ],
      ),
    );
  }
}
