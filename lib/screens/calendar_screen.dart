// calendar_screen.dart
// Workout scheduling: assign a workout to a date, highlight active days,
// view the schedule for the selected date.

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/vexon_card.dart';
import '../models/workout.dart';
import '../services/storage_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<String, String> _scheduled = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final scheduled = await StorageService.getScheduledWorkouts();
    if (mounted) setState(() => _scheduled = scheduled);
  }

  Workout? _workoutFor(DateTime day) {
    final id = _scheduled[StorageService.dateKeyFor(day)];
    if (id == null) return null;
    try {
      return kAllWorkouts.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _assignWorkout() async {
    final choice = await showModalBottomSheet<Workout>(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assign a workout', style: AppTextStyles.heading3()),
                const SizedBox(height: 12),
                ...kAllWorkouts.map((w) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(w.title,
                          style: AppTextStyles.body(color: Colors.white)),
                      subtitle: Text('${w.category} - ${w.duration}',
                          style: AppTextStyles.bodySmall()),
                      onTap: () => Navigator.of(context).pop(w),
                    )),
              ],
            ),
          ),
        );
      },
    );

    if (choice != null) {
      await StorageService.scheduleWorkout(_selectedDay, choice.id);
      await _load();
    }
  }

  Future<void> _clearWorkout() async {
    await StorageService.unscheduleWorkout(_selectedDay);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final assigned = _workoutFor(_selectedDay);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(title: Text('Schedule', style: AppTextStyles.heading3())),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            VexonCard(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 60)),
                lastDay: DateTime.now().add(const Duration(days: 90)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  });
                },
                calendarFormat: CalendarFormat.month,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                      color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600),
                  leftChevronIcon:
                      Icon(Icons.chevron_left, color: AppColors.textPrimaryDark),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: AppColors.textPrimaryDark),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: AppColors.textSecondary),
                  weekendStyle: TextStyle(color: AppColors.textSecondary),
                ),
                calendarStyle: const CalendarStyle(
                  defaultTextStyle: TextStyle(color: AppColors.textPrimaryDark),
                  weekendTextStyle: TextStyle(color: AppColors.textPrimaryDark),
                  todayDecoration: BoxDecoration(
                    color: AppColors.accentBlue,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
                eventLoader: (day) {
                  final w = _workoutFor(day);
                  return w == null ? [] : [w];
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Schedule for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
              style: AppTextStyles.heading3(),
            ),
            const SizedBox(height: 12),
            if (assigned == null)
              VexonDarkCard(
                onTap: _assignWorkout,
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline, color: AppColors.accentBlue),
                    const SizedBox(width: 10),
                    Text('Assign a workout to this day',
                        style: AppTextStyles.body(color: Colors.white)),
                  ],
                ),
              )
            else
              VexonCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Color(int.parse(
                            assigned.colorHex.replaceFirst('#', '0xFF'))),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.fitness_center_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(assigned.title,
                              style: AppTextStyles.heading3(
                                  color: AppColors.textPrimaryDark)),
                          Text('${assigned.category} - ${assigned.duration}',
                              style: AppTextStyles.bodySmall()),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _clearWorkout,
                      icon: const Icon(Icons.close, color: AppColors.danger),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
