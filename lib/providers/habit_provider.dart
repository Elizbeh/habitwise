import 'package:flutter/material.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/services/habit_db_service.dart';

class HabitProvider extends ChangeNotifier {
  final List<Habit> _habits = [];
  
  final FirestoreService _firestoreService = FirestoreService();

  List<Habit> get habits => _habits;

  void addHabit(Habit habit) {
    _habits.add(habit);
    _firestoreService.addHabit(habit);
    notifyListeners();
  }

  void removeHabit(String habitId) {
   _habits.removeWhere((habit) => habitId == habitId);
   notifyListeners();
   _firestoreService.removeHabit(habitId);
  }

  void updateHabit(String habitId, Habit updatedHabit) {
    final index = _habits.indexWhere((habit) => habit.id == habitId);
    if (index != -1) {
      _habits[index] = updatedHabit;
    notifyListeners();
    _firestoreService.updateHabit(updatedHabit);
    }
  }

  Future<void> fetchHabits() async {
    _habits.clear();
    _firestoreService.getHabits().listen((fetchedHabits) {
      _habits.addAll(fetchedHabits);
      notifyListeners();
    });
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
