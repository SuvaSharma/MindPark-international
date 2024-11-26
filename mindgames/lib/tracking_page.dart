import 'dart:developer';

import 'package:accordion/accordion.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mindgames/circular_chart.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/task_line_chart.dart';
import 'package:mindgames/widgets/star_display.dart';

class TrackingPage extends ConsumerStatefulWidget {
  const TrackingPage({super.key});

  @override
  ConsumerState<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends ConsumerState<TrackingPage> {
  CloudStoreService cloudStoreService = CloudStoreService();
  late final String selectedChildUserId;
  List<ChartData> dataList = [];
  bool isLoading = true;

  late double performanceStrength = 0;
  bool allGamesPlayed = false;

  List<Map<String, dynamic>> gameResult = [
    {
      'domain': 'Attention',
      'tasks': [
        {
          'name': 'Symbol Safari',
          'data': [],
          'avg': 0,
        },
        {
          'name': 'Alert Alphas',
          'data': [],
          'avg': 0,
        },
        {
          'name': 'Track Titans',
          'data': [],
          'avg': 0,
        }
      ]
    },
    {
      'domain': 'Memory',
      'tasks': [
        {
          'name': 'Digit Dazzle',
          'data': [],
          'avg': 0,
        },
      ]
    },
    {
      'domain': 'Inhibitory Control',
      'tasks': [
        {
          'name': 'Alert Alphas',
          'data': [],
          'avg': 0,
        },
        {
          'name': 'Color Clash',
          'data': [],
          'avg': 0,
        }
      ]
    },
    {
      'domain': 'EQ',
      'tasks': [
        {
          'name': 'Mood Magic',
          'data': [],
          'avg': 0,
        }
      ]
    },
    {
      'domain': 'Speed',
      'tasks': [
        {
          'name': 'Symbol Safari',
          'data': [],
          'avg': 0,
        }
      ]
    },
  ];

  double calculateAverage(List<Map<String, dynamic>> data, String parameter) {
    double sum = 0;

    for (final element in data) {
      sum += element[parameter];
    }

    return sum / data.length;
  }

  Future<void> getData() async {
    try {
      final attentionAverage =
          await cloudStoreService.getAttentionAverage(selectedChildUserId);
      final spanAverage =
          await cloudStoreService.getMemoryAverage(selectedChildUserId);
      final inhbitionAverage =
          await cloudStoreService.getInhibitionAverage(selectedChildUserId);
      final eqAverage =
          await cloudStoreService.getEQAverage(selectedChildUserId);

      final speedAverage =
          await cloudStoreService.getSpeedAverage(selectedChildUserId);

      performanceStrength = (attentionAverage +
              spanAverage +
              inhbitionAverage +
              eqAverage +
              speedAverage) /
          5;

      log('My performance: $performanceStrength');

      // data to be used for circular chart
      dataList = [
        ChartData('Attention', attentionAverage, determineColor('Attention')),
        ChartData('Memory', spanAverage, determineColor('Memory')),
        ChartData('Inhibitory Control', inhbitionAverage,
            determineColor('Inhibitory Control')),
        ChartData('Speed', speedAverage, determineColor('Speed')),
        ChartData('EQ', eqAverage, determineColor('EQ')),
      ];

      //data to be used for accordion data

      // Attention
      final attentionSDMT = await cloudStoreService.getDataForTasks(
          selectedChildUserId, 'SDMT', 'accuracy');

      final attentionCPT = await cloudStoreService.getDataForTasks(
          selectedChildUserId, 'CPT', 'accuracy');

      final attentionTMT = await cloudStoreService.getDataForTasks(
          selectedChildUserId, 'TMT', 'accuracy');

      gameResult[0]['tasks'][0]['data'] = attentionSDMT;
      gameResult[0]['tasks'][1]['data'] = attentionCPT;
      gameResult[0]['tasks'][2]['data'] = attentionTMT;

      gameResult[0]['tasks'][0]['avg'] =
          calculateAverage(attentionSDMT, 'accuracy');
      gameResult[0]['tasks'][1]['avg'] =
          calculateAverage(attentionCPT, 'accuracy');
      gameResult[0]['tasks'][2]['avg'] =
          calculateAverage(attentionTMT, 'accuracy');

      // Memory
      final memoryDST = await cloudStoreService.getDataForTasks(
          selectedChildUserId, 'DST', 'span');
      gameResult[1]['tasks'][0]['data'] = memoryDST;
      gameResult[1]['tasks'][0]['avg'] = calculateAverage(memoryDST, 'span');

      // Inhibitory Control
      final inhibitionCPT = await cloudStoreService.getDataForTasks(
          selectedChildUserId, 'CPT', 'inhibitoryControl');
      final inhibitionStroop = await cloudStoreService.getDataForTasks(
          selectedChildUserId, 'Stroop', 'accuracy');

      gameResult[2]['tasks'][0]['data'] = inhibitionCPT;
      gameResult[2]['tasks'][1]['data'] = inhibitionStroop;

      gameResult[2]['tasks'][0]['avg'] =
          calculateAverage(inhibitionCPT, 'inhibitoryControl');
      gameResult[2]['tasks'][1]['avg'] =
          calculateAverage(inhibitionStroop, 'accuracy');

      // Emotional Quotient
      final eqERT = await cloudStoreService.getDataForTasks(
          selectedChildUserId, 'ERT', 'accuracy');
      gameResult[3]['tasks'][0]['data'] = eqERT;
      gameResult[3]['tasks'][0]['avg'] = calculateAverage(eqERT, 'accuracy');

      // Speed
      final speedSDMT = await cloudStoreService.getDataForTasks(
          selectedChildUserId, 'SDMT', 'score');
      gameResult[4]['tasks'][0]['data'] = speedSDMT;
      gameResult[4]['tasks'][0]['avg'] = calculateAverage(speedSDMT, 'score');

      allGamesPlayed = attentionSDMT.isNotEmpty &&
          attentionCPT.isNotEmpty &&
          attentionTMT.isNotEmpty &&
          memoryDST.isNotEmpty &&
          inhibitionStroop.isNotEmpty &&
          inhibitionCPT.isNotEmpty &&
          eqERT.isNotEmpty &&
          speedSDMT.isNotEmpty;
    } catch (e) {
      // Handle any errors that might occur during data fetch
      log('Error fetching data: $e');
    }
  }

  Accordion _nestedAccordion() {
    return Accordion(
        children: gameResult
            .map((item) => _accordionSection(item['domain'], item['tasks']))
            .toList());
  }

  AccordionSection _accordionSection(
      String domainName, List<Map<String, dynamic>> item) {
    return AccordionSection(
      isOpen: true,
      leftIcon: determineIcon(domainName),
      rightIcon: Icon(
        Icons.arrow_drop_down,
        color: Colors.white,
        size: MediaQuery.of(context).size.width * 0.06,
      ),
      headerBackgroundColor: determineColor(domainName),
      headerBackgroundColorOpened: determineColor(domainName),
      header: Text(domainName.tr,
          style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.06,
              fontWeight: FontWeight.bold)),
      headerPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
      contentBackgroundColor: const Color(0xfff7f7f7),
      content: _taskContent(domainName, item),
      contentHorizontalPadding: MediaQuery.of(context).size.width * 0.03,
      contentVerticalPadding: MediaQuery.of(context).size.width * 0.03,
      contentBorderColor: determineColor(domainName),
      contentBorderWidth: MediaQuery.of(context).size.width * 0.0040,
    );
  }

