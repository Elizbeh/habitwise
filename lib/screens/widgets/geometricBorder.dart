import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GeometricBorderContainer extends StatelessWidget {
  final Widget child;

  GeometricBorderContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    // Getting the full width of the screen
    double screenWidth = MediaQuery.of(context).size.width;

    // Accessing the current theme's colors
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;

    return Container(
      width: screenWidth,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor, // Using primary color from theme
            secondaryColor, // Using secondary color from theme
            Color.fromRGBO(46, 197, 187, 1.0), // Use a custom color or define it in your theme
          ],
          begin: Alignment.centerRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ClipPath(
        clipper: GeometricClipper(),
        child: Container(
          color: theme.colorScheme.background, // Dynamically use theme background color
          padding: EdgeInsets.all(20.0),
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
