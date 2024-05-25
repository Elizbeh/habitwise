import 'package:flutter/material.dart';
import 'package:habitwise/providers/habit_provider.dart';
import 'package:provider/provider.dart';
import 'package:habitwise/models/habit.dart';
class HabitTile extends StatefulWidget {
  final Habit habit;

  const HabitTile({required this.habit});

  @override
  _HabitTileState createState() => _HabitTileState();
}

class _HabitTileState extends State<HabitTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white, // Background color of the tile
        borderRadius: BorderRadius.circular(10.0), // Radius
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(2, 2),
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
            SizedBox(height: 4),
            LinearProgressIndicator(
              value: widget.habit.progress / widget.habit.frequency,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 4),
            Text('Progress: ${widget.habit.progress}/${widget.habit.frequency}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                _showEditHabitDialog(context, widget.habit);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                Provider.of<HabitProvider>(context, listen: false).removeHabit(widget.habit.id);
              },
            ),
          ],
        ),
        onTap: () {
          Provider.of<HabitProvider>(context, listen: false).updateHabit(
            widget.habit.id,
            widget.habit.incrementProgress(),
          );
        },
      ),
    );
  }

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
              title: Text('Edit Habit'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                    ),
                    TextField(
                      controller: frequencyController,
                      decoration: InputDecoration(labelText: 'Frequency (times per day)'),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButton<String>(
                      value: selectedCategory,
                      hint: Text('Select Category'),
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
                  child: Text('Cancel'),
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
                    );
                    Navigator.pop(context);
                  },
                  child: Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

  
