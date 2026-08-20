// storage_service.dart
// Central wrapper around SharedPreferences. Every screen that needs to
// read/write local data goes through this service so persistence logic
// lives in one place.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../models/meal.dart';
import '../models/user_profile.dart';

class StorageService {
  // ---------- Keys ----------
  static const String kCompletedKey = 'completed_workout_ids';
  static const String kProfileNameKey = 'profile_name';
  static const String kProfileUsernameKey = 'profile_username';
  static const String kProfileCountryKey = 'profile_country';
  static const String kDarkModeKey = 'dark_mode_enabled';
  static const String kUsersKey = 'registered_users';

  static const String kStreakCountKey = 'streak_count';
  static const String kLastActiveDateKey = 'last_active_date';
  static const String kCalorieTargetKey = 'calorie_target';
  static const String kCaloriesLoggedTodayKey = 'calories_logged_today';
  static const String kWaterCupsKey = 'water_cups_today';

  /// Daily water goal shown as "X / 8 cups" on Nutrition. Named here so
  /// the storage clamp and the UI always agree on the same number.
  static const int kWaterTargetCups = 8;
  static const String kWeightLogKey = 'weight_log'; // JSON list of {date, kg}
  static const String kCaloriesWeeklyKey = 'calories_weekly'; // JSON list of 7 ints
  static const String kWorkoutsWeeklyKey = 'workouts_weekly'; // JSON list of 7 ints
  static const String kMealsKey = 'meals_today'; // JSON list of Meal
  static const String kChatHistoryKey = 'nox_chat_history';
  static const String kScheduledWorkoutsKey =
      'scheduled_workouts'; // JSON map yyyy-mm-dd -> workoutId

  static const String kOnboardingCompleteKey = 'onboarding_complete';
  static const String kUserProfileKey = 'user_profile'; // JSON UserProfile
  static const String kRecentWorkoutTitlesKey =
      'recent_workout_titles'; // JSON list, most recent first

  static const String kNotifyWorkoutKey = 'notify_workout_enabled';
  static const String kNotifyWaterKey = 'notify_water_enabled';
  static const String kNotifyMealKey = 'notify_meal_enabled';

  static const String kDailyResetDateKey = 'daily_reset_date';

