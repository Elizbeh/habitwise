import 'dart:async';
import 'package:flutter/material.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/services/habit_db_service.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = []; // List to store habits
  final HabitDBService _habitDBService = HabitDBService(); // Instance of HabitDBService for database operations
  StreamSubscription? _habitsSubscription; // Subscription for listening to changes in habits stream

  List<Map<String, dynamic>> achievements = []; // List to store achievements

  List<Habit> get habits => _habits; // Getter for habits list

  // Method to initialize habits by subscribing to habit changes from the database
  void initializeHabits(String groupId) {
    _habitsSubscription?.cancel();
    _habitsSubscription = _habitDBService.getHabits(groupId).listen((fetchHabits) {
      _habits = fetchHabits; // Update habits list with fetched habits
      _checkAchievements(); // Check achievements whenever habits change
      notifyListeners(); // Notify listeners to update UI
    });
  }

  @override
  void dispose() {
    _habitsSubscription?.cancel(); // Cancel subscription to avoid memory leaks
    super.dispose();
  }

  // Method to add a habit to the database and update the local list
  void addHabit(String groupId, Habit habit) {
    _habits.add(habit); // Add habit to local list
    _habitDBService.addHabit(groupId, habit); // Add habit to database
    _checkAchievements(); // Check achievements after adding a habit
    notifyListeners(); // Notify listeners to update UI
  }

  // Method to clear the existing habits list (useful for refreshing)
  Future<void> fetchHabits() async {
    _habits.clear(); // Clear the existing habits
    notifyListeners(); // Notify listeners to update UI
  }

  // Method to remove a habit from the database and local list
  void removeHabit(String groupId, String habitId) {
    _habits.removeWhere((habit) => habit.id == habitId); // Remove habit from local list
    _checkAchievements(); // Check achievements after removing a habit
    notifyListeners(); // Notify listeners to update UI
    _habitDBService.removeHabit(groupId, habitId); // Remove habit from database
  }

  // Method to update a habit in the database and local list
  void updateHabit(String groupId, String habitId, Habit updatedHabit) {
    final index = _habits.indexWhere((habit) => habit.id == habitId); // Find index of habit in local list
    if (index != -1) {
      _habits[index] = updatedHabit; // Update habit in local list
      _checkAchievements(); // Check achievements after updating a habit
      notifyListeners(); // Notify listeners to update UI
      _habitDBService.updateHabit(groupId, updatedHabit); // Update habit in database
    }
  }

  // Method to get a habit by its ID
  Habit getHabitById(String id) {
    return _habits.firstWhere((habit) => habit.id == id, orElse: () => throw Exception('Habit not found'));
  }

  // Method to check achievements based on completed habits
  void _checkAchievements() {
    final completedHabitsCount = _habits.where((habit) => habit.isCompleted).length;

    // Clear previous achievements
    achievements.clear();

    // Example achievements based on habits
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

    // Notify listeners to update achievements in UI
    notifyListeners();
  }
}
