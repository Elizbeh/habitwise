import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:habitwise/themes/theme.dart';  // Adjust the path if needed

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
        toolbarHeight: 300, // Increased height for a more prominent effect
        centerTitle: false,
        flexibleSpace: Container(
           height: 300, 
          child: Stack(
            children: [
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(80),
                  ),
                  gradient: LinearGradient(
                    colors: appBarGradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              // Blurred effect
              ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(80),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              // Background image
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 210,
                    height: 180,
                    child: Image.asset(
                      'assets/images/app_img.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              // Logo
              Positioned(
                top: 150,
                left: 20,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset('assets/images/logo.png'),
                  ),
                ),
              ),
              // App Title
              Positioned(
                top: 160, // Lower than the logo to avoid overlap
                left: 80, // Position the title next to the logo
                child: Text(
                  'HabitWize',
                  style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
              ),
              // Welcome text
              Positioned(
                top: 220, // Adjust this position based on your layout
                left: 20,
                right: 20,
                child: Text(
                  _isFirstLogin
                    ? 'Welcome, ${widget.user.username}!'
                    : 'Welcome Back, ${widget.user.username}!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 250, 229, 41), // Adjust the text color for visibility
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ],
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
      body: SafeArea(
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 2.0),
    child: Consumer2<HabitProvider, GoalProvider>(
      builder: (context, habitProvider, goalProvider, child) {
        final List<Habit> habits = habitProvider.personalHabits;
        final List<Goal> goals = goalProvider.goals;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Confetti Widget
              Align(
                alignment: Alignment.topRight,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: 3.14, // Confetti to the left
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
              // Quote Section
              _buildQuoteSection(),
              SizedBox(height: 20.0),

              // Group Section
              _buildGroupSection(context),
              SizedBox(height: 20.0),

              // Overview Section for Habits and Goals
              if (habits.isNotEmpty || goals.isNotEmpty) 
                _buildOverview(habits, goals)
              else 
                PlaceholderWidget(),
            ],
          ),
        );
      },
    ),
  ),
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
       String userId = Provider.of<UserProvider>(context).user!.uid;

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
                      MaterialPageRoute(builder: (context) => CreateGroupScreen(user: widget.user)),
                    );
                  },
                  child: Text('Create a group'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(46, 197, 187, 1.0),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showJoinGroupDialog(context, groupProvider, userId);  // Pass userId here
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

  void _showJoinGroupDialog(BuildContext context, GroupProvider groupProvider, String userId) {
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
              groupProvider.joinGroup(groupCode, userId).then((success) {
                if (success) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Joined group successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to join group. Please check the group code and try again.')),
                  );
                }
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $error')),
                );
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
  final theme = Theme.of(context);

  return Stack(
    children: [
      InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            '/groupDetails',
            arguments: {
              'groupId': group.groupId,
              'user': Provider.of<UserProvider>(context, listen: false).user,
            },
          );
        },
        child: Container(
          width: 250.0,
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: theme.colorScheme.secondary,
              width: 2.0,
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
                style: theme.textTheme.titleMedium,
              ),
              SizedBox(height: 10.0),
              CircleAvatar(
                radius: 40,
                backgroundImage: group.groupPictureUrl != null
                    ? NetworkImage(group.groupPictureUrl!)
                    : AssetImage('assets/images/default_profilePic.png') as ImageProvider,
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_rounded, color: Colors.grey),
                  SizedBox(width: 5.0),
                  Text('Members: ${group.members.length}', style: theme.textTheme.bodyMedium),
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
                    backgroundColor: theme.colorScheme.secondary,
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
            // Removing the logic that checks if the user is the creator
            groupProvider.leaveGroup(group.groupId, userId!);
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
      // Accessing the current theme's colors
      final theme = Theme.of(context);
      
      return GeometricBorderContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Quote of the Day',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground, // Use theme color for text
              ) ?? TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800], // Fallback color
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              quoteProvider.quote,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onBackground.withOpacity(0.7), // Use theme color for text
              ) ?? TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.blueGrey[700], // Fallback color
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
    final theme = Theme.of(context); // Accessing the current theme

    return Column(
      children: [
        Text(
          'Your progress and statistics will be displayed here.',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ) ?? TextStyle(
            fontSize: 16, // Fallback font size
            fontWeight: FontWeight.bold,
          ),
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
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground.withOpacity(0.7), // Use theme color
          ) ?? TextStyle(
            fontSize: 18, // Fallback font size
            fontWeight: FontWeight.bold,
            color: Colors.grey, // Fallback color
          ),
        ),
        SizedBox(height: 10.0),
        Text(
          'Start creating your habits and goals to see your progress here.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.6), // Use theme color
          ) ?? TextStyle(
            fontSize: 16, // Fallback font size
            color: Colors.grey, // Fallback color
          ),
        ),
      ],
    );
  }
}
