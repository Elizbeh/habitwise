import 'package:flutter/material.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/models/user.dart';
import 'package:habitwise/screens/goals_screen.dart';
import 'package:habitwise/screens/habit_screen.dart';
import 'package:habitwise/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:habitwise/providers/habit_provider.dart';
import '../widgets/line_chart_widget.dart';
import '../widgets/pie_chart_widget.dart';
import '../widgets/bottom_navigation_bar.dart';

class DashboardScreen extends StatelessWidget {
  final HabitWiseUser user;

  DashboardScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor:  Color.fromRGBO(126, 35, 191, 0.498),
      ),
      body: Center(
        child: Consumer<HabitProvider>(
          builder: (context, habitProvider, child) {
            final List<Habit> habits = habitProvider.habits;

            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome back, ${user.username}!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Your progress and statistics will be displayed here.',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.0),
                  if (habits.isNotEmpty)
                    Column(
                      children: [
                        Container(
                          height: 200,
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: LineChartWidget(habits: habits),
                        ),
                        SizedBox(height: 20.0),
                        Container(
                          height: 200,
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: PieChartWidget(habits: habits),
                        ),
                      ],
                    )
                  else
                    Text('No habits to display.'),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: 0, // Assuming DashboardScreen is at index 0
        onTap: (index) {
          if (index != 0) {
            if (index == 1) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => GoalScreen(user: user)), // Pass the user
              );
            } else if (index == 2) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HabitScreen(user: user)), // Pass the user
              );
            } else if (index == 3) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ProfilePage(user: user)), // Pass the user
              );
            }
          }
        }, 
      ),
    );
  }
}
