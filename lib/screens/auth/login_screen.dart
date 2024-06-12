import 'package:flutter/material.dart';
import 'package:habitwise/models/user.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../dashboard_screen.dart';
import '../../methods/auth_methods.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen(
      {Key? key,
      required TextEditingController passwordController,
      required TextEditingController emailController,
      required Future<Null> Function(dynamic username) onLoginSuccess})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 28),
            const Text(
              'HabitWise',
              style: TextStyle(
                fontFamily: 'Billabong',
                color: Color.fromRGBO(126, 35, 191, 0.498),
                fontSize: 50,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color.fromRGBO(126, 35, 191, 0.498),
                  width: 4,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                  height: 80,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 28),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () async {
                        String email = emailController.text.trim();
                        String password = passwordController.text.trim();

                        if (email.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in all fields'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }

                        // Authenticate user using email and password
                        String loginResult = await AuthMethod().login(
                          email: email,
                          password: password,
                        );

                        if (loginResult == 'success') {
                          // If login is successful, retrieve user details
                          HabitWiseUser? user =
                              await AuthMethod().getUserDetails();

                          if (user != null) {
                            // If user details are available, navigate to dashboard
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => DashboardScreen(user: user),
                              ),
                            );
                          } else {
                            // Handle case where user details are not available
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('User data is not available'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } else {
                          // If login fails, show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(loginResult),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromRGBO(126, 35, 191, 0.498)),
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 16),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Log in',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Forgot your login details? ",
                        style: TextStyle(fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgot_password');
                        },
                        child: const Text(
                          'Get help logging in',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text(
                          'Sign up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color.fromRGBO(126, 35, 191, 0.498),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
