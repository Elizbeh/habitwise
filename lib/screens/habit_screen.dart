import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:habitwise/main.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/models/user.dart';
import 'package:habitwise/providers/habit_provider.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/screens/dashboard_screen.dart';
import 'package:habitwise/screens/goals_screen.dart';
import 'package:habitwise/screens/profile_screen.dart';
import 'package:habitwise/widgets/habit_tile.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:habitwise/widgets/bottom_navigation_bar.dart';
import 'package:habitwise/screens/dialogs/add_habit_dialog.dart';
import 'package:habitwise/screens/data/icons/category_icons.dart';

class HabitScreen extends StatefulWidget {
  final HabitWiseUser user;
  final String groupId;

  HabitScreen({required this.user, required this.groupId});

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

  List<Habit> filterHabitsByDate(List<Habit> habits, DateTime selectedDate) {
    return habits.where((habit) =>
        habit.startDate.isBefore(selectedDate.add(Duration(days: 1))) &&
        (habit.endDate?.isAfter(selectedDate.subtract(Duration(days: 1))) ?? true)).toList();
  }

  List<Habit> _sortAndFilterHabits(List<Habit> habits) {
    List<Habit> filteredHabits = filterHabitsByCategory(habits, selectedCategory);
    filteredHabits = filterHabitsByDate(filteredHabits, _selectedDay);

    switch (sortingCriteria) {
      case 'Priority':
        filteredHabits.sort((a, b) => a.priority.compareTo(b.priority));
        break;
      case 'Completion Status':
        filteredHabits.sort((a, b) => (a.isCompleted ? 1 : 0).compareTo(b.isCompleted ? 1 : 0));
        break;
      case 'Category':
        filteredHabits.sort((a, b) => (a.category ?? '').compareTo(b.category ?? ''));
        break;
    }

    return filteredHabits;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, themeMode, child) {
        final isDarkMode = themeMode == ThemeMode.dark;
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
            elevation: 0,
            toolbarHeight: 80,
            title: Text(
              'Habits',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.white,
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
                    const Color.fromRGBO(126, 35, 191, 0.498),
                    const Color.fromARGB(255, 93, 156, 164),
                    const Color.fromARGB(233, 93, 59, 99),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
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
                    child: Text(
                      value,
                      style: TextStyle(color: Colors.white,)
                    ),
                  );
                }).toList(),
              ),
              IconButton(
                color: isDarkMode ? Colors.white : Colors.black,
                icon: const Icon(Icons.logout),
                onPressed: () {
                  Provider.of<UserProvider>(context, listen: false).logoutUser();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2035, 1, 1),
                  focusedDay: _selectedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
                Expanded(
                  child: Consumer<HabitProvider>(
                    builder: (context, habitProvider, child) {
                      final filteredHabits = _sortAndFilterHabits(habitProvider.habits);
                      if (filteredHabits.isEmpty) {
                        return Center(child: Text('No habits found for the selected criteria.'));
                      }
                      return ListView.builder(
                        itemCount: filteredHabits.length,
                        itemBuilder: (context, index) {
                          final habit = filteredHabits[index];
                          final leadingIcon = categoryIcons[habit.category ?? ''] ?? Icons.sunny;
                          return HabitTile(
                            habit: habit,
                            groupId: widget.groupId,
                            leadingIcon: leadingIcon,
                            onCompleted: () {
                              // Function to mark habit as completed
                              habitProvider.markHabitAsComplete(widget.groupId, habit.id);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
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
                Widget destinationScreen;
                switch (index) {
                  case 0:
                    destinationScreen = DashboardScreen(user: widget.user, groupId: widget.groupId);
                    break;
                  case 1:
                    destinationScreen = GoalScreen(user: widget.user);
                    break;
                  case 2:
                    destinationScreen = HabitScreen(user: widget.user, groupId: widget.groupId);
                    break;
                  case 3:
                    destinationScreen = ProfilePage(user: widget.user);
                    break;
                  default:
                    return;
                }
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => destinationScreen),
                               );
              }
            },
            themeNotifier: appThemeNotifier, // Pass the themeNotifier to the BottomNavigationBarWidget
          ),
        );
      },
    );
  }
}
