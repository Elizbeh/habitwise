import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:habitwise/screens/data/goal_helper.dart';
import 'package:habitwise/themes/theme.dart'; // Your custom theme
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditGoalDialog extends StatefulWidget {
  final Goal? goal; // Goal object for editing, null for adding a new goal
  final void Function(Goal) addGoalToGroup; // Function to add a goal to a group
  final String groupId; // ID of the group
  final void Function(Goal) onUpdateGoal; // Function to handle updating an existing goal
  final void Function(String) onDeleteGoal; // Function to handle deleting a goal

  EditGoalDialog({
    this.goal,
    required this.addGoalToGroup,
    required this.groupId,
    required this.onUpdateGoal,
    required this.onDeleteGoal,
  });

  @override
  _EditGoalDialogState createState() => _EditGoalDialogState();
}

class _EditGoalDialogState extends State<EditGoalDialog> {
  late TextEditingController _titleController; // Controller for the title input field
  late TextEditingController _descriptionController; // Controller for the description input field
  late TextEditingController _targetController; // Controller for the target input field
  late DateTime _selectedDate; // Selected target date
  late TimeOfDay _selectedTime; // Selected target time
  late String _selectedCategory; // Selected category for the goal
  GoalTemplate? _selectedTemplate; // Selected goal template

  @override
  void initState() {
    super.initState();
    // Initialize text controllers and selected values based on existing goal or defaults
    _titleController = TextEditingController(text: widget.goal?.title ?? '');
    _descriptionController = TextEditingController(text: widget.goal?.description ?? '');
    _targetController = TextEditingController(text: widget.goal?.target.toString() ?? '');
    _selectedDate = widget.goal?.targetDate ?? DateTime.now();
    _selectedTime = TimeOfDay.fromDateTime(widget.goal?.targetDate ?? DateTime.now());
    _selectedCategory = widget.goal?.category ?? '';
    _selectedTemplate = null; // No template selected by default
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: primaryColor, width: 3.0), // Border for the dialog
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
      ),
      backgroundColor: Color.fromRGBO(230, 230, 250, 1.0), // Light background color for the dialog
      child: Column(
        mainAxisSize: MainAxisSize.min, // Minimize size of the dialog
        children: [
          AppBar(
            centerTitle: true,
            title: Text(
              widget.goal != null ? 'Edit Goal' : 'Add Goal', // Title changes based on context
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
            backgroundColor: primaryColor.withOpacity(0.7), // Lighter version of primary color
            elevation: 0,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown for selecting category
                  DropdownButtonFormField<String>(
                    value: _selectedCategory.isNotEmpty ? _selectedCategory : null,
                    items: GoalHelper.categoryIcons.keys
                        .map<DropdownMenuItem<String>>((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Row(
                          children: [
                            Icon(GoalHelper.categoryIcons[category], color: secondaryColor),
                            SizedBox(width: 8),
                            Text(category, style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value; // Update selected category
                        });
                      }
                    },
                    decoration: InputDecoration(labelText: 'Category'), // Label for the dropdown
                  ),
                  SizedBox(height: 10),
                  // Text field for title
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Title'), // Label for title input
                  ),
                  SizedBox(height: 10),
                  // Text field for description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'), // Label for description input
                  ),
                  SizedBox(height: 10),
                  // Text field for target
                  TextFormField(
                    controller: _targetController,
                    decoration: InputDecoration(labelText: 'Target'), // Label for target input
                    keyboardType: TextInputType.number, // Numeric keyboard for target
                  ),
                  SizedBox(height: 10),
                  // Row for date and time pickers
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          readOnly: true, // Prevent user from typing directly
                          decoration: InputDecoration(
                            labelText: _selectedDate == null
                                ? 'Select date'
                                : DateFormat.yMMMd().format(_selectedDate), // Format date
                          ),
                          onTap: () => _selectDate(context), // Date picker on tap
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          readOnly: true, // Prevent user from typing directly
                          decoration: InputDecoration(
                            labelText: _selectedTime == null
                                ? 'Select time'
                                : _selectedTime.format(context), // Format time
                          ),
                          onTap: () => _selectTime(context), // Time picker on tap
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Dropdown for selecting goal template
                  DropdownButtonFormField<GoalTemplate>(
                    value: _selectedTemplate,
                    items: GoalHelper.goalTemplates.map((template) {
                      return DropdownMenuItem<GoalTemplate>(
                        value: template,
                        child: Text(template.title), // Display template title
                      );
                    }).toList(),
                    onChanged: (template) {
                      setState(() {
                        _selectedTemplate = template!; // Update selected template
                        _titleController.text = template.title; // Update title from template
                        _descriptionController.text = template.description; // Update description from template
                        _selectedCategory = template.category; // Update category from template
                        _targetController.text = template.target.toString(); // Update target from template
                        _selectedDate = template.startDate; // Update selected date from template
                        _selectedTime = TimeOfDay.fromDateTime(template.endDate); // Update selected time from template
                      });
                    },
                    decoration: InputDecoration(labelText: 'Choose Template'), // Label for template dropdown
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                ),
                child: Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(width: 20.0),
              ElevatedButton(
                onPressed: () {
                  // Validate inputs before proceeding
                  if (_titleController.text.isNotEmpty &&
                      _descriptionController.text.isNotEmpty &&
                      _selectedCategory.isNotEmpty &&
                      _targetController.text.isNotEmpty) {
                    // Create a target date from selected date and time
                    final DateTime targetDate = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      _selectedTime.hour,
                      _selectedTime.minute,
                    );

                    // Create a new Goal object
                    final Goal goal = Goal(
                      title: _titleController.text,
                      description: _descriptionController.text,
                      category: _selectedCategory,
                      targetDate: targetDate,
                      target: int.parse(_targetController.text),
                      id: widget.goal?.id ?? UniqueKey().toString(), // Unique ID for new goal
                      priority: widget.goal?.priority ?? 0,
                      progress: widget.goal?.progress ?? 0,
                      endDate: targetDate,
                      isCompleted: widget.goal?.isCompleted ?? false,
                    );

                    if (widget.goal != null) {
                      // If editing an existing goal, update it
                      Provider.of<GoalProvider>(context, listen: false).updateGoal(goal).then((_) {
                        widget.onUpdateGoal(goal); // Trigger a state update after updating
                      });
                    } else {
                      // If adding a new goal, add it
                      Provider.of<GoalProvider>(context, listen: false).addGoal(goal).then((_) {
                        widget.addGoalToGroup(goal); // Add goal to the group
                      });
                    }

                    Navigator.pop(context); // Close the dialog
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor, // Primary color for the save button
                ),
                child: Text(widget.goal != null ? 'Save' : 'Add', style: TextStyle(color: Colors.white)), // Save or Add button
              ),
            
            ],
          ),
        ],
      ),
    );
  }

  // Method to select a date from the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate; // Update the selected date
      });
    }
  }

  // Method to select a time from the time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime; // Update the selected time
      });
    }
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    super.dispose();
  }
}

         
