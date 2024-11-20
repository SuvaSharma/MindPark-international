import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BarGraph extends StatefulWidget {
  final List<Map<String, dynamic>> dataList;
  final List<Map<String, dynamic>> parameterList;
  const BarGraph({
    super.key,
    required this.dataList,
    required this.parameterList,
  });
  final Color leftBarColor = const Color(0xFF309092);
  final Color rightBarColor = const Color(0xFFF88379);
  //final Color avgColor = Colors.purple;
  @override
  State<StatefulWidget> createState() => BarGraphState();
}

class BarGraphState extends State<BarGraph> {
  final double width = 10;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex = -1;

  @override
  void initState() {
    super.initState();

    rawBarGroups = widget.dataList
        .map((e) => makeGroupData(
              widget.dataList.indexOf(e),
              e['result'][widget.parameterList[0]['name']].toDouble(),
              e['result'][widget.parameterList[1]['name']].toDouble(),
            ))
        .toList();

    showingBarGroups = List.of(rawBarGroups);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: widget.dataList.length > 6
                      ? screenWidth * (widget.dataList.length / 6)
                      : screenWidth,
                  child: Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.02),
                    child: BarChart(
                      BarChartData(
                        maxY: widget.parameterList[1]['limit'] as double,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: ((group) {
                              return Colors.grey;
                            }),
                            getTooltipItem: (a, b, c, d) => null,
                          ),
                          // touchCallback: (FlTouchEvent event, response) {
                          //   if (response == null || response.spot == null) {
                          //     setState(() {
                          //       touchedGroupIndex = -1;
                          //       showingBarGroups = List.of(rawBarGroups);
                          //     });
                          //     return;
                          //   }

                          //   touchedGroupIndex = response.spot!.touchedBarGroupIndex;

                          //   setState(() {
                          //     if (!event.isInterestedForInteractions) {
                          //       touchedGroupIndex = -1;
                          //       showingBarGroups = List.of(rawBarGroups);
                          //       return;
                          //     }
                          //     showingBarGroups = List.of(rawBarGroups);
                          //     if (touchedGroupIndex != -1) {
                          //       var sum = 0.0;
                          //       for (final rod
                          //           in showingBarGroups[touchedGroupIndex].barRods) {
                          //         sum += rod.toY;
                          //       }
                          //       final avg = sum /
                          //           showingBarGroups[touchedGroupIndex]
                          //               .barRods
                          //               .length;

                          //       showingBarGroups[touchedGroupIndex] =
                          //           showingBarGroups[touchedGroupIndex].copyWith(
                          //         barRods: showingBarGroups[touchedGroupIndex]
                          //             .barRods
                          //             .map((rod) {
                          //           return rod.copyWith(
                          //               toY: avg, color: widget.avgColor);
                          //         }).toList(),
                          //       );
                          //     }
                          //   });
                          // },
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
                              getTitlesWidget: bottomTitles,
                              reservedSize:
                                  MediaQuery.of(context).size.height * 0.05,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize:
                                  MediaQuery.of(context).size.height * 0.05,
                              interval: 2,
                              getTitlesWidget: leftTitles,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: const Border(
                            left: BorderSide(color: Colors.black, width: 1),
                            bottom: BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        barGroups: showingBarGroups,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          getDrawingVerticalLine: (value) {
                            return const FlLine(
                              color: Color(0xffe7e8ec),
                              strokeWidth: 1,
                            );
                          },
                          drawHorizontalLine: true,
                          getDrawingHorizontalLine: (value) {
                            return const FlLine(
                              color: Color(0xffe7e8ec),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        extraLinesData: ExtraLinesData(
                          horizontalLines: [
                            if (widget.parameterList[0]['name'] ==
                                    'inattentiveness' ||
                                widget.parameterList[0]['name'] ==
                                    'hyperactivity')
                              HorizontalLine(
                                y: 6,
                                color: Colors.black,
                                strokeWidth: screenWidth * 0.005,
                                dashArray: [5, 5],
                              ),
                            if (widget.parameterList[0]['name'] ==
                                'socialCommunication')
                              HorizontalLine(
                                y: 5,
                                color: widget.leftBarColor,
                                strokeWidth: screenWidth * 0.005,
                                dashArray: [5, 5],
                              ),
                            if (widget.parameterList[0]['name'] ==
                                'socialCommunication')
                              HorizontalLine(
                                y: 9,
                                color: widget.leftBarColor,
                                strokeWidth: screenWidth * 0.005,
                                dashArray: [5, 5],
                              ),
                            if (widget.parameterList[1]['name'] ==
                                'repetitiveBehavior')
                              HorizontalLine(
                                y: 6,
                                color: widget.rightBarColor,
                                strokeWidth: screenWidth * 0.005,
                                dashArray: [5, 5],
                              ),
                            if (widget.parameterList[1]['name'] ==
                                'repetitiveBehavior')
                              HorizontalLine(
                                y: 12,
                                color: widget.rightBarColor,
                                strokeWidth: screenWidth * 0.005,
                                dashArray: [5, 5],
                              )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Legend(
                  color: widget.leftBarColor,
                  text: widget.parameterList[0]['title'],
                ),
                SizedBox(width: screenWidth * 0.05),
                Legend(
                  color: widget.rightBarColor,
                  text: widget.parameterList[1]['title'],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    final screenWidth = MediaQuery.of(context).size.width;
    var style = TextStyle(
      color: const Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: screenWidth * 0.035,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Row(
        children: [
          Text(value.toInt().toString(), style: style),
        ],
      ),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final screenWidth = MediaQuery.of(context).size.width;
    Widget text;
    var style = TextStyle(
      color: const Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: screenWidth * 0.035,
    );
    if (value.toInt() >= 0 && value.toInt() < widget.dataList.length) {
      text = Text(
        DateFormat.Md()
            .format(widget.dataList[value.toInt()]['assessmentDate']),
        style: style,
      );
    } else {
      text = Text('', style: style);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: widget.leftBarColor,
          width: width,
        ),
        BarChartRodData(
          toY: y2,
          color: widget.rightBarColor,
          width: width,
        ),
      ],
    );
  }
}

class Legend extends StatelessWidget {
  final Color color;
  final String text;

  const Legend({
    super.key,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: <Widget>[
        Container(
          width: screenWidth * 0.03,
          height: screenWidth * 0.03,
          color: color,
        ),
        SizedBox(width: screenWidth * 0.02),
        Text(
          text,
          style: TextStyle(
            color: const Color(0xff7589a2),
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.038,
          ),
        ),
      ],
    );
  }
}
