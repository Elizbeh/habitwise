import 'dart:async';
import 'package:habitwise/main.dart';
import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/models/user.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/screens/data/icons/category_icons.dart';
import 'package:habitwise/services/goals_db_service.dart';
import 'package:habitwise/services/group_db_service.dart';
import 'package:habitwise/widgets/bottom_navigation_bar.dart';
import 'package:habitwise/widgets/goal_tile.dart';
import 'package:habitwise/widgets/habit_tile.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:habitwise/screens/dialogs/add_goal_dialog.dart';
import 'package:habitwise/screens/dialogs/add_habit_dialog.dart';
import 'package:habitwise/services/habit_db_service.dart';


class GroupDetailsScreen extends StatefulWidget {
  final HabitWiseGroup group;
  final HabitWiseUser user;

  GroupDetailsScreen({required this.group, required this.user});

  @override
  _GroupDetailsScreenState createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final GroupDBService _groupDBService = GroupDBService();

  final GoalDBService _goalDBService = GoalDBService();
  final HabitDBService _habitDBService = HabitDBService();

  HabitWiseGroup? group;
  String creatorName = '';
  bool isMember = false;
  bool isCreator = false;
  bool isMembersExpanded = false;
  bool _descriptionExpanded =  false;
  int _selectedIndex = 0; // switch between habits and goals
  final int _currentIndex = 0;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _fetchGroupDetails();
    });
  }

  Future<void> _fetchGroupDetails() async {
  try {
    final fetchedGroup = widget.group; 
    final userId = Provider.of<UserProvider>(context, listen: false).user?.uid ?? '';

    // Fetch the group creator's name
    final fetchedCreatorName = fetchedGroup.members.firstWhere((member) => member.id == fetchedGroup.groupCreator).name;

    // Check if the current user is a member and/or the creator of the group
    final fetchedIsMember = fetchedGroup.members.any((member) => member.id == userId);  // Check membership using member.id
    final fetchedIsCreator = fetchedGroup.groupCreator == userId;

    setState(() {
      group = fetchedGroup;
      creatorName = fetchedCreatorName;
      isMember = fetchedIsMember;
      isCreator = fetchedIsCreator;
    });
  } catch (e) {
    print('Error fetching group details: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to load group details. Please try again.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

  void _onNavItemTapped(int index) {
    // Navigate to the appropriate screen based on the index
    switch (index) {
      case 0:
        Navigator.of(context).pushNamed('/dashboard');
        break;
      case 1:
        Navigator.of(context).pushNamed('/goals');
        break;
      case 2:
        Navigator.of(context).pushNamed('/habit');
        break;
      case 3:
        Navigator.of(context).pushNamed('/profile');
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GoalProvider(groupId: group?.groupId ?? ''),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
            ' ${group?.groupType ?? 'No Group Name'}',
            style: TextStyle(
              color: Colors.white, 
              fontSize: 20, 
              fontWeight: FontWeight.w600,
            ),
          ),
        
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(134, 41, 137, 1.0),
                    Color.fromRGBO(181, 58, 185, 1),
                    Color.fromRGBO(46, 197, 187, 1.0),
                  ],
                  begin: Alignment.centerRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
            titleSpacing: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  Provider.of<UserProvider>(context, listen: false).logoutUser();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
              ),
            ],
          ),
        
        body: SafeArea(
          child: group != null
              ? Column(
                  children: [
                    // Banner below AppBar
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                          Color.fromRGBO(134, 41, 137, 1.0),
                          Color.fromRGBO(181, 58, 185, 1),
                          Color.fromRGBO(46, 197, 187, 1.0),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.bottomRight,
                        ),
                      ),
  
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Picture Section
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: group!.groupPictureUrl != null && group!.groupPictureUrl!.isNotEmpty
                                ? NetworkImage(group!.groupPictureUrl!) as ImageProvider<Object>
                                : const AssetImage('assets/images/default_profilePic.png'),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${group?.groupType ?? 'Group Type'}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Created by $creatorName on ${DateFormat('yyyy-MM-dd').format(group?.creationDate ?? DateTime.now())}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                // Description Section
                                Text(
                                  'Description:',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _descriptionExpanded = !_descriptionExpanded;
                                    });
                                  },
                                  child: AnimatedCrossFade(
                                    firstChild: Container(
                                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 100),
                                      child: Text(
                                        group?.description ?? 'No description provided.',
                                        maxLines: 2,
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ),
                                    secondChild: Container(
                                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 100),
                                      child: Text(
                                        group?.description ?? 'No description provided.',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ),
                                    crossFadeState: _descriptionExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                    duration: Duration(milliseconds: 200),
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                // Members Dropdown Button
                                DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    hint: Text(
                                      'Members (${group?.members.length ?? 0})',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color:  Colors.white),
                                    ),
                                    items: (group?.members ?? []).map((member) {
                                      return DropdownMenuItem<String>(
                                        value: member.id,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundImage: member.profilePictureUrl != null
                                                    ? NetworkImage(member.profilePictureUrl!) as ImageProvider
                                                    : AssetImage('assets/images/default_profilePic.png'),
                                                ),
                                                SizedBox(width: 8.0),
                                                Text(member.name ?? 'No Name', style: TextStyle(color: Colors.black)),
                                              ],
                                            ),
                                            // Remove button
                                            if (isCreator)
                                              TextButton(
                                                onPressed: () {
                                                  // Handle member removal
                                                },
                                                child: Text('Remove', style: TextStyle(color: Colors.red)),
                                              ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (selectedMemberId) {
                                      // Handle member selection
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                 
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 16.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AddGoalDialog(
                                            addGoalToGroup: (Goal goal) async {
                                              try {
                                                await _goalDBService.addGoalToGroup(group!.groupId, goal.id);
                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                  content: Text('Goal added to group successfully!'),
                                                  duration: Duration(seconds: 3),
                                                ));
                                                setState(() {});
                                              } catch (e) {
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                  content: Text('Error adding goal: $e'),
                                                  duration: const Duration(seconds: 2),
                                                ));
                                              }
                                            },
                                            groupId: group!.groupId,
                                          );
                                        },
                                      );
                                    },
                                    child: const Text('Add Goal'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AddHabitDialog(isGroupHabit: true, groupId: group!.groupId);
                                        },
                                      );
                                    },
                                    child: const Text('Add Habit'),
                                  ),
                                ],
                              ),
                              if (isMember && !isCreator) ...[
                                ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await _groupDBService.leaveGroup(
                                          group!.groupId, Provider.of<UserProvider>(context, listen: false).user!.uid);
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        content: Text('Left group successfully!'),
                                        duration: Duration(seconds: 2),
                                      ));
                                      setState(() {});
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text('Error leaving group: $e'),
                                        duration: const Duration(seconds: 2),
                                      ));
                                    }
                                  },
                                  child: const Text('Leave Group'),
                                ),
                              ],
                              if (!isMember && !isCreator) ...[
                                ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await _groupDBService.joinGroup(
                                          group!.groupId, Provider.of<UserProvider>(context, listen: false).user!.uid);
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        content: Text('Joined group successfully!'),
                                        duration: Duration(seconds: 2),
                                      ));
                                      setState(() {});
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text('Error joining group: $e'),
                                        duration: const Duration(seconds: 2),
                                      ));
                                    }
                                  },
                                  child: const Text('Join Group'),
                                ),
                              ],
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: Theme.of(context).colorScheme.primary),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _selectedIndex = 0;
                                          });
                                        },
                                        child: const Text('Goals'),
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: _selectedIndex == 0 ? Colors.white : Colors.black,
                                          backgroundColor:
                                              _selectedIndex == 0 ? Theme.of(context).colorScheme.primary : Colors.white,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(8.0),
                                              bottomLeft: Radius.circular(8.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 48,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _selectedIndex = 1;
                                          });
                                        },
                                        child: const Text('Habits'),
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: _selectedIndex == 1 ? Colors.white : Colors.black,
                                          backgroundColor:
                                              _selectedIndex == 1 ? Theme.of(context).colorScheme.primary : Colors.white,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(8.0),
                                              bottomRight: Radius.circular(8.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_selectedIndex == 0) ...[
                                SizedBox(height: 16.0),
                                Text('Group Goals:', style: TextStyle(fontWeight: FontWeight.bold)),
                                StreamBuilder<List<Goal>>(
                                  stream: _goalDBService.getGroupGoalsStream(group!.groupId),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(child: Text('Error: ${snapshot.error}'));
                                    } else {
                                      List<Goal> goals = snapshot.data ?? [];
                                      return Column(
                                        children: goals.map((goal) => GoalTile(goal: goal, groupId: group!.groupId)).toList(),
                                      );
                                    }
                                  },
                                ),
                              ],
                              if (_selectedIndex == 1) ...[
                                SizedBox(height: 16.0),
                                Text('Group Habits:', style: TextStyle(fontWeight: FontWeight.bold)),
                                StreamBuilder<List<Habit>>(
                                  stream: _habitDBService.getGroupHabitsStream(group!.groupId),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(child: Text('Error: ${snapshot.error}'));
                                    } else {
                                      List<Habit> habits = snapshot.data ?? [];
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: habits.length,
                                        itemBuilder: (context, index) {
                                          final habit = habits[index];
                                          final leadingIcon = categoryIcons[habit.category ?? ''] ?? Icons.star;
                                          return HabitTile(habit: habit, groupId: group!.groupId, leadingIcon: leadingIcon);
                                        },
                                      );
                                    }
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                child: CircularProgressIndicator(),
                ),
              ),
              bottomNavigationBar: BottomNavigationBarWidget(
              currentIndex: _currentIndex,
              onTap: _onNavItemTapped,
              themeNotifier: appThemeNotifier,
            ),
          ),
      );
    }
}