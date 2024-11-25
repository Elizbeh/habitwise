import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/models/user.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:habitwise/screens/dialogs/add_goal_dialog.dart';
import 'package:habitwise/screens/widgets/custom-calendar.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:habitwise/screens/dialogs/edit_goal_dialog.dart';
import 'package:habitwise/screens/widgets/goal_tile.dart';
import 'package:habitwise/screens/widgets/bottom_navigation_bar.dart';
import 'package:habitwise/screens/dashboard_screen.dart';
import 'package:habitwise/screens/personal_habits.dart';
import 'package:habitwise/screens/profile_screen.dart';
import '../main.dart';

// Define the gradient colors as constants
const List<Color> appBarGradientColors = [
  Color.fromRGBO(134, 41, 137, 1.0),
  Color.fromRGBO(181, 58, 185, 1),
  Color.fromRGBO(46, 197, 187, 1.0),
];

class GoalScreen extends StatefulWidget {
  final HabitWiseUser user;
  final String? groupId;

  GoalScreen({required this.user, this.groupId});

  @override
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  String sortingCriteria = 'Priority';
  String selectedCategory = 'All';
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    Provider.of<GoalProvider>(context, listen: false).fetchGoals();
  }

  List<Goal> _sortAndFilterGoals(List<Goal> goals) {
    List<Goal> filteredGoals = goals.where((goal) {
      if (selectedCategory != 'All' && goal.category != selectedCategory) {
        return false;
      }
      if (goal.targetDate == null) {
        return false;
      }
      return goal.targetDate.isBefore(_selectedDay.add(Duration(days: 1))) &&
          (goal.endDate?.isAfter(_selectedDay.subtract(Duration(days: 1))) ?? true);
    }).toList();

    if (sortingCriteria == 'Priority') {
      filteredGoals.sort((a, b) => a.priority.compareTo(b.priority));
    } else if (sortingCriteria == 'Completion Status') {
      filteredGoals.sort((a, b) => (a.isCompleted ? 1 : 0).compareTo(b.isCompleted ? 1 : 0));
    } else if (sortingCriteria == 'Category') {
      filteredGoals.sort((a, b) => a.category.compareTo(b.category));
    }

    return filteredGoals;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        
  automaticallyImplyLeading: false, // Remove default back button
  iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.white), // White icons from theme
  elevation: 0,
  toolbarHeight: 120, // Increase height to create space for title and categories
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop(); // Navigate back
            },
            child: Icon(Icons.arrow_back, color: Colors.white), // Custom back arrow icon
          ),
          const SizedBox(width: 10), // Space between the back icon and title
          Text(
            'Personal Goal Board',
            style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(color: Colors.white), // White title from theme
          ),
          const Spacer(), 
          const SizedBox(width: 16),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (String result) {
              setState(() {
                sortingCriteria = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Priority',
                child: Text('Priority'),
              ),
              const PopupMenuItem<String>(
                value: 'Completion Status',
                child: Text('Completion Status'),
              ),
              const PopupMenuItem<String>(
                value: 'Category',
                child: Text('Category'),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 10), // Space between title and categories
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <String>[
            'All',
            'Health & Fitness',
            'Work & Productivity',
            'Personal Development',
            'Self-Care',
            'Finance',
            'Education',
            'Relationships',
            'Hobbies',
          ].map((category) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = category;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5), // Reduced padding
                margin: EdgeInsets.symmetric(horizontal: 4), // Reduced margin
                decoration: BoxDecoration(
                  color: selectedCategory == category ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: selectedCategory == category ? Colors.black : Colors.white,
                    fontSize: 18
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ],
  ),
  centerTitle: false,
  flexibleSpace: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(0),
        bottomRight: Radius.circular(50),
      ),
      gradient: LinearGradient(
        colors: appBarGradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(0),
        bottomRight: Radius.circular(50),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          color: Colors.transparent,
        ),
      ),
    ),
  ),
),

      body: SafeArea(
        child: Column(
          children: [
            CustomCalendar(),
            Divider(color: Colors.grey),
            Expanded(
              child: Consumer<GoalProvider>(
                builder: (context, provider, child) {
                  final filteredGoals = _sortAndFilterGoals(provider.goals);
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredGoals.length,
                    itemBuilder: (context, index) {
                      final goal = filteredGoals[index];
                      return GestureDetector(
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) => EditGoalDialog(
                              goal: goal,
                              onUpdateGoal: (updatedGoal) {
                                Provider.of<GoalProvider>(context, listen: false).updateGoal(updatedGoal);
                              },
                              onDeleteGoal: (goalId) {
                                Provider.of<GoalProvider>(context, listen: false).removeGoal(goalId);
                              },
                              addGoalToGroup: (Goal newGoal) {
                                // Handle the updated goal ...
                              },
                              groupId: widget.groupId ?? '',
                            ),
                          );
                        },
                        child: GoalTile(goal: goal, groupId: widget.groupId ?? '', isAdmin: true,),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddGoalDialog(
              addGoalToGroup: (goal) async {
                try {
                  if (widget.groupId != null && widget.groupId!.isNotEmpty) {
                    await Provider.of<GoalProvider>(context, listen: false).addGoalToGroup(goal, widget.groupId!);
                  } else {
                    await Provider.of<GoalProvider>(context, listen: false).addGoal(goal);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Goal added successfully!'),
                    duration: Duration(seconds: 2),
                  ));
                } catch (error) {
                  print("Error adding goal: $error");
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Error adding goal: $error'),
                    duration: Duration(seconds: 2),
                  ));
                }
              },
              groupId: widget.groupId ?? '',
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white,),
        backgroundColor: theme.primaryColor,
        
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            if (index == 0) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => DashboardScreen(
                    user: widget.user,
                    groupId: widget.groupId ?? '', 
                  ),
                ),
              );
            } else if (index == 2) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => HabitScreen(
                    user: widget.user,
                    groupId: widget.groupId ?? '', 
                  ),
                ),
              );
            } else if (index == 3) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ProfilePage(user: widget.user),
                ),
              );
            }
          }
        }, themeNotifier: appThemeNotifier,
      ),
    );
  }
}
