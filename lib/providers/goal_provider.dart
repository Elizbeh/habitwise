import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/services/goals_db_service.dart';

class GoalProvider with ChangeNotifier {
  final GoalDBService _dbService = GoalDBService();
  final String? groupId;

  List<Goal> _goals = [];

  GoalProvider({this.groupId}) {
    if (groupId != null && groupId!.isNotEmpty) {
      fetchGroupGoals(groupId!);
    } else {
      fetchGoals();
    }
  }

  List<Goal> get goals => _goals;

  // Function to add a goal
  Future<void> addGoal(Goal goal) async {
    try {
      await _dbService.addGoal(goal);
      _goals.add(goal);
      notifyListeners();
    } catch (error) {
      print("Error adding goal: $error");
      throw error;
    }
  }

    // Function to fetch goals
  Future<void> fetchGoals() async {
    try {
      _dbService.getGoals().listen((List<Goal> data) {
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
      _dbService.getGroupGoalsStream(groupId).listen((List<Goal> data) {
        _goals = data;
        notifyListeners();
      });
    } catch (error) {
      print("Error fetching group goals: $error");
      throw error;
    }
  }

  // Function to add a goal to a group
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

  // Function to remove a goal
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

  // Function to update a goal
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

  // Function to mark a goal as completed
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
}