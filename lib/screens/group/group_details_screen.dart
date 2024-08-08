import 'dart:async';
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
import 'package:habitwise/services/user_db_service.dart';
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
  final UserDBService _userDBService = UserDBService();
  final GoalDBService _goalDBService = GoalDBService();
  final HabitDBService _habitDBService = HabitDBService();

  HabitWiseGroup? group;
  String creatorName = '';
  bool isMember = false;
  bool isCreator = false;
  bool isMembersExpanded = false;
  bool _descriptionExpanded = false;
  int _selectedIndex = 0;

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
      final fetchedCreatorName = await _userDBService.getUserNameById(fetchedGroup.groupCreator);
      final fetchedIsMember = fetchedGroup.members.contains(userId);
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GoalProvider(groupId: group?.groupId ?? ''),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${group?.groupType ?? ''}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(126, 35, 191, 0.498),
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              color: Colors.white,
              onPressed: () {
                Provider.of<UserProvider>(context, listen: false).logoutUser();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: group != null
              ? Column(
                  children: [
                    _buildBanner(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildActionButtons(),
                              _buildContent(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(child: CircularProgressIndicator()),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 93, 156, 164), Color.fromRGBO(126, 35, 191, 0.498)],
          begin: Alignment.bottomCenter,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: group!.groupPictureUrl != null
                    ? NetworkImage(group!.groupPictureUrl!) as ImageProvider
                    : AssetImage('assets/default_group.png'),
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${group!.groupName}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Created by $creatorName on ${DateFormat('yyyy-MM-dd').format(group!.creationDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    _descriptionWidget(),
                    SizedBox(height: 8.0),
                    _buildMembersSection(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () => _showAddGoalDialog(),
          child: const Text('Add Goal'),
        ),
        ElevatedButton(
          onPressed: () => _showAddHabitDialog(),
          child: const Text('Add Habit'),
        ),
        if (isMember && !isCreator) ...[
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () => _leaveGroup(),
            child: const Text('Leave Group'),
          ),
        ],
        if (!isMember && !isCreator) ...[
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () => _joinGroup(),
            child: const Text('Join Group'),
          ),
        ],
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        SizedBox(height: 16.0),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Color.fromRGBO(126, 35, 191, 0.498)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _selectedIndex = 0),
                  child: const Text('Goals'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: _selectedIndex == 0 ? Colors.white : Colors.black,
                    backgroundColor:
                        _selectedIndex == 0 ? Color.fromRGBO(126, 35, 191, 0.498) : Colors.white,
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
                color: Color.fromRGBO(126, 35, 191, 0.498),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _selectedIndex = 1),
                  child: const Text('Habits'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: _selectedIndex == 1 ? Colors.white : Colors.black,
                    backgroundColor:
                        _selectedIndex == 1 ? Color.fromRGBO(126, 35, 191, 0.498) : Colors.white,
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
        SizedBox(height: 16.0),
        if (_selectedIndex == 0) ...[
          Text('Group Goals:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
          Text('Group Habits:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
    );
  }

  Widget _buildMembersSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Members:',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        DropdownButton<String>(
          value: isMembersExpanded ? 'Hide Members' : 'Show Members',
          icon: Icon(Icons.expand_more, color: Colors.white),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(color: Colors.white),
          dropdownColor: Color.fromRGBO(126, 35, 191, 0.498),
          onChanged: (String? newValue) {
            setState(() {
              isMembersExpanded = !isMembersExpanded;
            });
          },
          items: <String>['Show Members', 'Hide Members'].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        if (isMembersExpanded) ...[
          SizedBox(height: 8.0),
          FutureBuilder<List<String>>(
            future: _fetchMemberUsernames(group!.members),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                List<String> usernames = snapshot.data ?? [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: usernames.map((username) => Text(
                    username,
                    style: TextStyle(color: Colors.white),
                  )).toList(),
                );
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _descriptionWidget() {
    final descriptionText = group?.description ?? '';
    const int maxLines = 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          descriptionText,
          maxLines: _descriptionExpanded ? null : maxLines,
          overflow: _descriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 8.0),
        GestureDetector(
          onTap: () {
            setState(() {
              _descriptionExpanded = !_descriptionExpanded;
            });
          },
          child: Text(
            _descriptionExpanded ? 'Show Less' : 'Show More',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Future<List<String>> _fetchMemberUsernames(List<String> memberIds) async {
    List<String> usernames = [];
    for (String id in memberIds) {
      try {
        String username = await _userDBService.getUserNameById(id);
        usernames.add(username);
      } catch (e) {
        print('Error fetching username for $id: $e');
      }
    }
    return usernames;
  }

  void _showAddGoalDialog() {
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
  }

  void _showAddHabitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddHabitDialog(isGroupHabit: true, groupId: group!.groupId);
      },
    );
  }

  Future<void> _leaveGroup() async {
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
  }

  Future<void> _joinGroup() async {
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
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: 'Goals',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.track_changes),
          label: 'Habits',
        ),
      ],
      selectedItemColor: Color.fromRGBO(126, 35, 191, 0.498),
      unselectedItemColor: Colors.black,
      backgroundColor: Colors.white,
    );
  }
}
