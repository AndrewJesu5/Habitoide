// lib/habit_provider.dart
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'habit.dart';

class HabitCompletion {
  final String habitId;
  final DateTime date;

  HabitCompletion({required this.habitId, required this.date});
}

enum MascotState { happy, neutral, sad }

class HabitProvider with ChangeNotifier {
  final List<Habit> _habits = [];
  final Uuid _uuid = const Uuid();

  final List<HabitCompletion> _completionHistory = [];

  int _currentLevel = 1;
  double _currentXp = 0.0;
  double _xpToNextLevel = 100.0;

  int get currentLevel => _currentLevel;
  double get currentXp => _currentXp;
  double get xpToNextLevel => _xpToNextLevel;

  List<Habit> get habits => List.unmodifiable(_habits);
  List<HabitCompletion> get completionHistory => List.unmodifiable(_completionHistory); 

  int get goodHabitsDoneCount => _habits.where((h) => h.type == HabitType.good && h.isDoneToday).length;
  int get totalGoodHabitsCount => _habits.where((h) => h.type == HabitType.good).length;
  int get badHabitsDoneCount => _habits.where((h) => h.type == HabitType.bad && h.isDoneToday).length;
  int get totalBadHabitsCount => _habits.where((h) => h.type == HabitType.bad).length;

  MascotState get mascotState {
    if (totalGoodHabitsCount == 0 && totalBadHabitsCount == 0) {
      return MascotState.neutral;
    }
    double goodHabitRatio = totalGoodHabitsCount > 0 ? goodHabitsDoneCount / totalGoodHabitsCount : 1.0;
    double badHabitPenalty = totalBadHabitsCount > 0 ? badHabitsDoneCount / totalBadHabitsCount : 0.0;
    double effectiveScore = (goodHabitRatio * 100) - (badHabitPenalty * 50);

    if (effectiveScore >= 70) {
      return MascotState.happy;
    } else if (effectiveScore >= 30) {
      return MascotState.neutral;
    } else {
      return MascotState.sad;
    }
  }

  HabitProvider() {
    _calculateXpToNextLevel();
  }

  void _calculateXpToNextLevel() {
    _xpToNextLevel = 100 + (_currentLevel -1) * 50;
    notifyListeners();
  }

  void _checkForLevelUp() {
    bool leveledUp = false;
    while (_currentXp >= _xpToNextLevel) {
      _currentXp -= _xpToNextLevel;
      _currentLevel++;
      leveledUp = true;
      _calculateXpToNextLevel();
      if (kDebugMode) {
        print("LEVEL UP! Novo nível: $_currentLevel. XP para próximo: $_xpToNextLevel");
      }
    }
    if (leveledUp) {
      notifyListeners();
    }
  }

  void addHabit(String name, HabitType type, double xpValue) {
    if (name.trim().isEmpty || xpValue < 0) { return; }
    final newHabit = Habit(
      id: _uuid.v4(),
      name: name.trim(),
      type: type,
      xpYield: xpValue,
    );
    _habits.add(newHabit);
    notifyListeners();
  }

  void toggleHabitStatus(String habitId) {
    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) { return; }

    final habit = _habits[habitIndex];
    bool preToggleDoneState = habit.isDoneToday;
    habit.isDoneToday = !habit.isDoneToday;

    if (habit.type == HabitType.good) {
      if (habit.isDoneToday && !preToggleDoneState) {
        _currentXp += habit.xpYield;
        _checkForLevelUp();
      } else if (!habit.isDoneToday && preToggleDoneState) {
        _currentXp -= habit.xpYield;
        if (_currentXp < 0) { _currentXp = 0; }
      }
    }

    final today = DateTime.now();
    bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

    if (habit.isDoneToday) {
      if (!_completionHistory.any((c) => c.habitId == habitId && isSameDay(c.date, today))) {
        _completionHistory.add(HabitCompletion(habitId: habitId, date: today));
      }
    } else {
      _completionHistory.removeWhere((c) => c.habitId == habitId && isSameDay(c.date, today));
    }
    
    notifyListeners();
  }

  void removeHabit(String habitId) {
    _habits.removeWhere((h) => h.id == habitId);
    _completionHistory.removeWhere((c) => c.habitId == habitId);
    notifyListeners();
  }

  void resetDailyHabits() {
    for (var habit in _habits) {
      habit.isDoneToday = false;
    }
    notifyListeners();
  }
}