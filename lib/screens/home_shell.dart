// home_shell.dart
// Bottom-navigation container: Home, Workouts, Progress, Nutrition, Profile.
// A floating action button gives quick access to Nox, the AI coach chat,
// from any tab.
//
// The active tab is driven by TabNavigation.index rather than purely local
// state, so other screens (e.g. Home's "Start Workout" quick action) can
// switch tabs directly instead of pushing a duplicate standalone copy of
// a tab screen - see tab_navigation.dart for why that matters.

import 'package:flutter/material.dart';
import '../widgets/page_transitions.dart';
import '../theme/app_colors.dart';
import '../services/tab_navigation.dart';
import 'home_screen.dart';
import 'workouts_screen.dart';
import 'progress_screen.dart';
import 'nutrition_screen.dart';
import 'profile_screen.dart';
import 'nox_chat_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _screens = const [
    HomeScreen(),
    WorkoutsScreen(),
    ProgressScreen(),
    NutritionScreen(),
    ProfileScreen(),
  ];

  final _labels = const ['Home', 'Workouts', 'Progress', 'Nutrition', 'Profile'];
  final _icons = const [
    Icons.home_rounded,
    Icons.fitness_center_rounded,
    Icons.insights_rounded,
    Icons.restaurant_rounded,
    Icons.person_rounded,
  ];

  @override
  void initState() {
    super.initState();
    // Always open on Home, regardless of whatever tab was active the last
    // time HomeShell existed (e.g. after a logout/login cycle).
    TabNavigation.goToHome();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: TabNavigation.index,
      builder: (context, index, _) {
        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: KeyedSubtree(
              key: ValueKey(index),
              child: _screens[index],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primaryBlue,
            onPressed: () {
              Navigator.of(context).push(vexonRoute(const NoxChatScreen()));
            },
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            color: AppColors.darkSurface,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:
                    List.generate(_labels.length, (i) => _navItem(i, index)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _navItem(int i, int activeIndex) {
    final selected = activeIndex == i;
    final color = selected ? AppColors.accentBlue : AppColors.textSecondary;
    return InkWell(
      onTap: () => TabNavigation.goTo(i),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icons[i], color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              _labels[i],
              style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
