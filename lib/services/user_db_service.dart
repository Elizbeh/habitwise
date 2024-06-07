import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitwise/models/user.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class UserDBService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(HabitWiseUser user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      logger.e('Error Creating user: $e');
      throw e;
    }
  }

  Future<HabitWiseUser?> getUserById(String userId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(userId).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return HabitWiseUser.fromMap(data);
      }
      return null;
    } catch (e) {
      logger.e('Error getting user: $e');
      throw e;
    }
  }

  Future<String> getUserNameById(String userId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(userId).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return data['username'] ?? 'Unknown';
      }
      return 'Unknown';
    } catch (e) {
      logger.e('Error getting username: $e');
      throw e;
    }
  }
}
