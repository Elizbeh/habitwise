import 'package:flutter/material.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
 final Function(String) onSignupSuccess;

  SignUpScreen({
    Key? key,
    required this.onSignupSuccess,
  }) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String _message = '';
  Color _messageColor = Colors.red;

  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  late TextEditingController emailController;
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController passwordConfirmController;
  
  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    passwordConfirmController = TextEditingController();

    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Color.fromRGBO(46, 197, 187, 1.0),
      end: Color.fromRGBO(134, 41, 137, 1.0),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60.0),
                const Text(
                  'HabitWise',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(134, 41, 137, 1.0),
                    fontSize: 32,
                  ),
                ),
                Image.asset(
                  'assets/images/logo1.png',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: AnimatedBuilder(
                            animation: _colorAnimation,
                            builder: (context, child) {
                              return Text(
                                'Sign up',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: _colorAnimation.value,
                                ),
                              );
                            },
                          ),
                        ),
                        const TextSpan(
                          text: ' to track your habits and achieve your goals',
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    children: [
                      // Email input field
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: const TextStyle(fontSize: 18),
                          filled: true,
                          fillColor: Colors.grey[300],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      // Username input field
                      TextField(
                        controller: usernameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Username',
                          hintStyle: const TextStyle(fontSize: 18),
                          filled: true,
                          fillColor: Colors.grey[300],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Password input field
                      TextField(
                        controller: passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: const TextStyle(fontSize: 18),
                          filled: true,
                          fillColor: Colors.grey[300],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Confirm Password input field
                      TextField(
                        controller: passwordConfirmController,
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          hintStyle: const TextStyle(fontSize: 18),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Sign Up Button
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                           // Validate input fields
                            String email = emailController.text.trim();
                            String username = usernameController.text.trim();
                            String password =passwordController.text.trim();
                            String confirmPassword = passwordConfirmController.text.trim();

                            // Basic validation checks
                            if (email.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                              setState(() {
                                _message = 'Please fill in all fields correctly';
                                _messageColor = Colors.red;
                              });
                              return;
                            }

                            if (confirmPassword != password) {
                              setState(() {
                                _message = 'Passwords do not match';
                                _messageColor = Colors.red;
                              });
                              return;
                            }

                            setState(() {
                              _isLoading = true;
                              _message = '';
                            });

                            // Attempt to sign up the user
                            await userProvider.signUpUser(
                              email: email,
                              password: password,
                              username: username,
                              confirmPassword: confirmPassword,
                              context: context,
                            );

                            // Handle success and error messages directly after the await
                            setState(() {
                              _isLoading = false;
                              if (userProvider.errorMessage.isNotEmpty) {
                                _message = userProvider.errorMessage;
                                _messageColor = Colors.red;
                              } else {
                                _message = 'Sign up successful. Please verify your email.';
                                _messageColor = Colors.green;
                              }
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Color.fromRGBO(134, 41, 137, 1.0)),
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(vertical: 16),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                     
                      // Display error or success message
                      Text(
                        _message,
                        style: TextStyle(
                          color: _messageColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      // Navigation to login screen
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?',
                            style: TextStyle(fontSize: 20),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: const Text(
                              'Log in',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(46, 197, 187, 1.0),
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]
            ),
          ),
          // Show loading indicator if _isLoading is true
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
