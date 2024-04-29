import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/user.dart';

final logger = Logger();

class AuthMethod {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> login({required String email, required String password}) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return "Please fill all the fields";
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "success";
    } catch (e) {
      logger.e('Error occurred while logging in: $e');
      return e.toString();
    }
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username, required String confirmPassword,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        return "Please fill all the fields";
      }

      if (password.length < 6) {
        return "Password must be at least 6 characters long";
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection("users").doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'username': username,
          'goals': [],
          'habits': [],
          'soloStats': {},
          'familyId': '',
          'groupIds': [],
        });
        return 'success';
      } else {
        return 'An error occurred while signing up';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'The email address is already in use';
      } else if (e.code == 'weak-password') {
        return 'The password provided is too weak';
      } else {
        logger.e('Firebase Auth Error: $e');
        return 'An error occurred while signing up';
      }
    } on FirebaseException catch (e) {
      if (e.code == 'network-request-failed') {
        return 'A network error has occurred. Please check your internet connection and try again.';
      } else {
        logger.e('Firebase Error: $e');
        return 'An error occurred while signing up';
      }
    } catch (e) {
      logger.e('Error signing up: $e');
      return 'An error occurred while signing up';
    }
  }

  Future<HabitWiseUser?> getUserDetails() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot snapshot = await _firestore.collection('users').doc(user.uid).get();
        if (snapshot.exists) {
          return HabitWiseUser.fromMap(snapshot.data() as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      logger.e('Error getting user details $e');
      return null;
    }
  }

  logout() {}
}
