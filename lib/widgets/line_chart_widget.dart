import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habitwise/models/habit.dart';

class LineChartWidget extends StatelessWidget {
  final List<Habit> habits;

  LineChartWidget({required this.habits});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: 7,
        minY: 0,
        maxY: 10,
        lineBarsData: [
          LineChartBarData(
            spots: habits
                .asMap()
                .entries
                .map((entry) => FlSpot(
                    entry.key.toDouble(), entry.value.progress.toDouble()))
                .toList(),
            isCurved: true,
            color:  Color.fromRGBO(126, 35, 191, 0.498),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}