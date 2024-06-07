import 'package:flutter/material.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/providers/habit_provider.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/screens/data/habit_templates.dart';
import 'package:provider/provider.dart';


class AddHabitDialog extends StatefulWidget {
  final String? groupId;
  final bool isGroupHabit;// Add groupId for group habits, null for personal habits

  const AddHabitDialog({
    Key? key, 
    this.groupId,
    required this.isGroupHabit,
    }) : super(key:key);

  @override
  _AddHabitDialogState createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController frequencyController = TextEditingController();
  String selectedCategory = 'All';
  String? selectedTemplate;

  void applyTemplate(Map<String, dynamic> template) {
    setState(() {
      titleController.text = template['title'];
      descriptionController.text = template['description'];
      frequencyController.text = template['frequency'].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Habit'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue!;
                  selectedTemplate = null;
                });
              },
              items: <String>['All', ...habitTemplates.keys]
                  .map<DropdownMenuItem<String>>((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
            if (selectedCategory != 'All')
              DropdownButton<String>(
                value: selectedTemplate,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTemplate = newValue!;
                    applyTemplate(habitTemplates[selectedCategory]!
                        .firstWhere((template) => template['title'] == newValue));
                  });
                },
                items: habitTemplates[selectedCategory]!
                    .map<DropdownMenuItem<String>>((template) {
                  return DropdownMenuItem<String>(
                    value: template['title'],
                    child: Text(template['title']),
                  );
                }).toList(),
              ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Habit Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Habit Description'),
            ),
            TextField(
              controller: frequencyController,
              decoration: const InputDecoration(labelText: 'Frequency per Day'),
              keyboardType: TextInputType.number,
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
              groupId: widget.isGroupHabit ? widget.groupId: null, // Assign groupId if it's a group habit
            );
            // Determine where to add the habit based on whether it's a group habit
            if (widget.isGroupHabit) {
              // Add the habit to the group details screen
              Provider.of<HabitProvider>(context, listen: false).addHabit(widget.groupId!, newHabit);
            } else {
              // Add the habit to the individual habit screen using the user's UID
              final userId = Provider.of<UserProvider>(context, listen: false).user?.uid;
              if (userId != null) {
                Provider.of<HabitProvider>(context, listen: false).addHabit(userId, newHabit);
              }
            }
            Navigator.pop(context);
          },
          child: const Text('Add Habit'),
        ),
      ],
    );
  }
}
