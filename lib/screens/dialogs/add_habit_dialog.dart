import 'package:flutter/material.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/providers/habit_provider.dart';
import 'package:provider/provider.dart';

class AddHabitDialog extends StatefulWidget {
  @override
  _AddHabitDialogState createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController frequencyController = TextEditingController();
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Habit'),
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
              controller: frequencyController,
              decoration: const InputDecoration(labelText: 'Frequency (times per day)'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: selectedCategory == 'All' ? null : selectedCategory,
              hint: const Text('Select Category'),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue ?? 'All';
                });
              },
              items: <String>[
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
            final newHabit = Habit(
              id: DateTime.now().toString(),
              title: titleController.text,
              description: descriptionController.text,
              createdAt: DateTime.now(),
              startDate: DateTime.now(),
              frequency: int.tryParse(frequencyController.text) ?? 1,
              isCompleted: false,
              category: selectedCategory,
            );
            Provider.of<HabitProvider>(context, listen: false).addHabit(newHabit);
            Navigator.pop(context);
          },
          child: const Text('Add Habit'),
        ),
      ],
    );
  }
}
