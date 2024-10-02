import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitwise/models/goal.dart';

class GoalDBService {
  // Collection reference for groups
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

  /// Adds a goal to the user's goals collection
Future<void> addUserGoal(String userId, Goal goal) async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(userId).collection('goals').add(goal.toMap());
  } catch (error) {
    print("Error adding goal to Firestore: $error");
    throw error; // Rethrow the error to handle it in the caller
  }
}


  // Add an individual goal to the user's 'goals' subcollection
  Future<void> addGoal(String userId, Goal goal) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('goals')
          .doc(goal.id)
          .set(goal.toMap());
    } catch (error) {
      print("Error adding individual goal: $error");
      throw error; // Re-throwing error to handle it at the call site
    }
  }

  // Add a group goal to the group's 'goals' subcollection
  Future<void> addGoalToGroup(String groupId, Goal goal) async {
    try {
      await groupCollection
          .doc(groupId)
          .collection('goals')
          .doc(goal.id)
          .set(goal.toMap());
    } catch (error) {
      print("Error adding group goal: $error");
      throw error; // Re-throwing error to handle it at the call site
    }
  }

  // Fetch user goals from the user's 'goals' subcollection
  Stream<List<Goal>> getUserGoalsStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('goals')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Goal.fromMap(doc.data() as Map<String, dynamic>))
              .toList();
        });
  }

  // Fetch group goals from the group's 'goals' subcollection
  Stream<List<Goal>> getGroupGoalsStream(String groupId) {
    return groupCollection
        .doc(groupId)
        .collection('goals')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Goal.fromMap(doc.data() as Map<String, dynamic>))
              .toList();
        });
  }

  // Remove an individual goal from the user's 'goals' subcollection
  Future<void> removeGoal(String userId, String goalId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('goals')
          .doc(goalId)
          .delete();
    } catch (error) {
      print("Error removing individual goal: $error");
      throw error; // Re-throwing error to handle it at the call site
    }
  }

  // Remove a group goal from the group's 'goals' subcollection
  Future<void> removeGroupGoal(String groupId, String goalId) async {
    try {
      await groupCollection
          .doc(groupId)
          .collection('goals')
          .doc(goalId)
          .delete();
    } catch (error) {
      print("Error removing group goal: $error");
      throw error; // Re-throwing error to handle it at the call site
    }
  }

  // Update an individual goal in the user's 'goals' subcollection
  Future<void> updateGoal(String userId, Goal updatedGoal) async {
    try {
      await FirebaseFirestore.instance
          .collection('users') // Access the users collection
          .doc(userId) // Reference the specific user document
          .collection('goals') // Access the user's goals subcollection
          .doc(updatedGoal.id) // Reference the goal document by ID
          .update(updatedGoal.toMap()); // Update the goal using its map representation
    } catch (error) {
      print("Error updating individual goal: $error");
      throw error; // Re-throwing error to handle it at the call site
    }
  }


  // Update a group goal in the group's 'goals' subcollection
  Future<void> updateGroupGoal(String groupId, Goal updatedGoal) async {
    try {
      await groupCollection
          .doc(groupId)
          .collection('goals')
          .doc(updatedGoal.id)
          .update(updatedGoal.toMap());
    } catch (error) {
      print("Error updating group goal: $error");
      throw error; // Re-throwing error to handle it at the call site
    }
  }

  // Mark an individual goal as completed
  Future<void> markGoalAsCompleted(String userId, String goalId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('goals')
          .doc(goalId)
          .update({'isCompleted': true});
    } catch (error) {
      print("Error marking individual goal as completed: $error");
      throw error; // Re-throwing error to handle it at the call site
    }
  }

  // Mark a group goal as completed
  Future<void> markGroupGoalAsCompleted(String groupId, String goalId) async {
    try {
      await groupCollection
          .doc(groupId)
          .collection('goals')
          .doc(goalId)
          .update({'isCompleted': true});
    } catch (error) {
      print("Error marking group goal as completed: $error");
      throw error; // Re-throwing error to handle it at the call site
    }
  }
}
