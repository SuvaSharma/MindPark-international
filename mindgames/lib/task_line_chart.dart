import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TaskLineChart extends StatefulWidget {
  final List<FlSpot> dataPoints;
  final List<FlSpot> avgDataPoints;
  final List<Color> gradientColors;
  final String title;
  final List<Map<String, dynamic>> graphData;

  const TaskLineChart({
    super.key,
    required this.dataPoints,
    required this.avgDataPoints,
    required this.gradientColors,
    required this.title,
    required this.graphData,
  });

  @override
  State<TaskLineChart> createState() => _TaskLineChartState();
}

class _TaskLineChartState extends State<TaskLineChart> {
  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Column(children: [
              AspectRatio(
                aspectRatio: 1.70,
                child: LineChart(
                  showAvg ? avgData(context) : mainData(context),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.003),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor:
                            widget.gradientColors[0].withAlpha(225)),
                    onPressed: () {
                      setState(() {
                        showAvg = !showAvg;
                      });
                    },
                    child: Text(
                      !showAvg ? 'Show Average'.tr : 'Show Data'.tr,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ])
          ],
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(
      BuildContext context, double value, TitleMeta meta) {
    double fontSize = MediaQuery.of(context).size.width * 0.026;
    TextStyle style = TextStyle(
      fontSize: fontSize,
    );
    Widget text;

    if (value.toInt() >= 0 && value.toInt() < widget.graphData.length) {
      text = Text(
        DateFormat.Md().format(widget.graphData[value.toInt()]['sessionId']),
        style: style,
      );
    } else {
      text =
          Text('', style: style); // default empty text if index is out of range
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(BuildContext context, double value, TitleMeta meta) {
    double fontSize = MediaQuery.of(context).size.width * 0.026;
    TextStyle style = TextStyle(
      fontSize: fontSize,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0';
        break;
      case 20:
        text = '20';
        break;
      case 40:
        text = '40';
        break;
      case 60:
        text = '60';
        break;
      case 80:
        text = '80';
        break;
      case 100:
        text = '100';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData(BuildContext context) {
    return LineChartData(
      gridData: FlGridData(
        show: false,
        drawVerticalLine: false,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.teal,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.teal,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: MediaQuery.of(context).size.height * 0.05,
            interval: widget.graphData.length < 5
                ? 1
                : (widget.graphData.length ~/ 5).toDouble(),
            getTitlesWidget: (value, meta) =>
                bottomTitleWidgets(context, value, meta),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 20,
            getTitlesWidget: (value, meta) =>
                leftTitleWidgets(context, value, meta),
            reservedSize: MediaQuery.of(context).size.width *
                0.06, // Adjusted reserved size
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: const Color(0xff37434d),
        ),
      ),
      minX: 0,
      minY: 0,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: widget.dataPoints,
          isCurved: false,
          curveSmoothness: 0.08,
          gradient: LinearGradient(
            colors: widget.gradientColors,
          ),
          barWidth: MediaQuery.of(context).size.width * 0.0040,
          dotData: const FlDotData(
            show: false,
          ),
        ),
      ],
    );
  }

  LineChartData avgData(BuildContext context) {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: false,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: MediaQuery.of(context).size.height * 0.05,
            getTitlesWidget: (value, meta) =>
                bottomTitleWidgets(context, value, meta),
            interval: widget.graphData.length < 5
                ? 1
                : (widget.graphData.length ~/ 5).toDouble(),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) =>
                leftTitleWidgets(context, value, meta),
            reservedSize: MediaQuery.of(context).size.width *
                0.06, // Adjusted reserved size
            interval: 20,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      minY: 0,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: widget.avgDataPoints,
          isCurved: false,
          gradient: LinearGradient(
            colors: [
              ColorTween(
                      begin: widget.gradientColors[0],
                      end: widget.gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(
                      begin: widget.gradientColors[0],
                      end: widget.gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: MediaQuery.of(context).size.width * 0.0040,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(
                        begin: widget.gradientColors[0],
                        end: widget.gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(
                        begin: widget.gradientColors[0],
                        end: widget.gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
