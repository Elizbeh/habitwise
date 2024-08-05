import 'package:flutter/material.dart';
import 'package:habitwise/methods/auth_methods.dart';

class SignUpScreen extends StatefulWidget {
  // Instances of controllers and callbacks required for sign-up
  final AuthMethod authMethod = AuthMethod();
  final Future<Null> Function(String username) onSignupSuccess;
  final TextEditingController emailController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmController;

  SignUpScreen({
    Key? key,
    required this.emailController,
    required this.usernameController,
    required this.passwordController,
    required this.passwordConfirmController,
    required this.onSignupSuccess,
  }) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  // State variables for password visibility, loading state, and error messages
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String _errorMessage = '';

  // Animation controller and color animation for the sign-up header
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller with a 3-second duration, repeating indefinitely
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Define a color animation that transitions between two colors
    _colorAnimation = ColorTween(
      begin: const Color.fromARGB(255, 93, 156, 164),
      end: const Color.fromRGBO(126, 35, 191, 0.498),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    // Dispose of the animation controller to free resources
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content of the screen wrapped in a SingleChildScrollView
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40.0),
                const Text(
                  'HabitWise',
                  style: TextStyle(
                    fontFamily: 'Billabong',
                    color: Color.fromRGBO(126, 35, 191, 0.498),
                    fontSize: 50,
                  ),
                ),
                Image.asset(
                  'assets/images/logo.png',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 93, 156, 164),
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
                                  fontSize: 30,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Email input field
                      TextField(
                        controller: widget.emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: const TextStyle(
                            fontSize: 22,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Username input field
                      TextField(
                        controller: widget.usernameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Username',
                          hintStyle: const TextStyle(
                            fontSize: 24,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Password input field with visibility toggle
                      TextField(
                        controller: widget.passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: const TextStyle(
                            fontSize: 24,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
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
                      const SizedBox(height: 18),
                      // Confirm Password input field with visibility toggle
                      TextField(
                        controller: widget.passwordConfirmController,
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          hintStyle: const TextStyle(
                            fontSize: 24,
                          ),
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
                      const SizedBox(height: 28),
                      // Sign-Up button
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () async {
                            // Retrieve user input
                            String email = widget.emailController.text.trim();
                            String username = widget.usernameController.text.trim();
                            String password = widget.passwordController.text.trim();
                            String confirmPassword = widget.passwordConfirmController.text.trim();

                            // Input validation
                            if (email.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter your email'),
                                ),
                              );
                              return;
                            }

                            if (username.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter your username'),
                                ),
                              );
                              return;
                            }

                            if (password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter your password'),
                                ),
                              );
                              return;
                            }

                            if (confirmPassword != password) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Passwords do not match'),
                                ),
                              );
                              return;
                            }

                            // Set loading state
                            setState(() {
                              _isLoading = true;
                              _errorMessage = '';
                            });

                            // Attempt to sign up the user
                            String result = '';
                            try {
                              AuthResult authResult = await widget.authMethod.signUpUser(
                                email: email,
                                username: username,
                                password: password,
                                confirmPassword: confirmPassword,
                              );
                              if (authResult == AuthResult.success) {
                                result = 'success';
                              } else {
                                result = 'An error occurred during sign up';
                              }
                            } catch (e) {
                              result = 'An error occurred during sign up';
                            }

                            setState(() async {
                              _isLoading = false;
                              if (result == 'success') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Sign up successful'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                await widget.onSignupSuccess(username);
                                Navigator.pushReplacementNamed(context, '/login');
                              } else {
                                _errorMessage = result;
                              }
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(126, 35, 191, 0.498)),
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
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                                            const SizedBox(height: 16),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 16),
                      // Link to the login page for users who already have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(fontSize: 18),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: const Text(
                              'Log in',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 93, 156, 164),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Display error message if there's any
                      if (_errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Display loading indicator while processing
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
