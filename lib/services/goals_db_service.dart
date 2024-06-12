import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitwise/models/goal.dart';

class GoalDBService {
  final CollectionReference goalCollection =
      FirebaseFirestore.instance.collection('goals');

  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

  // Function to add a goal
  Future<void> addGoal(Goal goal, {String? groupId}) async {
    try {
      await goalCollection.doc(goal.id).set(goal.toMap());
      if (groupId != null && groupId.isNotEmpty) {
        await addGoalToGroup(groupId, goal.id);
      }
    } catch (error) {
      print("Error adding goal: $error");
      throw error;
    }
  }

  // Function to add a goal to a group
  Future<void> addGoalToGroup(String groupId, String goalId) async {
    try {
      await groupCollection.doc(groupId).update({
        'goals': FieldValue.arrayUnion([goalId])
      });
    } catch (error) {
      print("Error adding goal to group: $error");
      throw error;
    }
  }

   // Function to get a stream of goals for a specific group
  Stream<List<Goal>> getGroupGoalsStream(String groupId) {
    return groupCollection.doc(groupId).snapshots().asyncMap((groupDoc) async {
      List<String> goalIds = List<String>.from(groupDoc['goals'] ?? []);
      List<Goal> goals = [];
      for (String goalId in goalIds) {
        DocumentSnapshot goalDoc = await goalCollection.doc(goalId).get();
        if (goalDoc.exists) {
          goals.add(Goal.fromMap(goalDoc.data() as Map<String, dynamic>));
        }
      }
      return goals;
    });
  }


  // Function to get goals
  Stream<List<Goal>> getGoals() {
    return goalCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Goal.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Function to get goals for a specific group
  Future<List<Goal>> getGroupGoals(String groupId) async {
    try {
      DocumentSnapshot groupDoc = await groupCollection.doc(groupId).get();
      List<String> goalIds = List<String>.from(groupDoc['goals'] ?? []);
      List<Goal> goals = [];
      for (String goalId in goalIds) {
        DocumentSnapshot goalDoc = await goalCollection.doc(goalId).get();
        if (goalDoc.exists) {
          goals.add(Goal.fromMap(goalDoc.data() as Map<String, dynamic>));
        }
      }
      return goals;
    } catch (error) {
      print("Error fetching group goals: $error");
      throw error;
    }
  }

  // Function to remove a goal
  Future<void> removeGoal(String goalId) async {
    try {
      await goalCollection.doc(goalId).delete();
    } catch (error) {
      print("Error removing goal: $error");
      throw error;
    }
  }

  // Function to update a goal
  Future<void> updateGoal(Goal updatedGoal) async {
    try {
      await goalCollection.doc(updatedGoal.id).update(updatedGoal.toMap());
    } catch (error) {
      print("Error updating goal: $error");
      throw error;
    }
  }

  // Function to mark a goal as completed
  Future<void> markGoalAsCompleted(String goalId) async {
    try {
      await goalCollection.doc(goalId).update({'isCompleted': true});
    } catch (error) {
      print("Error marking goal as completed: $error");
      throw error;
    }
  }
}
