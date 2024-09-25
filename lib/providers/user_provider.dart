import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitwise/screens/auth/verify_email_screen.dart';
import '../models/user.dart';
import '../services/user_db_service.dart';
import '../services/group_db_service.dart';
import '../methods/auth_methods.dart';
import '../models/group.dart';

class UserProvider extends ChangeNotifier {
  final AuthMethod _authMethod = AuthMethod();
  final UserDBService _userDBService = UserDBService();
  final GroupDBService _groupDBService = GroupDBService();

  HabitWiseUser? _user;
  List<HabitWiseGroup> _userGroups = [];
  bool _isLoading = false;
  String _errorMessage = '';

  HabitWiseUser? get user => _user;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isEmailVerified => _authMethod.getCurrentUser()?.emailVerified ?? false;
  List<HabitWiseGroup> get userGroups => _userGroups;
  
  UserProvider() {
    _checkUserSession();
  }

  get groupId => null;

  Future<void> _checkUserSession() async {
    _isLoading = true;
    notifyListeners();
    try {
      final User? currentUser = _authMethod.getCurrentUser();
      if (currentUser != null) {
        await getUserDetails();
      } else {
        _errorMessage = 'No user is currently logged in.';
      }
    } catch (e) {
      _errorMessage = 'Error checking user session: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setUser(HabitWiseUser? user) {
    _user = user;
    notifyListeners();
  }

  Future<bool> reloadAndCheckEmailVerification() async {
    try {
      final User? currentUser = _authMethod.getCurrentUser();
      if (currentUser != null) {
        await currentUser.reload();
        User? updatedUser = _authMethod.getCurrentUser();
        if (updatedUser != null && updatedUser.emailVerified) {
          _user?.emailVerified = true;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      _errorMessage = 'Error reloading and checking email verification: $e';
      notifyListeners();
    }
    return false;
  }

  Future<HabitWiseUser?> getUserDetails() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final currentUser = _authMethod.getCurrentUser();
      if (currentUser != null) {
        final userDetails = await _userDBService.getUserDetailsById(currentUser.uid);
        if (userDetails != null) {
          _user = HabitWiseUser.fromMap(userDetails);
          await fetchUserGroups();
        } else {
          _errorMessage = 'User details not found.';
        }
      } else {
        _errorMessage = 'Current user is null.';
      }
    } catch (e) {
      _errorMessage = 'Error getting user details: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return _user;
  }

  Future<void> resendVerificationEmail() async {
    try {
      final User? currentUser = _authMethod.getCurrentUser();
      if (currentUser != null && !currentUser.emailVerified) {
        await currentUser.sendEmailVerification();
        _errorMessage = 'Verification email sent. Please check your inbox.';
      }
    } catch (e) {
      _errorMessage = 'Error resending verification email: $e';
      notifyListeners();
    }
  }

  Future<void> loginUser({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      AuthResult result = await _authMethod.login(email: email, password: password);
      if (result == AuthResult.success) {
        await getUserDetails();
        if (_user != null && !_user!.emailVerified) {
          _errorMessage = 'Please verify your email address.';
        }
      } else {
        _errorMessage = _handleAuthError(result);
      }
    } catch (e) {
      _errorMessage = 'Error logging in: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpUser({
    required String email,
    required String password,
    required String username,
    required String confirmPassword,
    required BuildContext context,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      AuthResult result = await _authMethod.signUpUser(
        email: email,
        password: password,
        username: username,
        confirmPassword: confirmPassword,
      );

      if (result == AuthResult.success) {
        _errorMessage = 'Please verify your email address.';
        await _authMethod.sendEmailVerification();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VerifyEmailScreen()),
        );
      } else {
        _errorMessage = _handleAuthError(result);
      }
    } catch (e) {
      _errorMessage = 'Error signing up: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyEmailAndCompleteRegistration() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      AuthResult result = await _authMethod.verifyEmailAndCompleteRegistration();
      if (result == AuthResult.success) {
        await getUserDetails();
      } else {
        _errorMessage = 'Email verification failed or is not completed.';
      }
    } catch (e) {
      _errorMessage = 'Error verifying email: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logoutUser() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _authMethod.logout();
      _user = null;
      _userGroups.clear();
    } catch (e) {
      _errorMessage = 'Error logging out: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserGroups() async {
    try {
      final userId = _user?.uid;
      if (userId != null) {
        _userGroups = await _groupDBService.getAllGroups(userId);
        notifyListeners();
      } else {
        _errorMessage = 'User ID is not available.';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error fetching user groups: $e';
      notifyListeners();
    }
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
      case AuthResult.emailNotVerified:
        return 'Email is not verified.';
      case AuthResult.userNotFound:
        return 'User not found.';
      case AuthResult.wrongPassword:
        return 'Incorrect password.';
      case AuthResult.userDisabled:
        return 'User account is disabled.';
      case AuthResult.operationNotAllowed:
        return 'Operation not allowed.';
      case AuthResult.tooManyRequests:
        return 'Too many requests. Try again later.';
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

  Future<void> updateUserProfile(HabitWiseUser user) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _userDBService.updateUserProfile(user);
      _user = user;
    } catch (e) {
      _errorMessage = 'Error updating user profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
