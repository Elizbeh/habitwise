import 'dart:async';
import 'package:flutter/material.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/services/habit_db_service.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription? _habitsSubscription;

  List<Habit> get habits => _habits;

  HabitProvider() {
    _initializeHabits();
  }

  void _initializeHabits() {
    _habitsSubscription = _firestoreService.getHabits().listen((fetchHabits) {
      _habits = fetchHabits;
      notifyListeners();
    });
  }
  @override
  void dispose() {
    _habitsSubscription?.cancel();
    super.dispose();
  }

  void addHabit(Habit habit) {
    _habits.add(habit);
    _firestoreService.addHabit(habit);
    notifyListeners();
  }

  Future<void> fetchHabits() async {
    _habits.clear(); // Clear the existing habits
    notifyListeners(); // Notify listeners to update UI
  }


  void removeHabit(String habitId) {
   _habits.removeWhere((habit) => habit.id == habitId);
   notifyListeners();
   _firestoreService.removeHabit(habitId);
  }

  void updateHabit(String habitId, Habit updatedHabit) {
    final index = _habits.indexWhere((habit) => habit.id == habitId);
    if (index != -1) {
      _habits[index] = updatedHabit;
    notifyListeners();
    _firestoreService.updateHabit(updatedHabit);
    notifyListeners();
    }
  }

  Habit? getHabitById(String id) {
  for (var habit in _habits) {
    if (habit.id == id) {
      return habit;
    }
  }
  return null;
  }
}