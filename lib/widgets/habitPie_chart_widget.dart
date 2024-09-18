import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habitwise/models/habit.dart';

class PieChartWidget extends StatelessWidget {
  final List<Habit> habits;

  PieChartWidget({required this.habits});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300, // Constrain the height
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sections: habits.map((habit) {
                        final double percentage = habit.progress / habit.frequency * 100;
                        return PieChartSectionData(
                          value: percentage,
                          color: _getColorForCategory(habit.category),
                          radius: 80,
                          titlePositionPercentageOffset: 0.7, // Adjust title position
                          titleStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          // Display percentage as a label for accessibility
                          title: '${percentage.toStringAsFixed(1)}%',
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        'Total\n${habits.length} Habits',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      children: habits.map((habit) {
        return Row(
          children: [
            Container(
              width: 16,
              height: 16,
              color: _getColorForCategory(habit.category),
            ),
            SizedBox(width: 8),
            // Text with habit title for visual users
            Text(habit.title),
          ],
        );
      }).toList(),
    );
  }

  Color _getColorForCategory(String? category) {
    switch (category) {
      case 'Health & Fitness':
        return Color.fromRGBO(19, 188, 249, 0.482);
      case 'Work & Productivity':
        return Color.fromARGB(255, 209, 17, 155);
      case 'Personal Development':
        return Colors.yellow;
      case 'Self-Care':
        return Color.fromARGB(255, 80, 41, 170);
      case 'Finance':
        return Color.fromARGB(255, 5, 236, 55);
      default:
        return Colors.pink;
    }
  }
}
