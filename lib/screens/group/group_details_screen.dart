import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/models/habit.dart';
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
  bool isExpanded = false;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _fetchGroupDetails();
    });
  }

  Future<void> _fetchGroupDetails() async {
    final String groupId = ModalRoute.of(context)!.settings.arguments as String;
    try {
      final fetchedGroup = await _groupDBService.getGroupById(groupId);
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
      // Handle error gracefully, e.g., show an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GoalProvider(groupId: group?.groupId ?? ''),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          toolbarHeight: 60,
          title: Text(
            '${group?.groupType}',
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
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
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
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
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
                    // Banner below AppBar
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(203, 157, 236, 0.494),
                            Color.fromRGBO(208, 164, 239, 0.475),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: group!.groupPictureUrl != null
                                  ? NetworkImage(group!.groupPictureUrl!) as ImageProvider<Object>?
                                  : null,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 130.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8.0),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${group!.groupName}',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple,
                                        ),
                                      ),
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.bottom,
                                        baseline: TextBaseline.alphabetic,
                                        child: SizedBox(
                                          width: 3, // Adjust as needed
                                          height: 3, // Adjust as needed
                                          child: Text(
                                            '₁',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              textBaseline: TextBaseline.alphabetic,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' by $creatorName',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'Created on ${DateFormat('yyyy-MM-dd').format(group!.creationDate)} @ ${DateFormat('HH:mm:ss').format(group!.creationDate)}',
                                  style: TextStyle(fontSize: 10, color: Colors.pink),
                                ),
                                SizedBox(height: 4.0),
                                AnimatedCrossFade(
                                  firstChild: Container(
                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 100),
                                    child: Text(
                                      '${group!.description} ',
                                      style: TextStyle(fontSize: 12),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  secondChild: Container(
                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 100),
                                    child: Text(
                                      '${group!.description} ',
                                      style: TextStyle(fontSize: 12, color: Colors.purple),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                  duration: Duration(milliseconds: 300),
                                ),
                                SizedBox(height: 4.0),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isExpanded = !isExpanded;
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          isExpanded ? 'See less ' : 'See more ',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                        color: Colors.blue,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                FutureBuilder<List<String>>(
                                  future: _fetchMemberUsernames(group!.members),
                                  builder: (context, membersSnapshot) {
                                    if (membersSnapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    } else if (membersSnapshot.hasError) {
                                      return Center(child: Text('Error: ${membersSnapshot.error}'));
                                    } else {
                                      List<String> memberUsernames = membersSnapshot.data ?? [];
                                      return DropdownButton<String>(
                                        value: null,
                                        hint: Text(
                                          'Members: ${memberUsernames.join(', ')}',
                                          style: TextStyle(color: Colors.purple, fontSize: 12),
                                        ),
                                        items: memberUsernames.map((String username) {
                                          return DropdownMenuItem<String>(
                                            value: username,
                                            child: Text(username),
                                          );
                                        }).toList(),
                                        onChanged: (_) {},
                                      );
                                    }
                                  },
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
                                                  ),
                                                );
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
                                  border: Border.all(color: const Color.fromRGBO(126, 35, 191, 0.498)),
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
                                              _selectedIndex == 0 ? const Color.fromRGBO(126, 35, 191, 0.498) : Colors.white,
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
                                      color: const Color.fromRGBO(126, 35, 191, 0.498),
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
                                              _selectedIndex == 1 ? const Color.fromRGBO(126, 35, 191, 0.498) : Colors.white,
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
      ),
    );
  }

  /// Fetches usernames for a list of user IDs.
  Future<List<String>> _fetchMemberUsernames(List<String> memberIds) async {
    List<String> usernames = [];
    for (String id in memberIds) {
      String username = await _userDBService.getUserNameById(id);
      usernames.add(username);
    }
    return usernames;
  }
}
