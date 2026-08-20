// meal.dart
// Meal data model + high-protein suggestions for the Nutrition screen.

class Meal {
  final String id;
  final String name;
  final String slot; // Breakfast, Lunch, Dinner
  final int calories;
  final int proteinGrams;
  final bool logged;

  const Meal({
    required this.id,
    required this.name,
    required this.slot,
    required this.calories,
    required this.proteinGrams,
    this.logged = false,
  });

  Meal copyWith({bool? logged}) => Meal(
        id: id,
        name: name,
        slot: slot,
        calories: calories,
        proteinGrams: proteinGrams,
        logged: logged ?? this.logged,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slot': slot,
        'calories': calories,
        'proteinGrams': proteinGrams,
        'logged': logged,
      };

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
        id: json['id'],
        name: json['name'],
        slot: json['slot'],
        calories: json['calories'],
        proteinGrams: json['proteinGrams'],
        logged: json['logged'] ?? false,
      );
}

const List<String> kMealSlots = ['Breakfast', 'Lunch', 'Dinner'];

/// Default meal plan for the day. Persisted state (logged flags) is
/// layered on top via StorageService.
final List<Meal> kDefaultMeals = [
  const Meal(
    id: 'm1',
    name: 'Egg Whites & Oats',
    slot: 'Breakfast',
    calories: 420,
    proteinGrams: 38,
  ),
  const Meal(
    id: 'm2',
    name: 'Grilled Chicken & Rice',
    slot: 'Lunch',
    calories: 620,
    proteinGrams: 52,
  ),
  const Meal(
    id: 'm3',
    name: 'Salmon & Vegetables',
    slot: 'Dinner',
    calories: 540,
    proteinGrams: 45,
  ),
];

/// High-protein suggestions shown below the meal sections.
const List<Map<String, String>> kProteinSuggestions = [
  {'name': 'Greek Yogurt Bowl', 'protein': '24g protein'},
  {'name': 'Steak & Sweet Potato', 'protein': '48g protein'},
  {'name': 'Tuna & Whole Wheat Wrap', 'protein': '36g protein'},
  {'name': 'Protein Shake & Almonds', 'protein': '30g protein'},
];
