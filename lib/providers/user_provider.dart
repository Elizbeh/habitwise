import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../services/user_db_service.dart';
import '../methods/auth_methods.dart';

class UserProvider extends ChangeNotifier {
  final AuthMethod _authMethod = AuthMethod();
  final UserDBService _userDBService = UserDBService();

  HabitWiseUser? _user;
  bool _isLoading = false;
  String _errorMessage = '';

  HabitWiseUser? get user => _user;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  UserProvider() {
    // Schedule the call to getUserDetails after the current microtask completes.
    Future.microtask(() => getUserDetails());
  }

  Future<HabitWiseUser?> getUserDetails() async {
    _isLoading = true;
    _errorMessage = '';
    _safeNotifyListeners();
    
    try {
      final currentUser = _authMethod.getCurrentUser();
      if (currentUser != null) {
        _user = await _userDBService.getUserById(currentUser.uid);
        _isLoading = false;
        _safeNotifyListeners();
        return _user;
      } else {
        _isLoading = false;
        _safeNotifyListeners();
        throw Exception('Current user is null');
      }
    } catch (e) {
      _errorMessage = 'Error getting user details: $e';
      _isLoading = false;
      _safeNotifyListeners();
      throw Exception(_errorMessage);
    }
  }

  Future<void> loginUser({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = '';
    _safeNotifyListeners();

    try {
      String result = await _authMethod.login(email: email, password: password);
      if (result == 'success') {
        await getUserDetails(); // Fetch the logged-in user's details
      } else {
        _errorMessage = result;
      }
    } catch (e) {
      _errorMessage = 'Error logging in: $e';
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> signUpUser({required String email, required String password, required String username, required String confirmPassword}) async {
    _isLoading = true;
    _errorMessage = '';
    _safeNotifyListeners();

    try {
      AuthResult result = await _authMethod.signUpUser(email: email, password: password, username: username, confirmPassword: confirmPassword);
      if (result == AuthResult.success) {
        await getUserDetails(); // Fetch the new user's details
      } else {
        _errorMessage = _handleAuthError(result);
      }
    } catch (e) {
      _errorMessage = 'Error signing up: $e';
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> logoutUser() async {
    await _authMethod.logout();
    _user = null;
    _isLoading = false;
    _errorMessage = '';
    _safeNotifyListeners();
  }

  String _handleAuthError(AuthResult result) {
    switch (result) {
      case AuthResult.invalidInput:
        return 'Please fill in all fields.';
      case AuthResult.emailInUse:
        return 'Email is already in use.';
      case AuthResult.weakPassword:
        return 'Password is too weak.';
      case AuthResult.networkError:
        return 'Network error occurred.';
      case AuthResult.unknownError:
        return 'An unknown error occurred.';
      default:
        return 'An error occurred.';
    }
  }

  void _safeNotifyListeners() {
    Future.microtask(() {
      if (!_isDisposed) {
        notifyListeners();
      }
    });
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
