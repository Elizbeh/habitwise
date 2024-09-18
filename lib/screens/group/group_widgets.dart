import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/screens/data/icons/category_icons.dart';
import 'package:habitwise/services/goals_db_service.dart';
import 'package:habitwise/services/group_db_service.dart';
import 'package:habitwise/services/habit_db_service.dart';
import 'package:habitwise/widgets/goal_tile.dart';
import 'package:habitwise/widgets/habit_tile.dart';
import 'package:provider/provider.dart';

class GroupGoalList extends StatelessWidget {
  final String groupId;

  GroupGoalList({required this.groupId});

  @override
  Widget build(BuildContext context) {
    final goalDBService = Provider.of<GoalDBService>(context);

    return StreamBuilder<List<Goal>>(
      stream: goalDBService.getGroupGoalsStream(groupId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No goals found for this group.'));
        } else {
          List<Goal> goals = snapshot.data ?? [];
          print('Fetched goals: ${goals.map((goal) => goal.toMap())}');
          return goals.isEmpty
            ? Center(child: Text('No goals found.'))
            : Column(
                children: goals.map((goal) => GoalTile(goal: goal, groupId: groupId)).toList(),
              );
        }
      },
    );
  }
}
class GroupHabitList extends StatelessWidget {
  final String groupId;

  GroupHabitList({required this.groupId});

  @override
  Widget build(BuildContext context) {
    final habitDBService = Provider.of<HabitDBService>(context);

    return StreamBuilder<List<Habit>>(
      stream: habitDBService.getGroupHabitsStream(groupId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Habit> habits = snapshot.data ?? [];
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              final leadingIcon = categoryIcons[habit.category ?? ''] ?? Icons.star;
              return HabitTile(habit: habit, groupId: groupId, leadingIcon: leadingIcon);
            },
          );
        }
      },
    );
  }
}
