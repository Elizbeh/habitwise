import 'package:flutter/material.dart';
import 'package:habitwise/models/habit.dart';
import 'package:habitwise/providers/habit_provider.dart';
import 'package:provider/provider.dart';

class HabitScreen extends StatefulWidget {
  @override
  _HabitScreenState createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  late HabitProvider habitProvider;

  @override
  void initState() {
    super.initState();
    habitProvider = Provider.of<HabitProvider>(context, listen: false);
    habitProvider.fetchHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habits'),
      ),
      body: Consumer<HabitProvider>(
        builder: (context, provider, child) {
          final habits = provider.habits;
          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return HabitTile(habit: habit);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddHabitDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController frequencyController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Habit'),
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
                final newHabit = Habit(
                  id: DateTime.now().toString(),
                  title: titleController.text,
                  description: descriptionController.text,
                  createdAt: DateTime.now(),
                  startDate: DateTime.now(),
                  frequency: int.tryParse(frequencyController.text) ?? 1,
                  isCompleted: false,
                );
                habitProvider.addHabit(newHabit);
                Navigator.pop(context);
              },
              child: Text('Add Habit'),
            ),
          ],
        );
      },
    );
  }
}

class HabitTile extends StatelessWidget {
  final Habit habit;

  const HabitTile({required this.habit});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(habit.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(habit.description),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: habit.progress / habit.frequency,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 4),
          Text('Progress: ${habit.progress}/${habit.frequency}'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _showEditHabitDialog(context, habit);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              final habitProvider = Provider.of<HabitProvider>(context, listen: false);
              habitProvider.removeHabit(habit.id);
            },
          ),
        ],
      ),
      onTap: () {
        final habitProvider = Provider.of<HabitProvider>(context, listen: false);
        habitProvider.updateHabit(habitProvider.habits.indexOf(habit), habit.incrementProgress());
      },
    );
  }

  void _showEditHabitDialog(BuildContext context, Habit habit) {
    final TextEditingController titleController = TextEditingController(text: habit.title);
    final TextEditingController descriptionController = TextEditingController(text: habit.description);
    final TextEditingController frequencyController = TextEditingController(text: habit.frequency.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                );
                final habitProvider = Provider.of<HabitProvider>(context, listen: false);
                habitProvider.updateHabit(habitProvider.habits.indexOf(habit), updatedHabit);
                Navigator.pop(context);
              },
              child: Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }
}
