// tab_navigation.dart
// A tiny shared signal that lets any widget switch the active HomeShell
// tab without needing a BuildContext reference to HomeShell itself.
//
// Why this exists: screens like Workouts, Progress, and Nutrition are
// designed to live as tab bodies inside HomeShell's single Scaffold (no
// AppBar/Scaffold of their own, by design, to avoid double bars). Pushing
// them as a brand new standalone route - e.g. from Home's "Start Workout"
// quick action - puts them outside that Scaffold entirely, which breaks
// any Material-dependent widget they use (ChoiceChip/FilterChip, for
// example) and also stacks a confusing duplicate screen with no bottom
// nav. Calling TabNavigation.goTo(...) instead just switches tabs, which
// is both the correct fix and the better UX.

import 'package:flutter/foundation.dart';

class TabNavigation {
  TabNavigation._();

  static const int home = 0;
  static const int workouts = 1;
  static const int progress = 2;
  static const int nutrition = 3;
  static const int profile = 4;

  /// The active tab index. HomeShell listens to this; any screen can call
  /// [goTo] (or the named helpers below) to switch tabs from anywhere.
  static final ValueNotifier<int> index = ValueNotifier<int>(home);

  static void goTo(int tab) => index.value = tab;
  static void goToWorkouts() => goTo(workouts);
  static void goToProgress() => goTo(progress);
  static void goToNutrition() => goTo(nutrition);
  static void goToProfile() => goTo(profile);
  static void goToHome() => goTo(home);
}
