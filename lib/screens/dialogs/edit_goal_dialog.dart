import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:habitwise/screens/data/goal_helper.dart';
import 'package:habitwise/themes/theme.dart'; // Your custom theme
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditGoalDialog extends StatefulWidget {
  final Goal? goal; // Goal object for editing, null for adding
  final void Function(Goal) addGoalToGroup; // Function to add goal to group
  final String groupId;
  final void Function(Goal) onUpdateGoal;
  final void Function(String) onDeleteGoal;

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
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _selectedCategory;
  GoalTemplate? _selectedTemplate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal?.title ?? '');
    _descriptionController = TextEditingController(text: widget.goal?.description ?? '');
    _targetController = TextEditingController(text: widget.goal?.target.toString() ?? '');
    _selectedDate = widget.goal?.targetDate ?? DateTime.now();
    _selectedTime = TimeOfDay.fromDateTime(widget.goal?.targetDate ?? DateTime.now());
    _selectedCategory = widget.goal?.category ?? '';
    _selectedTemplate = null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: primaryColor, width: 3.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      backgroundColor: Color.fromRGBO(230, 230, 250, 1.0), // Light background color
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            centerTitle: true,
            title: Text(
              widget.goal != null ? 'Edit Goal' : 'Add Goal',
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
                          _selectedCategory = value;
                        });
                      }
                    },
                    decoration: InputDecoration(labelText: 'Category'),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _targetController,
                    decoration: InputDecoration(labelText: 'Target'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: _selectedDate == null
                                ? 'Select date'
                                : DateFormat.yMMMd().format(_selectedDate),
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
                                : _selectedTime.format(context),
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
                    decoration: InputDecoration(labelText: 'Choose Template'),
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
                      widget.onUpdateGoal(goal);
                    } else {
                      // If adding a new goal, add it
                      Provider.of<GoalProvider>(context, listen: false).addGoal(goal);
                      widget.addGoalToGroup(goal);
                    }

                    Navigator.pop(context); // Close the dialog
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
                child: Text(widget.goal != null ? 'Save' : 'Add', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
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
