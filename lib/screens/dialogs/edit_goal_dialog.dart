import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:habitwise/screens/data/goal_helper.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditGoalDialog extends StatefulWidget {
  final Goal? goal; // Goal object for editing, null for adding
  final void Function(Goal) addGoalToGroup; // Function to add goal to group

  EditGoalDialog({this.goal, required this.addGoalToGroup});

  @override
  _EditGoalDialogState createState() => _EditGoalDialogState();
}

class _EditGoalDialogState extends State<EditGoalDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal?.title ?? '');
    _descriptionController = TextEditingController(text: widget.goal?.description ?? '');
    _targetController = TextEditingController(text: widget.goal?.target.toString() ?? '');
    _selectedDate = widget.goal?.targetDate ?? DateTime.now();
    _selectedTime = TimeOfDay.fromDateTime(widget.goal?.targetDate ?? DateTime.now());
    _selectedCategory = widget.goal?.category ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.goal != null ? 'Edit Goal' : 'Add Goal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory.isNotEmpty ? _selectedCategory : null,
              items: GoalHelper.categoryIcons.keys
                  .map<DropdownMenuItem<String>>((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Row(
                    children: [
                      Icon(GoalHelper.categoryIcons[category]),
                      SizedBox(width: 8),
                      Text(category),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Category',
                hintText: 'Select category',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _targetController,
              decoration: InputDecoration(labelText: 'Target'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a target';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: DateFormat.yMMMd().format(_selectedDate),
                    ),
                    onTap: () => _selectDate(context),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: _selectedTime.format(context),
                    ),
                    onTap: () => _selectTime(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty &&
                _descriptionController.text.isNotEmpty &&
                _selectedCategory.isNotEmpty &&
                _targetController.text.isNotEmpty) {
              final DateTime targetDate = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
                _selectedTime.hour,
                _selectedTime.minute,
              );

              final Goal goal = Goal(
                title: _titleController.text,
                description: _descriptionController.text,
                category: _selectedCategory,
                targetDate: targetDate,
                target: int.parse(_targetController.text),
                id: widget.goal?.id ?? UniqueKey().toString(),
                priority: widget.goal?.priority ?? 0,
                progress: widget.goal?.progress ?? 0,
                endDate: targetDate,
                isCompleted: widget.goal?.isCompleted ?? false,
              );

              if (widget.goal != null) {
                // If editing an existing goal, update it
                Provider.of<GoalProvider>(context, listen: false).updateGoal(goal);
              } else {
                // If adding a new goal, add it
                Provider.of<GoalProvider>(context, listen: false).addGoal(goal);
                widget.addGoalToGroup(goal);
              }

              Navigator.pop(context); // Close the dialog
            }
          },
          child: Text(widget.goal != null ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
}
