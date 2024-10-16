import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/providers/habit_provider.dart';

class HabitTile extends StatefulWidget {
  final Habit habit;
  final String? groupId; // Make groupId nullable for individual habits
  final IconData leadingIcon;
  final VoidCallback? onCompleted; // Callback to handle completion
  final Color backgroundColor; // Customizable background color
  final Color shadowColor; // Customizable shadow color
  final Color progressColor; // Customizable progress bar color

  const HabitTile({
    required this.habit,
    this.groupId, // Nullable for individual habits
    required this.leadingIcon,
    this.onCompleted,
    this.backgroundColor = Colors.white, // Default to white
    this.shadowColor = const Color.fromRGBO(126, 35, 191, 0.498), // Default shadow color
    this.progressColor = const Color.fromRGBO(126, 35, 191, 0.498), // Default progress color
  });

  @override
  _HabitTileState createState() => _HabitTileState();
}

class _HabitTileState extends State<HabitTile> {
  void _updateProgress(int increment) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    habitProvider.incrementHabitProgress(widget.habit.id, groupId: widget.groupId); // Pass groupId if available
  }

  @override
  Widget build(BuildContext context) {
    final double progressRatio = widget.habit.frequency > 0
        ? widget.habit.progress / widget.habit.frequency
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: widget.backgroundColor, // Use customizable background color
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: widget.shadowColor, // Use customizable shadow color
            blurRadius: 4.0,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(widget.leadingIcon),
        title: Text(widget.habit.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.habit.description),
            const SizedBox(height: 4),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: widget.habit.progress > 0
                      ? () => _updateProgress(-1)
                      : null,
                ),
                Expanded(
                  child: Container(
                    height: 8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressRatio,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                            widget.progressColor), // Use customizable progress color
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _updateProgress(1),
                ),
              ],
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
                Provider.of<HabitProvider>(context, listen: false)
                    .removeHabit(widget.habit.id, groupId: widget.groupId); // Remove habit from provider
              },
            ),
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: () {
                Provider.of<HabitProvider>(context, listen: false)
                    .markHabitAsComplete(widget.habit.id, groupId: widget.groupId); // Mark habit as complete
                if (widget.onCompleted != null) {
                  widget.onCompleted!(); // Invoke onCompleted callback
                }
              },
            ),
          ],
        ),
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
                      updatedHabit,
                      groupId: widget.groupId, // Pass groupId if available
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
