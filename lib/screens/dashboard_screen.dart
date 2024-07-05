import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/models/user.dart';
import 'package:habitwise/providers/group_provider.dart';
import 'package:habitwise/providers/habit_provider.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/screens/goals_screen.dart';
import 'package:habitwise/screens/habit_screen.dart';
import 'package:habitwise/screens/profile_screen.dart';
import 'package:habitwise/screens/group/create_group_screen.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../widgets/goalPie_chart_widget.dart';
import '../widgets/habitPie_chart_widget.dart';
import '../widgets/bottom_navigation_bar.dart';

// Define the gradient colors as constants
const List<Color> appBarGradientColors = [
  Color.fromRGBO(126, 35, 191, 0.498),
  Color.fromRGBO(126, 35, 191, 0.498),
  Color.fromARGB(57, 181, 77, 199),
  Color.fromARGB(233, 93, 59, 99),
];

class DashboardScreen extends StatefulWidget {
  final HabitWiseUser user;

  DashboardScreen({required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

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
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            gradient: LinearGradient(
              colors: appBarGradientColors,
              begin: Alignment.bottomCenter,
              end: Alignment.topLeft,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Adjust the blur intensity as needed
              child: Container(
                color: Colors.transparent,
              ),
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
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Consumer2<HabitProvider, GoalProvider>(
                builder: (context, habitProvider, goalProvider, child) {
                  final List<Habit> habits = habitProvider.habits;
                  final List<Goal> goals = goalProvider.goals;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Stack(
                          children: [
                            Text(
                            'Welcome, ${widget.user.username}!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Positioned(
                              top: 0,
                              right: 0,
                              child: ConfettiWidget(
                                confettiController: _confettiController,
                                blastDirection: 3.14, // Confetti will go to the left
                                emissionFrequency: 0.05, // How often it should emit confetti
                                numberOfParticles: 15, // Number of confetti
                                gravity: 0.1, // Speed of falling confetti
                                colors: [
                                 Colors.grey,
                                  Colors.purple,
                                  Colors.yellow,
                                  
                                ], // Colors of confetti
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 20.0),
                        _buildGroupSection(context),
                        SizedBox(height: 20.0),
                        if (habits.isNotEmpty || goals.isNotEmpty) ...[
                          _buildGoalsOverview(goals),
                          SizedBox(height: 20.0),
                          _buildHabitsOverview(habits),
                        ] else ...[
                          PlaceholderWidget(),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: 0, // DashboardScreen is at index 0
        onTap: (index) {
          if (index != 0) {
            if (index == 1) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => GoalScreen(user: widget.user)),
              );
            } else if (index == 2) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HabitScreen(user: widget.user)),
              );
            } else if (index == 3) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user)),
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: appBarGradientColors,
              begin: Alignment.bottomCenter,
              end: Alignment.topLeft,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Groups',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 10),
              if (joinedGroups.isNotEmpty)
                SizedBox(
                  height: 200.0,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: joinedGroups.length,
                    separatorBuilder: (context, index) => SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      HabitWiseGroup group = joinedGroups[index];
                      return Stack(
                        children: [
                          Card(
                            margin: EdgeInsets.symmetric(horizontal: 8.0),
                            child: InkWell(
                              onTap: () {
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
                                  SizedBox(height: 20.0),
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
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.close, color: const Color.fromARGB(255, 236, 132, 124)),
                              onPressed: () {
                                // Check if the current user is the goal creator
                                if (group.groupCreator == widget.user.uid) {
                                  // If user is the creator, delete the group
                                  groupProvider.deleteGroup(group.groupId);
                                } else {
                                  // If user is not the creator, remove the group for the user
                                  groupProvider.removeGroup(group.groupId);
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                )
              else
                Text(
                  'No joined groups',
                  style: TextStyle(color: Colors.white),
                ),
              SizedBox(height: 10),
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

    Widget _buildGoalsOverview(List<Goal> goals) {
    return Container(
      height: 400,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Text(
            'Your Goals Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Expanded(child: GoalPieChartWidget(goals: goals)),
        ],
      ),
    );
  }

  Widget _buildHabitsOverview(List<Habit> habits) {
    return Container(
      height: 400,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Text(
            'Your Habits Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Expanded(child: PieChartWidget(habits: habits)),
        ],
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Your progress and statistics will be displayed here.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
          child: Container(
            height: 300, // Set the height you want
            width: 300, // Set the width you want
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40.0),
              image: DecorationImage(
                image: AssetImage('assets/images/backgroundImg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(height: 20.0),
        Text(
          'No habits or goals to display.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 10.0),
        Text(
          'Start creating your habits and goals to see your progress here.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
