import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitwise/models/goal.dart';

class GoalDBService {
  final CollectionReference goalCollection =
      FirebaseFirestore.instance.collection('goals');

  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

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

  Stream<List<Goal>> getGroupGoalsStream(String groupId) {
    return groupCollection.doc(groupId).snapshots().asyncMap((groupDoc) async {
      List<String> goalIds = List<String>.from(groupDoc['goals'] ?? []);
      if (goalIds.isEmpty) return [];
      QuerySnapshot goalSnapshots = await goalCollection.where(FieldPath.documentId, whereIn: goalIds).get();
      return goalSnapshots.docs.map((doc) => Goal.fromMap(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Stream<List<Goal>> getGoals() {
    return goalCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Goal.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> removeGoal(String goalId) async {
    try {
      await goalCollection.doc(goalId).delete();
    } catch (error) {
      print("Error removing goal: $error");
      throw error;
    }
  }

  Future<void> updateGoal(Goal updatedGoal) async {
    try {
      await goalCollection.doc(updatedGoal.id).update(updatedGoal.toMap());
    } catch (error) {
      print("Error updating goal: $error");
      throw error;
    }
  }

  Future<void> markGoalAsCompleted(String goalId) async {
    try {
      await goalCollection.doc(goalId).update({'isCompleted': true});
    } catch (error) {
      print("Error marking goal as completed: $error");
      throw error;
    }
  }
}
