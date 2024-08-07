import 'dart:async';
import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/services/goals_db_service.dart';

class GoalProvider with ChangeNotifier {
  final GoalDBService _dbService = GoalDBService();
  final String? groupId;

  List<Goal> _goals = [];
  StreamSubscription<List<Goal>>? _goalSubscription;

  GoalProvider({this.groupId}) {
    Future.microtask(() {
      if (groupId != null && groupId!.isNotEmpty) {
        fetchGroupGoals(groupId!);
      } else {
        fetchGoals();
      }
    });
  }

  List<Goal> get goals => _goals;

  @override
  void dispose() {
    _goalSubscription?.cancel();
    super.dispose();
  }

  Future<void> addGoal(Goal goal) async {
    try {
      await _dbService.addGoal(goal);
      notifyListeners();
    } catch (error) {
      print("Error adding goal: $error");
      throw error;
    }
  }

  Future<void> fetchGoals() async {
    try {
      _goalSubscription?.cancel();
      _goalSubscription = _dbService.getGoals().listen((List<Goal> data) {
        _goals = data;
        notifyListeners();
      });
    } catch (error) {
      print("Error fetching goals: $error");
      throw error;
    }
  }

  Future<void> fetchGroupGoals(String groupId) async {
    try {
      _goalSubscription?.cancel();
      _goalSubscription = _dbService.getGroupGoalsStream(groupId).listen((List<Goal> data) {
        _goals = data;
        notifyListeners();
      });
    } catch (error) {
      print("Error fetching group goals: $error");
      throw error;
    }
  }

  Future<void> addGoalToGroup(Goal goal, String groupId) async {
    try {
      await _dbService.addGoal(goal, groupId: groupId);
      _goals.add(goal);
      notifyListeners();
    } catch (error) {
      print("Error adding goal to group: $error");
      throw error;
    }
  }

  Future<void> removeGoal(String goalId) async {
    try {
      await _dbService.removeGoal(goalId);
      _goals.removeWhere((goal) => goal.id == goalId);
      notifyListeners();
    } catch (error) {
      print("Error removing goal: $error");
      throw error;
    }
  }

  Future<void> updateGoal(Goal updatedGoal) async {
    try {
      await _dbService.updateGoal(updatedGoal);
      final index = _goals.indexWhere((goal) => goal.id == updatedGoal.id);
      if (index != -1) {
        _goals[index] = updatedGoal;
        notifyListeners();
      }
    } catch (error) {
      print("Error updating goal: $error");
      throw error;
    }
  }

  Future<void> markGoalAsCompleted(String goalId) async {
    try {
      await _dbService.markGoalAsCompleted(goalId);
      final index = _goals.indexWhere((goal) => goal.id == goalId);
      if (index != -1) {
        _goals[index] = _goals[index].copyWith(isCompleted: true);
        notifyListeners();
      }
    } catch (error) {
      print("Error marking goal as completed: $error");
      throw error;
    }
  }

  void checkAndMarkGoalAsComplete(String goalId) async {
    try {
      final goalIndex = _goals.indexWhere((goal) => goal.id == goalId);
      if (goalIndex != -1) {
        final goal = _goals[goalIndex];
        if (goal.progress == goal.target && !goal.isCompleted) {
          final updatedGoal = goal.copyWith(isCompleted: true);
          _goals[goalIndex] = updatedGoal;
          await _dbService.updateGoal(updatedGoal);
          notifyListeners();
        }
      }
    } catch (error) {
      print("Error marking goal as complete: $error");
      // Handle error appropriately
    }
  }

  String getAchievementLevel() {
    final completedGoals = _goals.where((goal) => goal.isCompleted).length;

    if (completedGoals >= 10) {
      return 'Expert';
    } else if (completedGoals >= 5) {
      return 'Intermediate';
    } else if (completedGoals >= 1) {
      return 'Beginner';
    } else {
      return 'No Achievements';
    }
  }
}
