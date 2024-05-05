import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitwise/models/habit.dart';

class FirestoreService {
  final CollectionReference habitCollection = 
    FirebaseFirestore.instance.collection('habits');

  Future<void> addHabit(Habit habit) async {
    await habitCollection.add({
      'id' : habit.id,
      'title': habit.title,
      'description': habit.description,
      'createdAt': habit.createdAt.toIso8601String(),
      'isCompleted': habit.isCompleted,
    });
  }

  Stream<List<Habit>> getHabits() {
    return habitCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Habit(
          id: doc.id,
          title: doc['title'],
          description: doc['description'],
          createdAt: DateTime.parse(doc['createdAt']),
          isCompleted: doc['isCompleted'],
        );
      }).toList();
    });
  }

  void removeHabit(String habitId) {

  }

  void updateHabit(Habit updatedHabit) {}
}