  // ---------- Completed workouts ----------
  static Future<List<String>> getCompletedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(kCompletedKey) ?? [];
  }

  static Future<void> setCompletedIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(kCompletedKey, ids);
  }

  static Future<void> markWorkoutComplete(String workoutId, {String? title}) async {
    final ids = await getCompletedIds();
    if (!ids.contains(workoutId)) {
      ids.add(workoutId);
      await setCompletedIds(ids);
      await _bumpStreak();
      await _bumpWeeklyWorkouts();
      if (title != null) await _pushRecentWorkoutTitle(title);
    }
  }

  // ---------- Profile / Settings ----------
  // Name/username/country are simple free-text account fields. Age, goal,
  // height, weight, and experience live only in UserProfile (see below) -
  // keeping a single source of truth so editing them anywhere (Profile,
  // Settings, onboarding) stays in sync with what Nox and the calorie
  // calculation actually use.
  static Future<void> saveProfile({
    required String name,
    required String username,
    required String country,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kProfileNameKey, name);
    await prefs.setString(kProfileUsernameKey, username);
    await prefs.setString(kProfileCountryKey, country);
  }

  static Future<Map<String, String>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(kProfileNameKey) ?? 'Alex',
      'username': prefs.getString(kProfileUsernameKey) ?? 'alexlifts',
      'country': prefs.getString(kProfileCountryKey) ?? 'Pakistan',
    };
  }

  static Future<void> setDarkMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kDarkModeKey, enabled);
  }

  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(kDarkModeKey) ?? true;
  }

  // ---------- Registered users ----------
  static Future<Map<String, String>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kUsersKey);
    if (raw == null) return {};
    return Map<String, String>.from(jsonDecode(raw));
  }

  static Future<void> saveUsers(Map<String, String> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kUsersKey, jsonEncode(users));
  }

  // ---------- Streak ----------
  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(kStreakCountKey) ?? 0;
  }

  static Future<void> _bumpStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final lastActive = prefs.getString(kLastActiveDateKey);
    if (lastActive == today) return; // already counted today

    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    final current = prefs.getInt(kStreakCountKey) ?? 0;
    final next = (lastActive == yesterday) ? current + 1 : 1;

    await prefs.setInt(kStreakCountKey, next);
    await prefs.setString(kLastActiveDateKey, today);
  }

  static String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ---------- Calories / mission ----------
  static Future<int> getCalorieTarget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(kCalorieTargetKey) ?? 2600;
  }

  static Future<void> setCalorieTarget(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(kCalorieTargetKey, value);
  }

  static Future<int> getCaloriesLoggedToday() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(kCaloriesLoggedTodayKey) ?? 0;
  }

  static Future<void> addCaloriesLogged(int value) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(kCaloriesLoggedTodayKey) ?? 0;
    await prefs.setInt(kCaloriesLoggedTodayKey, current + value);
  }

  // ---------- Water ----------
  static Future<int> getWaterCups() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(kWaterCupsKey) ?? 0;
  }

  static Future<void> setWaterCups(int cups) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(kWaterCupsKey, cups.clamp(0, kWaterTargetCups));
  }

  // ---------- Weight log ----------
  static Future<List<Map<String, dynamic>>> getWeightLog() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kWeightLogKey);
    if (raw == null) {
      return [
        {'label': 'Mon', 'kg': 82.0},
        {'label': 'Tue', 'kg': 81.7},
        {'label': 'Wed', 'kg': 81.9},
        {'label': 'Thu', 'kg': 81.4},
        {'label': 'Fri', 'kg': 81.2},
        {'label': 'Sat', 'kg': 80.9},
        {'label': 'Sun', 'kg': 80.6},
      ];
    }
    return List<Map<String, dynamic>>.from(jsonDecode(raw));
  }

  static Future<void> addWeightEntry(double kg) async {
    final prefs = await SharedPreferences.getInstance();
    final log = await getWeightLog();
    log.add({'label': _dateKey(DateTime.now()).substring(5), 'kg': kg});
    if (log.length > 7) log.removeAt(0);
    await prefs.setString(kWeightLogKey, jsonEncode(log));
  }

  // ---------- Weekly analytics (calories burned / workouts) ----------
  static Future<List<int>> getWeeklyCalories() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kCaloriesWeeklyKey);
    if (raw == null) return [320, 480, 260, 510, 390, 610, 430];
    return List<int>.from(jsonDecode(raw));
  }

  static Future<List<int>> getWeeklyWorkoutCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kWorkoutsWeeklyKey);
    if (raw == null) return [1, 1, 0, 1, 1, 1, 0];
    return List<int>.from(jsonDecode(raw));
  }

  static Future<void> _bumpWeeklyWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final counts = await getWeeklyWorkoutCounts();
    final weekday = DateTime.now().weekday - 1; // 0 = Mon
    if (weekday >= 0 && weekday < counts.length) {
      counts[weekday] += 1;
    }
    await prefs.setString(kWorkoutsWeeklyKey, jsonEncode(counts));

    final calories = await getWeeklyCalories();
    if (weekday >= 0 && weekday < calories.length) {
      calories[weekday] += 300;
    }
    await prefs.setString(kCaloriesWeeklyKey, jsonEncode(calories));
  }

  // ---------- Meals ----------
  static Future<List<Meal>> getMealsToday() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kMealsKey);
    if (raw == null) return List.of(kDefaultMeals);
    final list = jsonDecode(raw) as List;
    return list.map((e) => Meal.fromJson(e)).toList();
  }

  static Future<void> saveMealsToday(List<Meal> meals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        kMealsKey, jsonEncode(meals.map((m) => m.toJson()).toList()));
  }

  // ---------- Nox chat history ----------
  static Future<List<ChatMessage>> getChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kChatHistoryKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => ChatMessage.fromJson(e)).toList();
  }

  static Future<void> saveChatHistory(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed =
        messages.length > 100 ? messages.sublist(messages.length - 100) : messages;
    await prefs.setString(
        kChatHistoryKey, jsonEncode(trimmed.map((m) => m.toJson()).toList()));
  }

  // ---------- Calendar scheduling ----------
  static Future<Map<String, String>> getScheduledWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kScheduledWorkoutsKey);
    if (raw == null) return {};
    return Map<String, String>.from(jsonDecode(raw));
  }

  static Future<void> scheduleWorkout(DateTime date, String workoutId) async {
    final prefs = await SharedPreferences.getInstance();
    final map = await getScheduledWorkouts();
    map[_dateKey(date)] = workoutId;
    await prefs.setString(kScheduledWorkoutsKey, jsonEncode(map));
  }

  static Future<void> unscheduleWorkout(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final map = await getScheduledWorkouts();
    map.remove(_dateKey(date));
    await prefs.setString(kScheduledWorkoutsKey, jsonEncode(map));
  }

  static String dateKeyFor(DateTime date) => _dateKey(date);

  // ---------- Onboarding ----------
  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(kOnboardingCompleteKey) ?? false;
  }

  static Future<void> setOnboardingComplete(bool complete) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingCompleteKey, complete);
  }

  static Future<UserProfile> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kUserProfileKey);
    if (raw == null) return UserProfile.empty;
    return UserProfile.fromJson(jsonDecode(raw));
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kUserProfileKey, jsonEncode(profile.toJson()));
    // Seed the calorie target from the onboarding data the first time,
    // without clobbering a value the user may have customized since.
    if (prefs.getInt(kCalorieTargetKey) == null) {
      await prefs.setInt(kCalorieTargetKey, profile.suggestedCalorieTarget);
    }
  }

  // ---------- Recent workouts (for Nox context) ----------
  static Future<List<String>> getRecentWorkoutTitles({int limit = 5}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kRecentWorkoutTitlesKey);
    if (raw == null) return [];
    final list = List<String>.from(jsonDecode(raw));
    return list.take(limit).toList();
  }

  static Future<void> _pushRecentWorkoutTitle(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getRecentWorkoutTitles(limit: 20);
    list.removeWhere((t) => t == title);
    list.insert(0, title);
    final trimmed = list.take(10).toList();
    await prefs.setString(kRecentWorkoutTitlesKey, jsonEncode(trimmed));
  }

  // ---------- Notification preferences ----------
  static Future<Map<String, bool>> getNotificationPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'workout': prefs.getBool(kNotifyWorkoutKey) ?? true,
      'water': prefs.getBool(kNotifyWaterKey) ?? true,
      'meal': prefs.getBool(kNotifyMealKey) ?? false,
    };
  }

  static Future<void> setNotificationPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    switch (key) {
      case 'workout':
        await prefs.setBool(kNotifyWorkoutKey, value);
        break;
      case 'water':
        await prefs.setBool(kNotifyWaterKey, value);
        break;
      case 'meal':
        await prefs.setBool(kNotifyMealKey, value);
        break;
    }
  }

  // ---------- Daily rollover ----------
  /// Calories logged, water cups, and meal-logged flags are all "today"
  /// values that previously never reset - once logged, they stayed logged
  /// forever. This resets them the first time the app runs on a new day.
  /// Cheap and idempotent - safe to call on every cold start.
  static Future<void> ensureDailyRollover() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final lastReset = prefs.getString(kDailyResetDateKey);
    if (lastReset == today) return;

    await prefs.setInt(kCaloriesLoggedTodayKey, 0);
    await prefs.setInt(kWaterCupsKey, 0);

    final meals = await getMealsToday();
    final resetMeals = meals.map((m) => m.copyWith(logged: false)).toList();
    await saveMealsToday(resetMeals);

    await prefs.setString(kDailyResetDateKey, today);
  }

  /// Returns every key/value currently stored, as raw strings (debug use).
  static Future<Map<String, String>> getAllRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final Map<String, String> result = {};
    for (final key in keys) {
      final value = prefs.get(key);
      result[key] = value.toString();
    }
    return result;
  }
}
