import 'package:flutter/material.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/providers/habit_provider.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/screens/data/habit_templates.dart';
import 'package:habitwise/themes/theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:habitwise/screens/data/icons/category_icons.dart';

class AddHabitDialog extends StatefulWidget {
  final String? groupId; // Optional group ID for group habits
  final bool isGroupHabit; // Indicates if the habit is for a group
  final Function? onHabitAdded; // Callback function to run after adding a habit

  const AddHabitDialog({
    Key? key,
    required this.isGroupHabit,
    this.groupId,
    this.onHabitAdded,
  }) : super(key: key);

  @override
  _AddHabitDialogState createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController frequencyController = TextEditingController();

  String? selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  Map<String, dynamic>? selectedTemplate;

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
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

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
          'New Habit',
          style: Theme.of(context).appBarTheme.titleTextStyle,
          textAlign: TextAlign.center,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  selectedCategory = value;
                  selectedTemplate = null;
                  if (value != null && habitTemplates.containsKey(value)) {
                    selectedTemplate = habitTemplates[value]![0];
                    _applyTemplate(selectedTemplate!);
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
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Habit Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Habit Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: frequencyController,
              decoration: InputDecoration(
                labelText: 'Frequency per Day',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8),
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
                    onTap: () => _selectDate(context, true),
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
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
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
                      selectedTemplate = template;
                      _applyTemplate(template);
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
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: secondaryColor
          ),
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.white),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromRGBO(134, 41, 137, 1.0),
          ),
          onPressed: () async {
            if (selectedCategory != null &&
                titleController.text.isNotEmpty &&
                frequencyController.text.isNotEmpty) {
              
              if (_startDate != null && (_endDate == null || _endDate!.isAfter(_startDate!))) {
                final newHabit = Habit(
                  id: '',
                  title: titleController.text,
                  description: descriptionController.text,
                  createdAt: DateTime.now(),
                  startDate: _startDate!,
                  endDate: _endDate,
                  frequency: int.tryParse(frequencyController.text) ?? 1,
                  isCompleted: false,
                  category: selectedCategory!,
                  groupId: widget.isGroupHabit ? widget.groupId : null,
                );

                // Add habit using Firebase-generated ID
                if (widget.isGroupHabit && widget.groupId != null) {
                  await Provider.of<HabitProvider>(context, listen: false)
                      .addHabit(newHabit, groupId: widget.groupId!); // Use addGroupHabit here
                } else {
                  final userId = Provider.of<UserProvider>(context, listen: false)
                      .user
                      ?.uid;
                  if (userId != null) {
                    await Provider.of<HabitProvider>(context, listen: false)
                        .addHabit(newHabit); // Use addHabitToUser here
                  }
                }

                if (widget.onHabitAdded != null) {
                  widget.onHabitAdded!();
                }

                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Start date must be before end date.'),
                ));
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Please fill out all required fields'),
              ));
            }
          },
          child: Text(
            'Add Habit',
            style: TextStyle(color: Colors.white), // Text color of add button
          ),
        ),
      ],
    );
  }
}
