// This widget represents a tile for displaying a habit item, including its title, description, progress, and actions like editing and deleting.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/providers/habit_provider.dart';

class HabitTile extends StatefulWidget {
  final Habit habit;
  final String groupId;

  const HabitTile({required this.groupId, required this.habit});

  @override
  _HabitTileState createState() => _HabitTileState();
}

class _HabitTileState extends State<HabitTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white, // Background color of the tile
        borderRadius: BorderRadius.circular(10.0), // Radius
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero, // Remove default ListTile padding
        title: Text(widget.habit.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.habit.description),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: widget.habit.progress / widget.habit.frequency,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 4),
            Text('Progress: ${widget.habit.progress}/${widget.habit.frequency}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _showEditHabitDialog(context, widget.habit); // Show edit habit dialog
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                Provider.of<HabitProvider>(context, listen: false).removeHabit(widget.groupId, widget.habit.id); // Remove habit from provider
              },
            ),
          ],
        ),
        onTap: () {
          Provider.of<HabitProvider>(context, listen: false).updateHabit(
            widget.habit.id,
            widget.habit.incrementProgress(),
          ); // Update habit progress
        },
      ),
    );
  }

  // Method to show edit habit dialog
  void _showEditHabitDialog(BuildContext context, Habit habit) {
    final TextEditingController titleController = TextEditingController(text: habit.title);
    final TextEditingController descriptionController = TextEditingController(text: habit.description);
    final TextEditingController frequencyController = TextEditingController(text: habit.frequency.toString());
    String? selectedCategory = habit.category;

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
                      value: selectedCategory,
                      hint: const Text('Select Category'),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue;
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
                    final updatedHabit = habit.copyWith(
                      title: titleController.text,
                      description: descriptionController.text,
                      frequency: int.tryParse(frequencyController.text) ?? 1,
                      category: selectedCategory,
                    );
                    Provider.of<HabitProvider>(context, listen: false).updateHabit(
                      habit.id,
                      updatedHabit,
                    ); // Update habit in provider
                    Navigator.pop(context);
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
}
