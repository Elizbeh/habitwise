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

  void updateHabit(int index, Habit updatedHabit) {
    _habits[index] = updatedHabit;
    notifyListeners();
    _firestoreService.updateHabit(updatedHabit);
  }

  Future<void> fetchHabits() async {
    _habits.clear();
    final habits = _firestoreService.getHabits();
    _habits.addAll(habits as Iterable<Habit>);
    notifyListeners();
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
