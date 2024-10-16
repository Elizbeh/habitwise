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
                          color: _getColorForCategory(goal.category, context),
                          radius: 80,
                          titlePositionPercentageOffset: 0.7, // Adjust title position
                          titleStyle: Theme.of(context).textTheme.bodyText2!.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onBackground,
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
                        style: Theme.of(context).textTheme.headline6?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Column(
      children: goals.map((goal) {
        return Row(
          children: [
            Container(
              width: 16,
              height: 16,
              color: _getColorForCategory(goal.category, context),
            ),
            SizedBox(width: 8),
            // Text with goal title for visual users
            Text(
              goal.title,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getColorForCategory(String? category, BuildContext context) {
    switch (category) {
      case 'Health & Fitness':
        return Color.fromRGBO(134, 41, 137, 1.0);
      case 'Work & Productivity':
        return Theme.of(context).colorScheme.primary; // Use primary color from the theme
      case 'Personal Development':
        return Theme.of(context).colorScheme.secondary; // Use secondary color from the theme
      case 'Self-Care':
        return Theme.of(context).colorScheme.tertiary; // Use tertiary color from the theme
      case 'Finance':
        return Color.fromARGB(255, 201, 5, 236);
      default:
        return Colors.pink;
    }
  }
}
