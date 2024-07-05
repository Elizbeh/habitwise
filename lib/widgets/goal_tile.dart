import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:habitwise/screens/dialogs/edit_goal_dialog.dart';
import 'package:provider/provider.dart';

class GoalTile extends StatelessWidget {
  final Goal goal;
  final String groupId; 
  final Function(Goal)? onUpdateGoal;
  final Function(String)? onDeleteGoal;

  const GoalTile({
    required this.goal, 
    required this.groupId,
    this.onUpdateGoal,
    this.onDeleteGoal,}); // Initialize groupId

  @override
  Widget build(BuildContext context) {
    final int progress = goal.progress?.toInt() ?? 0;
    final int target = goal.target?.toInt() ?? 1;
    final double progressRatio = progress / target;

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
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    final int updatedProgress = (progress - 1).clamp(0, target);
                    _updateProgress(context, goal, updatedProgress);
                  },
                ),
                Expanded(
                  child: Container(
                    height: 8, // Set the desired height for the progress bar
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8), // Set the desired radius
                      child: LinearProgressIndicator(
                        value: progressRatio,
                        backgroundColor: Colors.grey[300],
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    final int updatedProgress = (progress + 1).clamp(0, target);
                    _updateProgress(context, goal, updatedProgress);
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Progress: $progress/$target', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Due: ${goal.targetDate.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => EditGoalDialog(
                    goal: goal,
                    groupId: groupId,
                    addGoalToGroup: (newGoal) {
                      Provider.of<GoalProvider>(context, listen: false).addGoal(goal); // Add goal to main goals list
                      if (goal != null) {
                        Provider.of<GoalProvider>(context, listen: false).addGoal(goal); // Add goal to group-specific goals list
                      }
                    },

                    onUpdateGoal: (updatedGoal) {
                       Provider.of<GoalProvider>(context, listen: false).updateGoal(updatedGoal);
                    },
                    onDeleteGoal: (goalId) {
                      Provider.of<GoalProvider>(context, listen: false).removeGoal(goalId);
                    },
                  ),
                );
              },
            ),
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

  void _updateProgress(BuildContext context, Goal goal, int updatedProgress) {
    Provider.of<GoalProvider>(context, listen: false).updateGoal(goal.copyWith(progress: updatedProgress));
    if (updatedProgress == goal.target) {
      Provider.of<GoalProvider>(context, listen: false).markGoalAsCompleted(goal.id);
    }
  }
}
