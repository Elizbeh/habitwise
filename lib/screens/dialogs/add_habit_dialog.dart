import 'package:flutter/material.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/providers/habit_provider.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/screens/data/habit_templates.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:habitwise/screens/data/icons/category_icons.dart';

class AddHabitDialog extends StatefulWidget {
  final String? groupId;
  final bool isGroupHabit; // Add groupId for group habits, null for personal habits
  final Function? onHabitAdded;

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
      title: Container(
        padding: EdgeInsets.all(8),
        color: Color.fromRGBO(126, 35, 191, 0.498),
        child: Text(
          'Add New Habit',
          style: TextStyle(color: Colors.white),
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
                      Icon(categoryIcons[category], color: Colors.purple),
                      SizedBox(width: 8),
                      Text(category),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedCategory = value;
                  selectedTemplate = null; // Reset selected template when category changes
                  if (value != null && habitTemplates.containsKey(value)) {
                    selectedTemplate = habitTemplates[value]![0]; // Default to first template
                    _applyTemplate(selectedTemplate!);
                  }
                });
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
              controller: titleController,
              decoration: InputDecoration(labelText: 'Habit Title'),
            ),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Habit Description'),
            ),
            TextFormField(
              controller: frequencyController,
              decoration: InputDecoration(labelText: 'Frequency per Day'),
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: _startDate == null
                          ? 'Select Start Date'
                          : DateFormat.yMMMd().format(_startDate!),
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
                    ),
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
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
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey,
          ),
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.white),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromRGBO(126, 35, 191, 0.498),
          ),
          onPressed: () {
            if (selectedCategory != null &&
                titleController.text.isNotEmpty &&
                frequencyController.text.isNotEmpty) {
              final newHabit = Habit(
                id: DateTime.now().toString(),
                title: titleController.text,
                description: descriptionController.text,
                createdAt: DateTime.now(),
                startDate: _startDate ?? DateTime.now(),
                endDate: _endDate,
                frequency: int.tryParse(frequencyController.text) ?? 1,
                isCompleted: false,
                category: selectedCategory!, // Non-null assertion here
                groupId: widget.isGroupHabit ? widget.groupId : null,
              );

              // Determine where to add the habit based on whether it's a group habit
              if (widget.isGroupHabit) {
                // Add the habit to the group details screen
                Provider.of<HabitProvider>(context, listen: false)
                    .addHabit(widget.groupId!, newHabit);
              } else {
                // Add the habit to the individual habit screen using the user's UID
                final userId =
                    Provider.of<UserProvider>(context, listen: false)
                        .user
                        ?.uid;
                if (userId != null) {
                  Provider.of<HabitProvider>(context, listen: false)
                      .addHabit(userId, newHabit);
                }
              }
              Navigator.pop(context);
            } else {
              // Show an error if required fields are missing
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Please fill out all required fields'),
              ));
            }
          },
          child: Text(
            'Add Habit',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
