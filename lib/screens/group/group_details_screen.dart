import 'dart:async';
import 'package:habitwise/main.dart';
import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/models/user.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:habitwise/providers/group_provider.dart';
import 'package:habitwise/providers/habit_provider.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/screens/group/group_info.dart';
import 'package:habitwise/screens/group/group_widgets.dart';
import 'package:habitwise/widgets/bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:habitwise/screens/dialogs/add_goal_dialog.dart';
import 'package:habitwise/screens/dialogs/add_habit_dialog.dart';
import 'package:habitwise/screens/group/create_group_screen.dart';




class GroupDetailsScreen extends StatefulWidget {
  final HabitWiseGroup group;
  final HabitWiseUser user;

  GroupDetailsScreen({required this.group, required this.user});

  @override
  _GroupDetailsScreenState createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  HabitWiseGroup? group;
  String creatorName = '';
  bool isMember = false;
  bool isCreator = false;
  bool isMembersExpanded = false;
  int _selectedIndex = 0; // switch between habits and goals
  final int _currentIndex = 0;


  
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _fetchGroupDetails();
    _fetchGroupGoals();
  });
}

  Future<void> _fetchGroupDetails() async {
    try {
      final fetchedGroup = widget.group;
      final userId = Provider.of<UserProvider>(context, listen: false).user?.uid ?? '';

      // Fetch the group creator's name
      final fetchedCreatorName = fetchedGroup.members.firstWhere((member) => member.id == fetchedGroup.groupCreator).name;

      // Check if the current user is a member and/or the creator of the group
      final fetchedIsMember = fetchedGroup.members.any((member) => member.id == userId);
      final fetchedIsCreator = fetchedGroup.groupCreator == userId;

      setState(() {
        group = fetchedGroup;
        creatorName = fetchedCreatorName;
        isMember = fetchedIsMember;
        isCreator = fetchedIsCreator;
      });
    } catch (e) {
      print('Error fetching group details: $e');
      showSnackBar(context, 'Failed to load group details. Please try again.');
    }
  }

  void _fetchGroupGoals() {
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);
    goalProvider.fetchGroupGoals(widget.group.groupId);
  }

  Future<void> _handleGroupAction(bool isJoin) async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      if (isJoin) {
        await groupProvider.joinGroup(group!.groupId, userProvider.user!.uid);
        showSnackBar(context, 'Joined group successfully!');
      } else {
        await groupProvider.leaveGroup(group!.groupId, userProvider.user!.uid);
        showSnackBar(context, 'Left the group successfully');
      }
      setState(() {});
    } catch (e) {
      showSnackBar(context, 'Error during group action: $e', isError: true);
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
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GoalProvider( groupId: group?.groupId, userId: widget.user.uid)),
          ChangeNotifierProvider(create: (_) => HabitProvider()),
          ChangeNotifierProvider(create: (_) => GroupProvider()),
          ],
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
              ' ${group?.groupName?? 'No Group Name'}',
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
                    begin: Alignment.bottomCenter,
                    end: Alignment.bottomRight,
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
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(134, 41, 137, 1.0), // Start color
                            Color.fromRGBO(46, 197, 187, 1.0), // End color
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30.0),
                          bottomRight: Radius.circular(30.0),
                        ),
                        border: Border.all(
                          color: Colors.transparent, // No background color for the border itself
                          width: 1.0, // Set the thickness of the border
                        ),
                      ),
                      child: Container(
                        // This inner container provides the transparent background effect
                        decoration: BoxDecoration(
                          color: Colors.transparent, // Outer container transparent
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30.0),
                            bottomRight: Radius.circular(30.0),
                          ),
                        ),
                        child: GroupInfoSection(
                          group: group!,
                          creatorName: creatorName,
                          isCreator: isCreator,
                          onMemberRemoved: (memberId) {
                            // Handle member removal here
                          },
                          onEditGroupInfo: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateGroupScreen(
                                  groupToEdit: group,
                                  onGroupUpdated: () {
                                    setState(() {
                                      // Update UI
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
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
                                      // Check if group is null before proceeding
                                      if (group == null) {
                                        showSnackBar(context, 'Group is not available', isError: true);
                                        return;
                                      }

                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AddGoalDialog(
                                            addGoalToGroup: (Goal goal) async {
                                              final goalProvider = Provider.of<GoalProvider>(context, listen: false);
                                              try {
                                                // Use the non-null groupId
                                                await goalProvider.addGoalToGroup(goal, group!.groupId);
                                                showSnackBar(context, 'Goal added to group successfully!');
                                              } catch (e) {
                                                showSnackBar(context, 'Error adding goal: $e', isError: true);
                                              }
                                            },
                                            groupId: group!.groupId,  // Access groupId with null check
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
                                    if (group == null) {
                                      showSnackBar(context, 'Group is not available', isError: true);
                                      return;
                                    }

                                    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
                                    try {
                                      await groupProvider.leaveGroup(group!.groupId, Provider.of<UserProvider>(context, listen: false).user!.uid);
                                      showSnackBar(context, 'Left the group successfully');
                                      // Optionally, you can navigate back or refresh the UI
                                      Navigator.of(context).pop(); // Close the screen or navigate as needed
                                    } catch (e) {
                                      showSnackBar(context, 'Error leaving group: $e', isError: true);
                                    }
                                  },
                                  child: const Text('Leave Group'),
                                ),
                              ],
                              if (!isMember && !isCreator) ...[
                                ElevatedButton(
                                  onPressed: () async {
                                    if (group == null) {
                                      showSnackBar(context, 'Group is not available', isError: true);
                                      return;
                                    }

                                    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
                                    final userProvider = Provider.of<UserProvider>(context, listen: false);

                                    try {
                                      await groupProvider.joinGroup(group!.groupId, userProvider.user!.uid);
                                      showSnackBar(context, 'Joined group successfully!');
                                      
                                      // Optionally, you can refresh the UI or navigate back
                                      setState(() {}); // Ensure this is necessary based on your widget's state management
                                    } catch (e) {
                                      showSnackBar(context, 'Error joining group: $e', isError: true);
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
                                GroupGoalList(groupId: group!.groupId),
                              ],
                              if (_selectedIndex == 1) ...[
                                SizedBox(height: 16.0),
                                Text('Group Habits:', style: TextStyle(fontWeight: FontWeight.bold)),
                                GroupHabitList(groupId: group!.groupId),
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

void showSnackBar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 2),
    ),
  );
}
