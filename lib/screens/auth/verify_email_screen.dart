import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitwise/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/models/user.dart';

class VerifyEmailScreen extends StatefulWidget {
  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  Future<void> _checkEmailVerification() async {
    User? user = _auth.currentUser;

    if (user != null) {
      if (user.emailVerified) {
        // Call verifyEmailAndCompleteRegistration to update the status in Firestore
        await _completeRegistration(user);
      } else {
        // Poll for email verification status
        Timer.periodic(Duration(seconds: 5), (timer) async {
          user = await _auth.currentUser?.reload().then((_) => _auth.currentUser);

          if (user != null && user!.emailVerified) {
            timer.cancel();
            // Call verifyEmailAndCompleteRegistration to update the status in Firestore
            await _completeRegistration(user!);
          }
        });
      }
    } else {
      // If user is null, navigate to login screen
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _completeRegistration(User user) async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Call the method to verify email and update status in Firestore
    await userProvider.verifyEmailAndCompleteRegistration();
    
    // Fetch user details again to ensure all data is up-to-date
    HabitWiseUser? habitWiseUser = await userProvider.getUserDetails();

    if (habitWiseUser != null) {
      // Navigate to the dashboard if email verification and user data retrieval were successful
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(
            user: habitWiseUser,
            groupId: habitWiseUser.groupIds.isNotEmpty ? habitWiseUser.groupIds[0] : '',
          ),
        ),
      );
    } else {
      // Show an error message if user data could not be retrieved
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User data not found.')),
      );
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResending = true;
    });

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification email sent. Please check your inbox.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resend verification email.')),
        );
      }
    }

    setState(() {
      _isResending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Email'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add Image Widget
              Image.asset(
                'assets/images/verifyImg.png',
                height: 150, // Adjust the height as needed
              ),
              SizedBox(height: 20),
              Text(
                'Please verify your email address to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isResending ? null : _resendVerificationEmail,
                child: _isResending
                    ? CircularProgressIndicator()
                    : Text('Resend Verification Email'),
              ),
              SizedBox(height: 20),
              Text(
                'If you have already verified your email, please wait a moment while we check the verification status.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
