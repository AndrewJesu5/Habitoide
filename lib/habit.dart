// lib/habit.dart
import 'dart:convert';

enum HabitType {
  good,
  bad
}

String habitTypeToString(HabitType type) => type.toString().split('.').last;
HabitType habitTypeFromString(String typeString) =>
    HabitType.values.firstWhere((e) => e.toString().split('.').last == typeString, orElse: () => HabitType.good);


class Habit {
  final String id;
  String name; 
  HabitType type; 
  bool isDoneToday;

  Habit({
    required this.id,
    required this.name,
    required this.type,
    this.isDoneToday = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': habitTypeToString(type), 
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: habitTypeFromString(map['type'] ?? 'good'),
      isDoneToday: false,
    );
  }

  String toJson() => json.encode(toMap());
  factory Habit.fromJson(String source) => Habit.fromMap(json.decode(source));
}

class HabitCompletion {
  final String habitId;
  final DateTime date;

  HabitCompletion({required this.habitId, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'habitId': habitId,
      'date': date.toIso8601String(), 
    };
  }

  factory HabitCompletion.fromMap(Map<String, dynamic> map) {
    return HabitCompletion(
      habitId: map['habitId'] ?? '',
      date: DateTime.parse(map['date']),
    );
  }

  String toJson() => json.encode(toMap());
  factory HabitCompletion.fromJson(String source) => HabitCompletion.fromMap(json.decode(source));
}