import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/methods/auth_methods.dart';
import 'package:habitwise/screens/auth/login_screen.dart';
import 'package:habitwise/screens/auth/signup_screen.dart';
import 'package:habitwise/screens/home_screen.dart';

import 'models/user.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDqiOs99zZhD3Q7g48oLPx3XCr0Jt5ywgs',
      appId: '1:704019757717:android:a0ca31290d595fe408f99c',
      messagingSenderId: '704019757717',
      projectId: 'habitwise-e8dc4',
      storageBucket: 'habitwise-e8dc4.appspot.com',
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final TextEditingController signupEmailController = TextEditingController();
  final TextEditingController signupUsernameController = TextEditingController();
  final TextEditingController signupPasswordController = TextEditingController();
  final TextEditingController signupConfirmPasswordController = TextEditingController();

  MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitWise',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: LoginScreen(
        emailController: loginEmailController,
        passwordController: loginPasswordController,
        onLoginSuccess: (username) async {
          // Fetch user data using UserProvider
          UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
          HabitWiseUser? user = await userProvider.getUserDetails();
          if (user != null) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeScreen(user: user),
              ),
            );
          } else {
            // Handle error if user data isn't available
          }
        },
      ),
      routes: {
        '/login': (context) => LoginScreen(
          emailController: loginEmailController,
          passwordController: loginPasswordController,
          onLoginSuccess: (username) async{
            // Access UserProvider from context
            UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
            HabitWiseUser? user = await userProvider.getUserDetails();
            if (user != null) {
              // Use the context from the MaterialApp widget
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => HomeScreen(user: user),
                ),
              );
            } else {
              // Handle Error if user Data is not available
            }
          },
        ),
        '/signup': (context) => SignUpScreen(
          emailController: signupEmailController,
          usernameController: signupUsernameController,
          passwordController: signupPasswordController,
          passwordConfirmController: signupConfirmPasswordController,
        ),
        '/home': (context) => FutureBuilder<HabitWiseUser>(
          future: AuthMethod().getUserDetails(),
          builder: (context, AsyncSnapshot<HabitWiseUser> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              return HomeScreen(user: snapshot.data!);
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
