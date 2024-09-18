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
import 'package:habitwise/widgets/custom-calendar.dart';
import 'package:habitwise/widgets/habit_tile.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:habitwise/widgets/bottom_navigation_bar.dart';
import 'package:habitwise/screens/dialogs/add_habit_dialog.dart';
import 'package:habitwise/screens/data/icons/category_icons.dart';

// Define the gradient colors as constants
const List<Color> appBarGradientColors = [
    Color.fromRGBO(134, 41, 137, 1.0),
    Color.fromRGBO(181, 58, 185, 1),
    Color.fromRGBO(46, 197, 187, 1.0),
];

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
    final theme = Theme.of(context);
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, themeMode, child) {
        final isDarkMode = themeMode == ThemeMode.dark;
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white), // Back arrow icon
              onPressed: () {
                Navigator.of(context).pop(); // Navigate back
              },
            ),
            iconTheme: IconThemeData(color: Colors.white), // White icons
            elevation: 0,
            toolbarHeight: 80,
            title: Align(
              alignment: Alignment.centerLeft, // Align the title to the left
              child: Text(
                'Habits',
                style: theme.appBarTheme.titleTextStyle?.copyWith(color: Colors.white), // White title
              ),
            ),
            centerTitle: false, // Disable center title
            flexibleSpace: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                gradient: LinearGradient(
                  colors: appBarGradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
              DropdownButton<String>(
                value: selectedCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue ?? 'All';
                  });
                },
                underline: SizedBox(), // Remove underline
                icon: Icon(Icons.arrow_drop_down, color: Colors.white), // White dropdown icon
                style: TextStyle(color: Colors.white), // White text in dropdown
                dropdownColor: theme.scaffoldBackgroundColor, // Dropdown uses the theme background
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
                isDense: true, // Make dropdown compact
              ),
              const SizedBox(width: 20), // Space between DropdownButton and the right-side button
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.white), // 3-dotted icon in white
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
          body: SafeArea(
            child: Column(
              children: [
                CustomCalendar(),
                Divider(height: 10.0, thickness: 2.0),
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
            child: const Icon(Icons.add, color: Colors.white,),
            backgroundColor: theme.primaryColor,
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
