import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitwise/models/habit.dart';

class FirestoreService {
  final CollectionReference habitCollection = 
    FirebaseFirestore.instance.collection('habits');

  Future<void> addHabit(Habit habit) async {
    await habitCollection.doc(habit.id).set(habit.toMap());
  }

  Stream<List<Habit>> getHabits() {
    return habitCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Habit.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> removeHabit(String habitId) async {
    await habitCollection.doc(habitId).delete();
  }

  Future<void> updateHabit(Habit updatedHabit) async {
    await habitCollection.doc(updatedHabit.id).update(updatedHabit.toMap());
  }
}