  Widget _taskContent(String domainName, List<Map<String, dynamic>> data) {
    String parameter = '';
    log('--------------------');
    log('$data');
    return SingleChildScrollView(
      child: Column(
        children: data.map((item) {
          String levelName = item['name'];
          List<Map<String, dynamic>> levelData = item['data'];
          log('$levelData');
          double avgData = item['avg'];
          switch (domainName) {
            case 'Attention':
              switch (levelName) {
                case 'Symbol Safari':
                case 'Alert Alphas':
                case 'Track Titans':
                  parameter = 'accuracy';
                  break;
              }
              break;

            case 'Memory':
              switch (levelName) {
                case 'Digit Dazzle':
                  parameter = 'span';
                  break;
              }
              break;

            case 'Inhibitory Control':
              switch (levelName) {
                case 'Color Clash':
                  parameter = 'accuracy';
                  break;
                case 'Alert Alphas':
                  parameter = 'inhibitoryControl';
              }
              break;

            case 'EQ':
              switch (levelName) {
                case 'Mood Magic':
                  parameter = 'accuracy';
                  break;
              }
              break;

            case 'Speed':
              switch (levelName) {
                case 'Symbol Safari':
                  parameter = 'score';
                  break;
              }
              break;
          }
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.025),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.height * 0.025),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.020),
                child: Column(
                  children: [
                    //level name and circular chart
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.013),
                          child: Text(
                            levelName.tr,
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05,
                              fontWeight: FontWeight.bold,
                              color: determineColor(domainName),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: !avgData.isNaN,
                          child: SizedBox(
                            height: MediaQuery.of(context).size.width * 0.2,
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: CircularChart(
                              chartData: ChartData(levelName, avgData,
                                  determineColor(domainName)),
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.033,
                            ),
                          ),
                        ),
                      ],
                    ),
                    //line chart
                    levelData.isEmpty
                        ? Text('No data available currently!'.tr,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05,
                            ))
                        : levelData.length == 1
                            ? Text('Need further data to plot graph'.tr,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.05,
                                ))
                            : Padding(
                                padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width *
                                        0.02,
                                    right: MediaQuery.of(context).size.width *
                                        0.02),
                                child: TaskLineChart(
                                  dataPoints: levelData
                                      .map((item) => FlSpot(
                                          levelData.indexOf(item).toDouble(),
                                          item[parameter].toDouble()))
                                      .toList(),
                                  avgDataPoints: levelData
                                      .map((item) => FlSpot(
                                          levelData.indexOf(item).toDouble(),
                                          avgData))
                                      .toList(),
                                  gradientColors: [
                                    determineColor(domainName),
                                    determineColor(domainName).withOpacity(0.5)
                                  ],
                                  title: '',
                                  graphData: levelData,
                                ),
                              )
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color determineColor(String domainName) {
    switch (domainName) {
      case 'Attention':
        return Colors.indigo;
      case 'Memory':
        return Colors.blue;
      case 'Inhibitory Control':
        return Colors.red;
      case 'Speed':
        return Colors.orange;
      case 'EQ':
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  Icon determineIcon(String domainName) {
    switch (domainName) {
      case 'Attention':
        return Icon(Icons.visibility,
            color: Colors.white,
            size: MediaQuery.of(context).size.width *
                0.05); // Icon representing focus or visibility
      case 'Memory':
        return Icon(Icons.memory,
            color: Colors.white,
            size: MediaQuery.of(context).size.width *
                0.05); // Icon representing memory or brain
      case 'Inhibitory Control':
        return Icon(Icons.block,
            color: Colors.white,
            size: MediaQuery.of(context).size.width *
                0.05); // Icon representing control or blocking
      case 'Speed':
        return Icon(Icons.speed,
            color: Colors.white,
            size: MediaQuery.of(context).size.width *
                0.05); // Icon representing speed
      case 'EQ':
        return Icon(Icons.favorite,
            color: Colors.white,
            size: MediaQuery.of(context).size.width *
                0.05); // Icon representing emotional intelligence (heart)
      default:
        return const Icon(Icons.help_outline,
            color: Colors.white); // Default icon representing unknown
    }
  }

  @override
  void initState() {
    super.initState();
    final selectedChild = ref.read(selectedChildDataProvider);
    selectedChildUserId = selectedChild!.childId;
    getData().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  List<Widget> buildGrid() {
    List<Widget> widgetList = [];
    int dataIndex = 0;
    for (int i = 0; i < 9; i++) {
      int index = i + 1;
      if (index % 2 == 0) {
        widgetList.add(const SizedBox());
      } else {
        widgetList.add(Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dataList[dataIndex].x.tr,
              style: TextStyle(
                color: dataList[dataIndex].color,
                fontSize: MediaQuery.of(context).size.width * 0.035,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: dataList[dataIndex].color,
              ),
              textAlign: TextAlign.center,
            ),
            Flexible(
              child: CircularChart(
                  chartData: dataList[dataIndex],
                  fontSize: MediaQuery.of(context).size.width * 0.05),
            ),
          ],
        ));
        dataIndex++;
      }
    }
    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/levelscreen.png'),
                fit: BoxFit.cover)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Text('Tracking Page'.tr,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.08,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF309092),
                        )),
                  ),
                  isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator())
                      : GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 3,
                          physics: const NeverScrollableScrollPhysics(),
                          children: buildGrid(),
                        ),
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.96,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                        MediaQuery.of(context).size.width * 0.070),
                    topRight: Radius.circular(
                        MediaQuery.of(context).size.width * 0.070),
                  ),
                  color: const Color(0xffEFF0EE),
                ),
                child: Column(
                  children: [
                    Divider(
                      color: const Color.fromARGB(255, 107, 107, 107),
                      height: 40,
                      thickness: MediaQuery.of(context).size.height * 0.003,
                      indent: MediaQuery.of(context).size.width * 0.47,
                      endIndent: MediaQuery.of(context).size.width * 0.47,
                    ),
                    Visibility(
                      visible: allGamesPlayed,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: MediaQuery.of(context).size.width * 0.3,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: performanceStrength >= 75
                                    ? Colors.green.withOpacity(0.2)
                                    : performanceStrength >= 50
                                        ? Colors.blue.withOpacity(0.2)
                                        : Colors.red.withOpacity(0.2),
                              ),
                              child: Center(
                                child: Icon(
                                  performanceStrength >= 75
                                      ? Icons.emoji_events
                                      : performanceStrength >= 50
                                          ? Icons.emoji_people
                                          : Icons.thumb_up,
                                  size: MediaQuery.of(context).size.width * 0.2,
                                  color: performanceStrength >= 75
                                      ? Colors.amber
                                      : performanceStrength >= 50
                                          ? Colors.lightBlueAccent
                                          : Colors.orange,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height *
                                      0.01),
                              child: Text(
                                performanceStrength >= 75
                                    ? 'Awesome Achiever'.tr
                                    : performanceStrength >= 50
                                        ? 'Great Performer'.tr
                                        : 'Keep Trying'.tr,
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.05,
                                  color: performanceStrength >= 75
                                      ? Colors.amber
                                      : performanceStrength >= 50
                                          ? Colors.lightBlueAccent
                                          : Colors.deepOrange,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.01,
                              ),
                              child: StarDisplay(
                                  numberOfStars: performanceStrength >= 75
                                      ? 3
                                      : performanceStrength >= 50
                                          ? 2
                                          : 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 0.025,
                          left: MediaQuery.of(context).size.width * 0.025,
                          right: MediaQuery.of(context).size.width * 0.025,
                        ),
                        child: isLoading
                            ? const Center(
                                child: SizedBox(
                                    child:
                                        CircularProgressIndicator.adaptive()))
                            : _nestedAccordion(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
