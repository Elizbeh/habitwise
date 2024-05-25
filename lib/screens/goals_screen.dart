import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/models/user.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:habitwise/screens/dashboard_screen.dart';
import 'package:habitwise/screens/dialogs/add_goal_dialog.dart';
import 'package:habitwise/screens/habit_screen.dart';
import 'package:habitwise/screens/profile_screen.dart';
import 'package:habitwise/widgets/goal_tile.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:habitwise/widgets/bottom_navigation_bar.dart';

class GoalScreen extends StatefulWidget {
  final HabitWiseUser user; // Add this line

  GoalScreen({required this.user}); // Modify constructor

  @override
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  String sortingCriteria = 'Priority';
  String selectedCategory = 'All'; // Default category selection
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay;
  int _currentIndex = 1; // Assuming GoalScreen is at index 1

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    Provider.of<GoalProvider>(context, listen: false).fetchGoals();
  }

  // Filter goals based on category
  List<Goal> filterGoalsByCategory(List<Goal> goals, String category) {
    if (category == 'All') {
      return goals; // No need for filtering, returns all goals
    } else {
      return goals.where((goal) => goal.category == category).toList();
    }
  }

  // Filter goals based on the selected date
  List<Goal> filterGoalsByDate(List<Goal> goals, DateTime? selectedDate) {
    if (selectedDate == null) {
      return goals; // Returns all goals if no date is selected
    } else {
      return goals.where((goal) =>
        goal.targetDate.isBefore(selectedDate.add(Duration(days: 1))) &&
        (goal.endDate?.isAfter(selectedDate.subtract(Duration(days: 1))) ?? true)
      ).toList();
    }
  }

  List<Goal> _sortAndFilterGoals(List<Goal> goals) {
    List<Goal> filteredGoals = filterGoalsByCategory(goals, selectedCategory);
    filteredGoals = filterGoalsByDate(filteredGoals, _selectedDay);
    
    // Sort filtered goals based on sorting criteria
    if (sortingCriteria == 'Priority') {
      filteredGoals.sort((a, b) => a.priority.compareTo(b.priority));
    } else if (sortingCriteria == 'Completion Status') {
      filteredGoals.sort((a, b) => (a.isCompleted ? 1 : 0).compareTo(b.isCompleted ? 1 : 0));
    } else if (sortingCriteria == 'Category') {
      filteredGoals.sort((a, b) => (a.category ?? '').compareTo(b.category ?? ''));
    }

    return filteredGoals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  Color.fromRGBO(126, 35, 191, 0.498),
        title: const Text('Goals'),
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
                selectedCategory = newValue ?? 'All'; // Update selected category
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
          )
        ],
      ),
      body: SingleChildScrollView(
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
                  if (format == CalendarFormat.week) {
                    _calendarFormat = CalendarFormat.week;
                  } else if (format == CalendarFormat.twoWeeks) {
                    _calendarFormat = CalendarFormat.twoWeeks;
                  } else {
                    _calendarFormat = CalendarFormat.month;
                  }
                });
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                });
              },
            ),
            Consumer<GoalProvider>(
              builder: (context, provider, child) {
                final filteredGoals = _sortAndFilterGoals(provider.goals); // apply sorting and filtering
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredGoals.length,
                  itemBuilder: (context, index) {
                    final goal = filteredGoals[index];
                    return GoalTile(goal: goal);
                  },
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddGoalDialog(),
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
                MaterialPageRoute(builder: (context) => DashboardScreen(user: widget.user)), // Pass the user
              );
            } else if (index == 1) {
              // Already on GoalScreen, do nothing
            } else if (index == 2) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HabitScreen(user: widget.user)), // Pass the user
              );
            } else if (index == 3) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user)), // Pass the user
              );
            }
          }
        },
      ),
    );
  }
}
