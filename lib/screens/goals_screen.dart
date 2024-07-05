import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/models/user.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:habitwise/screens/dialogs/add_goal_dialog.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:habitwise/screens/dialogs/edit_goal_dialog.dart';
import 'package:habitwise/widgets/goal_tile.dart';
import 'package:habitwise/widgets/bottom_navigation_bar.dart';
import 'package:habitwise/screens/dashboard_screen.dart';
import 'package:habitwise/screens/habit_screen.dart';
import 'package:habitwise/screens/profile_screen.dart';

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
    if (widget.groupId != null) {
      Provider.of<GoalProvider>(context, listen: false).fetchGroupGoals(widget.groupId!);
    } else {
      Provider.of<GoalProvider>(context, listen: false).fetchGoals();
    }
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        toolbarHeight: 80,
        title: Text(
          'Goals',
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
          PopupMenuButton<String>(
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
          const SizedBox(width: 10),
          DropdownButton<String>(
            value: selectedCategory,
            onChanged: (String? newValue) {
              setState(() {
                selectedCategory = newValue ?? 'All';
              });
            },
            items: <String>[
              'All',
              'Health & Fitness',
              'Work & Productivity',
              'Personal Development',
              'Self-Care',
              'Finance',
              'Education',
              'Relationships',
              'Hobbies'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2035, 1, 1),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
            ),
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
                              groupId: widget.groupId!,
                            ),
                          );
                        },
                        child: GoalTile(goal: goal, groupId: widget.groupId ?? ''),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddGoalDialog(
              addGoalToGroup: (goal) async {
                try {
                  if (widget.groupId != null && widget.groupId!.isNotEmpty) {
                    await Provider.of<GoalProvider>(context, listen: false).addGoalToGroup(goal, widget.groupId ?? '');
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
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            if (index == 0) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => DashboardScreen(user: widget.user)),
              );
            } else if (index == 1) {
              // Do nothing, already on GoalScreen
            } else if (index == 2) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => HabitScreen(user: widget.user)),
              );
            } else if (index == 3) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => ProfilePage(user: widget.user)),
              );
            }
          }
        },
      ),
    );
  }
}
