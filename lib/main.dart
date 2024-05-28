import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:habitwise/providers/habit_provider.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/screens/auth/login_screen.dart';
import 'package:habitwise/screens/auth/signup_screen.dart';
import 'package:habitwise/screens/dashboard_screen.dart';
import 'package:habitwise/screens/goals_screen.dart';
import 'package:habitwise/screens/habit_screen.dart';
import 'package:habitwise/screens/landing_page.dart';
import 'package:habitwise/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:habitwise/methods/auth_methods.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['API_KEY'],
      appId: dotenv.env['APP_ID'],
      messagingSenderId: dotenv.env['MESSAGING_SENDER_ID'],
      projectId: dotenv.env['PROJECT_ID'],
      storageBucket: dotenv.env['STORAGE_BUCKET'],
    ),
  );

  final userProvider = UserProvider();
  final habitProvider = HabitProvider();
  final goalProvider = GoalProvider();

  await userProvider.getUserDetails(); // Fetch user details once

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider.value(value: habitProvider),
        ChangeNotifierProvider.value(value: goalProvider),
      ],
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HabitWise',
      theme: ThemeData(
         primarySwatch: Colors.deepPurple,
        primaryColor: Color.fromRGBO(126, 35, 191, 0.498),
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
              // Handle error if user data isn't available: Todo..
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
              // Handle error if user data isn't available. todo...
            }
          },
        ),
        // Default route for handling user-dependent screens
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
        '/habit': (context) => FutureBuilder<HabitWiseUser>(
          future: AuthMethod().getUserDetails(),
          builder: (context, AsyncSnapshot<HabitWiseUser> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              return HabitScreen(user: snapshot.data!);
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
        '/goals': (context) => FutureBuilder<HabitWiseUser>(
          future: AuthMethod().getUserDetails(),
          builder: (context, AsyncSnapshot<HabitWiseUser> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              return GoalScreen(user: snapshot.data!);
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
        '/profile': (context) => FutureBuilder<HabitWiseUser>(
          future: AuthMethod().getUserDetails(),
          builder: (context, AsyncSnapshot<HabitWiseUser> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              return ProfilePage(user: snapshot.data!);
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
      },
    );
  }
}