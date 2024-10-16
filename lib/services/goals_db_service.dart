import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitwise/models/goal.dart';

class GoalDBService {
  final CollectionReference groupCollection = FirebaseFirestore.instance.collection('groups');

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
      throw error;
    }
  }

  // Add a goal to a group's 'goals' subcollection
  Future<void> addGoalToGroup(String groupId, Goal goal) async {
    try {
      await groupCollection
          .doc(groupId)
          .collection('goals')
          .doc(goal.id)
          .set(goal.toMap());
    } catch (error) {
      print("Error adding group goal: $error");
      throw error;
    }
  }

  // Fetch individual goals stream
  Stream<List<Goal>> getUserGoalsStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('goals')
        .snapshots()
        .map((snapshot) {
          print("Fetched ${snapshot.docs.length} individual goals for user: $userId");
          return snapshot.docs
              .map((doc) => Goal.fromMap(doc.data() as Map<String, dynamic>))
              .toList();
        })
        .handleError((error) {
          print("Error fetching user goals: $error");
        });
  }

  // Fetch group goals stream
  Stream<List<Goal>> getGroupGoalsStream(String groupId) {
    return groupCollection
        .doc(groupId)
        .collection('goals')
        .snapshots()
        .map((snapshot) {
          print("Fetched ${snapshot.docs.length} group goals for group: $groupId");
          return snapshot.docs
              .map((doc) => Goal.fromMap(doc.data() as Map<String, dynamic>))
              .toList();
        })
        .handleError((error) {
          print("Error fetching group goals: $error");
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
      print("Goal removed for user $userId: goalId = $goalId");
    } catch (error) {
      print("Error removing individual goal: $error");
      throw error;
    }
  }

  // Remove a group goal from the group's 'goals' subcollection
  Future<void> removeGroupGoal(String groupId, String goalId) async {
    try {
      await groupCollection.doc(groupId).collection('goals').doc(goalId).delete();
      print("Group goal removed for group $groupId: goalId = $goalId");
    } catch (error) {
      print("Error removing group goal: $error");
      throw error;
    }
  }

  // Update an individual goal
  Future<void> updateGoal(String userId, Goal updatedGoal) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('goals')
          .doc(updatedGoal.id)
          .update(updatedGoal.toMap());
      print("Goal updated for user $userId: goalId = ${updatedGoal.id}");
    } catch (error) {
      print("Error updating individual goal: $error");
      throw error;
    }
  }

  // Update a group goal
  Future<void> updateGroupGoal(String groupId, Goal updatedGoal) async {
    try {
      final goalRef = groupCollection
          .doc(groupId)
          .collection('goals')
          .doc(updatedGoal.id);

      await goalRef.update(updatedGoal.toMap());
      print("Group goal updated for group $groupId: goalId = ${updatedGoal.id}");
    } catch (error) {
      print("Error updating group goal: $error");
      throw error;
    }
  }

  // Fetch a single group goal
  Future<Goal?> getGroupGoal(String groupId, String goalId) async {
    try {
      print('Fetching group goal: groupId = $groupId, goalId = $goalId');
      DocumentSnapshot goalSnapshot = await groupCollection
          .doc(groupId)
          .collection('goals')
          .doc(goalId)
          .get(const GetOptions(source: Source.server)); // Force fetch from server

      if (goalSnapshot.exists) {
        return Goal.fromMap(goalSnapshot.data() as Map<String, dynamic>);
      } else {
        print("Group goal with ID $goalId not found.");
        return null;
      }
    } catch (error) {
      print("Error fetching group goal: $error");
      throw error;
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
      print("Goal marked as completed for user $userId: goalId = $goalId");
    } catch (error) {
      print("Error marking goal as completed: $error");
      throw error;
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
      print("Group goal marked as completed for group $groupId: goalId = $goalId");
    } catch (error) {
      print("Error marking group goal as completed: $error");
      throw error;
    }
  }

  // Update group goal progress
  Future<void> updateGroupGoalProgress(Goal goal, int updatedProgress, {required String groupId}) async {
    try {
      print('Updating progress for goal ID: ${goal.id}, Group ID: $groupId');

      final goalRef = groupCollection
          .doc(groupId)
          .collection('goals')
          .doc(goal.id);

      await goalRef.update({'groupProgress': updatedProgress});
      print('Group goal progress updated successfully for goal ID: ${goal.id}');
    } catch (e) {
      print('Error updating group goal progress: $e');
      throw e;
    }
  }
}
