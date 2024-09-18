import 'package:flutter/material.dart';

class GeometricBorderContainer extends StatelessWidget {
  final Widget child;

  GeometricBorderContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    // Getting the full width of the screen
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      // Set width to full screen width
      width: screenWidth,
      padding: EdgeInsets.all(16.0), // Padding around the container
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(134, 41, 137, 1.0),
            Color.fromRGBO(181, 58, 185, 1),
            Color.fromRGBO(46, 197, 187, 1.0),
          ],
          begin: Alignment.centerRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ClipPath(
        clipper: GeometricClipper(),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(20.0), // Padding inside the geometric shape
          child: child,
        ),
      ),
    );
  }
}

class GeometricClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double width = size.width;
    final double height = size.height;

    path.moveTo(0, height * 0.2);
    path.lineTo(width * 0.2, 0);
    path.lineTo(width * 0.8, 0);
    path.lineTo(width, height * 0.2);
    path.lineTo(width, height * 0.8);
    path.lineTo(width * 0.8, height);
    path.lineTo(width * 0.2, height);
    path.lineTo(0, height * 0.8);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
