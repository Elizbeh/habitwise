// Import necessary packages
import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:habitwise/screens/dialogs/edit_goal_dialog.dart';
import 'package:provider/provider.dart';

// Widget for displaying a single goal in a tile format
class GoalTile extends StatelessWidget {
  final Goal goal;

  const GoalTile({required this.goal});

  @override
  Widget build(BuildContext context) {
    // Calculate progress and target values
    final num progress = goal.progress ?? 0;
    final num target = goal.target ?? 1;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(126, 35, 191, 0.498),
            blurRadius: 4.0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.description),
            const SizedBox(height: 4),
            // Display progress indicators based on progress and target
            Row(
              children: List.generate(target.toInt(), (index) {
                return IconButton(
                  icon: Icon(
                    progress > index ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: progress > index ? Colors.green : Colors.grey,
                  ),
                  onPressed: () {
                    final updatedProgress = index + 1;
                    Provider.of<GoalProvider>(context, listen: false).updateGoal(
                      goal.copyWith(progress: updatedProgress),
                    );
                    if (updatedProgress == target) {
                      Provider.of<GoalProvider>(context, listen: false).markGoalAsCompleted(goal.id);
                    }
                  },
                );
              }),
            ),
            const SizedBox(height: 4),
            Text('Progress: $progress/$target', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            // Display due date
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Due: ${goal.targetDate.toLocal().toString().split(' ')[0]}', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => EditGoalDialog(
                    goal: goal,
                    addGoalToGroup: (Goal newGoal) {
                      Provider.of<GoalProvider>(context, listen: false).updateGoal(newGoal);
                    },
                  ),
                );
              },
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                Provider.of<GoalProvider>(context, listen: false).removeGoal(goal.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
