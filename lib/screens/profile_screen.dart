import 'dart:io';
import 'dart:ui';
import 'package:habitwise/main.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:habitwise/models/user.dart';
import 'package:habitwise/providers/habit_provider.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/services/storage_service.dart';
import 'package:habitwise/services/user_db_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:habitwise/widgets/bottom_navigation_bar.dart';

const List<Color> appBarGradientColors = [
    Color.fromRGBO(134, 41, 137, 1.0),
    Color.fromRGBO(181, 58, 185, 1),
    Color.fromRGBO(46, 197, 187, 1.0),
];


class ProfilePage extends StatefulWidget {
  final HabitWiseUser user;

  ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Map<String, dynamic>> achievements = [];
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();

  final ValueNotifier<ThemeMode> _themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  @override
  void initState() {
    super.initState();
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

  Future<void> _uploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      try {
        String imageUrl = await _storageService.uploadFile(_imageFile!);
        print('Uploaded Image URL: $imageUrl');

        HabitWiseUser updatedUser = widget.user.copyWith(profilePictureUrl: imageUrl);
        await UserDBService().updateUserProfile(updatedUser);

        if (mounted) {
          setState(() {
            widget.user.profilePictureUrl = imageUrl;
          });
        }
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  void _calculateAchievements() {
    print('Calculating achievements...');

    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);

    final completedHabits = habitProvider.habits.where((habit) => habit.isCompleted).length;
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
        toolbarHeight: 80,
        title: Row(
          children: [
            Container(
              width: 40, // Adjust width as needed
              height: 40, // Adjust height as needed
              decoration: BoxDecoration(
                color: Colors.white, // Background color for logo
                borderRadius: BorderRadius.circular(8), // Optional: rounded corners
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0), // Optional: padding around the logo
                child: Image.asset('assets/images/logo.png'),
              ),
            ),
            const SizedBox(width: 8), // Space between logo and title
            Expanded(
              child: Text(
                'Profile',
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
        currentIndex: 3,
        onTap: (index) {
          if (index != 3) {
            if (index == 0) {
              Navigator.of(context).pushReplacementNamed('/dashboard');
            } else if (index == 1) {
              Navigator.of(context).pushReplacementNamed('/goals');
            } else if (index == 2) {
              Navigator.of(context).pushReplacementNamed('/habit');
            }
          }
        }, 
        themeNotifier: appThemeNotifier,
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final profilePictureUrl = widget.user.profilePictureUrl ?? '';

    return GestureDetector(
      onTap: _uploadImage,
      child: Row(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: profilePictureUrl.isNotEmpty
                ? CachedNetworkImageProvider(profilePictureUrl)
                : const AssetImage('assets/images/default_profilePic.png') as ImageProvider,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.username,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.user.email,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHabitStats(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        final totalHabits = provider.habits.length;
        final completedHabits = provider.habits.where((habit) => habit.isCompleted).length;
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
            color: Color.fromRGBO(126, 35, 191, 0.498),
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
