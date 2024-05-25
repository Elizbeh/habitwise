import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:provider/provider.dart';

class GoalTile extends StatelessWidget {
  final Goal goal;

  const GoalTile({required this.goal});

  @override
  Widget build(BuildContext context) {
     // Provide deafault values if goal.progress or goal target is null
      final num progress = goal.progress ??  0.0;
      final num target = goal.target ?? 1.0;

      print('Goal progress: $progress, Goal target: $target');
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(goal.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.description),
            SizedBox(height: 4),
            LinearProgressIndicator(
              value: goal.progress / goal.target,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 4),
            Text('Progress: ${goal.progress}/${goal.target}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Implement edit goal functionality. TODO...
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
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
