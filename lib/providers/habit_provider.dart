// This class provides the functionality to manage habits, including fetching, adding, removing, and updating habits.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/services/habit_db_service.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = []; // List to store habits
  final HabitDBService _habitDBService = HabitDBService(); // Instance of HabitDBService for database operations
  StreamSubscription? _habitsSubscription; // Subscription for listening to changes in habits stream

  List<Habit> get habits => _habits; // Getter for habits list

  // Constructor to initialize habits and subscribe to habit changes
  HabitProvider() {
    _initializeHabits();
  }

  // Method to initialize habits by subscribing to habit changes from the database
  void _initializeHabits() {
    String groupId = 'your_group_id_here'; // Placeholder group ID
    _habitsSubscription = _habitDBService.getHabits(groupId).listen((fetchHabits) {
      _habits = fetchHabits; // Update habits list with fetched habits
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
    notifyListeners(); // Notify listeners to update UI
    _habitDBService.removeHabit(groupId, habitId); // Remove habit from database
  }

  // Method to update a habit in the database and local list
  void updateHabit(String habitId, Habit updatedHabit) {
    final index = _habits.indexWhere((habit) => habit.id == habitId); // Find index of habit in local list
    if (index != -1) {
      _habits[index] = updatedHabit; // Update habit in local list
      notifyListeners(); // Notify listeners to update UI
      _habitDBService.updateHabit(habitId, updatedHabit); // Update habit in database
    }
  }
  

  // Method to get a habit by its ID
  Habit getHabitById(String id) {
    return _habits.firstWhere((habit) => habit.id == id, orElse: () => throw Exception('Habit not found'));
  }
}
