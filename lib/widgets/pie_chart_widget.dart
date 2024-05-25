import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habitwise/models/habit.dart';


class PieChartWidget extends StatelessWidget {
  final List<Habit> habits;

  PieChartWidget({required this.habits});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: habits.map((habit) {
          final double percentage = habit.progress / habit.frequency * 100;
          return PieChartSectionData(
            value: percentage,
            title: '${percentage.toStringAsFixed(1)}%',
            color: _getColorForCategory(habit.category),
          );
        }).toList(),
      ),
    );
  }

  Color _getColorForCategory(String? category) {
    switch (category) {
      case 'Health & Fitness':
        return Colors.green;
      case 'Work & Productivity':
        return Colors.blue;
      case 'Personal Development':
        return Colors.purple;
      case 'Self-Care':
        return Colors.pink;
      case 'Finance':
        return Colors.orange;
      case 'Education':
        return Colors.red;
      case 'Relationships':
        return Colors.yellow;
      case 'Hobbies':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}