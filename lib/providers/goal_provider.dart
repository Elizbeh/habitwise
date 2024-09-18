import 'dart:async';
import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/services/goals_db_service.dart';

class GoalProvider with ChangeNotifier {
  final GoalDBService _dbService = GoalDBService();
  final String? groupId; // Determines if we're fetching group or individual goals

  List<Goal> _goals = [];
  StreamSubscription<List<Goal>>? _goalSubscription;

  GoalProvider({this.groupId}) {
    Future.microtask(() {
      if (groupId != null && groupId!.isNotEmpty) {
        fetchGroupGoals(groupId!); // Fetch group goals if groupId is provided
      } else {
        fetchGoals(); // Otherwise, fetch individual goals
      }
    });
  }

  List<Goal> get goals => _goals;

  @override
  void dispose() {
    _goalSubscription?.cancel();
    super.dispose();
  }

  // Add an individual goal
  Future<void> addGoal(Goal goal) async {
    try {
      await _dbService.addGoal(goal);
    } catch (error) {
      print("Error adding individual goal: $error");
      throw error;
    }
  }

  // Add a goal to a group (only when dealing with a group context)
  Future<void> addGoalToGroup(Goal goal, String groupId) async {
    try {
      await _dbService.addGoalToGroup(groupId, goal);  // Add the goal to the group's subcollection
      _goals.add(goal);  // Add the goal to the local list
      notifyListeners();
    } catch (error) {
      print("Error adding group goal: $error");
      throw error;
    }
  }

  // Fetch all individual goals
  Future<void> fetchGoals() async {
    try {
      _goalSubscription?.cancel();
      _goalSubscription = _dbService.getGoals().listen((List<Goal> data) {
        _goals = data;
        notifyListeners();
      });
    } catch (error) {
      print("Error fetching individual goals: $error");
      throw error;
    }
  }

  // Fetch group-specific goals
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

  // Remove an individual goal
  Future<void> removeGoal(String goalId) async {
    try {
      if (groupId != null && groupId!.isNotEmpty) {
        // If it's a group goal, remove from group's subcollection
        await _dbService.removeGroupGoal(groupId!, goalId);
      } else {
        // Otherwise, remove from the individual goals collection
        await _dbService.removeGoal(goalId);
      }
      _goals.removeWhere((goal) => goal.id == goalId);
      notifyListeners();
    } catch (error) {
      print("Error removing goal: $error");
      throw error;
    }
  }

  // Update an individual or group goal
  Future<void> updateGoal(Goal updatedGoal) async {
    try {
      if (groupId != null && groupId!.isNotEmpty) {
        // If it's a group goal, update in the group's subcollection
        await _dbService.updateGroupGoal(groupId!, updatedGoal);
      } else {
        // Otherwise, update in the individual goals collection
        await _dbService.updateGoal(updatedGoal);
      }
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

  // Mark a goal as completed (works for both individual and group goals)
  Future<void> markGoalAsCompleted(String goalId) async {
    try {
      if (groupId != null && groupId!.isNotEmpty) {
        // If it's a group goal, mark as completed in the group's subcollection
        await _dbService.markGroupGoalAsCompleted(groupId!, goalId);
      } else {
        // Otherwise, mark as completed in the individual goals collection
        await _dbService.markGoalAsCompleted(goalId);
      }
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

  // Get achievement level based on the number of completed goals
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
