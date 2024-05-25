import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:provider/provider.dart';

class AddGoalDialog extends StatefulWidget {
  @override
  _AddGoalDialogState createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController progressController = TextEditingController();
  final TextEditingController targetController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Goal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: progressController,
              decoration: const InputDecoration(labelText: 'Progress'),
            ),
            TextField(
              controller: targetController,
              decoration: const InputDecoration(labelText: 'Target (e.g., 100%)'),
              keyboardType: TextInputType.number,
            ),
            ListTile(
                            title: Text('Select Date'),
              subtitle: Text('${selectedDate.year}-${selectedDate.month}-${selectedDate.day}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2022),
                  lastDate: DateTime(2030),
                );
                if (pickedDate != null && pickedDate != selectedDate) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
            ),
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
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final newGoal = Goal(
              id: DateTime.now().toString(),
              title: titleController.text,
              description: descriptionController.text,
              progress:int.tryParse(progressController.text) ?? 0,
              target: int.tryParse(targetController.text) ?? 1,
              targetDate: selectedDate,
              category: selectedCategory,
            );
            Provider.of<GoalProvider>(context, listen: false).addGoal(newGoal);
            Navigator.pop(context);
          },
          child: const Text('Add Goal'),
        ),
      ],
    );
  }
}
