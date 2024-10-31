import 'package:flutter/material.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'landing_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();

    Future.delayed(const Duration(seconds: 2), () async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      bool isLoggedIn = userProvider.isEmailVerified;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            final user = userProvider.currentUser; // HabitWiseUser?
            final groupId = userProvider.groupId; // Ensure this getter is defined

            if (user != null) {
              return DashboardScreen(user: user, groupId: groupId!);
            } else {
              return LandingPage(
                onThemeChanged: () {},
                themeNotifier: ValueNotifier(ThemeMode.light),
              );
            }
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(134, 41, 137, 1.0),
                  Color.fromRGBO(181, 58, 185, 1),
                  Color.fromRGBO(46, 197, 187, 1.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(134, 41, 137, 1.0).withOpacity(0.7),
                  const Color.fromRGBO(46, 197, 187, 1.0).withOpacity(0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: screenWidth * 0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
