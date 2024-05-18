import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          FractionallySizedBox(
            alignment: Alignment.topCenter,
            heightFactor: 0.33,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/backgroundImg.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Gradient Background
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.33,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo or App Name
                const Text(
                  'HabitWise',
                  style: TextStyle(
                    fontFamily: 'Billabong',
                    color: Color.fromRGBO(181, 126, 220, 0.5),
                    fontSize: 50,
                  ),
                ),
                const SizedBox(height: 20.0),
                // Title
                const Text(
                  'Welcome to HabitWise',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10.0),
                // Subtitle
                AnimatedSubtitle(),
                const SizedBox(height: 40.0),
                // Action Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Color.fromRGBO(181, 126, 220, 0.5),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Text(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
          color: Colors.white,
          fontSize: 18.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
