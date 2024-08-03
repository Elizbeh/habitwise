import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitwise/models/habit.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HabitDBService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase authentication instance

  // Method to get the habit collection for a specific group
  CollectionReference _getHabitCollection(String groupId) {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');
    if (groupId.isEmpty) throw ArgumentError('Group ID cannot be empty');
    return FirebaseFirestore.instance.collection('groups').doc(groupId).collection('habits');
  }

  // Method to add a habit to the database
  Future<void> addHabit(String groupId, Habit habit) async {
    try {
      if (habit.id.isEmpty || groupId.isEmpty) throw ArgumentError('Invalid ID or group ID');
      await _getHabitCollection(groupId).doc(habit.id).set(habit.toMap());
    } catch (e) {
      print('Error adding habit: $e');
    }
  }

  // Method to add a habit to a group (same as addHabit for consistency)
  Future<void> addHabitToGroup(String groupId, Habit habit) async {
    await _getHabitCollection(groupId).doc(habit.id).set(habit.toMap()); // Set habit data in Firestore
  }

  // Method to fetch habits from the database as a stream
  Stream<List<Habit>> getHabits(String groupId) {
    return _getHabitCollection(groupId).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Habit.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  // Method to remove a habit from the database
  Future<void> removeHabit(String groupId, String habitId) async {
    try {
      if (habitId.isEmpty || groupId.isEmpty) throw ArgumentError('Invalid ID or group ID');
      await _getHabitCollection(groupId).doc(habitId).delete();
    } catch (e) {
      print('Error removing habit: $e');
    }
  }

  // Method to update a habit in the database
  Future<void> updateHabit(String groupId, Habit updatedHabit) async {
    try {
      if (updatedHabit.id.isEmpty || groupId.isEmpty) throw ArgumentError('Invalid ID or group ID');
      await _getHabitCollection(groupId).doc(updatedHabit.id).update(updatedHabit.toMap());
      
    } catch (e) {
      print('Error updating habit: $e');
    }
  }

  Future<void> updateGroupHabit(String groupId, Habit updatedHabit) async {
    await _getHabitCollection(groupId).doc(updatedHabit.id).update(updatedHabit.toMap());
  }

  // Method to fetch group habits as a stream
  Stream<List<Habit>> getGroupHabitsStream(String groupId) {
    return _getHabitCollection(groupId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Habit.fromMap(doc.data() as Map<String, dynamic>); // Convert document data to Habit object
      }).toList();
    });
  }
}
