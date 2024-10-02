import 'dart:async';
import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/services/goals_db_service.dart';

class GoalProvider with ChangeNotifier {
  final GoalDBService _dbService = GoalDBService();
  final String? groupId; // Used to determine if we're fetching group or individual goals
  final String userId; 

   List<Goal> _individualGoals = []; // List to hold individual goals
  List<Goal> _groupGoals = []; // List to hold group goals
  StreamSubscription<List<Goal>>? _goalSubscription; // Subscription for real-time updates

  // Constructor that initializes fetching goals based on groupId
  GoalProvider({required this.userId, this.groupId}) {
    Future.microtask(() {
      if (groupId != null && groupId!.isNotEmpty) {
        fetchGroupGoals(groupId!); // Fetch group-specific goals if groupId is provided
      } else {
        fetchGoals(); // Fetch individual goals
      }
    });
  }

    // Getter to expose the list of goals depending on context (group or individual)
  List<Goal> get goals => groupId != null && groupId!.isNotEmpty ? _groupGoals : _individualGoals;
  // Dispose method to cancel the subscription when the provider is disposed
  @override
  void dispose() {
    _goalSubscription?.cancel();
    print("Disposing GoalProvider...");
    super.dispose();
  }

  // Add an individual goal to the database// Add an individual goal to the database
  Future<void> addGoal(Goal goal) async {
    try {
      // Call the GoalDBService to add the goal
      await _dbService.addGoal(userId, goal); // Assuming your GoalDBService has this method

      _individualGoals.add(goal); // Update the local list with the new goal
      notifyListeners(); // Notify listeners to update the UI
    } catch (error) {
      // Handle any errors that may occur
      throw Exception('Failed to add goal: $error');
    }
  }

  // Add a goal to a group (only applicable in a group context)
  Future<void> addGoalToGroup(Goal goal, String groupId) async {
    try {
      await _dbService.addGoalToGroup(groupId, goal); // Add the goal to the group's subcollection
      _groupGoals.add(goal); // Update the local list with the new goal
      notifyListeners(); // Notify listeners to update the UI
    } catch (error) {
      print("Error adding group goal: $error");
      throw error; // Rethrow the error to handle it upstream
    }
  }

  // Fetch all individual goals from the database
  Future<void> fetchGoals() async {
    try {
      _goalSubscription?.cancel(); // Cancel any existing subscriptions
      _goalSubscription = _dbService.getUserGoalsStream(userId).listen((List<Goal> data) {
        //_goals = data; // Update the local list with fetched goals
        notifyListeners(); // Notify listeners to update the UI
      });
    } catch (error) {
      print("Error fetching individual goals: $error");
      throw error; // Rethrow the error to handle it upstream
    }
  }

  // Fetch group-specific goals from the database
  Future<void> fetchGroupGoals(String groupId) async {
    try {
      _goalSubscription?.cancel(); // Cancel any existing subscriptions
      _goalSubscription = _dbService.getGroupGoalsStream(groupId).listen((List<Goal> data) {
        _groupGoals = data; // Update the local list with fetched group goals
        notifyListeners(); // Notify listeners to update the UI
      });
    } catch (error) {
      print("Error fetching group goals: $error");
      throw error; // Rethrow the error to handle it upstream
    }
  }

  // Remove an individual goal from the database
  Future<void> removeGoal(String goalId) async {
    try {
      if (groupId != null && groupId!.isNotEmpty) {
        await _dbService.removeGroupGoal(groupId!, goalId);
      } else {
        await _dbService.removeGoal(userId, goalId); // Include userId for individual goal
      }
      _individualGoals.removeWhere((goal) => goal.id == goalId); // Remove the goal from the local list
      notifyListeners(); // Notify listeners to update the UI
    } catch (error) {
      print("Error removing goal: $error");
      throw error; // Rethrow the error to handle it upstream
    }
  }

  // Update an individual or group goal in the database
  Future<void> updateGoal(Goal updatedGoal) async {
    try {
      if (groupId != null && groupId!.isNotEmpty) {
        await _dbService.updateGroupGoal(groupId!, updatedGoal);
      } else {
        await _dbService.updateGoal(userId, updatedGoal); // Ensure updatedGoal includes userId if needed
      }
      final index = _individualGoals.indexWhere((goal) => goal.id == updatedGoal.id);
      if (index != -1) {
        _individualGoals[index] = updatedGoal; // Update the goal in the local list
        notifyListeners(); // Notify listeners to update the UI
      }
    } catch (error) {
      print("Error updating goal: $error");
      throw error; // Rethrow the error to handle it upstream
    }
  }

  // Mark a goal as completed (works for both individual and group goals)
  Future<void> markGoalAsCompleted(String goalId) async {
    try {
      final index = _individualGoals.indexWhere((goal) => goal.id == goalId);
      if (index != -1) {
        await _dbService.markGoalAsCompleted(userId, goalId); // Include userId
        _individualGoals[index] = _individualGoals[index].copyWith(isCompleted: true); // Update the local goal
        notifyListeners(); // Notify listeners to update the UI
      }
    } catch (error) {
      print("Error marking goal as completed: $error");
      throw error; // Rethrow the error to handle it upstream
    }
  }

  // Get achievement level based on the number of completed goals
  String getAchievementLevel() {
    final completedGoals = _individualGoals.where((goal) => goal.isCompleted).length; // Count completed goals

    // Determine achievement level based on completed goals
    if (completedGoals >= 10) {
      return 'Expert';
    } else if (completedGoals >= 5) {
      return 'Intermediate';
    } else if (completedGoals >= 1) {
      return 'Beginner';
    } else {
      return 'No Achievements'; // No completed goals
    }
  }
}
