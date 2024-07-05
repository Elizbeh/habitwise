import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/user_db_service.dart';

final logger = Logger();

enum AuthResult {
  success,
  invalidInput,
  emailInUse,
  weakPassword,
  networkError,
  unknownError,
}

class AuthMethod {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserDBService _userDBService = UserDBService();

  // Login method
  Future<String> login({required String email, required String password}) async {
    try {
      UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (authResult.user != null) {
        return 'success';
      } else {
        return 'Login failed';
      }
    } catch (e) {
      logger.e('Error signing in: $e');
      return e.toString();
    }
  }

  // Sign-up method
  Future<AuthResult> signUpUser({
    required String email,
    required String password,
    required String username,
    required String confirmPassword,
  }) async {
    // Validate input
    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      return AuthResult.invalidInput;
    }

    if (password.length < 6) {
      return AuthResult.weakPassword;
    }

    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Create user in Firestore with default permissions
        HabitWiseUser habitWiseUser = HabitWiseUser(
          uid: user.uid,
          email: email,
          username: username,
          goals: [],
          habits: [],
          soloStats: {},
          groupIds: [],
          canCreateGroup: false, // Default permission
          canJoinGroups: true, id: '',    // Default permission
        );

        await _userDBService.createUser(habitWiseUser);
        return AuthResult.success;
      } else {
        return AuthResult.unknownError;
      }
    } on FirebaseAuthException catch (e) {
      logger.e('Firebase Auth Error: $e');
      return _handleFirebaseAuthError(e);
    } catch (e) {
      logger.e('Error signing up: $e');
      return AuthResult.unknownError;
    }
  }

  // Method to get user details
  Future<HabitWiseUser?> getUserDetails() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        return await _userDBService.getUserById(user.uid);
      }
      throw Exception('User details not found');
    } catch (e) {
      logger.e('Error getting user details $e');
      throw Exception('Error getting user details');
    }
  }

  // Logout method
  Future<void> logout() async {
    await _auth.signOut();
    await clearLocalData();
  }

  // Clear local data
  Future<void> clearLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Handle Firebase Auth errors
  AuthResult _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return AuthResult.emailInUse;
      case 'weak-password':
        return AuthResult.weakPassword;
      case 'network-request-failed':
        return AuthResult.networkError;
      default:
        return AuthResult.unknownError;
    }
  }
}
