import 'package:flutter/material.dart';

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50); // 50 is the curve height
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.26,
            child: Container(
              decoration: BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(126, 35, 191, 0.498),
                Color.fromARGB(255, 222, 144, 236),
                Color.fromRGBO(126, 35, 191, 0.498),
                Color.fromARGB(217, 155, 100, 179),
                Color.fromARGB(57, 181, 77, 199),
                Color.fromARGB(239, 128, 76, 154),
                Color.fromARGB(239, 128, 76, 154),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topLeft,
            ),
          ),
            ),
          ),
          // Background Image
          Positioned.fill(
            child: FractionallySizedBox(
              alignment: Alignment.topCenter,
              heightFactor: 0.38,
              child: ClipPath(
                clipper: BottomCurveClipper(),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/backgroundImg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
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
                const SizedBox(height: 200.0),
                // Logo App Name
                const Text(
                  'HabitWise',
                  style: TextStyle(
                    fontFamily: 'Billabong',
                    color: Colors.white,
                    fontSize: 50,
                  ),
                ),
                Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromRGBO(126, 35, 191, 0.498),
                  width: 4, // Outline width
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
                const SizedBox(height: 10.0),
                // Title
                const Text(
                  'Welcome to HabitWise',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15.0),
                // Subtitle
                AnimatedSubtitle(),
                const SizedBox(height: 40.0),
                // Action Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Color.fromRGBO(126, 35, 191, 0.498),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      elevation: 1,
                      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                    ),
                    child: Text(
                      'Get Started',
                      style: TextStyle(
                        color: Color.fromARGB(152, 151, 11, 251),
                        fontSize: 22.0,
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
                    fontSize: 20,
                  ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
