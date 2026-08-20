// user_profile.dart
// Structured onboarding data. Distinct from the free-text "profile" fields
// already stored in StorageService (name/username/country) - this model
// holds the physical + goal data used to personalize the dashboard,
// workout suggestions, and Nox's responses.

class UserProfile {
  final int age;
  final double heightCm;
  final double weightKg;
  final String goal; // 'Muscle Gain' | 'Fat Loss'
  final String experience; // 'Beginner' | 'Intermediate' | 'Advanced'

  const UserProfile({
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    required this.experience,
  });

  static const empty = UserProfile(
    age: 0,
    heightCm: 0,
    weightKg: 0,
    goal: '',
    experience: '',
  );

  bool get isComplete => age > 0 && heightCm > 0 && weightKg > 0 && goal.isNotEmpty;

  /// Rough daily calorie target derived from onboarding data. This is a
  /// simple heuristic (not a medical calculation) used to seed the
  /// Home/Nutrition calorie targets until the user overrides it.
  int get suggestedCalorieTarget {
    // Mifflin-St Jeor, male-oriented baseline, then goal-adjusted.
    final bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    final activity = bmr * 1.5; // moderate activity multiplier
    if (goal == 'Muscle Gain') return (activity + 300).round();
    if (goal == 'Fat Loss') return (activity - 400).round();
    return activity.round();
  }

  UserProfile copyWith({
    int? age,
    double? heightCm,
    double? weightKg,
    String? goal,
    String? experience,
  }) =>
      UserProfile(
        age: age ?? this.age,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        goal: goal ?? this.goal,
        experience: experience ?? this.experience,
      );

  Map<String, dynamic> toJson() => {
        'age': age,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'goal': goal,
        'experience': experience,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        age: json['age'] ?? 0,
        heightCm: (json['heightCm'] ?? 0).toDouble(),
        weightKg: (json['weightKg'] ?? 0).toDouble(),
        goal: json['goal'] ?? '',
        experience: json['experience'] ?? '',
      );
}

const List<String> kOnboardingGoals = ['Muscle Gain', 'Fat Loss'];
const List<String> kOnboardingExperience = ['Beginner', 'Intermediate', 'Advanced'];
