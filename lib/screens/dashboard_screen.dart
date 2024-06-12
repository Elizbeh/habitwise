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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        toolbarHeight: 80,
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(126, 35, 191, 0.498),
                Color.fromARGB(255, 222, 144, 236),
                Color.fromRGBO(126, 35, 191, 0.498),
                Color.fromARGB(57, 181, 77, 199),
                Color.fromARGB(255, 201, 5, 236)
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topLeft,
            ),
          ),
        ),
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<UserProvider>(context, listen: false).logoutUser();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Consumer<HabitProvider>(builder: (context, habitProvider, child) {
            final List<Habit> habits = habitProvider.habits;

            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome back, ',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${user.username}!',
                    style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Your progress and statistics will be displayed here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          }),
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
              // Display joined groups using ListView instead of GridView
              if (joinedGroups.isNotEmpty)
                SizedBox(
                  height: 200,
                  width: 150, // Set a fixed height for ListView
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: joinedGroups.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      HabitWiseGroup group = joinedGroups[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Stack(
                          children: [
                            InkWell(
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
                                  Icon(Icons.group_rounded),
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
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  // Provide a confirmation dialog before deleting the group
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Confirm Delete"),
                                        content: Text("Are you sure you want to delete this group?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // Delete the group when confirmed
                                              String groupId = group.groupId;
                                              Provider.of<GroupProvider>(context, listen: false).deleteGroup(groupId);
                                              Navigator.pop(context); // Close the dialog
                                            },
                                            child: Text("Delete"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
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
