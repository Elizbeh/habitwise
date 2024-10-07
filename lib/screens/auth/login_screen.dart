import 'package:flutter/material.dart';
import 'package:habitwise/models/user.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../dashboard_screen.dart';
import '../../methods/auth_methods.dart';

class LoginScreen extends StatefulWidget {
  final Function(String username) onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final AuthMethod _authMethod = AuthMethod(); // Private instance of AuthMethod
  late TextEditingController _emailController; // Initialize email controller
  late TextEditingController _passwordController; // Initialize password controller
  bool obscureText = true; // Initial state for password field
  bool _isLoading = false; // Initial state for loading indicator
  bool _isHovering = false; // Initial state for hover
  String _message = ''; // Variable to hold 
  Color _messageColor = Colors.transparent;

  late AnimationController _animationController; // Animation controller
  late Animation<double> _opacityAnimation; // Opacity animation

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(); // Instantiate email controller
    _passwordController = TextEditingController(); // Instantiate password controller

    // Initialize animation controller
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose(); // Dispose controllers to avoid memory leaks
    _passwordController.dispose();
    _animationController.dispose(); // Dispose the animation controller
    super.dispose();
  }

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
                    color: Color.fromRGBO(134, 41, 137, 1.0),
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Image.asset(
                  'assets/images/logo.png',
                  width: 60,
                  height: 60,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: const Text(
                      'Build habits, reach goals. Log in to begin.',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Tooltip(
                        message: 'Enter your email address',
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: const TextStyle(
                              fontSize: 18,
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
                          controller: _passwordController,
                          obscureText: obscureText,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: const TextStyle(
                              fontSize: 18,
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
                      _buildLoginButton(context),
                      const SizedBox(height: 24),
                      _buildFooterButtons(context),
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

  Widget _buildLoginButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: InkWell(
          onTap: _isLoading ? null : () => _handleLogin(context),
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
    );
  }

  Widget _buildFooterButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Forgot your login details?", style: TextStyle(fontSize: 16),),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/forgot_password');
              },
              child: const Text(
                'Get help logging in',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color.fromRGBO(46, 197, 187, 1.0),
                ),
              ),
            ),
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account?", style: TextStyle(fontSize: 18),),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: const Text(
                'Sign up',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Color.fromRGBO(134, 41, 137, 1.0),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleLogin(BuildContext context) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

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

    AuthResult loginResult = await _authMethod.login(
      email: email,
      password: password,
    );

    if (loginResult == AuthResult.success) {
      UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.getUserDetails();
      HabitWiseUser? user = userProvider.user;

      if (user != null && user.emailVerified) {
        await userProvider.fetchUserGroups();
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
          _message = 'Please verify your email to log in';
          _messageColor = Colors.red;
        });
      }
    } else {
      setState(() {
        _message = 'Login failed. Please try again.';
        _messageColor = Colors.red;
      });
    }

    setState(() {
      _isLoading = false; // Reset loading state
    });
  }
}
