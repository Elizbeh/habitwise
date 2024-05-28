import 'dart:async';
import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/services/goals_db_service.dart';

class GoalProvider with ChangeNotifier {
  List<Goal> _goals = [];

  final FirestoreService _firestoreService = FirestoreService();

  List<Goal> get goals => _goals;

  void fetchGoals() {
    _firestoreService.getGoals().listen((List<Goal> fetchGoals) {
      _goals = fetchGoals;
      notifyListeners();
    });
  }

  Future<void> addGoal(Goal goal) async {
    await _firestoreService.addGoal(goal);
    fetchGoals();
  }

  Future<void> updateGoal(Goal updatedGoal) async {
    await _firestoreService.updateGoal(updatedGoal);
    final index = _goals.indexWhere((goal) => goal.id == updatedGoal.id);
    if (index != -1) {
      _goals[index] = updatedGoal;
      notifyListeners();
    }
  }
  Future<void> removeGoal(String id) async {
    await _firestoreService.removeGoal(id);
    fetchGoals();
  }

  Goal findById(String id) {
    return _goals.firstWhere((goal) => goal.id == id);
  }

  void markGoalAsCompleted(String goalId) {
    int index = _goals.indexWhere((goal) => goal.id == goalId);
    if (index != -1) {
      _goals[index].isCompleted = true;
      notifyListeners();
      // Call FirestoreService to mark goal as completed in Firestore
      _firestoreService.markGoalAsCompleted(goalId);
    }
  }

}
