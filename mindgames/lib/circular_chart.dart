import 'package:flutter/material.dart';
import 'package:mindgames/utils/convert_to_nepali_numbers.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CircularChart extends StatelessWidget {
  final ChartData chartData;
  final double fontSize;

  const CircularChart(
      {super.key, required this.chartData, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final List<ChartData> updatedChartData = [
      ChartData(chartData.x, chartData.y, chartData.color),
      ChartData('Nothing', 100 - chartData.y, chartData.color.withOpacity(0.4)),
    ];

    return SizedBox(
      child: SfCircularChart(
        annotations: <CircularChartAnnotation>[
          CircularChartAnnotation(
            widget: Text(
              '${convertToNepaliNumbers(chartData.y.toStringAsFixed(0))}%',
              style: TextStyle(color: chartData.color, fontSize: fontSize),
            ),
          ),
        ],
        series: <CircularSeries>[
          DoughnutSeries<ChartData, String>(
            dataSource: updatedChartData,
            pointColorMapper: (ChartData data, _) => data.color,
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => data.y,
            innerRadius: '80%',
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}
