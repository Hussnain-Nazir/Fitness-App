// achievement.dart
// Badge definitions for the gamification system. Achievements are derived
// from existing data (streak count, completed workout ids) rather than
// tracked separately, so there's nothing new to keep in sync.

import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool Function(int streak, int completedCount) isUnlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
  });
}

final List<Achievement> kAchievements = [
  Achievement(
    id: 'first_workout',
    title: 'First Workout',
    description: 'Complete your first workout',
    icon: Icons.emoji_events_rounded,
    isUnlocked: (streak, completed) => completed >= 1,
  ),
  Achievement(
    id: 'streak_7',
    title: '7-Day Streak',
    description: 'Train 7 days in a row',
    icon: Icons.local_fire_department_rounded,
    isUnlocked: (streak, completed) => streak >= 7,
  ),
  Achievement(
    id: 'streak_30',
    title: '30-Day Streak',
    description: 'Train 30 days in a row',
    icon: Icons.workspace_premium_rounded,
    isUnlocked: (streak, completed) => streak >= 30,
  ),
];
