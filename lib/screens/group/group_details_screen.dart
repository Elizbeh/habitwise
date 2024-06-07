import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/services/group_db_service.dart';
import 'package:habitwise/services/user_db_service.dart';
import 'package:habitwise/widgets/goal_tile.dart';
import 'package:provider/provider.dart';
import 'package:habitwise/screens/dialogs/add_goal_dialog.dart';
import 'package:habitwise/screens/dialogs/add_habit_dialog.dart';
import 'package:habitwise/services/goals_db_service.dart';
import 'package:habitwise/services/habit_db_service.dart';
import 'package:habitwise/widgets/habit_tile.dart'; // Import the HabitTile widget

class GroupDetailsScreen extends StatefulWidget {
  GroupDetailsScreen({Key? key}) : super(key: key);

  @override
  _GroupDetailsScreenState createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  late GroupDBService _groupDBService;
  late UserDBService _userDBService;
  late GoalDBService _goalDBService;
  late HabitDBService _habitDBService;

  @override
  void initState() {
    super.initState();
    // Initialize the database services
    _groupDBService = GroupDBService();
    _userDBService = UserDBService();
    _goalDBService = GoalDBService();
    _habitDBService = HabitDBService();
  }

  @override
  Widget build(BuildContext context) {
    // Get the groupId from the route arguments
    final String groupId = ModalRoute.of(context)!.settings.arguments as String;
    // Access the UserProvider to get the current user's information
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Group Details')),
      body: FutureBuilder<HabitWiseGroup>(
        future: _groupDBService.getGroupById(groupId), // Fetch the group details
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while waiting for data
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show an error message if there's an error
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            // Show a message if the group is not found
            return Center(child: Text('Group not found'));
          } else {
            HabitWiseGroup group = snapshot.data!;
            // Fetch the group creator's name
            return FutureBuilder<String>(
              future: _userDBService.getUserNameById(group.groupCreator),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  // Show a loading indicator while waiting for data
                  return Center(child: CircularProgressIndicator());
                } else if (userSnapshot.hasError) {
                  // Show an error message if there's an error
                  return Center(child: Text('Error: ${userSnapshot.error}'));
                } else {
                  // Extract necessary data and determine the user's role in the group
                  String creatorName = userSnapshot.data ?? 'Unknown';
                  String userId = userProvider.user?.uid ?? '';
                  bool isMember = group.members.contains(userId);
                  bool isCreator = group.groupCreator == userId;

                  return Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Display group details
                          Text('Group Name: ${group.groupName}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8.0),
                          Text('Group Type: ${group.groupType}'),
                          SizedBox(height: 8.0),
                          Text('Description: ${group.description}'),
                          SizedBox(height: 8.0),
                          Text('Created by: $creatorName'),
                          SizedBox(height: 8.0),
                          Text('Created on: ${group.creationDate.toLocal().toString().split(' ')[0]}'),
                          SizedBox(height: 8.0),
                          Text('Members: ${group.members.join(', ')}'),
                          SizedBox(height: 16.0),
                          // Button to add a habit to the group
                          ElevatedButton(
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AddHabitDialog(isGroupHabit: true, groupId: groupId);
                                },
                              );
                            },
                            child: Text('Add Habit'),
                          ),
                          // Button to add a goal to the group
                          ElevatedButton(
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AddGoalDialog(
                                    isGroupGoal: true,
                                    groupId: groupId, 
                                    targetId: '', 
                                    addGoalToGroup: (groupId, goalId ) async { 
                                      try {
                                        await _goalDBService.addGoalToGroup(groupId, goalId);
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text('Goal added to group successfully!'),
                                          duration: Duration(seconds: 2),
                                        ));
                                        setState(() {}); // Trigger UI update
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text('Error adding goal to group: $e'),
                                          duration: Duration(seconds: 2),
                                        ));
                                      }
                                    },
                                    addGoalToHabit: (groupId, habit ) {  },
                                  );
                                },
                              );
                            },
                            child: Text('Add Goal'),
                          ),
                          // Button to leave the group if the user is a member but not the creator
                          if (isMember && !isCreator) ...[
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  await _groupDBService.leaveGroup(group.groupId, userId);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text('Left group successfully!'),
                                    duration: Duration(seconds: 2),
                                  ));
                                  setState(() {}); // Trigger UI update
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text('Error leaving group: $e'),
                                    duration: Duration(seconds: 2),
                                  ));
                                }
                              },
                              child: Text('Leave Group'),
                            ),
                          ],
                          // Button to join the group if the user is not a member
                          if (!isMember) ...[
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  await _groupDBService.joinGroup(group.groupId, userId);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text('Joined group successfully!'),
                                    duration: Duration(seconds: 2),
                                  ));
                                  setState(() {}); // Trigger UI update
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text('Error joining group: $e'),
                                    duration: Duration(seconds: 2),
                                  ));
                                }
                              },
                              child: Text('Join Group'),
                            ),
                          ],
                          // Display group goals if the user is the creator
                          if (isCreator) ...[
                            SizedBox(height: 16.0),
                            Text('Group Goals:', style: TextStyle(fontWeight: FontWeight.bold)),
                            StreamBuilder<List<Goal>>(
                              stream: _goalDBService.getGroupGoalsStream(groupId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  // Show a loading indicator while waiting for data
                                  return Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  // Show an error message if there's an error
                                  return Center(child: Text('Error: ${snapshot.error}'));
                                } else {
                                  // Display the list of group goals
                                  List<Goal> goals = snapshot.data ?? [];
                                  return Column(
                                    children: goals.map((goal) => GoalTile(goal: goal)).toList(),
                                  );
                                }
                              },
                            ),
                          ],
                          SizedBox(height: 16.0),
                          Text('Group Habits:', style: TextStyle(fontWeight: FontWeight.bold)),
                          // Display group habits
                          StreamBuilder<List<Habit>>(
                            stream: _habitDBService.getGroupHabitsStream(groupId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                // Show a loading indicator while waiting for data
                                return Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                // Show an error message if there's an error
                                return Center(child: Text('Error: ${snapshot.error}'));
                              } else {
                                // Display the list of group habits using HabitTile
                                List<Habit> habits = snapshot.data ?? [];
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: habits.length,
                                  itemBuilder: (context, index) {
                                    final habit = habits[index];
                                    return HabitTile(habit: habit, groupId: groupId,); // Use the shared HabitTile widget
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      ),                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
