import 'package:flutter/material.dart';
import 'package:habitwise/models/user.dart';
import 'package:habitwise/providers/habit_provider.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:provider/provider.dart';
import 'package:habitwise/widgets/bottom_navigation_bar.dart';

class ProfilePage extends StatefulWidget {
  final HabitWiseUser user;

  ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(126, 35, 191, 0.498),
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(context),
              const SizedBox(height: 20),
              _buildHabitStats(context),
              const SizedBox(height: 20),
              _buildGoalStats(context),
              const SizedBox(height: 20),
              _buildGamificationSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: 3, // Set the current index to the profile tab
        onTap: (index) {
          if (index != 3) {
            if (index == 0) {
              Navigator.of(context).pushReplacementNamed('/dashboard');
            } else if (index == 1) {
              Navigator.of(context).pushReplacementNamed('/goals');
            } else if (index == 2) {
              Navigator.of(context).pushReplacementNamed('/habit');
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

  Widget _buildProfileHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: (widget.user.profilePictureUrl != null && widget.user.profilePictureUrl!.isNotEmpty)
              ? NetworkImage(widget.user.profilePictureUrl!)
              : AssetImage('assets/images/default_avatar.png') as ImageProvider,
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.user.username,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.user.email,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHabitStats(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        final totalHabits = provider.habits.length;
        final completedHabits = provider.habits.where((habit) => habit.isCompleted).length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habits',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total', totalHabits, Colors.blue),
                _buildStatCard('Completed', completedHabits, Colors.green),
                _buildStatCard('In Progress', totalHabits - completedHabits, Colors.orange),
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
        print('Total Goals: $totalGoals, Completed Goals: $completedGoals');
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
                _buildStatCard('In Progress', totalGoals - completedGoals, Colors.orange),
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

  Widget _buildGamificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildAchievementCard('Beginner', Icons.star, Colors.amber),
            _buildAchievementCard('Intermediate', Icons.star_half, Colors.amber[700]),
            _buildAchievementCard('Expert', Icons.star_border, Colors.amber[900]),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementCard(String title, IconData icon, Color? color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 16, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
