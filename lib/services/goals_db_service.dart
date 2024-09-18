import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitwise/models/goal.dart';

class GoalDBService {
  // Collection for individual goals
  final CollectionReference goalCollection =
      FirebaseFirestore.instance.collection('goals');

  // Collection for groups
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

  // Add an individual goal to the 'goals' collection
  Future<void> addGoal(Goal goal) async {
    try {
      await goalCollection.doc(goal.id).set(goal.toMap());
    } catch (error) {
      print("Error adding individual goal: $error");
      throw error;
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
      throw error;
    }
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

  // Fetch all individual goals from the 'goals' collection
  Stream<List<Goal>> getGoals() {
    return goalCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Goal.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Remove an individual goal
  Future<void> removeGoal(String goalId) async {
    try {
      await goalCollection.doc(goalId).delete();
    } catch (error) {
      print("Error removing individual goal: $error");
      throw error;
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
      throw error;
    }
  }

  // Update an individual goal in the 'goals' collection
  Future<void> updateGoal(Goal updatedGoal) async {
    try {
      await goalCollection.doc(updatedGoal.id).update(updatedGoal.toMap());
    } catch (error) {
      print("Error updating individual goal: $error");
      throw error;
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
      throw error;
    }
  }

  // Mark an individual goal as completed
  Future<void> markGoalAsCompleted(String goalId) async {
    try {
      await goalCollection.doc(goalId).update({'isCompleted': true});
    } catch (error) {
      print("Error marking individual goal as completed: $error");
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
    } catch (error) {
      print("Error marking group goal as completed: $error");
      throw error;
    }
  }
}
