import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habitwise/main.dart';
import 'package:logger/logger.dart';
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
  emailNotVerified,
  userNotFound,
  wrongPassword,
  userDisabled,
  operationNotAllowed,
  tooManyRequests, emailAlreadyInUse,
}

class AuthMethod {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserDBService _userDBService = UserDBService();

  Future<AuthResult> login({required String email, required String password}) async {
  try {
    UserCredential authResult = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = authResult.user;
    if (user != null) {
      await user.reload(); // Ensure we have the latest information
      // Reload user again to get updated status
      user = _auth.currentUser; 
      return user!.emailVerified ? AuthResult.success : AuthResult.emailNotVerified;
    }
    return AuthResult.unknownError;
  } on FirebaseAuthException catch (e) {
    logger.e('Firebase Auth Error: ${e.message}');
    return _handleFirebaseAuthError(e);
  } catch (e) {
    logger.e('Error signing in: $e');
    return AuthResult.unknownError;
  }
}

  Future<AuthResult> signUpUser({
    required String email,
    required String password,
    required String username,
    required String confirmPassword,
  }) async {
    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      return AuthResult.invalidInput;
    }

    if (password.length < 6) {
      return AuthResult.weakPassword;
    }

    if (password != confirmPassword) {
      return AuthResult.invalidInput; // Passwords don't match
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();

        HabitWiseUser habitWiseUser = HabitWiseUser(
          uid: user.uid,
          email: email,
          username: username,
          goals: [],
          habits: [],
          soloStats: {},
          groupIds: [],
          groupRoles: {},
          canCreateGroup: true,
          canJoinGroups: true,
          emailVerified: false,
        );
        await _userDBService.createUser(habitWiseUser);

        return AuthResult.success;
      } else {
        return AuthResult.unknownError;
      }
    } on FirebaseAuthException catch (e) {
      logger.e('Firebase Auth Error: ${e.message}');
      return _handleFirebaseAuthError(e);
    } catch (e) {
      logger.e('Error signing up: $e');
      return AuthResult.unknownError;
    }
  }

  Future<void> updateEmailVerificationStatus(String userId, bool isVerified) async {
    try {
      await _userDBService.updateEmailVerificationStatus(userId, isVerified);
    } catch (e) {
      logger.e('Error updating email verification status: $e');
      throw Exception('Failed to update email verification status');
    }
  }

  Future<void> sendEmailVerification(BuildContext context) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Verification email sent successfully.')),
      );
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'too-many-requests') {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Too many requests. Please try again later.')),
      );
    } else {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Error sending email verification.')),
      );
    }
  }
}

  Future<AuthResult> verifyEmailAndCompleteRegistration() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        if (user.emailVerified) {
          await updateEmailVerificationStatus(user.uid, true);
          return AuthResult.success;
        } else {
          return AuthResult.emailNotVerified;
        }
      } else {
        return AuthResult.unknownError;
      }
    } catch (e) {
      logger.e('Error verifying email: $e');
      return AuthResult.unknownError;
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  AuthResult _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return AuthResult.emailInUse;
      case 'weak-password':
        return AuthResult.weakPassword;
      case 'network-request-failed':
        return AuthResult.networkError;
      case 'user-not-found':
        return AuthResult.userNotFound;
      case 'wrong-password':
        return AuthResult.wrongPassword;
      case 'user-disabled':
        return AuthResult.userDisabled;
      case 'operation-not-allowed':
        return AuthResult.operationNotAllowed;
      case 'too-many-requests':
        return AuthResult.tooManyRequests;
      default:
        return AuthResult.unknownError;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      logger.e('Error logging out: $e');
      throw Exception('Failed to log out');
    }
  }
}
