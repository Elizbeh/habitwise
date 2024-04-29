import 'package:flutter/material.dart';
import '/models/user.dart';
import '../methods/auth_methods.dart';

class UserProvider extends ChangeNotifier {
  HabitWiseUser? _user;
  bool _isLoading = false;
  String _errorMessage = '';

  HabitWiseUser? get user => _user;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  final AuthMethod _authMethod = AuthMethod();

  UserProvider() {
    getUserDetails();
  }

  Future<void> getUserDetails() async {
    _isLoading = true;
    notifyListeners();
    _user = await _authMethod.getUserDetails();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loginUser({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();
    String result = await _authMethod.login(email: email, password: password);
    if (result == 'success') {
      await getUserDetails();
    } else {
      _errorMessage = result;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpUser({
    required String email,
    required String password,
    required String username,
  }) async {
    _isLoading = true;
    notifyListeners();
    String result = await _authMethod.signUpUser(email: email, password: password, username: username, confirmPassword: '');
    if (result == 'success') {
      await getUserDetails();
    } else {
      _errorMessage = result;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logoutUser() async {
    _user = null;
    _isLoading = false;
    _errorMessage = '';
    await _authMethod.logout();
    notifyListeners();
  }
}
