import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:habitwise/screens/group/group_details_screen.dart';
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
  late GroupProvider groupProvider;
  late UserProvider userProvider;

  int _selectedIndex = 0;

   // Method to handle navigation rail and bottom navigation selection changes
  void _onNavigationRailSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 1:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => GoalScreen(user: widget.user)),
        );
        break;
      case 2:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HabitScreen(user: widget.user, groupId: widget.groupId)),
        );
        break;
      case 3:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user)),
        );
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _checkFirstLogin();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();

    // Fetch the quote after a slight delay to ensure the widget is built
    Future.delayed(Duration.zero, () {
      Provider.of<QuoteProvider>(context as BuildContext, listen: false).fetchQuote();
    });

    // Fetch providers
    groupProvider = Provider.of<GroupProvider>(context as BuildContext, listen: false);
    userProvider = Provider.of<UserProvider>(context as BuildContext, listen: false);
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    try {
      await groupProvider.fetchGroups(userProvider.currentUser!.uid);
    } catch (e) {
      if (mounted) {
        showSnackBar(context as BuildContext, 'Error fetching groups: $e', isError: true);
      }
    }
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
    final isLargeScreen = MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;
    final useNavigationRail = isLargeScreen || screenWidth > 600;
    final logoSize = isLargeScreen ? 60.0 : 40.0; // Increase logo size for large screens



    // Set heights based on orientation
    final appBarHeight = isLargeScreen ? 200.0 : 300.0;
    final imageHeight = isLargeScreen ? 90.0 : 180.0;

    // Set font sizes based on orientation and screen width
    final titleFontSize = isLargeScreen ? 32.0 : 28.0;
    final welcomeFontSize = isLargeScreen ? 28.0 : 24.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        toolbarHeight: appBarHeight,
        centerTitle: false,
        flexibleSpace: Container(
          height: appBarHeight,
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
                    width: screenWidth * 0.35,
                    height: imageHeight,
                    child: Image.asset(
                      'assets/images/app_img.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              // Logo
              Positioned(
                top: appBarHeight * 0.5,
                left: 20,
                child: Container(
                  width: 40,
                  height: 40,
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
                top: appBarHeight * 0.5,
                left: 20,
                child: Container(
                  width: logoSize,
                  height: logoSize,
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
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: logoSize,
                      height: logoSize,
                      fit: BoxFit.contain, // Ensure the logo fits within the circle
                    ),
                  ),
                ),
              ),

              // App Title
              Positioned(
                top: appBarHeight * 0.5,
                left: 70,
                child: Text(
                  'HabitWize',
                  style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                    fontSize: titleFontSize, // Use the conditional font size
                    color: Colors.white,
                  ),
                ),
              ),         
              // Welcome text
              Positioned(
                top: appBarHeight * 0.75,
                left: 0,
                right: 0,
                child: Center(
                  child: _isFirstLogin
                      ? Text(
                          'Welcome, ${widget.user.username}!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: welcomeFontSize,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 250, 229, 41),
                          ),
                          textAlign: TextAlign.center, // Center text
                        )
                      : Text(
                          'Welcome Back, ${widget.user.username}!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: welcomeFontSize,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 250, 229, 41),
                          ),
                          textAlign: TextAlign.center, // Center text
                        ),
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
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.0),
            child: Consumer2<HabitProvider, GoalProvider>(
              builder: (context, habitProvider, goalProvider, child) {
                final List<Habit> habits = habitProvider.personalHabits;
                final List<Goal> goals = goalProvider.goals;

                return Row(
                  children: [
                    // Navigation Rail for larger screens
                    if (isLargeScreen)
                      NavigationRail(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: _onNavigationRailSelected,
                        labelType: NavigationRailLabelType.none,
                        extended: true,
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.dashboard),
                            label: Text('Dashboard'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.star),
                            label: Text('Goals'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.assignment),
                            label: Text('Habits'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.person),
                            label: Text('Profile'),
                          ),
                        ],
                      ),      
                      // Main content area
                      Expanded(
                        child: SafeArea(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.0),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Confetti Widget
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: ConfettiWidget(
                                      confettiController: _confettiController,
                                      blastDirection: 3.14,
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
                            ),
                          ),
                        ),
                      ),

                  ],
                );
              },
            ),
          ),
        
        ),
          // Show BottomNavigationBar only on smaller screens
        bottomNavigationBar: isLargeScreen
          ? null
          : BottomNavigationBarWidget(
              currentIndex: _selectedIndex,
              onTap: (index) {
                if (index != _selectedIndex) {
                  _onNavigationRailSelected(index);
                }
              },
              themeNotifier: appThemeNotifier,
            ), 
    );
  }


  Widget _buildGroupSection(BuildContext context) {
  return Consumer<GroupProvider>(
    builder: (context, groupProvider, child) {
      String userId = Provider.of<UserProvider>(context).currentUser!.uid;

      // Filter joined groups (user is a member but not the creator)
      List<HabitWiseGroup> joinedGroups = groupProvider.groups.where((group) {
        return group.creatorId != userId && group.memberIds.contains(userId);
      }).toList();

      // Filter created groups (user is the creator)
      List<HabitWiseGroup> createdGroups = groupProvider.groups.where((group) {
        return group.creatorId == userId;
      }).toList();

      return Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Your Groups',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,    
            ),
            SizedBox(height: 10),

            // Subtitle for Joined Groups
            if (joinedGroups.isNotEmpty)
              Text(
                'Groups You Joined 💪',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
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
                    return _buildGroupCard(context, group, groupProvider, true); // true for joined
                  },
                ),
              )
            else
              Text(
                'No joined groups 🚀',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600),
              ),

            SizedBox(height: 20), // Added spacing between sections

            // Subtitle for Created Groups
            if (createdGroups.isNotEmpty)
              Text(
                'Groups You Created',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            SizedBox(height: 10),
            if (createdGroups.isNotEmpty)
              SizedBox(
                height: 250.0,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: createdGroups.length,
                  separatorBuilder: (context, index) => SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    HabitWiseGroup group = createdGroups[index];
                    return _buildGroupCard(context, group, groupProvider, false); // false for created
                  },
                ),
              )
            else
              Text(
                'No created groups 💪',
                style: TextStyle(color: Theme.of(context).primaryColor), // Use primary color
              ),

            SizedBox(height: 20), // Additional spacing for clarity
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
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showJoinGroupDialog(context, groupProvider, userId);
                  },
                  child: Text('Join a group'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
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

  Widget _buildGroupCard(
    BuildContext context, HabitWiseGroup group, GroupProvider groupProvider, bool isJoined) {
      final theme = Theme.of(context);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;
      final isCreator = group.creatorId == currentUser?.uid;  // Check if current user is the group creator

      // Subtle background color for visual differentiation
      final backgroundColor = isCreator
      ? theme.colorScheme.primary.withOpacity(0.1)
      : theme.colorScheme.secondary.withOpacity(0.1);
      return Stack(
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                '/groupDetails',
                arguments: {
                  'groupId': group.groupId,
                  'user': currentUser,
                },
              );
            },
            child: Container(
              width: 200.0,
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: backgroundColor, // Apply background color based on group status
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
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 10.0),
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: group.groupPictureUrl != null && group.groupPictureUrl!.isNotEmpty
                        ? NetworkImage(group.groupPictureUrl!)
                        : const AssetImage('assets/images/default_profilePic.png') as ImageProvider,
                    backgroundColor: Colors.transparent, // Set background to transparent to avoid purple
                  ),
                
                  SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_rounded, color: Colors.grey),
                      SizedBox(width: 5.0),
                      Text('Members: ${group.members.length}', style: theme.textTheme.bodySmall),
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
                        textStyle: TextStyle(fontSize: 14)
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
            left: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: isJoined 
                    ? Icon(Icons.check_circle, color: Colors.green, size: 24.0,)
                    : Icon(Icons.star, color: Color.fromARGB(255, 236, 132, 124), size: 24.0),
                  onPressed: () {
                    // No action needed, just visual indicator
                  },
                ),
                
                IconButton(
                  icon: Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () {
                    if (isCreator) {
                      // Confirm group deletion
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Delete Group'),
                            content: Text('Are you sure you want to delete this group?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await groupProvider.deleteGroup(group.groupId, group.creatorId, currentUser!.uid);
                                  Navigator.of(context).pop();
                                },
                                child: Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (isJoined) {
                      // Confirm leaving the group
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Leave Group'),
                            content: Text('Are you sure you want to leave this group?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await groupProvider.leaveGroup(group.groupId, currentUser!.uid);
                                  Navigator.of(context).pop();
                                },
                                child: Text('Leave'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      );

}
  
  void _showJoinGroupDialog(BuildContext context, GroupProvider groupProvider, String userId) {
  final TextEditingController groupCodeController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      bool _isJoining = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Join a Group'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: groupCodeController,
                  decoration: InputDecoration(hintText: "Enter Group Code"),
                ),
                if (_isJoining)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  String groupCode = groupCodeController.text.trim();
                  if (groupCode.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a group code.')),
                    );
                    return;
                  }

                  setState(() {
                    _isJoining = true;
                  });

                  // Try to join the group
                  bool success = await groupProvider.joinGroup(groupCode, userId, context);

                  // Show the result
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? 'Joined group successfully!' : 'Failed to join group. Please check the group code and try again.')),
                  );

                  setState(() {
                    _isJoining = false;
                  });
                },
                child: Text('Join'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );
    },
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
            width: MediaQuery.of(context as BuildContext).size.width * 0.8,
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
                  height: 250,
                  child: GoalPieChartWidget(goals: goals),
                ),
              ],
            ),
          ),
          // Habits Overview
          Container(
            width: MediaQuery.of(context as BuildContext).size.width * 0.8,
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
                color: theme.colorScheme.onBackground,
              ) ?? TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 33, 43, 48), // Fallback color
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              quoteProvider.quote,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onBackground.withOpacity(0.7),
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
          style: theme.textTheme.bodyLarge?.copyWith(
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
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground.withOpacity(0.7), // Use theme color
          ) ?? TextStyle(
            fontSize: 20, // Fallback font size
            fontWeight: FontWeight.bold,
            color: Colors.black
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
