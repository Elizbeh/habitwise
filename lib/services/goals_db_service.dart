import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitwise/models/goal.dart';

class FirestoreService {
  final CollectionReference goalCollection =
      FirebaseFirestore.instance.collection('goals');

  Future<void> addGoal(Goal goal) async {
    await goalCollection.doc(goal.id).set({
      'id': goal.id,
      'title': goal.title,
      'description': goal.description,
      'target': goal.target,
      'targetDate': goal.targetDate,
      'category': goal.category,
      'isCompleted': goal.isCompleted,
    });
  }

  Stream<List<Goal>> getGoals() {
    return goalCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Goal(
          id: doc.id,
          title: doc['title'],
          description: doc['description'],
          target: doc['target'],
          targetDate: doc['targetDate'].toDate(),
          category: doc['category'],
          isCompleted: doc['isCompleted'],
        );
      }).toList();
    });
  }

  Future<void> removeGoal(String goalId) async {
    await goalCollection.doc(goalId).delete();
  }

  Future<void> updateGoal(Goal updatedGoal) async {
    await goalCollection.doc(updatedGoal.id).update({
      'title': updatedGoal.title,
      'description': updatedGoal.description,
      'target': updatedGoal.target,
      'targetDate': updatedGoal.targetDate,
      'category': updatedGoal.category,
      'isCompleted': updatedGoal.isCompleted,
    });
  }
}
