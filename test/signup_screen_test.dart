import 'dart:js';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/models/user.dart';
import 'package:habitwise/screens/auth/signup_screen.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Mock class for UserProvider
class MockUserProvider extends Mock implements UserProvider {
  @override
  void addListener(VoidCallback listener) {}

  @override
  void dispose() {}

  @override
  String get errorMessage => "";

  @override
  Future<void> fetchUserGroups() async {}

  @override
  Future<HabitWiseUser?> getUserDetails() async {
    return null;
  }

  @override
  String? get groupId => null;

  @override
  bool get hasListeners => false;

  @override
  bool get isEmailVerified => false;

  @override
  bool get isLoading => false;

  @override
  Future<void> loginUser({required String email, required String password}) async {}

  @override
  Future<void> logoutUser() async {}

  @override
  void notifyListeners() {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  Future<void> resendVerificationEmail() async {}

  @override
  Future<void> signUpUser({
    required String email,
    required String password,
    required String username,
    required String confirmPassword,
    required BuildContext context,
  }) async {
    // Simulate successful signup for testing
    return Future.value();
  }

  @override
  Future<void> updateUserProfile(HabitWiseUser user) async {}

  @override
  HabitWiseUser? get user => null;

  @override
  List<HabitWiseGroup> get userGroups => [];

  @override
  Future<void> verifyEmailAndCompleteRegistration() async {}
}

void main() {
  group('SignUpScreen', () {
    late MockUserProvider mockUserProvider;
    late TextEditingController emailController;
    late TextEditingController usernameController;
    late TextEditingController passwordController;
    late TextEditingController passwordConfirmController;

    setUp(() {
      mockUserProvider = MockUserProvider();
      emailController = TextEditingController();
      usernameController = TextEditingController();
      passwordController = TextEditingController();
      passwordConfirmController = TextEditingController();
    });

    Widget createWidgetUnderTest() {
      return ChangeNotifierProvider<UserProvider>.value(
        value: mockUserProvider,
        child: MaterialApp(
          home: SignUpScreen(
            onSignupSuccess: (String username) async {
              // Logic here should be similar to what you added in your main app
              UserProvider userProvider = Provider.of<UserProvider>(context as BuildContext, listen: false);
              
              HabitWiseUser? user = await userProvider.getUserDetails();
              if (user != null) {
                // Push replacement to the next screen
                Navigator.of(context as BuildContext).pushReplacement(MaterialPageRoute(
                  builder: (context) => Scaffold(
                    body: Center(
                      child: Text('Please verify your email to access the app.'),
                    ),
                  ),
                ));
              }
            },
          ),
        ),
      );
    }

    testWidgets('renders SignUpScreen and verifies widgets', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify if the widgets are present
      expect(find.text('HabitWise'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(4)); // Email, Username, Password, Confirm Password
      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets('shows error message when fields are empty', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Tap the Sign Up button
      await tester.tap(find.text('Sign up'));
      await tester.pump(); // Rebuild the widget after the state has changed

      // Verify if the error message is displayed
      expect(find.text('Please fill in all fields correctly'), findsOneWidget);
    });

    tearDown(() {
      emailController.dispose();
      usernameController.dispose();
      passwordController.dispose();
      passwordConfirmController.dispose();
    });
  });
}
