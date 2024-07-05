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
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      logger.e('Error Creating user: $e');
      throw e;
    }
  }

  /*static Future<String> uploadImageToStorage(File imageFile) async {
    try {
      var uuid = Uuid();
      String fileName = '${uuid.v4()}_${path.basename(imageFile.path)}';

      Reference ref = FirebaseStorage.instance.ref().child('images/$fileName');
      UploadTask uploadTask = ref.putFile(imageFile);

      TaskSnapshot storageTaskSnapshot = await uploadTask;
      String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      throw e;
    }
  }*/
  static Future<String> uploadImageToStorage(File imageFile) async {
  try {
    var uuid = Uuid();
    String fileName = '${uuid.v4()}_${path.basename(imageFile.path)}';
    Reference ref = FirebaseStorage.instance.ref().child('images/$fileName');
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot storageTaskSnapshot = await uploadTask;
    return await storageTaskSnapshot.ref.getDownloadURL();
  } catch (e) {
    logger.e('Error uploading image to Firebase Storage: $e');
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

  Future<void> updateUserProfile(HabitWiseUser user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      logger.e('Error updating user profile: $e');
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
