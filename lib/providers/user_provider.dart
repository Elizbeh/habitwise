import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitwise/providers/group_provider.dart';
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
  final GroupProvider _groupProvider = GroupProvider(); // Initialize GroupProvider

  HabitWiseUser? _user;
  bool _isLoading = false;
  String _errorMessage = '';

  HabitWiseUser? get user => _user;
  
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isEmailVerified => _authMethod.getCurrentUser()?.emailVerified ?? false;
  List<HabitWiseGroup> get userGroups => _groupProvider.userGroups; // Use GroupProvider to access userGroups

 // Add this getter if you want to get the first group ID
  String? get groupId {
    if (_groupProvider.userGroups.isNotEmpty) {
      return _groupProvider.userGroups.first.groupId; // Assuming each group has an 'id'
    }
    return null; // If no group is available, return null
  }

  UserProvider() {
    _checkUserSession();
  }

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
        await _groupProvider.fetchGroups(currentUser.uid); // Fetch user groups from GroupProvider
      } else {
        _errorMessage = 'User details not found.';
      }
    } else {
      _errorMessage = 'Current user is null.';
    }
  } catch (e) {
    _errorMessage = 'Error getting user details: ${e.toString()}'; // Consider using e.toString() for better clarity
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

   Future<void> fetchUserGroups() async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentUser = _authMethod.getCurrentUser();
      if (currentUser != null) {
        await _groupProvider.fetchGroups(currentUser.uid); // Fetch user groups from GroupProvider
      } else {
        _errorMessage = 'Current user is null, cannot fetch groups.';
      }
    } catch (e) {
      _errorMessage = 'Error fetching user groups: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
        await _authMethod.sendEmailVerification(context);
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
      _groupProvider.clearUserGroups(); // Clear user groups in GroupProvider
    } catch (e) {
      _errorMessage = 'Error logging out: $e';
    } finally {
      _isLoading = false;
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
