import 'package:flutter/material.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/models/user.dart';
import 'package:habitwise/providers/habit_provider.dart';
import 'package:habitwise/screens/dashboard_screen.dart';
import 'package:habitwise/screens/data/icons/category_icons.dart';
import 'package:habitwise/screens/dialogs/add_habit_dialog.dart';
import 'package:habitwise/screens/goals_screen.dart';
import 'package:habitwise/screens/profile_screen.dart';
import 'package:habitwise/widgets/habit_tile.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:habitwise/widgets/bottom_navigation_bar.dart';

class HabitScreen extends StatefulWidget {
  final HabitWiseUser user;

  HabitScreen({required this.user});

  @override
  _HabitScreenState createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  String sortingCriteria = 'Priority';
  String selectedCategory = 'All';
  CalendarFormat _calendarFormat = CalendarFormat.week;
  final DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay;
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Habit> filterHabitsByCategory(List<Habit> habits, String category) {
    if (category == 'All') {
      return habits;
    } else {
      return habits.where((habit) => habit.category == category).toList();
    }
  }

  List<Habit> filterHabitsByDate(List<Habit> habits, DateTime? selectedDate) {
    if (selectedDate == null) {
      return habits;
    } else {
      return habits.where((habit) =>
        habit.startDate.isBefore(selectedDate.add(Duration(days: 1))) &&
        (habit.endDate?.isAfter(selectedDate.subtract(Duration(days: 1))) ?? true)
      ).toList();
    }
  }

  List<Habit> _sortAndFilterHabits(List<Habit> habits) {
    List<Habit> filteredHabits = filterHabitsByCategory(habits, selectedCategory);
    filteredHabits = filterHabitsByDate(filteredHabits, _selectedDay);
    
    if (sortingCriteria == 'Priority') {
      filteredHabits.sort((a, b) => a.priority.compareTo(b.priority));
    } else if (sortingCriteria == 'Completion Status') {
      filteredHabits.sort((a, b) => (a.isCompleted ? 1 : 0).compareTo(b.isCompleted ? 1 : 0));
    } else if (sortingCriteria == 'Category') {
      filteredHabits.sort((a, b) => (a.category ?? '').compareTo(b.category ?? ''));
    }

    return filteredHabits;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        title: const Text(
          'Habits',
          style: TextStyle(
            color: Colors.white
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 100),
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
                });
              },
            ),
            Consumer<HabitProvider>(
              builder: (context, HabitProvider, child) {
                final filteredHabits = _sortAndFilterHabits(HabitProvider.habits);
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredHabits.length,
                  itemBuilder: (context, index) {
                    final habit = filteredHabits[index];
                    final leadingIcon = categoryIcons[habit.category ?? ''] ?? Icons.sunny;
                    return HabitTile(habit: habit, groupId: '', leadingIcon: leadingIcon);
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
            builder: (context) => const AddHabitDialog(isGroupHabit: false),
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
                MaterialPageRoute(builder: (context) => DashboardScreen(user: widget.user)),
              );
            } else if (index == 1) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => GoalScreen(user: widget.user)),
              );
            } else if (index == 2) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HabitScreen(user: widget.user)),
              );
            } else if (index == 3) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user)),
              );
            }
          }
        },
      ),
    );
  }
}
