import 'dart:async';
import 'dart:ui';
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
  bool _isCheckingVerification = false;

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
        // Show progress while checking
        setState(() {
          _isCheckingVerification = true; // Show a loading spinner
        });

        // Poll for email verification status every 10 seconds
        Timer.periodic(Duration(seconds: 10), (timer) async {
          await user?.reload();
          user = _auth.currentUser;

          if (user != null && user!.emailVerified) {
            timer.cancel();
            await _completeRegistration(user!);
          }
        });
      }
    } else {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _completeRegistration(User user) async {
    try {
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
    } catch (e) {
      // Handle error if email verification or registration fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to verify email. Please try again.')),
      );
    } finally {
      // Hide progress indicators
      setState(() {
        _isCheckingVerification = false;
      });
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
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        toolbarHeight: 120,
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Verify Email',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
            ),
          ],
        ),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            gradient: LinearGradient(
              colors: appBarGradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ),
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
                height: 250, // Adjust the height as needed
              ),
              SizedBox(height: 20),
              Text(
                'Please verify your email address to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Color.fromRGBO(134, 41, 137, 1.0)),
              ),
              SizedBox(height: 20),
              if (_isCheckingVerification)
                Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      'Checking verification status...',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isResending ? null : _resendVerificationEmail,
                child: _isResending
                    ? CircularProgressIndicator()
                    : Text('Resend Verification Email', style: TextStyle(fontSize: 24),),
              ),
              SizedBox(height: 20),
              Text(
                'If you have already verified your email, please wait a moment while we check the verification status.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
