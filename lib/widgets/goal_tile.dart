import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:habitwise/screens/dialogs/edit_goal_dialog.dart';
import 'package:provider/provider.dart';
import 'package:habitwise/screens/dialogs/celebration.dart';

class GoalTile extends StatelessWidget {
  final Goal goal;
  final String? groupId;
  final Function(Goal)? onUpdateGoal;
  final Function(String)? onDeleteGoal;

  const GoalTile({
    required this.goal,
    this.groupId,
    this.onUpdateGoal,
    this.onDeleteGoal,
  });

  @override
  Widget build(BuildContext context) {
    final int progress = goal.progress?.toInt() ?? 0;
    final int target = goal.target?.toInt() ?? 1;
    final double progressRatio = target > 0 ? progress / target : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background, // Use theme's background color
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            blurRadius: 4.0,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          goal.title ?? '',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.description ?? '', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    final int updatedProgress = (progress - 1).clamp(0, target);
                    _updateProgress(context, updatedProgress);
                  },
                ),
                Expanded(
                  child: Container(
                    height: 8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressRatio,
                        backgroundColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    final int updatedProgress = (progress + 1).clamp(0, target);
                    _updateProgress(context, updatedProgress);
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Progress: $progress/$target',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Due: ${goal.targetDate?.toLocal().toString().split(' ')[0] ?? ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
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
                    addGoalToGroup: (newGoal) {
                      if (groupId != null && groupId!.isNotEmpty) {
                        Provider.of<GoalProvider>(context, listen: false)
                            .addGoalToGroup(newGoal, groupId!);
                      } else {
                        Provider.of<GoalProvider>(context, listen: false).addGoal(newGoal);
                      }
                    },
                    groupId: groupId ?? "",
                    onUpdateGoal: (updatedGoal) {
                      Provider.of<GoalProvider>(context, listen: false)
                          .updateGoal(updatedGoal);
                    },
                    onDeleteGoal: (goalId) {
                      Provider.of<GoalProvider>(context, listen: false)
                          .removeGoal(goalId);
                    },
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                if (groupId != null && groupId!.isNotEmpty) {
                  // Delete group goal
                  Provider.of<GoalProvider>(context, listen: false)
                      .removeGroupGoal(groupId!, goal.id ?? '');
                } else {
                  // Delete individual goal
                  Provider.of<GoalProvider>(context, listen: false)
                      .removeGoal(goal.id ?? '');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateProgress(BuildContext context, int updatedProgress) {
    if (groupId != null && groupId!.isNotEmpty) {
      context
          .read<GoalProvider>()
          .updateGroupGoal(goal.copyWith(progress: updatedProgress), groupId!);

      if (updatedProgress >= (goal.target ?? 0)) {
        context
            .read<GoalProvider>()
            .markGroupGoalAsCompleted(groupId!, goal.id ?? '');

        _showCompletionDialog(context);
      }
    } else {
      context
          .read<GoalProvider>()
          .updateGoal(goal.copyWith(progress: updatedProgress));

      if (updatedProgress >= (goal.target ?? 0)) {
        context
            .read<GoalProvider>()
            .markGoalAsCompleted(goal.id ?? '');

        _showCompletionDialog(context);
      }
    }
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CombinedCelebrationDialog();
      },
    );
  }
}
