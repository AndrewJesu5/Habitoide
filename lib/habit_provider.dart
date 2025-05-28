// Arquivo: lib/habit_provider.dart

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'habit.dart';

enum MascotState { happy, neutral, sad }

class HabitProvider with ChangeNotifier {
  final List<Habit> _habits = [];
  double _currentScore = 50.0;
  double _scoreAtDayStart = 50.0;

  final Uuid _uuid = const Uuid();

  List<Habit> get habits => [..._habits];
  double get currentScore => _currentScore;
  int get habitsDoneCount => _habits.where((h) => h.isDoneToday).length;
  int get totalHabitsCount => _habits.length;

  MascotState get mascotState {
    if (_currentScore >= 70) {
      return MascotState.happy;
    } else if (_currentScore >= 31) {
      return MascotState.neutral;
    } else {
      return MascotState.sad;
    }
  }

  HabitProvider() {
    _recalculateHabitPoints();
  }

  void _recalculateHabitPoints() {
    if (_habits.isEmpty) {
      for (var habit in _habits) {
        habit.points = 0;
      }
      _updateCurrentScore();
      return;
    }

    double pointsToDistribute = 100.0 - _scoreAtDayStart;
    if (pointsToDistribute < 0) pointsToDistribute = 0;

    double pointsPerHabit = (pointsToDistribute / _habits.length);
    if (pointsPerHabit.isNaN || pointsPerHabit.isInfinite) {
        pointsPerHabit = 0;
    }

    for (var habit in _habits) {
      habit.points = pointsPerHabit;
    }
    _updateCurrentScore();
  }

  void addHabit(String name) {
    final newHabit = Habit(
      id: _uuid.v4(),
      name: name,
    );
    _habits.add(newHabit);
    _recalculateHabitPoints();
    notifyListeners();
  }

  void toggleHabitStatus(String habitId) {
    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex != -1) {
      _habits[habitIndex].isDoneToday = !_habits[habitIndex].isDoneToday;
      _updateCurrentScore();
      notifyListeners();
    }
  }

  void _updateCurrentScore() {
    double calculatedScore = _scoreAtDayStart;
    for (var habit in _habits) {
      if (habit.isDoneToday) {
        calculatedScore += habit.points;
      }
    }
    _currentScore = calculatedScore.clamp(0.0, 100.0);
  }

  void removeHabit(String habitId) {
    _habits.removeWhere((h) => h.id == habitId);
    _recalculateHabitPoints();
    notifyListeners();
  }

  void resetDailyHabits() {
    if (totalHabitsCount > 0 && habitsDoneCount == totalHabitsCount) {
      _scoreAtDayStart = 50.0;
    } else if (totalHabitsCount > 0) {
      double pointsOfUncompletedHabits = 0;
      for (var habit in _habits) {
        if (!habit.isDoneToday) {
          pointsOfUncompletedHabits += habit.points;
        }
      }
      _scoreAtDayStart = _currentScore - pointsOfUncompletedHabits;
    } else {
      _scoreAtDayStart = _currentScore;
    }

    _scoreAtDayStart = _scoreAtDayStart.clamp(0.0, 100.0);

    for (var habit in _habits) {
      habit.isDoneToday = false;
    }

    _recalculateHabitPoints();

    print(
        "Dia resetado. Pontuação atual: $_currentScore. Nova pontuação inicial do dia: $_scoreAtDayStart. Pontos por hábito: ${_habits.isNotEmpty ? _habits.first.points.toStringAsFixed(2) : 0}");
    notifyListeners();
  }
}