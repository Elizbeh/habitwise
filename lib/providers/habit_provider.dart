import 'dart:async';
import 'package:flutter/material.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/services/habit_db_service.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  final HabitDBService _habitDBService = HabitDBService();
  StreamSubscription? _habitsSubscription;

  List<Map<String, dynamic>> achievements = [];

  List<Habit> get habits => _habits;

  // Initialize habits based on groupId
  void initializeHabits(String? groupId) {
    _habitsSubscription?.cancel();
    if (groupId != null && groupId.isNotEmpty) {
      _habitsSubscription = _habitDBService.getGroupHabitsStream(groupId).listen((fetchHabits) {
        _habits = fetchHabits;
        _checkAchievements();
        notifyListeners();
      });
    } else {
      // Listen for individual habits
      _habitsSubscription = _habitDBService.getUserHabitsStream().listen((fetchHabits) {
        _habits = fetchHabits;
        _checkAchievements();
        notifyListeners();
      });
    }
  }

  @override
  void dispose() {
    _habitsSubscription?.cancel();
    super.dispose();
  }

  // Adding a habit either to a group or to the user
  Future<void> addHabit(Habit habit, {String? groupId}) async {
    if (groupId != null && groupId.isNotEmpty) {
      // If groupId is provided, add to the group habits
      _habits.add(habit); // Update local state
      await _habitDBService.addHabitToGroup(groupId, habit);
    } else {
      // If no groupId, add to user's habits
      await _habitDBService.addHabitToUser(habit);
    }
    _checkAchievements();
    notifyListeners();
  }

  Future<void> fetchHabits() async {
    _habits.clear();
    notifyListeners();
  }

  void removeHabit(String groupId, String habitId) {
    _habits.removeWhere((habit) => habit.id == habitId);
    _habitDBService.removeHabit(groupId, habitId);
    _checkAchievements();
    notifyListeners();
  }

  void updateHabit(String groupId, String habitId, Habit updatedHabit) {
    final index = _habits.indexWhere((habit) => habit.id == habitId);
    if (index != -1) {
      _habits[index] = updatedHabit;
      _habitDBService.updateHabit(groupId, updatedHabit);
      _checkAchievements();
      notifyListeners();
    }
  }

  void markHabitAsComplete(String groupId, String habitId) {
    final habit = getHabitById(habitId);
    final updatedHabit = habit.complete();
    updateHabit(groupId, habitId, updatedHabit);
  }

  Habit getHabitById(String id) {
    return _habits.firstWhere((habit) => habit.id == id, orElse: () => throw Exception('Habit not found'));
  }

  void incrementHabitProgress(String groupId, String habitId) {
    final habit = getHabitById(habitId);
    final updatedHabit = habit.incrementProgress();
    updateHabit(groupId, habitId, updatedHabit);
  }

  void _checkAchievements() {
    final completedHabitsCount = _habits.where((habit) => habit.isCompleted).length;
    achievements.clear();

    if (completedHabitsCount >= 1) {
      achievements.add({
        'title': 'First Habit Completed',
        'icon': Icons.star,
        'color': Colors.amber,
      });
    }

    if (completedHabitsCount >= 5) {
      achievements.add({
        'title': 'Habit Master',
        'icon': Icons.star_half,
        'color': Colors.amber[700],
      });
    }

    if (completedHabitsCount >= 10) {
      achievements.add({
        'title': 'Habit Guru',
        'icon': Icons.star_border,
        'color': Colors.amber[900],
      });
    }

    notifyListeners();
  }


  
}
