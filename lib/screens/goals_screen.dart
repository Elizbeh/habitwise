import 'package:flutter/material.dart';
import 'package:habitwise/models/user.dart';

class GoalsScreen extends StatelessWidget {
  final HabitWiseUser user;

  GoalsScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Goals'),
      ),
      body: ListView.builder(
        itemCount: user.goals.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(user.goals[index]),
            //more details or actions for each goal
          );
        },
      ),
    );
  }
}