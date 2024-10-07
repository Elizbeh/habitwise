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
            automaticallyImplyLeading: false, // Remove default back button
            iconTheme: IconThemeData(color: Colors.white), // White icons
            elevation: 0,
            toolbarHeight: 150, // Increase height to create space for title and categories
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
                      'Routine Builder',
                      style: theme.appBarTheme.titleTextStyle?.copyWith(color: Colors.white), // White title
                    ),
                    const Spacer(), // Use Spacer to push the vertical menu icon to the right
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
                const SizedBox(height: 10), // Space between title and categories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <String>[
                      'All',
                      'Health',
                      'Work',
                      'Personal',
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
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: selectedCategory == category ? Colors.black : Colors.white,
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
                Divider(height: 10.0, thickness: 2.0),
                Expanded(
                  child: Consumer<HabitProvider>(
                    builder: (context, habitProvider, child) {
                      final filteredHabits = _sortAndFilterHabits(habitProvider.personalHabits);
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
                              habitProvider.markHabitAsComplete(habit.id, groupId: '' );
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
