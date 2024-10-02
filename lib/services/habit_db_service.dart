import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitwise/models/habit.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HabitDBService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to get the habit collection for a specific group
  CollectionReference _getGroupHabitCollection(String groupId) {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');
    if (groupId.isEmpty) throw ArgumentError('Group ID cannot be empty');
    
    return FirebaseFirestore.instance
        .collection('groups') // Main groups collection
        .doc(groupId)         // Specific group document
        .collection('habits'); // Subcollection for group habits
  }

  // Method to get the habit collection for a specific user
  CollectionReference _getUserHabitCollection() {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');
    return FirebaseFirestore.instance.collection('users').doc(user.uid).collection('habits');
  }

  // Method to add a habit to the database (for groups)
  Future<void> addHabitToGroup(String groupId, Habit habit) async {
    try {
      if (groupId.isEmpty) throw ArgumentError('Group ID cannot be empty');
      DocumentReference docRef = _getGroupHabitCollection(groupId).doc();
      await docRef.set(habit.toMap()..['id'] = docRef.id); // Store the habit with the generated ID
    } catch (e) {
      print('Error adding group habit: $e');
      rethrow; // Rethrow to handle it in the UI if necessary
    }
  }

  // Method to add a habit to the user's database (for individual habits)
  Future<void> addHabitToUser(Habit habit) async {
    try {
      DocumentReference docRef = _getUserHabitCollection().doc(); // Generate a new document reference
      await docRef.set(habit.toMap()..['id'] = docRef.id); // Store the habit with the generated ID
    } catch (e) {
      print('Error adding user habit: $e');
    }
  }

  // Method to fetch habits from the database as a stream for groups
  Stream<List<Habit>> getGroupHabitsStream(String groupId) {
    return _getGroupHabitCollection(groupId).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Habit.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  // Method to fetch individual habits from the database as a stream
  Stream<List<Habit>> getUserHabitsStream() {
    return _getUserHabitCollection().snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Habit.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  // Method to remove a habit from the user's database
  Future<void> removeHabitFromUser(String habitId) async {
    try {
      if (habitId.isEmpty) throw ArgumentError('Invalid habit ID');
      await _getUserHabitCollection().doc(habitId).delete();
    } catch (e) {
      print('Error removing user habit: $e');
    }
  }

  // Method to remove a habit from the group database
  Future<void> removeHabitFromGroup(String groupId, String habitId) async {
    try {
      if (habitId.isEmpty || groupId.isEmpty) throw ArgumentError('Invalid habit ID or group ID');
      await _getGroupHabitCollection(groupId).doc(habitId).delete();
    } catch (e) {
      print('Error removing group habit: $e');
    }
  }

  // Method to update a habit in the user's database
  Future<void> updateHabitInUser(Habit updatedHabit) async {
    try {
      if (updatedHabit.id.isEmpty) throw ArgumentError('Invalid habit ID');
      await _getUserHabitCollection().doc(updatedHabit.id).update(updatedHabit.toMap());
    } catch (e) {
      print('Error updating user habit: $e');
    }
  }

  // Method to update a habit in the group database
  Future<void> updateHabitInGroup(String groupId, Habit updatedHabit) async {
    try {
      if (updatedHabit.id.isEmpty || groupId.isEmpty) throw ArgumentError('Invalid habit ID or group ID');
      await _getGroupHabitCollection(groupId).doc(updatedHabit.id).update(updatedHabit.toMap());
    } catch (e) {
      print('Error updating group habit: $e');
    }
  }
}
