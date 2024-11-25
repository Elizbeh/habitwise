import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:habitwise/screens/data/goal_helper.dart';
import 'package:habitwise/themes/theme.dart'; // Importing custom theme
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AddGoalDialog extends StatefulWidget {
  final void Function(Goal) addGoalToGroup; // Callback to add goal to a group
  final String groupId; // ID of the group

  AddGoalDialog({required this.addGoalToGroup, required this.groupId});

  @override
  _AddGoalDialogState createState() => _AddGoalDialogState(); // Creating the state
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  // Text editing controllers for user input
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();

  // Variables to hold selected date, time, category, and template
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedCategory = '';
  GoalTemplate? _selectedTemplate;

  // Function to add a goal
  void _addGoal(BuildContext context) async {
  // Ensure all fields are filled before adding the goal
  if (_titleController.text.isNotEmpty &&
      _descriptionController.text.isNotEmpty &&
      _selectedCategory.isNotEmpty &&
      _targetController.text.isNotEmpty &&
      _selectedDate != null &&
      _selectedTime != null) {

    // Constructing the target date and time
    final DateTime targetDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Creating the goal object
    final Goal goal = Goal(
      title: _titleController.text,
      description: _descriptionController.text,
      category: _selectedCategory,
      targetDate: targetDate,
      target: int.parse(_targetController.text),
      id: UniqueKey().toString(),
      priority: 0,
      progress: 0,
      endDate: targetDate, // Assuming endDate is the same as targetDate
      isCompleted: false,
    );

    // Check if the goal is being added to a group
    if (widget.groupId.isNotEmpty) {
      try {
        await Provider.of<GoalProvider>(context, listen: false)
            .addGoalToGroup(goal, widget.groupId); // Add goal to group
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Goal added to group successfully!')));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding goal to group: $error')));
      }
    } else {
      // If not adding to a group, add to individual goals
      try {
        await Provider.of<GoalProvider>(context, listen: false).addGoal(goal);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Goal added successfully!')));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding goal: $error')));
      }
    }

    // Clear input fields after adding the goal
    _titleController.clear();
    _descriptionController.clear();
    _targetController.clear();
    _selectedCategory = '';
    _selectedTemplate = null; // Assuming this resets the selected template

    // Close the dialog
    Navigator.pop(context);
  } else {
    // If any field is empty, show a warning message
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')));
  }
}

  // Function to select a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // Update selected date
      });
    }
  }

  // Function to select a time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked; // Update selected time
      });
    }
  }

  
  @override
Widget build(BuildContext context) {
  return Dialog(
    shape: RoundedRectangleBorder(
      side: BorderSide(color: Theme.of(context).primaryColor, width: 3.0),
      borderRadius: BorderRadius.circular(12.0), // Rounded dialog corners
      ),
      backgroundColor: Theme.of(context).dialogBackgroundColor, // Use dialog background from theme
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            centerTitle: true,
            title: Text(
              'Add Goal',
              style: Theme.of(context).appBarTheme.titleTextStyle, // Use app bar title style from theme
            ),
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7), // Use primary color from theme
            elevation: 0,
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown for selecting goal category
                  DropdownButtonFormField<String>(
                    value: _selectedCategory.isNotEmpty ? _selectedCategory : null,
                    items: GoalHelper.categoryIcons.keys
                        .map<DropdownMenuItem<String>>((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Row(
                          children: [
                            Icon(GoalHelper.categoryIcons[category], color: Theme.of(context).colorScheme.secondary),
                            SizedBox(width: 8),
                            Text(category, style: Theme.of(context).textTheme.bodyText1),
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
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: Theme.of(context).textTheme.bodyText2, // Use label style from theme
                    ),
                  ),
                  SizedBox(height: 10),
                  // Text field for goal title
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: Theme.of(context).textTheme.bodyMedium, // Use label style from theme
                    ),
                  ),
                  SizedBox(height: 10),
                  // Text field for goal description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: Theme.of(context).textTheme.bodyMedium, // Use label style from theme
                    ),
                  ),
                  SizedBox(height: 10),
                  // Text field for goal target
                  TextFormField(
                    controller: _targetController,
                    decoration: InputDecoration(
                      labelText: 'Target',
                      labelStyle: Theme.of(context).textTheme.bodyMedium, // Use label style from theme
                    ),
                    keyboardType: TextInputType.number, // Numeric input for target
                  ),
                  SizedBox(height: 10),
                  // Row to select date and time
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: _selectedDate == null
                                ? 'Select date'
                                : DateFormat.yMMMd().format(_selectedDate!), // Display selected date
                            labelStyle: Theme.of(context).textTheme.bodyMedium,
                          ),
                          onTap: () => _selectDate(context), // On tap, open date picker
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: _selectedTime == null
                                ? 'Select time'
                                : _selectedTime!.format(context), // Display selected time
                            labelStyle: Theme.of(context).textTheme.bodyMedium,
                          ),
                          onTap: () => _selectTime(context), // On tap, open time picker
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
                        child: Text(template.title, style: Theme.of(context).textTheme.bodySmall), // Display template title with theme text style
                      );
                    }).toList(),
                    onChanged: (template) {
                      setState(() {
                        _selectedTemplate = template!; // Update selected template
                        // Populate fields with template values
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
                      labelStyle: Theme.of(context).textTheme.bodyMedium, // Use label style from theme
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Row for dialog action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Close dialog
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary, // Use secondary color for button
                ),
                child: Text('Cancel', style: TextStyle(color: Colors.white)), // Cancel button
              ),
              SizedBox(width: 20.0),
              ElevatedButton(
                onPressed: () => _addGoal(context), // Add goal on button press
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor, // Use primary color for button
                ),
                child: Text('Add Goal', style: TextStyle(color: Colors.white, fontSize: 16)), // Add goal button
              ),
            ],
          ),
        ],
      ),
    );
  }

}
