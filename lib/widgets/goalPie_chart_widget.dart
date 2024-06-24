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
                          title: '${goal.title}\n${percentage.toStringAsFixed(1)}%',
                          color: _getColorForCategory(goal.category),
                          radius: 80,
                          titleStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
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
            Text(goal.title),
          ],
        );
      }).toList(),
    );
  }

  Color _getColorForCategory(String? category) {
    switch (category) {
      case 'Health & Fitness':
        return Color.fromRGBO(126, 35, 191, 0.498);
      case 'Work & Productivity':
        return Color.fromARGB(255, 222, 144, 236);
      case 'Personal Development':
        return Color.fromRGBO(148, 24, 237, 0.494);
      case 'Self-Care':
        return Color.fromARGB(57, 181, 77, 199);
      case 'Finance':
        return Color.fromARGB(255, 201, 5, 236);
      default:
        return Color.fromARGB(57, 214, 93, 157);
    }
  }
}
