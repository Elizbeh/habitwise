import 'package:flutter/material.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/providers/habit_provider.dart';
import 'package:provider/provider.dart';
import 'package:habitwise/services/habit_db_service.dart';


void _showEditHabitDialog(BuildContext context, Habit habit, bool isGroupHabit, String? groupId) {
  final TextEditingController titleController = TextEditingController(text: habit.title);
  final TextEditingController descriptionController = TextEditingController(text: habit.description);
  final TextEditingController frequencyController = TextEditingController(text: habit.frequency.toString());
  String? editedCategory = habit.category ?? 'All';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Habit'),
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
                    value: editedCategory,
                    hint: const Text('Select Category'),
                    onChanged: (String? newValue) {
                      setState(() {
                        editedCategory = newValue;
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
                  final updatedHabit = Habit(
                    id: habit.id,
                    title: titleController.text,
                    description: descriptionController.text,
                    createdAt: habit.createdAt,
                    startDate: habit.startDate,
                    frequency: int.tryParse(frequencyController.text) ?? habit.frequency,
                    isCompleted: habit.isCompleted,
                    category: editedCategory,
                  );
                  if (isGroupHabit && groupId != null) {
                    HabitDBService().updateGroupHabit(groupId, updatedHabit).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Habit updated successfully!')),
                      );
                      Navigator.pop(context);
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating habit: $error')),
                      );
                    });
                  } else {
                    Provider.of<HabitProvider>(context, listen: false).updateHabit(habit.id, updatedHabit);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      );
    },
  );
}