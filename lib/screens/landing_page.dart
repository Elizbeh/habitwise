import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  final VoidCallback onThemeChanged;
  final ValueNotifier<ThemeMode> themeNotifier;

  LandingPage({required this.onThemeChanged, required this.themeNotifier});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/background_image.png',
            fit: BoxFit.cover, // Cover the whole screen
          ),
          // Black Overlay
          Container(
            color: Colors.black.withOpacity(0.6), // Black overlay with 80% opacity
          ),
          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Static Title
              Text(
                'Welcome to HabitWise',
                style: TextStyle(
                  color: Colors.white, // Change text color to white for better visibility
                  fontSize: screenWidth * 0.1, // Larger font size
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.02), // Responsive height
              // Logo App Name
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, // White background for the logo
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 4, // Outline width
                  ),
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0), // Padding inside the circle
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: screenWidth * 0.1, // Responsive width
                      height: screenWidth * 0.1, // Responsive height
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02), // Responsive height
              // Centered Typing Animated Subtitle with Lightbulb
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomAnimatedSubtitle(
                    animationDuration: Duration(seconds: 4),
                    text: 'HabitWise helps you build daily routines and achieve long-term goals. Track your progress, stay motivated, and collaborate on group goals and habits. Make every day count!',
                    lightbulbColor: Colors.amber, // Gold color for the lightbulb
                    textStyle: TextStyle(
                      color: Colors.white,
                      //fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.05, // Text size
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.1), // Responsive height
              // Call-to-Action Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, // Text color
                  backgroundColor: Color.fromRGBO(126, 35, 191, 0.498), // Button background color
                  elevation: 4, // Increased elevation
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.24, // Wider button
                    vertical: screenHeight * 0.02, // Responsive height
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(.0),
                  ),
                ),
                child: Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05, // Responsive font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              // New Sections
              //_buildHeroSection(),
              //_buildFeaturesSection(),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
          // Bottom Section
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromRGBO(126, 35, 191, 0.8), Color.fromRGBO(126, 35, 191, 0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)), // Rounded top corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, -3), // Shadow position
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '© 2024 HabitWise. All Rights Reserved.',
                    style: TextStyle(
                      color: Color.fromARGB(255, 210, 208, 208),
                      fontSize: 16, // Adjust font size as needed
                      
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Contact Us',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16, // Adjust font size as needed
                      fontWeight: FontWeight.bold,
                      
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Discover Amazing Features',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Change text color to white for better visibility
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0), // Padding for responsiveness
      child: Column(
        children: [
          //_buildFeatureItem('Track Your Habits', 'Easily track your daily habits and progress.'),
          //_buildFeatureItem('Set Achievable Goals', 'Set and achieve your personal goals.'),
         // _buildFeatureItem('Analyze Your Progress', 'Get insights into your habit patterns.'),
        ],
      ),
    );
  }*/

  Widget _buildFeatureItem(String title, String description) {
    return ListTile(
      leading: Icon(Icons.star, color: Colors.white), // Icon color
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Change text color to white
      ),
      subtitle: Text(
        description,
        style: TextStyle(color: Colors.white), // Change text color to white
      ),
    );
  }
}

class CustomAnimatedSubtitle extends StatefulWidget {
  final Duration animationDuration;
  final String text;
  final Color lightbulbColor;
  final TextStyle textStyle;

  CustomAnimatedSubtitle({
    required this.animationDuration,
    required this.text,
    required this.lightbulbColor,
    required this.textStyle,
  });

  @override
  _CustomAnimatedSubtitleState createState() => _CustomAnimatedSubtitleState();
}

class _CustomAnimatedSubtitleState extends State<CustomAnimatedSubtitle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Initialize the AnimationController with the provided duration
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Create a CurvedAnimation to apply a curve to the animation
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Calculate the number of characters to display based on the animation value
        final textLength = (widget.text.length * _animation.value).round();
        return Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: widget.textStyle,
              children: [
                // Animate the text to show up as if it's being typed
                TextSpan(
                  text: widget.text.substring(0, textLength),
                ),
                // Always show the lightbulb icon next to the text
                WidgetSpan(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Icon(
                      Icons.lightbulb,
                      color: widget.lightbulbColor,
                      size: widget.textStyle.fontSize! * 1.5, // Increase size to 1.5 times the text font size
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
