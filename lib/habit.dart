// lib/habit.dart

enum HabitType {
  good,
  bad
}

class Habit {
  final String id;
  final String name;
  final HabitType type;
  final double xpYield;

  bool isDoneToday;

  Habit({
    required this.id,
    required this.name,
    required this.type,
    required this.xpYield,
    this.isDoneToday = false,
  }) : assert(xpYield >= 0, 'O valor de xpYield do hábito deve ser não negativo.');

  Habit copyWith({
    String? id,
    String? name,
    HabitType? type,
    double? xpYield,
    bool? isDoneToday,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      xpYield: xpYield ?? this.xpYield,
      isDoneToday: isDoneToday ?? this.isDoneToday,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Habit &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}