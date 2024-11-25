import 'dart:async';
import 'package:habitwise/main.dart';
import 'package:flutter/material.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/models/member.dart';
import 'package:habitwise/models/user.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:habitwise/providers/group_provider.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/screens/dashboard_screen.dart';
import 'package:habitwise/screens/personal_goal.dart';
import 'package:habitwise/screens/group/group_info.dart';
import 'package:habitwise/screens/group/group_widgets.dart';
import 'package:habitwise/screens/personal_habits.dart';
import 'package:habitwise/screens/profile_screen.dart';
import 'package:habitwise/screens/setting_screen.dart';
import 'package:habitwise/screens/widgets/bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:habitwise/screens/group/create_group_screen.dart';




class GroupDetailsScreen extends StatefulWidget {
  final HabitWiseGroup group;
  final HabitWiseUser user;
  final String? groupId;

  GroupDetailsScreen({required this.group, required this.user, this.groupId});

  @override
  _GroupDetailsScreenState createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  HabitWiseGroup? group;
  String creatorName = '';
  bool isMember = false;
  bool isAdmin = false;
  bool isMembersExpanded = false;
  int _selectedIndex = 0; // switch between habits and goals
  //final int _currentIndex = 0;
  bool _isDescriptionExpanded = false;

  int _currentIndex = 0; // You can handle the current tab index here

  // Function to handle the bottom navigation taps
  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    // You can handle the navigation here based on the tab
    switch (index) {
      case 0:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => DashboardScreen(  user: widget.user, groupId: widget.groupId ?? '', )));
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => GoalScreen(user: widget.user, groupId: widget.groupId ?? '', )));
        break;
      case 2:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => HabitScreen( user: widget.user, groupId: widget.groupId ?? '', )));
        break;
      case 3:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user)));
        break;
      case 4:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsPage(themeNotifier: appThemeNotifier,)));
        break;
      default:
        break;
    }
  }



  
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
      final userId = Provider.of<UserProvider>(context, listen: false).currentUser?.uid ?? '';

      // Fetch the creator's name by checking the members
      final fetchedCreator = fetchedGroup.members.firstWhere(
        (member) => member.role == MemberRole.admin, // Check for admin role
        orElse: () => Member(id: '', name: 'Unknown', role: MemberRole.member, email: ''),
      );
      final fetchedCreatorName = fetchedCreator.name;

      // Check if the current user is a member and their role
      final fetchedMember = fetchedGroup.members.firstWhere(
        (member) => member.id == userId,
        orElse: () => Member(id: '', name: '', role: MemberRole.member, email: ''),
      );

      // Check if the user is an admin
      final userRole = fetchedMember.role;
      final isAdminUser = userRole == MemberRole.admin; // Determine if the user is an admin

      setState(() {
        group = fetchedGroup;
        creatorName = fetchedCreatorName;
        isMember = fetchedMember.id.isNotEmpty;
        isAdmin = isAdminUser; // Set isAdmin based on the member role
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
        await groupProvider.joinGroup(group!.groupCode, userProvider.currentUser!.uid, context);
        showSnackBar(context, 'Joined group successfully!');
      } else {
        await groupProvider.leaveGroup(group!.groupId, userProvider.currentUser!.uid);
        showSnackBar(context, 'Left the group successfully');
      }
      setState(() {});
    } catch (e) {
      showSnackBar(context, 'Error during group action: $e', isError: true);
    }
  }    
    
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        extendBodyBehindAppBar: true,
         appBar: AppBar(
          backgroundColor: Colors.transparent, // Make AppBar background transparent
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(134, 41, 137, 1.0), // First color
                  Color.fromRGBO(181, 58, 185, 1.0), // Second color (optional)
                  Color.fromRGBO(46, 197, 187, 1.0), // Third color (optional)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
           ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      group!.groupName ?? 'Group Name',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                  ),
                 ),
                  Text(
                   ' ${group!.groupCode ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(0, 255, 255, 1.0)
                       ),
                    ),
                  ],
                ),
                SizedBox(height: 4.0),
                GestureDetector(
                        onTap: () {
                          setState(() {
                            _isDescriptionExpanded = !_isDescriptionExpanded;
                          });
                        },
                        child: Text(
                          group!.description != null
                              ? _isDescriptionExpanded
                                  ? group!.description // Show full text when expanded
                                  : (group!.description!.length > 30
                                      ? '${group!.description!.substring(0, 30)}...' // Show first 20 chars + ellipsis
                                      : group!.description!) // Show complete if it's less than or equal to 20 chars
                              : 'No description available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),  
                    ],
                  ),
                        
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
                                  isAdmin: isAdmin,
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
                                          }, user: widget.user,
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
                                 if (isMember && !isAdmin) ...[
                            ElevatedButton(
                              onPressed: () async {
                                if (group == null) {
                                  showSnackBar(context, 'Group is not available', isError: true);
                                  return;
                                }

                                final groupProvider = Provider.of<GroupProvider>(context, listen: false);
                                try {
                                  await groupProvider.leaveGroup(group!.groupId, Provider.of<UserProvider>(context, listen: false).currentUser!.uid);
                                  showSnackBar(context, 'Left the group successfully');
                                  
                                  // Close the screen to remove it from the stack
                                  Navigator.of(context).pop();
                                  
                                  // Optionally refresh the UI or navigate to another screen
                                  // You can call another method here if needed to refresh parent widget
                                } catch (e) {
                                  showSnackBar(context, 'Error leaving group: $e', isError: true);
                                }
                              },
                              child: const Text('Leave Group'),
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
                                        GroupGoalList(groupId: group!.groupId, isAdmin: true,),
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
                onTap: _onTap,
                themeNotifier: ValueNotifier(ThemeMode.light), // Pass theme if needed
              ),
          );
    }
}

void showSnackBar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Color.fromARGB(255, 224, 135, 129) : const Color.fromARGB(255, 111, 185, 114),
      duration: const Duration(seconds: 2),
    ),
  );
}
