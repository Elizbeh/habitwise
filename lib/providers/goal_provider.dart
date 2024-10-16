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
    if (groupId != null && groupId!.isNotEmpty) {
      fetchGroupGoals(groupId!);
    } else {
      fetchGoals();
    }
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

      //_individualGoals.add(goal); // Update the local list with the new goal
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
        _individualGoals = data; // Update the local list with fetched goals
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
      // For group goals
      await _dbService.removeGroupGoal(groupId!, goalId);
      _groupGoals.removeWhere((goal) => goal.id == goalId); // Update group goals
    } else {
      // For individual goals
      await _dbService.removeGoal(userId, goalId);
      _individualGoals.removeWhere((goal) => goal.id == goalId); // Update individual goals
    }
    notifyListeners(); // Notify listeners to update the UI
  } catch (error) {
    print("Error removing goal: $error");
    throw error; // Re-throw the error to handle it upstream
  }
}

Future<void> removeGroupGoal(String groupId, String goalId) async {
  await GoalDBService().removeGroupGoal(groupId, goalId);
}


 // Update an individual or group goal in the database
Future<void> updateGoal(Goal updatedGoal) async {
  try {
    if (groupId != null && groupId!.isNotEmpty) {
      await _dbService.updateGroupGoal(groupId!, updatedGoal); // For group goals
    } else {
      await _dbService.updateGoal(userId, updatedGoal); // For individual goals
    }
    // Update local goal list for group or individual context
    if (groupId != null && groupId!.isNotEmpty) {
      final index = _groupGoals.indexWhere((goal) => goal.id == updatedGoal.id);
      if (index != -1) {
        _groupGoals[index] = updatedGoal; // Update group goal list locally
      }
    } else {
      final index = _individualGoals.indexWhere((goal) => goal.id == updatedGoal.id);
      if (index != -1) {
        _individualGoals[index] = updatedGoal; // Update individual goal list locally
      }
    }
    notifyListeners(); // Notify listeners to update the UI
  } catch (error) {
    print("Error updating goal: $error");
    throw error; // Rethrow the error to handle it upstream
  }
}

    // Mark an individual goal as completed
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

    // Method to mark a group goal as completed
  Future<void> markGroupGoalAsCompleted(String groupId, String goalId) async {
    try {
      await _dbService.markGroupGoalAsCompleted(groupId, goalId);
      notifyListeners(); // Notify listeners that the goal has been marked as completed
    } catch (error) {
      print("Error marking group goal as completed: $error");
      throw error;
    }
  }

  // Get achievement level based on the number of completed individual goals
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

  // Method to update group goal progress via the DB service
Future<void> updateGroupGoalProgress(Goal goal, int updatedProgress, {required String groupId}) async {
  try {
    // Call the DB service to update the group goal's progress
    await _dbService.updateGroupGoalProgress(goal, updatedProgress, groupId: groupId);
    
    // Optionally, update the local state or UI after a successful progress update
    notifyListeners();
  } catch (error) {
    print("Error updating group goal progress: $error");
    // Handle the error appropriately, such as showing an error message to the user
  }
}

Future<void> updateGroupGoal(Goal updatedGoal, String groupId) async {
  try {
    await _dbService.updateGroupGoal(groupId, updatedGoal);
    final index = _groupGoals.indexWhere((g) => g.id == updatedGoal.id);
    if (index != -1) {
      _groupGoals[index] = updatedGoal; // Update locally
      notifyListeners(); // Notify UI to update
    }
  } catch (error) {
    print("Error updating group goal: $error");
    throw error;
  }
}

Future<void> completeGroupGoal(String goalId, String groupId) async {
  try {
    Goal? existingGoal = await _dbService.getGroupGoal(groupId, goalId);

    if (existingGoal != null) {
      await _dbService.updateGroupGoalProgress(
        Goal(
          id: existingGoal.id,
          title: existingGoal.title,
          description: existingGoal.description,
          category: existingGoal.category,
          priority: existingGoal.priority,
          progress: 100, // Mark as fully completed
          target: existingGoal.target,
          targetDate: existingGoal.targetDate,
          endDate: existingGoal.endDate,
          isCompleted: true,
        ),
        100, // Full progress
        groupId: groupId,
      );
    } else {
      print("Goal not found.");
    }
  } catch (error) {
    print("Error completing group goal: $error");
    throw error;
  }
}



}
