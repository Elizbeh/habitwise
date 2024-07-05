import 'dart:io';
import 'dart:ui';
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

  // Function to handle image upload for profile picture
  Future<void> _uploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      try {
        // Upload the selected image to the storage service
        String imageUrl = await _storageService.uploadFile(_imageFile!);
        print('Uploaded Image URL: $imageUrl');
        
        // Update Firestore with the new profile picture URL
        HabitWiseUser updatedUser = widget.user;
        updatedUser.profilePictureUrl = imageUrl;
        await UserDBService().updateUserProfile(updatedUser);

        // Update the state with the new profile picture URL
        setState(() {
          widget.user.profilePictureUrl = imageUrl;
        });
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }
  @override
  void initState() {
    super.initState();
    calculateAchievements();
  }

  // Function to calculate achievements based on completed habits and goals
  void calculateAchievements() {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);

    final completedHabits = habitProvider.habits.where((habit) => habit.isCompleted).length;
    final completedGoals = goalProvider.goals.where((goal) => goal.isCompleted).length;

    achievements.clear();

    // Achievements based on habits
    if (completedHabits >= 1) {
      achievements.add({
        'title': 'First Habit Completed',
        'icon': Icons.star,
        'color': Colors.amber,
      });
    }

    if (completedHabits >= 5) {
      achievements.add({
        'title': 'Habit Master',
        'icon': Icons.star_half,
        'color': Colors.amber[700],
      });
    }

    if (completedHabits >= 10) {
      achievements.add({
        'title': 'Habit Guru',
        'icon': Icons.star_border,
        'color': Colors.amber[900],
      });
    }

    //Achievements based on goals
    if (completedGoals >= 1) {
      achievements.add({
        'title': 'First Goal Achieved',
        'icon': Icons.flag,
        'color': Colors.blue,
      });
    }

    if (completedGoals >= 5) {
      achievements.add({
        'title': 'Goal Achiever',
        'icon': Icons.flag_outlined,
        'color': Colors.blue[700],
      });
    }

    if (completedGoals >= 10) {
      achievements.add({
        'title': 'Goal Conqueror',
        'icon': Icons.flag_rounded,
        'color': Colors.blue[900],
      });
    }

    //update UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        toolbarHeight: 80,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(126, 35, 191, 0.498),
                Color.fromRGBO(126, 35, 191, 0.498),
                Color.fromARGB(57, 181, 77, 199),
                Color.fromARGB(233, 93, 59, 99),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topLeft,
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
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
              Navigator.pushNamedAndRemoveUntil(
                context, '/login', (route) => false);
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

  // Widget to build the profile header section with the user's profile picture and information
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
                : const AssetImage('assets/default_avatar1.png') as ImageProvider,
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
          SizedBox(height: 24),
          const Divider(color: Colors.black),
          const SizedBox(height: 16)
        ],
      ),
    );
  }

  // Widget to build the habits statistics section
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

  // Widget to build the goals statistics section
   Widget _buildGoalStats(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, provider, child) {
        final totalGoals = provider.goals.length;
        final completedGoals = provider.goals.where((goal) => goal.isCompleted).length;
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

  // Widget to build individual statistic cards for habits and goals
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

  // Widget to build the achievements section
  Widget _buildGamificationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        _buildAchievementsList(),
      ],
    );
  }

  Widget _buildAchievementsList() {
    if (achievements.isEmpty) {
      return Text(
        'No achievements yet. Keep progressing!',
        style: TextStyle(fontSize: 18, color: Color.fromRGBO(126, 35, 191, 0.498), fontWeight: FontWeight.bold),
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