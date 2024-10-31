import 'package:flutter/material.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/providers/habit_provider.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/screens/data/habit_templates.dart';
import 'package:habitwise/themes/theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:habitwise/screens/data/icons/category_icons.dart';

class EditHabitDialog extends StatefulWidget {
  final Habit habit;
  final String? groupId; // Optional group ID for group habits
  final bool isGroupHabit; // Indicates if the habit is for a group
  final Function? onHabitUpdated; // Callback for when the habit is updated

  const EditHabitDialog({
    Key? key,
    required this.habit,
    required this.isGroupHabit,
    this.groupId,
    this.onHabitUpdated,
  }) : super(key: key);

  @override
  _EditHabitDialogState createState() => _EditHabitDialogState();
}

class _EditHabitDialogState extends State<EditHabitDialog> {
  // Controllers for the input fields
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController frequencyController = TextEditingController();

  String? selectedCategory; // Currently selected category
  DateTime? _startDate; // Start date of the habit
  DateTime? _endDate; // End date of the habit
  Map<String, dynamic>? selectedTemplate; // Currently selected habit template

  @override
  void initState() {
    super.initState();
    // Initialize controllers and state with current habit data
    titleController.text = widget.habit.title;
    descriptionController.text = widget.habit.description ?? '';
    frequencyController.text = widget.habit.frequency.toString();
    selectedCategory = widget.habit.category;
    _startDate = widget.habit.startDate;
    _endDate = widget.habit.endDate;
  }

  // Method to select a date for either start or end date
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2023),
      lastDate: DateTime(2090),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked; // Set start date
        } else {
          _endDate = picked; // Set end date
        }
      });
    }
  }

  // Apply the selected template values to the input fields
  void _applyTemplate(Map<String, dynamic> template) {
    if (template.containsKey('title')) {
      titleController.text = template['title'];
    }
    if (template.containsKey('description')) {
      descriptionController.text = template['description'];
    }
    if (template.containsKey('frequency')) {
      frequencyController.text = template['frequency'].toString();
    }
  }

  // Method to update the habit based on user inputs
  void _updateHabit(BuildContext context) {
    // Validate input fields
    if (selectedCategory != null &&
        titleController.text.isNotEmpty &&
        frequencyController.text.isNotEmpty &&
        _startDate != null && 
        (_endDate == null || _endDate!.isAfter(_startDate!))) {
      
      final updatedHabit = widget.habit.copyWith(
        title: titleController.text,
        description: descriptionController.text,
        startDate: _startDate!,
        endDate: _endDate,
        frequency: int.tryParse(frequencyController.text) ?? 1,
        category: selectedCategory!,
      );

      // Update the habit in the appropriate provider
      try {
        if (widget.isGroupHabit) {
          Provider.of<HabitProvider>(context, listen: false)
              .updateHabit(updatedHabit, groupId: widget.groupId); // Update group habit
        } else {
          final userId = Provider.of<UserProvider>(context, listen: false).currentUser?.uid;
          if (userId != null) {
            Provider.of<HabitProvider>(context, listen: false)
                .updateHabit(updatedHabit, groupId: ''); // Update user habit
          }
        }

        // Call the optional callback after updating
        widget.onHabitUpdated?.call();
        Navigator.pop(context); // Close the dialog
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error updating habit: ${e.toString()}'),
        ));
      }
    } else {
      // Show an error if required fields are missing or invalid
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill out all required fields correctly.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color.fromRGBO(230, 230, 250, 1.0),
      title: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Edit Habit',
          style: Theme.of(context).appBarTheme.titleTextStyle,
          textAlign: TextAlign.center,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown for selecting category
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categoryIcons.keys.map<DropdownMenuItem<String>>((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Row(
                    children: [
                      Icon(categoryIcons[category], color: primaryColor),
                      SizedBox(width: 8),
                      Text(category, style: TextStyle(fontSize: 14)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedCategory = value; // Update selected category
                  selectedTemplate = null; // Reset selected template when category changes
                  if (value != null && habitTemplates.containsKey(value)) {
                    selectedTemplate = habitTemplates[value]![0]; // Default to first template
                    _applyTemplate(selectedTemplate!); // Apply template
                  }
                });
              },
              decoration: InputDecoration(
                labelText: 'Category',
                hintText: 'Select category',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            // Input for habit title
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Habit Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            // Input for habit description
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Habit Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            // Input for frequency
            TextFormField(
              controller: frequencyController,
              decoration: InputDecoration(
                labelText: 'Frequency per Day',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8),
            // Date pickers for start and end dates
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: _startDate == null
                          ? 'Select Start Date'
                          : DateFormat.yMMMd().format(_startDate!),
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => _selectDate(context, true), // Select start date
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: _endDate == null
                          ? 'Select End Date'
                          : DateFormat.yMMMd().format(_endDate!),
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => _selectDate(context, false), // Select end date
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Dropdown for selecting template
            if (selectedCategory != null &&
                selectedCategory!.isNotEmpty &&
                habitTemplates.containsKey(selectedCategory))
              DropdownButtonFormField<Map<String, dynamic>>(
                value: selectedTemplate,
                items: habitTemplates[selectedCategory!]!.map((template) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: template,
                    child: Text(template['title']),
                  );
                }).toList(),
                onChanged: (template) {
                  if (template != null) {
                    setState(() {
                      selectedTemplate = template; // Update selected template
                      _applyTemplate(template); // Apply the selected template
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Choose Template',
                  hintText: 'Select template',
                  border: OutlineInputBorder(),
                ),
              ),
          ],
        ),
      ),
            actions: [
        // Cancel button to close the dialog without making changes
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: secondaryColor,
          ),
          onPressed: () => Navigator.pop(context), // Close the dialog
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.white),
          ),
        ),
        // Update button to save changes made to the habit
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromRGBO(134, 41, 137, 1.0), // Custom color for the button
          ),
          onPressed: () => _updateHabit(context), // Call the update function
          child: Text(
            'Update Habit',
            style: TextStyle(color: Colors.white), // Text color for the button
          ),
        ),
      ],
    );
  }
}
