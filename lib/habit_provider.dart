// lib/habit_provider.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'habit.dart';

class HabitCompletion {
  final String habitId;
  final DateTime date;
  HabitCompletion({required this.habitId, required this.date});
  Map<String, dynamic> toMap() => {'habitId': habitId, 'date': date.toIso8601String()};
  factory HabitCompletion.fromMap(Map<String, dynamic> map) => HabitCompletion(habitId: map['habitId'] ?? '', date: DateTime.parse(map['date']));
  String toJson() => json.encode(toMap());
  factory HabitCompletion.fromJson(String source) => HabitCompletion.fromMap(json.decode(source));
}

enum MascotState { happy, neutral, sad }

class HabitProvider with ChangeNotifier {
  final Uuid _uuid = const Uuid();

  // Chaves para SharedPreferences
  static const _habitsKey = 'habits_list';
  static const _historyKey = 'completion_history';
  static const _levelKey = 'player_level';
  static const _xpKey = 'player_xp';
  static const _lastResetKey = 'last_daily_reset';
  static const _outfitKey = 'mascot_outfit';

  List<Habit> _habits = [];
  List<HabitCompletion> _completionHistory = [];
  int _currentLevel = 1;
  double _currentXp = 0.0;
  double _xpToNextLevel = 100.0;
  String _currentOutfit = 'default';

  int get currentLevel => _currentLevel;
  double get currentXp => _currentXp;
  double get xpToNextLevel => _xpToNextLevel;
  String get currentOutfit => _currentOutfit;
  List<Habit> get habits => List.unmodifiable(_habits);
  List<HabitCompletion> get completionHistory => List.unmodifiable(_completionHistory);
  int get goodHabitsDoneCount => _habits.where((h) => h.type == HabitType.good && h.isDoneToday).length;
  int get totalGoodHabitsCount => _habits.where((h) => h.type == HabitType.good).length;
  int get badHabitsDoneCount => _habits.where((h) => h.type == HabitType.bad && h.isDoneToday).length;
  int get totalBadHabitsCount => _habits.where((h) => h.type == HabitType.bad).length;

  MascotState get mascotState {
    if (totalGoodHabitsCount == 0 && totalBadHabitsCount == 0) return MascotState.neutral;
    double goodHabitRatio = totalGoodHabitsCount > 0 ? goodHabitsDoneCount / totalGoodHabitsCount : 1.0;
    double badHabitPenalty = totalBadHabitsCount > 0 ? badHabitsDoneCount / totalBadHabitsCount : 0.0;
    double effectiveScore = (goodHabitRatio * 100) - (badHabitPenalty * 50);

    if (effectiveScore >= 70) return MascotState.happy;
    if (effectiveScore >= 30) return MascotState.neutral;
    return MascotState.sad;
  }

  HabitProvider() {
    _loadData();
  }
  
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> habitsJsonList = _habits.map((h) => h.toJson()).toList();
    await prefs.setStringList(_habitsKey, habitsJsonList);

    List<String> historyJsonList = _completionHistory.map((c) => c.toJson()).toList();
    await prefs.setStringList(_historyKey, historyJsonList);

    await prefs.setInt(_levelKey, _currentLevel);
    await prefs.setDouble(_xpKey, _currentXp);
    await prefs.setString(_outfitKey, _currentOutfit);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    List<String>? habitsJsonList = prefs.getStringList(_habitsKey);
    if (habitsJsonList != null) {
      _habits = habitsJsonList.map((json) => Habit.fromJson(json)).toList();
    }

    List<String>? historyJsonList = prefs.getStringList(_historyKey);
    if (historyJsonList != null) {
      _completionHistory = historyJsonList.map((json) => HabitCompletion.fromJson(json)).toList();
    }

    _currentLevel = prefs.getInt(_levelKey) ?? 1;
    _currentXp = prefs.getDouble(_xpKey) ?? 0.0;
    _currentOutfit = prefs.getString(_outfitKey) ?? 'default';

    final lastResetString = prefs.getString(_lastResetKey);
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (lastResetString != null) {
      final lastResetDate = DateTime.parse(lastResetString);
      if (lastResetDate.isBefore(today)) {
        resetDailyHabits(saveData: false);
        await prefs.setString(_lastResetKey, today.toIso8601String());
      }
    } else {
      await prefs.setString(_lastResetKey, today.toIso8601String());
    }
    
    _syncTodayStatus();

    _calculateXpToNextLevel(notify: false); 
    notifyListeners();
  }
  
  void changeOutfit(String newOutfitAsset) {
    if (_currentOutfit == newOutfitAsset) return;
    _currentOutfit = newOutfitAsset;
    _saveData();
    notifyListeners();
  }

  void _syncTodayStatus() {
    final today = DateTime.now();
    bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
    for (var habit in _habits) {
      habit.isDoneToday = _completionHistory.any((c) => c.habitId == habit.id && isSameDay(c.date, today));
    }
  }

  void _calculateXpToNextLevel({bool notify = true}) {
    _xpToNextLevel = 100 + (_currentLevel - 1) * 50;
    if (notify) {
      notifyListeners();
    }
  }

  void _checkForLevelUp() {
    bool didLevelUp = false;
    while (_currentXp >= _xpToNextLevel) {
      _currentXp -= _xpToNextLevel;
      _currentLevel++;
      didLevelUp = true; 
      _calculateXpToNextLevel(notify: false); 
      if (kDebugMode) {
        print("LEVEL UP! Novo nível: $_currentLevel. XP para próximo: $_xpToNextLevel");
      }
    }
  }

  void addHabit(String name, HabitType type) {
    if (name.trim().isEmpty) { return; }
    final newHabit = Habit(
      id: _uuid.v4(),
      name: name.trim(),
      type: type,
    );
    _habits.add(newHabit);
    _saveData();
    notifyListeners();
  }

  void toggleHabitStatus(String habitId) {
    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) { return; }

    final habit = _habits[habitIndex];
    bool preToggleDoneState = habit.isDoneToday;
    habit.isDoneToday = !habit.isDoneToday;

    const double xpPerHabit = 1.0;

    if (habit.type == HabitType.good) {
      if (habit.isDoneToday && !preToggleDoneState) {
        _currentXp += xpPerHabit;
        _checkForLevelUp();
      } else if (!habit.isDoneToday && preToggleDoneState) {
        _currentXp -= xpPerHabit;
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
    
    _saveData();
    notifyListeners();
  }

  void removeHabit(String habitId) {
    _habits.removeWhere((h) => h.id == habitId);
    _completionHistory.removeWhere((c) => c.habitId == habitId);
    _saveData();
    notifyListeners();
  }

  void resetDailyHabits({bool saveData = true}) {
    for (var habit in _habits) {
      habit.isDoneToday = false;
    }
    if (saveData) {
    }
    notifyListeners();
  }
}