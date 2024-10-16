import 'dart:io';
import 'dart:ui';
import 'package:habitwise/main.dart';
import 'package:flutter/material.dart';
import 'package:habitwise/models/user.dart';
import 'package:habitwise/providers/habit_provider.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/screens/dashboard_screen.dart';
import 'package:habitwise/screens/dialogs/edit_profile_dialogue.dart';
import 'package:habitwise/screens/habit_screen.dart';
import 'package:habitwise/themes/theme.dart';
import 'package:provider/provider.dart';
import 'package:habitwise/widgets/bottom_navigation_bar.dart';

const List<Color> appBarGradientColors = [
    Color.fromRGBO(134, 41, 137, 1.0),
    Color.fromRGBO(181, 58, 185, 1),
    Color.fromRGBO(46, 197, 187, 1.0),
];


class ProfilePage extends StatefulWidget {
  final HabitWiseUser user;

  const ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Map<String, dynamic>> achievements = [];
  late HabitWiseUser _currentUser;



  @override
  void initState() {
    super.initState();
    _currentUser = widget.user; // Initialize the current user with the passed user
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateAchievements());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final habitProvider = Provider.of<HabitProvider>(context);
    final goalProvider = Provider.of<GoalProvider>(context);

    habitProvider.addListener(_onDataChanged);
    goalProvider.addListener(_onDataChanged);
  }

  
  @override
  void dispose() {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);

    habitProvider.removeListener(_onDataChanged);
    goalProvider.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) {
      _calculateAchievements();
    }
  }

  

  void _calculateAchievements() {
    print('Calculating achievements...');

    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);

    final completedHabits = habitProvider.personalHabits.where((habit) => habit.isCompleted).length;
    final completedGoals = goalProvider.goals.where((goal) => goal.isCompleted).length;

    print('Completed Habits: $completedHabits');
    print('Completed Goals: $completedGoals');

    List<Map<String, dynamic>> newAchievements = [];

    if (completedHabits >= 1) {
      newAchievements.add({
        'title': 'First Habit Completed',
        'icon': Icons.star,
        'color': Colors.amber,
      });
    }

    if (completedHabits >= 5) {
      newAchievements.add({
        'title': 'Habit Master',
        'icon': Icons.star_half,
        'color': Colors.amber[700],
      });
    }

    if (completedHabits >= 10) {
      newAchievements.add({
        'title': 'Habit Guru',
        'icon': Icons.star_border,
        'color': Colors.amber[900],
      });
    }

    if (completedGoals >= 1) {
      newAchievements.add({
        'title': 'First Goal Achieved',
        'icon': Icons.flag,
        'color': Colors.blue,
      });
    }

    if (completedGoals >= 5) {
      newAchievements.add({
        'title': 'Goal Achiever',
        'icon': Icons.flag_outlined,
        'color': Colors.blue[700],
      });
    }

    if (completedGoals >= 10) {
      newAchievements.add({
        'title': 'Goal Conqueror',
        'icon': Icons.flag_rounded,
        'color': Colors.blue[900],
      });
    }

    if (mounted) {
      setState(() {
        achievements.clear();
        achievements.addAll(newAchievements);
      });

      print('Achievements updated: $achievements');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        toolbarHeight: 100,
        titleSpacing: 0, // Set titleSpacing to 0 to close the gap
        title: Text(
                'Profile',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
          
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(50),
            ),
            gradient: LinearGradient(
              colors: appBarGradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(50),
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

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context),
                const SizedBox(height: 20),
                const Divider(color: Colors.grey, thickness: 1),
                _buildHabitStats(context),
                const SizedBox(height: 8),
                _buildGoalStats(context),
                const SizedBox(height: 8),
                _buildGamificationSection(context),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: 3, // DashboardScreen is at index 0
        onTap: (index) {
          if (index != 3) {
            if (index == 0) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => DashboardScreen(user: widget.user, groupId: '',)),
              );
            } else if (index == 2) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HabitScreen(user: widget.user, groupId: '', )),
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

  Widget _buildProfileHeader(BuildContext context) {
    final profilePictureUrl = _currentUser.profilePictureUrl ?? '';

    return GestureDetector(
      onTap: () => _navigateToEditProfile(context), // Handle taps on the entire profile header
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _navigateToEditProfile(context),
              child: CircleAvatar(
                radius: 60,
                backgroundImage: profilePictureUrl.isNotEmpty
                    ? NetworkImage(profilePictureUrl)
                    : const AssetImage('assets/images/default_profilePic.png') as ImageProvider,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentUser.username,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentUser.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
              onPressed: () => _navigateToEditProfile(context),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: _currentUser), // Pass user object to EditProfileScreen
      ),
    ).then((updatedUser) {
      // If the user updates their profile, update the profile info
      if (updatedUser != null && updatedUser is HabitWiseUser) {
        setState(() {
          _currentUser = updatedUser;
        });
      }
    });
  }

  Widget _buildHabitStats(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        final totalHabits = provider.personalHabits.length;
        final completedHabits = provider.personalHabits.where((habit) => habit.isCompleted).length;
        final inProgressHabits = totalHabits - completedHabits;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habits',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total', totalHabits, Colors.blue),
                                _buildStatCard('Completed', completedHabits, Colors.green),
                _buildStatCard('In Progress', inProgressHabits, Colors.orange),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildGoalStats(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, provider, child) {
        final totalGoals = provider.goals.length;
        final completedGoals = provider.goals.where((goal) => goal.isCompleted).length;
        final inProgressGoals = totalGoals - completedGoals;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goals',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total', totalGoals, Colors.blue),
                _buildStatCard('Completed', completedGoals, Colors.green),
                _buildStatCard('In Progress', inProgressGoals, Colors.orange),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              count.toString(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamificationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Achievements',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildAchievementsList(),
      ],
    );
  }

  Widget _buildAchievementsList() {
    if (achievements.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'No achievements yet. Keep progressing!',
          style: TextStyle(
            fontSize: 18,
            color: const Color.fromARGB(255, 186, 182, 182),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return ListTile(
          leading: Icon(
            achievement['icon'],
            color: achievement['color'],
            size: 40,
          ),
          title: Text(
            achievement['title'],
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}
