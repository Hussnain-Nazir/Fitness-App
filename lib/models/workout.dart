// workout.dart
// Workout data model + seed data for the Workouts screen.

class Workout {
  final String id;
  final String title;
  final String category; // Chest, Arms, Legs, Full Body
  final String duration;
  final String difficulty; // Beginner, Intermediate, Advanced
  final String description;
  final String colorHex;
  final int caloriesEstimate;

  const Workout({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.difficulty,
    required this.description,
    required this.colorHex,
    required this.caloriesEstimate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'duration': duration,
        'difficulty': difficulty,
        'description': description,
        'colorHex': colorHex,
        'caloriesEstimate': caloriesEstimate,
      };

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
        id: json['id'],
        title: json['title'],
        category: json['category'],
        duration: json['duration'],
        difficulty: json['difficulty'] ?? 'Beginner',
        description: json['description'],
        colorHex: json['colorHex'],
        caloriesEstimate: json['caloriesEstimate'] ?? 250,
      );
}

const List<String> kWorkoutCategories = [
  'Chest',
  'Arms',
  'Legs',
  'Full Body',
];

const List<String> kWorkoutDifficulties = [
  'Beginner',
  'Intermediate',
  'Advanced',
];

/// Static seed data used across the app (Workouts, Detail, Home screens).
/// In a production app this would come from a database or API.
final List<Workout> kAllWorkouts = [
  const Workout(
    id: 'w1',
    title: 'Push Power Chest',
    category: 'Chest',
    duration: '35 min',
    difficulty: 'Intermediate',
    colorHex: '#2563EB',
    caloriesEstimate: 320,
    description:
        'Bench press, incline dumbbell press, and dips combined into a '
        'straight-forward chest routine built for strength and size.',
  ),
  const Workout(
    id: 'w2',
    title: 'Arm Builder',
    category: 'Arms',
    duration: '25 min',
    difficulty: 'Beginner',
    colorHex: '#3B82F6',
    caloriesEstimate: 210,
    description:
        'Curls, tricep pushdowns, and hammer curls in a superset format to '
        'pack size onto the biceps and triceps without wasted time.',
  ),
  const Workout(
    id: 'w3',
    title: 'Leg Day Foundation',
    category: 'Legs',
    duration: '45 min',
    difficulty: 'Advanced',
    colorHex: '#1D4ED8',
    caloriesEstimate: 450,
    description:
        'Squats, Romanian deadlifts, and walking lunges. Heavy compound '
        'lifts designed to build raw lower-body strength.',
  ),
  const Workout(
    id: 'w4',
    title: 'Full Body Circuit',
    category: 'Full Body',
    duration: '40 min',
    difficulty: 'Intermediate',
    colorHex: '#60A5FA',
    caloriesEstimate: 400,
    description:
        'A high-intensity circuit mixing bodyweight and free-weight moves '
        'to hit every major muscle group and keep the heart rate elevated.',
  ),
  const Workout(
    id: 'w5',
    title: 'Core & Discipline',
    category: 'Full Body',
    duration: '20 min',
    difficulty: 'Beginner',
    colorHex: '#2563EB',
    caloriesEstimate: 180,
    description:
        'A focused core session - planks, hanging leg raises, and cable '
        'crunches - to build a stable, strong midline.',
  ),
  const Workout(
    id: 'w6',
    title: 'Heavy Leg Press',
    category: 'Legs',
    duration: '30 min',
    difficulty: 'Advanced',
    colorHex: '#1E40AF',
    caloriesEstimate: 380,
    description:
        'Leg press, calf raises, and step-ups for a lower-body session that '
        'targets strength without loading the spine.',
  ),
];
