import 'dart:async';
import 'package:flutter/material.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/services/habit_db_service.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _personalHabits = [];
  List<Habit> _groupHabits = [];
  final HabitDBService _habitDBService = HabitDBService();
  StreamSubscription? _personalHabitsSubscription;
  StreamSubscription? _groupHabitsSubscription;

  // List to store achievements
  List<Map<String, dynamic>> achievements = [];

  // Getters for habits
  List<Habit> get personalHabits => _personalHabits;
  List<Habit> get groupHabits => _groupHabits;

  // Initialize habits for personal or group based on groupId
  void initializeHabits({String? groupId}) {
    if (groupId != null && groupId.isNotEmpty) {
      // Fetch group habits if groupId is provided
      _initializeGroupHabits(groupId);
    } else {
      // Fetch personal habits
      _initializePersonalHabits();
    }
  }

  // Initialize personal habits
  void _initializePersonalHabits() {
    _personalHabitsSubscription?.cancel(); // Cancel any existing subscription
    _personalHabitsSubscription = _habitDBService.getUserHabitsStream().listen((fetchHabits) {
      _personalHabits = fetchHabits;
      _checkAchievements();
      notifyListeners();
    });
  }

  // Initialize group habits
  void _initializeGroupHabits(String groupId) {
    _groupHabitsSubscription?.cancel(); // Cancel any existing subscription
    _groupHabitsSubscription = _habitDBService.getGroupHabitsStream(groupId).listen((fetchHabits) {
      _groupHabits = fetchHabits;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _personalHabitsSubscription?.cancel();
    _groupHabitsSubscription?.cancel();
    super.dispose();
  }

  // Add a habit either to a group or to the user
  Future<void> addHabit(Habit habit, {String? groupId}) async {
    if (groupId != null && groupId.isNotEmpty) {
      // If groupId is provided, add to the group habits
      _groupHabits.add(habit); // Update local state
      await _habitDBService.addHabitToGroup(groupId, habit);
    } else {
      // If no groupId, add to user's personal habits
      _personalHabits.add(habit); // Update local state
      await _habitDBService.addHabitToUser(habit);
    }
    _checkAchievements();
    notifyListeners();
  }

  // Remove a habit from personal or group habits
  Future<void> removeHabit(String habitId, {String? groupId}) async {
    if (groupId != null && groupId.isNotEmpty) {
      _groupHabits.removeWhere((habit) => habit.id == habitId);
      await _habitDBService.removeHabitFromGroup(groupId, habitId);
    } else {
      _personalHabits.removeWhere((habit) => habit.id == habitId);
      await _habitDBService.removeHabitFromUser(habitId);
    }
    _checkAchievements();
    notifyListeners();
  }

  // Update a habit in personal or group habits
  Future<void> updateHabit(Habit updatedHabit, {String? groupId}) async {
    if (groupId != null && groupId.isNotEmpty) {
      final index = _groupHabits.indexWhere((habit) => habit.id == updatedHabit.id);
      if (index != -1) {
        _groupHabits[index] = updatedHabit;
        await _habitDBService.updateHabitInGroup(groupId, updatedHabit);
      }
    } else {
      final index = _personalHabits.indexWhere((habit) => habit.id == updatedHabit.id);
      if (index != -1) {
        _personalHabits[index] = updatedHabit;
        await _habitDBService.updateHabitInUser(updatedHabit);
      }
    }
    _checkAchievements();
    notifyListeners();
  }

  // Mark a habit as complete in personal or group habits
  void markHabitAsComplete(String habitId, {String? groupId}) {
    if (groupId != null && groupId.isNotEmpty) {
      final habit = _groupHabits.firstWhere((habit) => habit.id == habitId);
      final updatedHabit = habit.complete();
      updateHabit(updatedHabit, groupId: groupId);
    } else {
      final habit = _personalHabits.firstWhere((habit) => habit.id == habitId);
      final updatedHabit = habit.complete();
      updateHabit(updatedHabit);
    }
  }

  // Increment progress for a habit in personal or group habits
  void incrementHabitProgress(String habitId, {String? groupId}) {
    if (groupId != null && groupId.isNotEmpty) {
      final habit = _groupHabits.firstWhere((habit) => habit.id == habitId);
      final updatedHabit = habit.incrementProgress();
      updateHabit(updatedHabit, groupId: groupId);
    } else {
      final habit = _personalHabits.firstWhere((habit) => habit.id == habitId);
      final updatedHabit = habit.incrementProgress();
      updateHabit(updatedHabit);
    }
  }

  // Check and update achievements
  void _checkAchievements() {
    final completedHabitsCount = _personalHabits.where((habit) => habit.isCompleted).length;
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
