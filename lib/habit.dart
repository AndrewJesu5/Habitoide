// Arquivo: lib/habit.dart

class Habit {
  String id;
  String name;
  bool isDoneToday;
  double points;

  Habit({
    required this.id,
    required this.name,
    this.isDoneToday = false,
    this.points = 0,
  });
}