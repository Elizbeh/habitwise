import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habitwise/models/habit.dart';

class GroupBarChart extends StatelessWidget {
  final List<Habit> habits;
  final double betweenSpace = 0.2;

  GroupBarChart({required this.habits});

  BarChartGroupData generateGroupData(
    int x,
    double progress,
    double frequency,
    double completion,
  ) {
    return BarChartGroupData(
      x: x,
      groupVertically: true,
      barRods: [
        BarChartRodData(
          fromY: 0,
          toY: progress,
          color: Colors.blue,
          width: 5,
        ),
        BarChartRodData(
          fromY: progress + betweenSpace,
          toY: progress + betweenSpace + frequency,
          color: Colors.green,
          width: 5,
        ),
        BarChartRodData(
          fromY: progress + betweenSpace + frequency + betweenSpace,
          toY: progress + betweenSpace + frequency + betweenSpace + completion,
          color: Colors.red,
          width: 5,
        ),
      ],
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'MON';
        break;
      case 1:
        text = 'TUE';
        break;
      case 2:
        text = 'WED';
        break;
      case 3:
        text = 'THU';
        break;
      case 4:
        text = 'FRI';
        break;
      case 5:
        text = 'SAT';
        break;
      case 6:
        text = 'SUN';
        break;
      default:
        text = '';
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Habit Activity',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Legend('Progress', Colors.blue),
              SizedBox(width: 8),
              Legend('Frequency', Colors.green),
              SizedBox(width: 8),
              Legend('Completion', Colors.red),
            ],
          ),
          const SizedBox(height: 14),
          AspectRatio(
            aspectRatio: 2,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(),
                  rightTitles: AxisTitles(),
                  topTitles: AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: bottomTitles,
                      reservedSize: 20,
                    ),
                  ),
                ),
                barTouchData: BarTouchData(enabled: false),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                barGroups: habits.asMap().entries.map((entry) {
                  int index = entry.key;
                  Habit habit = entry.value;
                  return generateGroupData(index, habit.progress.toDouble(), habit.frequency.toDouble(), habit.isCompleted ? 1.0 : 0.0);
                }).toList(),
                maxY: habits.map((h) => h.progress + h.frequency + (h.isCompleted ? 1.0 : 0.0)).reduce((a, b) => a > b ? a : b).toDouble() + (betweenSpace * 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Legend extends StatelessWidget {
  final String text;
  final Color color;

  const Legend(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}
