import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/screens/data/icons/category_icons.dart';
import 'package:habitwise/services/group_db_service.dart';
import 'package:habitwise/services/user_db_service.dart';
import 'package:habitwise/widgets/goal_tile.dart';
import 'package:provider/provider.dart';
import 'package:habitwise/screens/dialogs/add_goal_dialog.dart';
import 'package:habitwise/screens/dialogs/add_habit_dialog.dart';
import 'package:habitwise/services/goals_db_service.dart';
import 'package:habitwise/services/habit_db_service.dart';
import 'package:habitwise/widgets/habit_tile.dart';

class GroupDetailsScreen extends StatefulWidget {
  @override
  _GroupDetailsScreenState createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  late final GroupDBService _groupDBService;
  late final UserDBService _userDBService;
  late final GoalDBService _goalDBService;
  late final HabitDBService _habitDBService;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _groupDBService = GroupDBService();
    _userDBService = UserDBService();
    _goalDBService = GoalDBService();
    _habitDBService = HabitDBService();
  }

  @override
  Widget build(BuildContext context) {
    final String groupId = ModalRoute.of(context)!.settings.arguments as String;
    final userProvider = Provider.of<UserProvider>(context);

    return ChangeNotifierProvider(
      create: (_) => GoalProvider(groupId: groupId),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          toolbarHeight: 170,
          title: const Text(
            'Group Details',
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
                  Color.fromARGB(255, 222, 144, 236),
                  Color.fromRGBO(126, 35, 191, 0.498),
                  Color.fromARGB(57, 181, 77, 199),
                  Color.fromARGB(255, 201, 5, 236)
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topLeft,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: FutureBuilder<HabitWiseGroup>(
              future: _groupDBService.getGroupById(groupId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('Group not found'));
                } else {
                  HabitWiseGroup group = snapshot.data!;
                  return FutureBuilder<String>(
                    future: _userDBService.getUserNameById(group.groupCreator),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (userSnapshot.hasError) {
                        return Center(child: Text('Error: ${userSnapshot.error}'));
                      } else {
                        String creatorName = userSnapshot.data ?? 'Unknown';
                        String userId = userProvider.user?.uid ?? '';
                        bool isMember = group.members.contains(userId);
                        bool isCreator = group.groupCreator == userId;

                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 16.0),
                                Text('Group Name: ${group.groupName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8.0),
                                Text('Group Type: ${group.groupType}'),
                                const SizedBox(height: 8.0),
                                Text('Description: ${group.description}'),
                                const SizedBox(height: 8.0),
                                Text('Created by: $creatorName'),
                                const SizedBox(height: 8.0),
                                Text('Created on: ${group.creationDate.toLocal().toString().split(' ')[0]}'),
                                const SizedBox(height: 8.0),
                                Text('Members: ${group.members.join(', ')}'),
                                const SizedBox(height: 16.0),
                                ElevatedButton(
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AddHabitDialog(isGroupHabit: true, groupId: groupId);
                                      },
                                    );
                                  },
                                  child: const Text('Add Habit'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AddGoalDialog(
                                          addGoalToGroup: (Goal goal) async {
                                            try {
                                              await _goalDBService.addGoalToGroup(groupId, goal.id);
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                content: Text('Goal added to group successfully!'),
                                                duration: Duration(seconds: 2),
                                              ));
                                              setState(() {}); // Trigger UI update
                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                content: Text('Error adding goal to group: $e'),
                                                duration: const Duration(seconds: 2),
                                              ));
                                            }
                                          },
                                          groupId: groupId,
                                        );
                                      },
                                    );
                                  },
                                  child: const Text('Add Goal'),
                                ),
                                if (isMember && !isCreator) ...[
                                  ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        await _groupDBService.leaveGroup(group.groupId, userId);
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                          content: Text('Left group successfully!'),
                                          duration: Duration(seconds: 2),
                                        ));
                                        setState(() {}); // Trigger UI update
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
                                if (!isMember) ...[
                                  ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        await _groupDBService.joinGroup(group.groupId, userId);
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                          content: Text('Joined group successfully!'),
                                          duration: Duration(seconds: 2),
                                        ));
                                        setState(() {}); // Trigger UI update
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
                                            backgroundColor: _selectedIndex == 0 ? const Color.fromRGBO(126, 35, 191, 0.498) : Colors.white,
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
                                            backgroundColor: _selectedIndex == 1 ? const Color.fromRGBO(126, 35, 191, 0.498) : Colors.white,
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
                                  const SizedBox(height: 16.0),
                                  const Text('Group Goals:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  StreamBuilder<List<Goal>>(
                                    stream: _goalDBService.getGroupGoalsStream(groupId),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(child: Text('Error: ${snapshot.error}'));
                                      } else {
                                        List<Goal> goals = snapshot.data ?? [];
                                        return Column(
                                          children: goals.map((goal) => GoalTile(goal: goal)).toList(),
                                        );
                                      }
                                    },
                                  ),
                                ],
                                if (_selectedIndex == 1) ...[
                                  const SizedBox(height: 16.0),
                                  const Text('Group Habits:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  StreamBuilder<List<Habit>>(
                                    stream: _habitDBService.getGroupHabitsStream(groupId),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(child: Text('Error: ${snapshot.error}'));
                                      } else {
                                        List<Habit> habits = snapshot.data ?? [];
                                        return ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: habits.length,
                                          itemBuilder: (context, index) {
                                            final habit = habits[index];
                                            final leadingIcon = categoryIcons[habit.category ?? ''] ?? Icons.star;
                                            return HabitTile(habit: habit, groupId: groupId, leadingIcon: leadingIcon);
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

