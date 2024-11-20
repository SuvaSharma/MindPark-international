import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart'; // Import Syncfusion Charts
import 'package:collection/collection.dart'; // For groupBy method
import 'package:mindgames/graph_data.dart';

class BarGraphWidget extends StatelessWidget {
  final List<GraphData> graphData;
  final String difficultyLabel;
  final bool aggregateByYear;

  const BarGraphWidget({
    Key? key,
    required this.graphData,
    required this.difficultyLabel,
    this.aggregateByYear = true,
  }) : super(key: key);

  List<GraphData> _getYearlyAverages() {
    final groupedByYear = groupBy(graphData, (GraphData data) => data.year);

    return groupedByYear.entries.map((entry) {
      final int year = entry.key;
      final List<GraphData> yearlyData = entry.value;

      final double average =
          yearlyData.map((d) => d.data).reduce((a, b) => a + b) /
              yearlyData.length;

      return GraphData(year: year, month: 1, data: average);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width;
    double containerHeight = MediaQuery.of(context).size.height;
    final List<GraphData> dataToPlot =
        aggregateByYear ? _getYearlyAverages() : graphData;

    return Column(
      children: [
        Text(
          difficultyLabel,
          style: TextStyle(
              fontSize: containerWidth * 0.04, fontWeight: FontWeight.bold),
        ),
        Container(
          height: containerHeight * 0.2,
          width: containerWidth,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: dataToPlot.length > 6
                  ? containerWidth * (dataToPlot.length / 6)
                  : containerWidth,
              child: SfCartesianChart(
                primaryXAxis: aggregateByYear
                    ? DateTimeCategoryAxis(
                        intervalType: DateTimeIntervalType.years,
                        interval: 1,
                        dateFormat: DateFormat.y(),
                        majorGridLines: const MajorGridLines(width: 0),
                        labelStyle: TextStyle(
                          fontSize: containerWidth *
                              0.035, // Adjust font size for x-axis labels
                        ),
                      )
                    : DateTimeCategoryAxis(
                        intervalType: DateTimeIntervalType.months,
                        interval: 0.5,
                        dateFormat: DateFormat.MMM(),
                        majorGridLines: const MajorGridLines(width: 0),
                        labelStyle: TextStyle(
                          fontSize: containerWidth *
                              0.035, // Adjust font size for x-axis labels
                        ),
                      ),
                primaryYAxis: NumericAxis(
                  minimum: 0,
                  maximum: 110,
                  interval: 50,
                  labelFormat: '{value}',
                  labelStyle: TextStyle(
                    fontSize: containerWidth *
                        0.030, // Adjust font size for y-axis labels
                  ),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<GraphData, DateTime>>[
                  ColumnSeries<GraphData, DateTime>(
                    dataSource: dataToPlot,
                    xValueMapper: (GraphData data, _) =>
                        DateTime(data.year, aggregateByYear ? 1 : data.month),
                    yValueMapper: (GraphData data, _) => data.data,
                    color: Color(0xFF309092),
                    dataLabelSettings:
                        const DataLabelSettings(isVisible: false),
                    width: 0.15,
                    spacing: 0.1,
                    animationDuration: 0,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
