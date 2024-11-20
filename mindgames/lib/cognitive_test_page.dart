import 'package:accordion/accordion.dart';
import 'package:accordion/accordion_section.dart';
import 'package:accordion/controllers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' show Trans;
import 'package:intl/intl.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/task_line_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindgames/extensions/string_extensions.dart';
import 'package:mindgames/utils/convert_to_nepali_numbers.dart';

class CognitiveTestScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CognitiveTestScreen> createState() =>
      _CognitiveTestScreenState();
}

class _CognitiveTestScreenState extends ConsumerState<CognitiveTestScreen> {
  late final String selectedChildUserId;
  final List<Map<String, dynamic>> cognitiveTests = [
    {
      'displayName': 'Symbol Safari'.tr,
      'test': 'SDMT',
      'icon': Icons.code,
      'color': Colors.blue,
    },
    {
      'displayName': 'Color Clash'.tr,
      'test': 'Stroop',
      'icon': Icons.text_fields,
      'color': Colors.red,
    },
    {
      'displayName': 'Digit Dazzle'.tr,
      'test': 'DST',
      'icon': Icons.format_list_numbered,
      'color': Colors.green,
    },
    {
      'displayName': 'Track Titans'.tr,
      'test': 'TMT',
      'icon': Icons.trending_up,
      'color': Colors.orange,
    },
    {
      'displayName': 'Alert Alphas'.tr,
      'test': 'CPT',
      'icon': Icons.access_time,
      'color': Colors.brown,
    },
    {
      'displayName': 'Mood Magic'.tr,
      'test': 'ERT',
      'icon': Icons.face,
      'color': Colors.purple,
    }
  ];

