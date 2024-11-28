import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PerformanceApp extends StatelessWidget {
  const PerformanceApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Monthly Performance')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: PerformanceBarChart(),
        ),
      ),
    );
  }
}

class MonthlyPerformance {
  final int year;
  final int month; // 1 for January, 2 for February, etc.
  final double value;

  MonthlyPerformance(this.year, this.month, this.value);
}

class PerformanceBarChart extends StatelessWidget {
  PerformanceBarChart({super.key});
  // Performance data for different months across years
  final List<MonthlyPerformance> performanceData = [
    MonthlyPerformance(2023, 9, 75), // Sept 2023
    MonthlyPerformance(2023, 10, 85), // Oct 2023
    MonthlyPerformance(2023, 11, 95), // Nov 2023
    MonthlyPerformance(2023, 12, 105), // Dec 2023
    MonthlyPerformance(2024, 1, 110), // Jan 2024
    MonthlyPerformance(2024, 2, 120), // Feb 2024
    MonthlyPerformance(2024, 3, 90), // Mar 2024
    MonthlyPerformance(2024, 4, 80), // Apr 2024
    MonthlyPerformance(2024, 5, 130), // May 2024
    MonthlyPerformance(2024, 6, 140), // Jun 2024
    MonthlyPerformance(2024, 7, 100), // Jul 2024
    MonthlyPerformance(2024, 8, 85), // Aug 2024
    MonthlyPerformance(2024, 9, 120), // Sept 2024
  ];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 150,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    // Get both year and month for x-axis labels
                    int index = value.toInt();
                    final performance = performanceData[index];
                    String month = _getMonthAbbreviation(performance.month);
                    String text = '$month\n${performance.year}';
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(text),
                    );
                  })),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(value.toInt().toString()),
              );
            },
          )),
        ),
        barGroups: performanceData.asMap().entries.map((entry) {
          int index = entry.key;
          double value = entry.value.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                color: Colors.blueAccent,
                width: 16,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _getMonthAbbreviation(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
}
