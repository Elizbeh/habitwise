// Widget for adding a new goal
import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:habitwise/screens/data/goal_helper.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AddGoalDialog extends StatefulWidget {
  final void Function(Goal) addGoalToGroup;
  final String groupId;

  AddGoalDialog({required this.addGoalToGroup, required this.groupId});

  @override
  _AddGoalDialogState createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedCategory = '';
  GoalTemplate? _selectedTemplate;

  void _addGoal(BuildContext context) async {
  if (_titleController.text.isNotEmpty &&
      _descriptionController.text.isNotEmpty &&
      _selectedCategory.isNotEmpty &&
      _targetController.text.isNotEmpty &&
      _selectedDate != null &&
      _selectedTime != null) {
    final DateTime targetDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final Goal goal = Goal(
      title: _titleController.text,
      description: _descriptionController.text,
      category: _selectedCategory,
      targetDate: targetDate,
      target: int.parse(_targetController.text),
      id: UniqueKey().toString(),
      priority: 0,
      progress: 0,
      endDate: targetDate,
      isCompleted: false,
    );

    if (widget.groupId.isNotEmpty) {
      try {
        await Provider.of<GoalProvider>(context, listen: false).addGoalToGroup(goal, widget.groupId);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Goal added to group successfully!'),
          duration: Duration(seconds: 2),
        ));
      } catch (error) {
        print("Error adding goal to group: $error");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error adding goal to group: $error'),
          duration: Duration(seconds: 2),
        ));
      }
    } else {
      try {
        await Provider.of<GoalProvider>(context, listen: false).addGoal(goal);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Goal added successfully!'),
          duration: Duration(seconds: 2),
        ));
      } catch (error) {
        print("Error adding goal: $error");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error adding goal: $error'),
          duration: Duration(seconds: 2),
        ));
      }
    }

    _titleController.clear();
    _descriptionController.clear();
    _targetController.clear();
    _selectedCategory = '';
    _selectedTemplate = null;

    Navigator.pop(context);
  }
}

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Goal'),
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
                      labelText: _selectedDate == null
                          ? 'Select date'
                          : DateFormat.yMMMd().format(_selectedDate!),
                    ),
                    onTap: () => _selectDate(context),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: _selectedTime == null
                          ? 'Select time'
                          : _selectedTime!.format(context),
                    ),
                    onTap: () => _selectTime(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<GoalTemplate>(
              value: _selectedTemplate,
              items: GoalHelper.goalTemplates.map((template) {
                return DropdownMenuItem<GoalTemplate>(
                  value: template,
                  child: Text(template.title),
                );
              }).toList(),
              onChanged: (template) {
                setState(() {
                  _selectedTemplate = template!;
                  _titleController.text = template.title;
                  _descriptionController.text = template.description;
                  _selectedCategory = template.category;
                  _targetController.text = template.target.toString();
                  _selectedDate = template.startDate;
                  _selectedTime = TimeOfDay.fromDateTime(template.endDate);
                });
              },
              decoration: InputDecoration(
                labelText: 'Choose Template',
                hintText: 'Select template',
              ),
              validator: (value) {
                if (value == null) {
                  return 'Please select a template';
                }
                return null;
              },
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
          onPressed: () => _addGoal(context),
          child: Text('Add'),
        ),
      ],
    );
  }
}