  late final CloudStoreService _cloudStoreService;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cloudStoreService = CloudStoreService();
    final selectedChild = ref.read(selectedChildDataProvider);
    selectedChildUserId = selectedChild!.childId;
    getData();
  }

  void getData() async {
    final sdmtData = await _cloudStoreService.getSDMTData(selectedChildUserId);
    final stroopData =
        await _cloudStoreService.getStroopData(selectedChildUserId);
    final dstData = await _cloudStoreService.getDSTData(selectedChildUserId);
    final cptData = await _cloudStoreService.getCPTData(selectedChildUserId);
    final tmtData = await _cloudStoreService.getTMTData(selectedChildUserId);
    final ertData = await _cloudStoreService.getERTData(selectedChildUserId);

    cognitiveTests[0]['data'] = sdmtData;
    cognitiveTests[1]['data'] = stroopData;
    cognitiveTests[2]['data'] = dstData;
    cognitiveTests[3]['data'] = tmtData;
    cognitiveTests[4]['data'] = cptData;
    cognitiveTests[5]['data'] = ertData;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/levelscreen.png'),
              fit: BoxFit.cover),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: MediaQuery.of(context).size.width * 0.01,
                    mainAxisSpacing: MediaQuery.of(context).size.width * 0.01,
                  ),
                  itemCount: cognitiveTests.length,
                  itemBuilder: (context, index) {
                    final test = cognitiveTests[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CognitiveTestDetailScreen(
                              displayName: test['displayName'],
                              testName: test['test'],
                              icon: test['icon'],
                              data: test['data'],
                              color: test['color'],
                            ),
                          ),
                        );
                      },
                      child: CognitiveTestCard(
                        displayName: test['displayName'],
                        testName: test['test'],
                        icon: test['icon'],
                        color: test['color'],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class CognitiveTestCard extends StatelessWidget {
  final String displayName;
  final String testName;
  final IconData icon;
  final Color color;

  CognitiveTestCard(
      {required this.displayName,
      required this.testName,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Card(
      color: color.withAlpha(180),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: testName,
              child: Icon(
                icon,
                size: screenWidth * 0.125,
                color: Colors.white,
              ),
            ),
            SizedBox(height: screenHeight * 0.025),
            Text(
              displayName,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CognitiveTestDetailScreen extends ConsumerStatefulWidget {
  final String displayName;
  final String testName;
  final IconData icon;
  final List<Map<String, dynamic>>? data;
  final Color color;

  CognitiveTestDetailScreen({
    required this.displayName,
    required this.testName,
    required this.icon,
    this.data,
    required this.color,
  });

  @override
  ConsumerState<CognitiveTestDetailScreen> createState() =>
      _CognitiveTestDetailScreenState();
}

class _CognitiveTestDetailScreenState
    extends ConsumerState<CognitiveTestDetailScreen> {
  final CloudStoreService _cloudStoreService = CloudStoreService();
  late final String selectedChildUserId;
  bool isLoading = true;
  String parameter = '';

  //to plot the average line in the chart
  double avgParameterData = 0;

  String camelToSentence(String text) {
    var result = text.replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), r" ");
    var finalResult =
        result[0].toUpperCase() + result.substring(1).toLowerCase();
    return finalResult;
  }

  List<Map<String, dynamic>> data = [];

  void getData() async {
    data = await _cloudStoreService.getLevelChartData(
        selectedChildUserId, widget.testName);

    switch (widget.testName) {
      case 'SDMT':
        parameter = 'accuracy';
        break;
      case 'CPT':
        parameter = 'inhibitoryControl';
        break;
      case 'Stroop':
        parameter = 'accuracy';
        break;
      case 'TMT':
        parameter = 'accuracy';
        break;
      case 'DST':
        parameter = 'span';
        break;
      case 'ERT':
        parameter = 'accuracy';
        break;
    }

    double sum = 0;

    for (var item in data) {
      if (item.containsKey(parameter)) {
        sum += item[parameter];
      }
    }

    // Calculate the average
    if (data.isNotEmpty) {
      avgParameterData = sum / data.length;
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final selectedChild = ref.read(selectedChildDataProvider);
    selectedChildUserId = selectedChild!.childId;
    getData();
  }

  Accordion _nestedAccordion(List<Map<String, dynamic>>? data) {
    print(data);
    return Accordion(
      headerPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
      contentBorderWidth: 3,
      sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
      sectionClosingHapticFeedback: SectionHapticFeedback.light,
      children: data!.map((item) {
        return _accordionSection(DateFormat.yMMMMd().format(item['sessionId']),
            item, widget.color.withAlpha(180));
      }).toList(),
    );
  }

  Widget _taskContent(Map<String, dynamic> item) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: item['level'] == "TMT"
          ? item.entries.map<Widget>((entry) {
              // if the key is not game data
              if (entry.key != "gameData") {
                if (entry.key == 'sessionId' || entry.key == 'level')
                  return const SizedBox.shrink();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${camelToSentence(entry.key).capitalize()}: '.tr,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04),
                    ),
                    Text(
                      '${entry.key.capitalize().endsWith('Accuracy') || entry.key.capitalize().endsWith('Error') || entry.key.capitalize().endsWith('Span') || entry.key.capitalize().endsWith('Control') ? '${convertToNepaliNumbers(entry.value.toStringAsFixed(2))}%' : entry.value is double ? '${convertToNepaliNumbers(entry.value.toStringAsFixed(2))} ms' : entry.key.endsWith('Time') ? '${convertToNepaliNumbers('${entry.value}')} sec' : entry.value}',
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: screenWidth * 0.04),
                    )
                  ],
                );
              }
              // if the key is game data
              else {
                List<Widget> gameDataWidgets = [];
                for (var gameDataEntry in entry.value) {
                  gameDataWidgets.addAll(
                    gameDataEntry.entries.map<Widget>((gameEntry) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${camelToSentence(gameEntry.key).capitalize()}: '
                                .tr,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.04),
                          ),
                          Text(
                            '${gameEntry.key.endsWith('accuracy') || gameEntry.key.endsWith('Error') || gameEntry.key.endsWith('span') ? '${convertToNepaliNumbers(gameEntry.value.toStringAsFixed(2))}%' : gameEntry.value is double ? '${convertToNepaliNumbers(gameEntry.value.toStringAsFixed(2))} ms' : gameEntry.key.endsWith('time') ? '${convertToNepaliNumbers('${gameEntry.value}')} sec' : double.tryParse('${gameEntry.value}') != null ? convertToNepaliNumbers('${gameEntry.value}') : '${gameEntry.value}'.tr}',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: screenWidth * 0.04),
                          )
                        ],
                      );
                    }).toList(),
                  );
                  gameDataWidgets.add(SizedBox(
                      height: screenHeight *
                          0.025)); // Add some spacing between entries
                }
                return Column(children: gameDataWidgets);
              }
            }).toList()
          // if other levels are called
          : item.entries.map<Widget>((entry) {
              if (entry.key == 'sessionId') return const SizedBox.shrink();
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${camelToSentence(entry.key).capitalize()}: '.tr,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.04),
                  ),
                  Text(
                    '${entry.key.capitalize().endsWith('Accuracy') || entry.key.capitalize().endsWith('Error') || entry.key.capitalize().endsWith('Span') || entry.key.capitalize().endsWith('Control') ? '${convertToNepaliNumbers(entry.value.toStringAsFixed(2))}%' : entry.value is double && !entry.key.endsWith('score') ? '${convertToNepaliNumbers(entry.value.toStringAsFixed(2))} ms' : entry.key.endsWith('Time') ? '${convertToNepaliNumbers(entry.value)} sec' : double.tryParse('${entry.value}') != null ? convertToNepaliNumbers('${entry.value}') : '${entry.value}'.tr}',
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: screenWidth * 0.04),
                  )
                ],
              );
            }).toList(),
    );
  }

  AccordionSection _accordionSection(
      String sessionId, Map<String, dynamic> item, Color color) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return AccordionSection(
      isOpen: true,
      leftIcon:
          Icon(widget.icon, color: Colors.white, size: screenWidth * 0.06),
      rightIcon: Icon(
        Icons.arrow_drop_down,
        color: Colors.white,
        size: screenWidth * 0.06,
      ),
      headerBackgroundColor: !item.containsKey('status')
          ? color
          : item['status'] == 'Completed'
              ? color
              : Color.fromARGB(255, 146, 48, 48),
      headerBackgroundColorOpened: !item.containsKey('status')
          ? color
          : item['status'] == 'Completed'
              ? color
              : Color.fromARGB(255, 146, 48, 48),
      header: Text(
        sessionId,
        style: TextStyle(
          color: Colors.white,
          fontSize: screenWidth * 0.05,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: _taskContent(item),
      contentHorizontalPadding: 20,
      contentBorderColor: Colors.black54,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                widget.displayName,
                style: TextStyle(
                  fontSize: screenWidth * 0.07,
                  color: widget.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Hero(
                tag: widget.testName,
                child: Icon(
                  widget.icon,
                  size: screenWidth * 0.4,
                  color: widget.color.withAlpha(180),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : data.isNotEmpty
                      ? data.length == 1
                          ? Text('Need two data points to plot graph'.tr,
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: screenWidth * 0.04))
                          : TaskLineChart(
                              dataPoints: data
                                  .map((item) => FlSpot(
                                      data.indexOf(item).toDouble(),
                                      item[parameter]))
                                  .toList(),
                              avgDataPoints: data
                                  .map((item) => FlSpot(
                                      data.indexOf(item).toDouble(),
                                      avgParameterData))
                                  .toList(),
                              gradientColors: [
                                widget.color,
                                widget.color.withOpacity(0.5)
                              ],
                              title: widget.testName,
                              graphData: data,
                            )
                      : Text('No data available currently!'.tr,
                          style: TextStyle(
                              color: Colors.red, fontSize: screenWidth * 0.04)),
              SizedBox(height: screenHeight * 0.02),
              widget.data != null
                  ? Expanded(child: _nestedAccordion(widget.data))
                  : const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
