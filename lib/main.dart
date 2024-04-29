import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:habitwise/screens/auth/login_screen.dart';
import 'package:habitwise/screens/auth/signup_screen.dart';
import 'package:habitwise/screens/home_screen.dart';


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY']!,
      appId: dotenv.env['FIREBASE_APP_ID']!,
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
      projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'],
    ),
  );

  runApp(MyApp());
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
        onLoginSuccess: (username) {
          // Use the context from the MaterialApp widget
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomeScreen(username: username),
            ),
          );
        },
      ),
      routes: {
        '/login': (context) => LoginScreen(
          emailController: loginEmailController,
          passwordController: loginPasswordController,
          onLoginSuccess: (username) {
            // Use the context from the MaterialApp widget
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeScreen(username: username),
              ),
            );
          },
        ),
        '/signup': (context) => SignUpScreen(
          emailController: signupEmailController,
          usernameController: signupUsernameController,
          passwordController: signupPasswordController,
          passwordConfirmController: signupConfirmPasswordController,
        ),
        '/home': (context) => HomeScreen(username: ""),
      },
    );
  }
}
