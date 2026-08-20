// progress_screen.dart
// Premium analytics dashboard - circular progress, weekly bar chart for
// workouts, line chart for calories/weight, and streak visualization.
// Charts are built with fl_chart and are the primary visual element here.

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/vexon_card.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/animated_progress.dart';
import '../services/storage_service.dart';
import '../services/tab_navigation.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _streak = 0;
  List<int> _weeklyCalories = [];
  List<int> _weeklyWorkouts = [];
  List<Map<String, dynamic>> _weightLog = [];
  int _calorieTarget = 2600;
  int _caloriesLogged = 0;
  bool _hasActivity = false;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final streak = await StorageService.getStreak();
    final cals = await StorageService.getWeeklyCalories();
    final workouts = await StorageService.getWeeklyWorkoutCounts();
    final weight = await StorageService.getWeightLog();
    final target = await StorageService.getCalorieTarget();
    final logged = await StorageService.getCaloriesLoggedToday();
    final completed = await StorageService.getCompletedIds();

    if (!mounted) return;
    setState(() {
      _streak = streak;
      _weeklyCalories = cals;
      _weeklyWorkouts = workouts;
      _weightLog = weight;
      _calorieTarget = target;
      _caloriesLogged = logged;
      _hasActivity = streak > 0 || completed.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_weeklyCalories.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentBlue),
      );
    }

    final progress = (_caloriesLogged / _calorieTarget).clamp(0.0, 1.0);
    final maxCal = _weeklyCalories.reduce((a, b) => a > b ? a : b).toDouble();

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
            Text('Progress', style: AppTextStyles.heading1()),
            const SizedBox(height: 4),
            Text('Your analytics dashboard',
                style: AppTextStyles.bodySmall()),
            const SizedBox(height: 20),

            if (!_hasActivity) ...[
              VexonDarkCard(
                child: EmptyState(
                  icon: Icons.insights_outlined,
                  title: 'No activity yet',
                  message:
                      'Complete your first workout to start building real charts '
                      'here. The numbers below are a preview.',
                  actionLabel: 'Start a Workout',
                  onAction: TabNavigation.goToWorkouts,
                ),
              ),
              const SizedBox(height: 22),
            ],

            // Circular progress ring
            VexonCard(
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: AnimatedProgressRing(
                      value: progress,
                      backgroundColor: AppColors.cardBorderLight,
                      valueColor: AppColors.primaryBlue,
                      centerBuilder: (animatedValue) => Text(
                        '${(animatedValue * 100).round()}%',
                        style: AppTextStyles.heading3(color: AppColors.textPrimaryDark),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily Calorie Goal',
                            style: AppTextStyles.heading3(
                                color: AppColors.textPrimaryDark)),
                        const SizedBox(height: 4),
                        Text('$_caloriesLogged of $_calorieTarget kcal',
                            style: AppTextStyles.bodySmall()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.local_fire_department_rounded,
                    value: '$_streak',
                    label: 'DAY STREAK',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.fitness_center_rounded,
                    value: '${_weeklyWorkouts.fold<int>(0, (a, b) => a + b)}',
                    label: 'WORKOUTS THIS WEEK',
                    iconColor: AppColors.accentBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            const SectionHeader(title: 'Calories Burned - This Week'),
            const SizedBox(height: 12),
            VexonCard(
              child: SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    maxY: maxCal + 100,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= _dayLabels.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(_dayLabels[i],
                                  style: AppTextStyles.bodySmall()),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(_weeklyCalories.length, (i) {
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: _weeklyCalories[i].toDouble(),
                            color: AppColors.primaryBlue,
                            width: 16,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),

            const SectionHeader(title: 'Weight Trend'),
            const SizedBox(height: 12),
            VexonCard(
              child: SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= _weightLog.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(_weightLog[i]['label'].toString(),
                                  style: AppTextStyles.bodySmall()),
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(_weightLog.length, (i) {
                          return FlSpot(
                              i.toDouble(), (_weightLog[i]['kg'] as num).toDouble());
                        }),
                        isCurved: true,
                        color: AppColors.accentBlue,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.accentBlue.withOpacity(0.12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),

            const SectionHeader(title: 'Weekly Streak Visualization'),
            const SizedBox(height: 12),
            VexonCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_weeklyWorkouts.length, (i) {
                  final active = _weeklyWorkouts[i] > 0;
                  return Column(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primaryBlue
                              : AppColors.cardBorderLight,
                          shape: BoxShape.circle,
                        ),
                        child: active
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(_dayLabels[i], style: AppTextStyles.bodySmall()),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
