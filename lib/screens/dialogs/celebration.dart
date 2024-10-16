import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';

class CombinedCelebrationDialog extends StatefulWidget {
  @override
  _CombinedCelebrationDialogState createState() =>
      _CombinedCelebrationDialogState();
}

class _CombinedCelebrationDialogState extends State<CombinedCelebrationDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 10));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Rounded corners
      ),
      elevation: 10,
      backgroundColor: Colors.transparent, // Make background transparent
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: 300, // Set the width of the dialog
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(134, 41, 137, 1.0),
              Color.fromRGBO(181, 58, 185, 1),
              Color.fromRGBO(46, 197, 187, 1.0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.1,
                numberOfParticles: 20,
                colors: [Colors.red, Colors.blue, Colors.green, Colors.yellow],
                child: Container(
                  height: 50,
                ),
              ),
            ),
            SizedBox(height: 20),
            Lottie.asset(
              'assets/dancing_celebration.json',
              width: 120,
              height: 120,
              fit: BoxFit.fill,
            ),
            SizedBox(height: 10),
            Text(
              "Congrats! A goal has been completed! 🎉",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Change text color to white for contrast
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, 
                backgroundColor: Color.fromRGBO(134, 41, 137, 1.0),
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('OK', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  void startCelebration() {
    _confettiController.play();
  }
}
