import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:habitwise/providers/habit_provider.dart';
import 'package:provider/provider.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/methods/auth_methods.dart';
import 'package:habitwise/screens/auth/login_screen.dart';
import 'package:habitwise/screens/auth/signup_screen.dart';
import 'package:habitwise/screens/dashboard_screen.dart';
import 'package:habitwise/screens/habit_screen.dart';
import 'package:habitwise/screens/landing_page.dart';

import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
   options: FirebaseOptions(
      apiKey: FirebaseConfig.apiKey,
      appId: FirebaseConfig.appId,
      messagingSenderId: FirebaseConfig.messagingSenderId,
      projectId: FirebaseConfig.projectId,
      storageBucket: FirebaseConfig.storageBucket,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()..fetchHabits()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitWise',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LandingPage(),
        '/login': (context) => LoginScreen(
          emailController: TextEditingController(),
          passwordController: TextEditingController(),
          onLoginSuccess: (username) async {
            UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
            HabitWiseUser? user = await userProvider.getUserDetails();
            if (user != null) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => DashboardScreen(user: user),
                ),
              );
            } else {
              // Handle error if user data isn't available
            }
          },
        ),
        '/signup': (context) => SignUpScreen(
          emailController: TextEditingController(),
          usernameController: TextEditingController(),
          passwordController: TextEditingController(),
          passwordConfirmController: TextEditingController(),
          onSignupSuccess: (username) async {
            UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
            HabitWiseUser? user = await userProvider.getUserDetails();
            if (user != null) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => DashboardScreen(user: user),
                ),
              );
            } else {
              // Handle error if user data isn't available
            }
          },
        ),
        '/dashboard': (context) => FutureBuilder<HabitWiseUser>(
          future: AuthMethod().getUserDetails(),
          builder: (context, AsyncSnapshot<HabitWiseUser> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              return DashboardScreen(user: snapshot.data!);
            } else if (snapshot.hasError) {
              return Scaffold(
                body: Center(child: Text('Error fetching user data: ${snapshot.error}')),
              );
            } else {
              return Scaffold(
                body: Center(child: Text('User data not found')),
              );
            }
          },
        ),
        '/habit': (context) => HabitScreen(),
      },
    );
  }
}
