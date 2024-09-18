import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:habitwise/models/goal.dart';

class GoalPieChartWidget extends StatelessWidget {
  final List<Goal> goals;

  GoalPieChartWidget({required this.goals});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 250, // Constrain the height
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sections: goals.map((goal) {
                        final double percentage = goal.progress / goal.target * 100;
                        return PieChartSectionData(
                          value: percentage,
                          color: _getColorForCategory(goal.category),
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
                        'Total\n${goals.length} Goals',
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
      children: goals.map((goal) {
        return Row(
          children: [
            Container(
              width: 16,
              height: 16,
              color: _getColorForCategory(goal.category),
            ),
            SizedBox(width: 8),
            // Text with goal title for visual users
            Text(goal.title),
          ],
        );
      }).toList(),
    );
  }

  Color _getColorForCategory(String? category) {
    switch (category) {
      case 'Health & Fitness':
        return Color.fromRGBO(134, 41, 137, 1.0);
      case 'Work & Productivity':
        return Colors.green;
      case 'Personal Development':
        return Colors.yellow;
      case 'Self-Care':
        return Colors.blue;
      case 'Finance':
        return Color.fromARGB(255, 201, 5, 236);
      default:
        return Colors.pink;
    }
  }
}
