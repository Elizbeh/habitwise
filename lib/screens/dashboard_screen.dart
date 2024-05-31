import 'package:flutter/material.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/models/user.dart';
import 'package:habitwise/providers/habit_provider.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/providers/group_provider.dart';
import 'package:habitwise/screens/goals_screen.dart';
import 'package:habitwise/screens/habit_screen.dart';
import 'package:habitwise/screens/group/create_group_screen.dart';
import 'package:habitwise/screens/profile_screen.dart';
import 'package:provider/provider.dart';
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
        backgroundColor: Color.fromRGBO(126, 35, 191, 0.498),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<UserProvider>(context, listen: false).logoutUser();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
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
                  // Group section
                  _buildGroupSection(context),
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
        currentIndex: 0, //DashboardScreen is at index 0
        onTap: (index) {
          if (index != 0) {
            if (index == 1) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => GoalScreen(user: user)),
              );
            } else if (index == 2) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HabitScreen(user: user)),
              );
            } else if (index == 3) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ProfilePage(user: user)),
              );
            }
          }
        }, 
      ),
    );
  }

  Widget _buildGroupSection(BuildContext context) {
  return Consumer<GroupProvider>(
    builder: (context, groupProvider, child) {
      List<HabitWiseGroup> joinedGroups = groupProvider.groups;

      return Container(
        padding: EdgeInsets.all(10.0),
        color: Colors.grey[200],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Groups',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Display joined groups using GridView
            if (joinedGroups.isNotEmpty)
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2, // Number of columns in the grid
                crossAxisSpacing: 10.0, // Spacing between columns
                mainAxisSpacing: 10.0, // Spacing between rows
                children: joinedGroups.map((group) {
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        // Navigate to group details screen or perform action
                        Navigator.pushNamed(
                          context,
                          '/groupDetails',
                          arguments: {'groupId': group.groupId},
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(group.groupName),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/groupDetails',
                                arguments: group.groupId,
                              );
                            },
                            child: Text('View Details'),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              )
            else
              Text(
                'No joined groups',
                style: TextStyle(color: Color.fromRGBO(126, 35, 191, 0.498)),
              ),
            SizedBox(height: 10),
            // Button to navigate to create group screen
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CreateGroupScreen()),
                );
              },
              child: Text('Create a group'),
            ),
          ],
        ),
      );
    },
  );
}
}