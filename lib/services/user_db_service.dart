import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:habitwise/models/user.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

final logger = Logger();

class UserDBService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(HabitWiseUser user) async {
  try {
    // Check if the user already exists to prevent duplicates
    DocumentSnapshot existingUser = await _firestore.collection('users').doc(user.uid).get();
    if (!existingUser.exists) {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    }
  } catch (e) {
    logger.e('Error creating user: $e');
    throw Exception('Failed to create user');
  }
}

  Future<String> uploadImageToStorage(File imageFile) async {
    try {
      var uuid = Uuid();
      String fileName = '${uuid.v4()}_${path.basename(imageFile.path)}';
      Reference ref = FirebaseStorage.instance.ref().child('images/$fileName');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot storageTaskSnapshot = await uploadTask;
      return await storageTaskSnapshot.ref.getDownloadURL();
    } catch (e) {
      logger.e('Error uploading image to Firebase Storage: $e');
      throw Exception('Failed to upload image');
    }
  }

  Future<HabitWiseUser?> getUserById(String userId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(userId).get();
      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        return data != null ? HabitWiseUser.fromMap(data) : null;
      }
      return null;
    } catch (e) {
      logger.e('Error getting user by ID: $e');
      throw Exception('Failed to get user by ID');
    }
  }

  Future<void> updateUserProfile(HabitWiseUser user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      logger.e('Error updating user profile: $e');
      throw Exception('Failed to update user profile');
    }
  }

   // Fetch profile picture URL by user ID
  Future<String> getUserProfilePictureById(String userId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(userId).get();
      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        return data?['profilePictureUrl'] ?? ''; // Return empty string if not found
      }
      return ''; // Return empty string if document does not exist
    } catch (e) {
      logger.e('Error getting profile picture URL by ID: $e');
      throw Exception('Failed to get profile picture URL');
    }
  }

  Future<Map<String, dynamic>?> getUserDetailsById(String userId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(userId).get();
      return snapshot.exists ? snapshot.data() as Map<String, dynamic>? : null;
    } catch (e) {
      logger.e('Error getting user details by ID: $e');
      throw Exception('Failed to get user details');
    }
  }

  // Update email verification status in Firestore
  Future<void> updateEmailVerificationStatus(String userId, bool isVerified) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'emailVerified': isVerified,
      });
    } catch (e) {
      logger.e('Error updating email verification status: $e');
      throw Exception('Failed to update email verification status');
    }
  }

  // Method to update the user's group count
  Future<void> updateUserGroupCount(String userId, {required bool decrement}) async {
  final userRef = _firestore.collection('users').doc(userId);

  await _firestore.runTransaction((transaction) async {
    DocumentSnapshot snapshot = await transaction.get(userRef);
    if (snapshot.exists) {
      int currentCount = snapshot.get('joinedGroups') ?? 0;
      transaction.update(userRef, {
        'joinedGroups': currentCount + (decrement ? -1 : 1),
      });
    }
  });
}

}
