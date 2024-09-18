import 'package:flutter/material.dart';
import 'package:habitwise/models/user.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../dashboard_screen.dart';
import '../../methods/auth_methods.dart';

class LoginScreen extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Function(String username) onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onLoginSuccess,
  });

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthMethod _authMethod = AuthMethod(); // Private instance of AuthMethod
  bool obscureText = true; // Initial state for password field
  bool _isLoading = false; // Initial state for loading indicator
  bool _isHovering = false; // Initial state for hover
  String _message = ''; // Variable to hold 
  Color _messageColor = Colors.transparent;
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                const Text(
                  'HabitWise',
                  style: TextStyle(
                    color:Color.fromRGBO(134, 41, 137, 1.0),
                    fontWeight: FontWeight.bold,                  fontSize: 34,
                  ),
                ),
                SizedBox(height: 8),
                Image.asset(
                  'assets/images/logo.png',
                  width: 50,
                  height: 50,
                ),
                
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Build habits, reach goals. Log in to begin.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      if (_message.isNotEmpty)
                        Container(
                          color: _messageColor,
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            _message,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Tooltip(
                        message: 'Enter your email address',
                        child: TextField(
                          controller: widget.emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: const TextStyle(
                              fontSize: 16,
                            ),
                            filled: true,
                            fillColor: Colors.grey[300],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Tooltip(
                        message: 'Enter your password',
                        child: TextField(
                          controller: widget.passwordController,
                          obscureText: obscureText,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: const TextStyle(
                              fontSize: 16,
                            ),
                            filled: true,
                            fillColor: Colors.grey[300],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureText ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  obscureText = !obscureText;
                               });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: MouseRegion(
                          onEnter: (_) => setState(() => _isHovering = true),
                          onExit: (_) => setState(() => _isHovering = false),
                          child: InkWell(
                            onTap: _isLoading
                                ? null
                                : () async {
                                    String email = widget.emailController.text.trim();
                                    String password = widget.passwordController.text.trim();

                                    if (email.isEmpty || password.isEmpty) {
                                      setState(() {
                                        _message = 'Please fill in all fields';
                                        _messageColor = Colors.red;
                                      });
                                      return;
                                    }

                                    setState(() {
                                      _isLoading = true;
                                    });

                                    // Authenticate user using email and password
                                    AuthResult loginResult = await _authMethod.login(
                                      email: email,
                                      password: password,
                                    );

                                    if (loginResult == AuthResult.success) {
                                      UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
                                      HabitWiseUser? user = await userProvider.getUserDetails();

                                      if (user != null) {
                                        if (user.emailVerified) {
                                          await widget.onLoginSuccess(user.username);
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) => DashboardScreen(
                                                 user: user,
                                                groupId: user.groupIds.isNotEmpty ? user.groupIds[0] : '',
                                              ),
                                            ),
                                          );
                                        } else {
                                          setState(() {
                                            _message = 'Please verify your email address.';
                                            _messageColor = Colors.red;
                                          });
                                        }
                                      } else {
                                        setState(() {
                                          _message = 'User not found. Please sign up.';
                                          _messageColor = Colors.red;
                                        });
                                        Navigator.pushNamed(context, '/signup');
                                      }
                                    } else {
                                      setState(() {
                                        _message = _getErrorMessage(loginResult);
                                        _messageColor = Colors.red;
                                      });
                                    }

                                    setState(() {
                                      _isLoading = false;
                                    });
                                  },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                color: _isHovering
                                    ? Color.fromRGBO(46, 197, 187, 1.0)
                                    : Color.fromRGBO(134, 41, 137, 1.0),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: const Center(
                                child: Text(
                                  'Log in',
                                  style: TextStyle(color: Colors.white, fontSize: 24),
                                ),
                              ),
                            ),
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
                                fontSize: 14,
                                color: Color.fromRGBO(46, 197, 187, 1.0)
,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(fontSize: 18),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: const Text(
                              'Sign up',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color.fromRGBO(134, 41, 137, 1.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: Divider()),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "OR",
                              style: TextStyle(
                                color: Color.fromRGBO(46, 197, 187, 1.0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Implement Google sign-in logic here: TO DO
                        },
                        icon: Image.asset(
                          'assets/images/google_icon.png',
                          width: 24,
                          height: 24,
                          semanticLabel: 'Google logo',
                        ),
                        label: const Text(
                          'Sign in with Google',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
        ],
      ),
    );
  }

  // Helper method to get the error message
  String _getErrorMessage(AuthResult result) {
    switch (result) {
      case AuthResult.invalidInput:
        return 'Invalid email or password. Please try again.';
      case AuthResult.userNotFound:
        return 'User not found. Please check your credentials or sign up.';
      case AuthResult.wrongPassword:
        return 'Incorrect password. Please try again.';
      case AuthResult.userDisabled:
        return 'This account has been disabled. Please contact support.';
      case AuthResult.operationNotAllowed:
        return 'This operation is not allowed. Please contact support.';
      case AuthResult.tooManyRequests:
        return 'Too many login attempts. Please try again later.';
      case AuthResult.emailInUse:
        return 'This email is already in use. Please try a different one.';
      case AuthResult.weakPassword:
        return 'The password is too weak. Please try a stronger password.';
      case AuthResult.networkError:
        return 'A network error occurred. Please try again later.';
      case AuthResult.emailNotVerified:
        return 'Your email is not verified. Please verify it and try again.';
      default:
        return 'An unknown error occurred. Please try again.';
    }
  }
}
