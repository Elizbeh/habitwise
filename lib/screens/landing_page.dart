import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  final VoidCallback onThemeChanged;
  final ValueNotifier<ThemeMode> themeNotifier;

  LandingPage({required this.onThemeChanged, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    // MediaQuery to adapt layout based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Plain Background
          Container(
            color: Colors.transparent, // Set to transparent
          ),
          // Content
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.05), // Responsive height
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
                        width: screenWidth * 0.2, // Responsive width
                        height: screenWidth * 0.2, // Responsive height
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02), // Responsive height
                // Animated Title
                AnimatedTitle(),
                SizedBox(height: screenHeight * 0.03), // Responsive height
                // Subtitle
                AnimatedSubtitle(),
                SizedBox(height: screenHeight * 0.05), // Responsive height
                // Call-to-Action Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, // Text color
                    backgroundColor: Color.fromRGBO(126, 35, 191, 0.498), // Button background color
                    elevation: 2,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.1, // Responsive width
                      vertical: screenHeight * 0.02, // Responsive height
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
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
                SizedBox(height: screenHeight * 0.05), // Responsive height
                // New Sections
                _buildHeroSection(),
                _buildFeaturesSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.zero,
          child: Image.asset(
            'assets/images/hero_image.png',
            width: double.infinity,
            height: 320.0,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 16.0),
        Text(
          'Discover Amazing Features',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(126, 35, 191, 0.498), // Hero section title color
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
          _buildFeatureItem('Track Your Habits', 'Easily track your daily habits and progress.'),
          _buildFeatureItem('Set Achievable Goals', 'Set and achieve your personal goals.'),
          _buildFeatureItem('Analyze Your Progress', 'Get insights into your habit patterns.'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return ListTile(
      leading: Icon(Icons.star, color: Color.fromRGBO(126, 35, 191, 0.498)), // Icon color
      title: Text(
        title,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        description,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}

class AnimatedTitle extends StatefulWidget {
  @override
  _AnimatedTitleState createState() => _AnimatedTitleState();
}

class _AnimatedTitleState extends State<AnimatedTitle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation = Tween<Offset>(
      begin: Offset(1.0, 0.0), // Start from the right
      end: Offset.zero,
    ).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Welcome to ',
              style: TextStyle(
                color: Color.fromRGBO(126, 35, 191, 0.498), // Title color
                fontSize: MediaQuery.of(context).size.width * 0.08, // Responsive font size
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: 'HabitWise',
              style: TextStyle(
                color: Color.fromRGBO(126, 35, 191, 0.498), // Title color
                fontSize: MediaQuery.of(context).size.width * 0.1, // Responsive font size
                fontWeight: FontWeight.bold,
                fontFamily: 'Billabong', // Custom font for "HabitWise"
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedSubtitle extends StatefulWidget {
  @override
  _AnimatedSubtitleState createState() => _AnimatedSubtitleState();
}

class _AnimatedSubtitleState extends State<AnimatedSubtitle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation = Tween<Offset>(
      begin: Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Text(
        'Develop habits. Achieve goals. Transform your life.',
        style: TextStyle(
          color: Color.fromARGB(255, 93, 156, 164), // Subtitle color
          fontWeight: FontWeight.bold,
          fontSize: MediaQuery.of(context).size.width * 0.05, // Responsive font size
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
