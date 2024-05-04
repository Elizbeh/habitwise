import 'package:flutter/material.dart';
import 'package:habitwise/models/user.dart';

class DashboardScreen extends StatelessWidget {
  final HabitWiseUser user;
  
  DashboardScreen({required this.user});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome back, ${user.username}!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            //Add visualizaation element
            // my actual data visualization widgets goes here
            Text(
              'Your progress and statistics will be displayed here.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                //Navigate to goals screen
              },
              child: Text('View Goals'),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                //Navigate to habits screen
              },
              child: Text('View Habit'),
            ),
          ],
        ),
      ),
    );
  }
}