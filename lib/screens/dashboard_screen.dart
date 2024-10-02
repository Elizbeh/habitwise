import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/models/user.dart';
import 'package:habitwise/providers/group_provider.dart';
import 'package:habitwise/providers/habit_provider.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:habitwise/providers/quote_provider.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/screens/goals_screen.dart';
import 'package:habitwise/screens/habit_screen.dart';
import 'package:habitwise/screens/profile_screen.dart';
import 'package:habitwise/screens/group/create_group_screen.dart';
import 'package:habitwise/widgets/geometricBorder.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../widgets/goalPie_chart_widget.dart';
import '../widgets/habitPie_chart_widget.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../main.dart';

const List<Color> appBarGradientColors = [
    Color.fromRGBO(134, 41, 137, 1.0),
    Color.fromRGBO(181, 58, 185, 1),
    Color.fromRGBO(46, 197, 187, 1.0),
];

class DashboardScreen extends StatefulWidget {
  final HabitWiseUser user;
  final String groupId;

  DashboardScreen({required this.user, required this.groupId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isFirstLogin = true;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
     _checkFirstLogin();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
    // Fetch the quote after a slight delay to ensure the widget is built
    Future.delayed(Duration.zero, () {
      Provider.of<QuoteProvider>(context, listen: false).fetchQuote();
  });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }
  Future<void> _checkFirstLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstLogin = prefs.getBool('isFirstLogin_${widget.user.uid}');
    
    if (isFirstLogin == null || isFirstLogin) {
      setState(() {
        _isFirstLogin = true;
      });
      // Set the flag to false after the first login
      await prefs.setBool('isFirstLogin_${widget.user.uid}', false);
    } else {
      setState(() {
        _isFirstLogin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        toolbarHeight: 80,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset('assets/images/logo.png'),
              ),
            ),
            const SizedBox(width: 8), // Space between logo and title
            Expanded(
              child: Text(
                'HabitWize',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
            ),
          ],
        ),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            gradient: LinearGradient(
              colors: appBarGradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
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
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
      
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 16.0),
              child: Consumer2<HabitProvider, GoalProvider>(
                builder: (context, habitProvider, goalProvider, child) {
                  final List<Habit> habits = habitProvider.personalHabits;
                  final List<Goal> goals = goalProvider.goals;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Stack(
                          children: [
                            Text(
                              _isFirstLogin
                                ? 'Welcome, ${widget.user.username}!'
                                : 'Good to see you again, ${widget.user.username}!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: ConfettiWidget(
                                confettiController: _confettiController,
                                blastDirection: 3.14, // Confetti will go to the left
                                emissionFrequency: 0.05,
                                numberOfParticles: 10,
                                gravity: 0.1,
                                colors: [
                                Color.fromRGBO(134, 41, 137, 1.0),
                                Color.fromRGBO(181, 58, 185, 1),
                                Color.fromRGBO(46, 197, 187, 1.0),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.0),
                        _buildQuoteSection(),
                        SizedBox(height: 20.0),
                        _buildGroupSection(context),
                        SizedBox(height: 20.0),
                        if (habits.isNotEmpty || goals.isNotEmpty) ...[
                           _buildOverview(habits, goals),
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
                MaterialPageRoute(builder: (context) => HabitScreen(user: widget.user, groupId: widget.groupId)),
              );
            } else if (index == 3) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user)),
              );
            }
          }
        },
          themeNotifier: appThemeNotifier,
      ),
    
    );
  }

  Widget _buildGroupSection(BuildContext context) {
  return Consumer<GroupProvider>(
    builder: (context, groupProvider, child) {
      List<HabitWiseGroup> joinedGroups = groupProvider.groups;

      return Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Groups',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            if (joinedGroups.isNotEmpty)
              SizedBox(
                height: 250.0,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: joinedGroups.length,
                  separatorBuilder: (context, index) => SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    HabitWiseGroup group = joinedGroups[index];
                    return _buildGroupCard(context, group, groupProvider);
                  },
                ),
              )
            else
              Text(
                'No joined groups',
                style: TextStyle(color: Color.fromRGBO(46, 197, 187, 1.0)),
              ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => CreateGroupScreen()),
                    );
                  },
                  child: Text('Create a group'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(46, 197, 187, 1.0),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showJoinGroupDialog(context, groupProvider);
                  },
                  child: Text('Join a group'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(134, 41, 137, 1.0),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

  void _showJoinGroupDialog(BuildContext context, GroupProvider groupProvider) {
    final TextEditingController groupCodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Join a Group'),
          content: TextField(
            controller: groupCodeController,
            decoration: InputDecoration(hintText: "Enter Group Code"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String groupCode = groupCodeController.text.trim();
                if (groupCode.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a group code.')),
                  );
                  return;
                }

                // Call the join group method
                groupProvider.joinGroup(groupCode, widget.user.uid).then((success) {
                  if (success) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Joined group successfully!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to join group.')),
                    );
                  }
                });
              },
              child: Text('Join'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGroupCard(
    BuildContext context, HabitWiseGroup group, GroupProvider groupProvider) {
  return Stack(
    children: [
      InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            '/groupDetails',
            arguments: {
              'groupId': group.groupId,
              'user': Provider.of<UserProvider>(context, listen: false).user, // Directly get user
            },
          );
        },
        child: Container(
          width: 250.0,
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: Color.fromRGBO(46, 197, 187, 1.0), // Border color
              width: 2.0, // Border width
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                group.groupName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              CircleAvatar(
                radius: 40,
                backgroundImage: group.groupPictureUrl != null
                    ? NetworkImage(group.groupPictureUrl!)
                    : AssetImage('assets/images/default_profilePic.png')
                        as ImageProvider,
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_rounded,
                      color: Colors.grey),
                  SizedBox(width: 5.0),
                  Text(
                    'Members: ${group.members.length}',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      '/groupDetails',
                      arguments: group,
                    );
                  },
                  child: Text('View Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(46, 197, 187, 1.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: IconButton(
          icon: Icon(Icons.close, color: Color.fromARGB(255, 236, 132, 124)),
          onPressed: () {
            final userId = Provider.of<UserProvider>(context, listen: false).user?.uid;
            if (group.groupCreator == userId) {
              // If user is the creator, delete the group
              groupProvider.deleteGroup(group.groupId);
            } else {
              // If user is not the creator, leave the group
              groupProvider.leaveGroup(group.groupId, userId!);
            }
          },
        ),
      ),
    ],
  );
}

  Widget _buildOverview(List<Habit> habits, List<Goal> goals) {
  return Container(
    height: 400,
    padding: EdgeInsets.symmetric(horizontal: 16.0),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Goals Overview
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            margin: EdgeInsets.only(right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Goals Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 26.0),
                Container(
                  height: 250, // Set a fixed height
                  child: GoalPieChartWidget(goals: goals),
                ),
              ],
            ),
          ),
          // Habits Overview
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Habits Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  height: 250, // Set a fixed height
                  child: PieChartWidget(habits: habits),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}

Widget _buildQuoteSection() {
    return Consumer<QuoteProvider>(
      builder: (context, quoteProvider, child) {
        return GeometricBorderContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Quote of the Day',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                quoteProvider.quote,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.blueGrey[700],
                ),
              ),
            ],
          ),
        );
      },
    );
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
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            height: 200,
            width: double.infinity, 
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40.0),
              image: DecorationImage(
                image: AssetImage('assets/images/backgroundImg.png'),
                fit: BoxFit.fill,
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
