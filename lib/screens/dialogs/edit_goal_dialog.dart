import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:provider/provider.dart';

class EditGoalDialog extends StatefulWidget {
  final Goal goal;

  EditGoalDialog({required this.goal});

  @override
  _EditGoalDialogState createState() => _EditGoalDialogState();
}

class _EditGoalDialogState extends State<EditGoalDialog> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController progressController;
  late TextEditingController targetController;
  DateTime selectedDate = DateTime.now();
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.goal.title);
    descriptionController = TextEditingController(text: widget.goal.description);
    progressController = TextEditingController(text: widget.goal.progress.toString());
    targetController = TextEditingController(text: widget.goal.target.toString());
    selectedDate = widget.goal.targetDate;
    selectedCategory = widget.goal.category;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Goal'),
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
              keyboardType: TextInputType.number,
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
            final updatedGoal = Goal(
              id: widget.goal.id,
              title: titleController.text,
              description: descriptionController.text,
              progress: int.tryParse(progressController.text) ?? widget.goal.progress,
              target: int.tryParse(targetController.text) ?? widget.goal.target,
              targetDate: selectedDate,
              category: selectedCategory,
            );
            Provider.of<GoalProvider>(context, listen: false).updateGoal(updatedGoal);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
