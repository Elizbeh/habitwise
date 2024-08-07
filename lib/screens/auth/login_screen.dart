import 'package:flutter/material.dart';
import 'package:habitwise/models/user.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../dashboard_screen.dart';
import '../../methods/auth_methods.dart';

class LoginScreen extends StatefulWidget {
  final Future<void> Function(String username) onLoginSuccess;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginScreen({
    Key? key,
    required this.emailController,
    required this.passwordController,
    required this.onLoginSuccess,
  }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthMethod _authMethod = AuthMethod(); // Private instance of AuthMethod
  bool obscureText = true; // Initial state for password field
  bool _isLoading = false; // Initial state for loading indicator
  bool _isHovering = false; // Initial state for hover

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'HabitWise',
                  style: TextStyle(
                    fontFamily: 'Billabong',
                    color: Color.fromRGBO(126, 35, 191, 0.498),
                    fontSize: 60,
                  ),
                ),
                Image.asset(
                  'assets/images/logo.png',
                  width: 80,
                  height: 80,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 28),
                      Tooltip(
                        message: 'Enter your email address',
                        child: TextField(
                          controller: widget.emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Email',
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
                      ),
                      const SizedBox(height: 24),
                      Tooltip(
                        message: 'Enter your password',
                        child: TextField(
                          controller: widget.passwordController,
                          obscureText: obscureText,
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
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please fill in all fields'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() {
                                      _isLoading = true;
                                    });

                                    // Authenticate user using email and password
                                    String loginResult = await _authMethod.login(
                                      email: email,
                                      password: password,
                                    );

                                    if (loginResult == 'success') {
                                      // If login is successful, retrieve user details
                                      HabitWiseUser? user = await _authMethod.getUserDetails();

                                      if (user != null) {
                                        // Retrieve group IDs for the user
                                        List<String> groupIds = user.groupIds; // Corrected this line

                                        // If user details are available, navigate to dashboard
                                        Provider.of<UserProvider>(context, listen: false).setUser(user);
                                        widget.onLoginSuccess(user.username);
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) => DashboardScreen(user: user, groupId: ''),
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
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
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
                                    ? Colors.cyan
                                    : Color.fromARGB(122, 126, 35, 191),
                                borderRadius: BorderRadius.circular(30),
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
                            style: TextStyle(fontSize: 16),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/forgot_password');
                            },
                            child: const Text(
                              'Get help logging in',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color.fromARGB(255, 93, 156, 164),
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
                                color: Color.fromRGBO(126, 35, 191, 0.498),
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
                                color: Color.fromARGB(255, 93, 156, 164),
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
            ),
        ],
      ),
    );
  }
}
