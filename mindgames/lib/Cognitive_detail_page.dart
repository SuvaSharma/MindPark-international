import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mindgames/child.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/graph_data.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/utils/difficulty_enum.dart';
import 'package:mindgames/widgets/Container_widget.dart';
import 'package:mindgames/widgets/bar_graph_widget.dart';
import 'package:mindgames/widgets/gameprogressrow.dart';
import 'package:mindgames/widgets/wrapper_widget.dart';

class CognitiveDetailPage extends ConsumerStatefulWidget {
  const CognitiveDetailPage({super.key});

  @override
  ConsumerState<CognitiveDetailPage> createState() =>
      _CognitiveDetailPageState();
}

class _CognitiveDetailPageState extends ConsumerState<CognitiveDetailPage> {
  Child? selectedChild;
  List<GraphData> CognitiveeasyGraphData = [];
  List<GraphData> CognitivemediumGraphData = [];
  List<GraphData> CognitivehardGraphData = [];
  bool isLoading = true;
  Map<String, Map<Difficulty, double>> CognitiveprogressData = {};
  final List<bool> _selectedTimePeriod = <bool>[true, false];

  @override
  void initState() {
    super.initState();
    selectedChild = ref.read(selectedChildDataProvider);
    _fetchCognitiveGraphData();
    fetchCognitiveProgressData();
  }

  Future<void> _fetchCognitiveGraphData() async {
    final selectedChild = ref.read(selectedChildDataProvider);

    try {
      final CognitiveeasyData = await CloudStoreService()
          .getCognitiveGraphData(selectedChild, Difficulty.easy);
      final CognitivemediumData = await CloudStoreService()
          .getCognitiveGraphData(selectedChild, Difficulty.medium);
      final CognitivehardData = await CloudStoreService()
          .getCognitiveGraphData(selectedChild, Difficulty.hard);

      setState(() {
        CognitiveeasyGraphData = CognitiveeasyData;
        CognitivemediumGraphData = CognitivemediumData;
        CognitivehardGraphData = CognitivehardData;
        isLoading = false;
      });
    } catch (e) {
      log("Error fetching graph data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCognitiveProgressData() async {
    final selectedChild = ref.read(selectedChildDataProvider);
    String? userId = selectedChild?.childId;

    try {
      Map<String, Map<Difficulty, double>> Cognitivedata = {
        'Maze Magic': {
          Difficulty.easy: await CloudStoreService()
              .getMazeMagicDataWithDifficulty(userId, Difficulty.easy),
          Difficulty.medium: await CloudStoreService()
              .getMazeMagicDataWithDifficulty(userId, Difficulty.medium),
          Difficulty.hard: await CloudStoreService()
              .getMazeMagicDataWithDifficulty(userId, Difficulty.hard),
        },
      };

      setState(() {
        CognitiveprogressData = Cognitivedata;
        isLoading = false;
      });
    } catch (e) {
      // Handle errors here
      log('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    final showYear = _selectedTimePeriod[1];
    return WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const MainWrapper()));
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Image.asset(
                'assets/images/levelscreen.png',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
              ),
              SafeArea(
                  child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Cognitive Skills Detail Page'.tr,
                          style: TextStyle(
                            fontSize: screenWidth * 0.06,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: ToggleButtons(
                          direction: Axis.horizontal,
                          onPressed: (int index) {
                            setState(() {
                              // The button that is tapped is set to true, and the others to false.
                              for (int i = 0;
                                  i < _selectedTimePeriod.length;
                                  i++) {
                                _selectedTimePeriod[i] = i == index;
                              }
                            });
                          },
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                          selectedColor: Colors.white,
                          fillColor: const Color(0xFF309092),
                          color: const Color(0xFF309092),
                          constraints: BoxConstraints(
                            minHeight: screenWidth * 0.10,
                            minWidth: screenWidth * 0.20,
                          ),
                          isSelected: _selectedTimePeriod,
                          children: <Widget>[
                            Text(
                              'Month'.tr,
                              style: TextStyle(fontSize: screenWidth * 0.05),
                            ),
                            Text(
                              'Year'.tr,
                              style: TextStyle(fontSize: screenWidth * 0.05),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (isLoading)
                        Center(
                            child: SizedBox(
                          height: screenWidth * 0.09,
                          width: screenWidth * 0.09,
                          child: CircularProgressIndicator(
                              backgroundColor: Colors.black.withOpacity(0.2),
                              color: const Color(0xFF309092)),
                        ))
                      else
                        Column(
                          children: [
                            BarGraphWidget(
                              graphData: CognitiveeasyGraphData,
                              difficultyLabel: 'Easy Level'.tr,
                              aggregateByYear: showYear,
                            ),
                            BarGraphWidget(
                              graphData: CognitivemediumGraphData,
                              difficultyLabel: 'Medium Level'.tr,
                              aggregateByYear: showYear,
                            ),
                            BarGraphWidget(
                              graphData: CognitivehardGraphData,
                              difficultyLabel: 'Hard Level'.tr,
                              aggregateByYear: showYear,
                            ),
                          ],
                        ),
                      SizedBox(
                        height: screenHeight * 0.03,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Cognitive Skills Scores'.tr,
                          style: TextStyle(
                              color: const Color(0xFF309092),
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.05),
                        ),
                      ),
                      const Divider(
                        thickness: 2,
                        indent: 50,
                        endIndent: 50,
                        color: Colors.black45,
                      ),
                      SizedBox(
                        height: screenHeight * 0.03,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 18.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Maze Magic'.tr,
                            style: TextStyle(
                              color: const Color(0xFF309092),
                              fontSize: screenWidth * 0.06,
                            ),
                          ),
                        ),
                      ),
                      ContainerWidget(
                        screenWidth: screenWidth,
                        child: isLoading
                            ? Center(
                                child: SizedBox(
                                height: screenWidth * 0.09,
                                width: screenWidth * 0.09,
                                child: CircularProgressIndicator(
                                    backgroundColor:
                                        Colors.black.withOpacity(0.2),
                                    color: const Color(0xFF309092)),
                              ))
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                    buildGameProgressRow(
                                      'Maze Magic'.tr,
                                      CognitiveprogressData['Maze Magic'] ??
                                          {}, // null error avoid garna empty map
                                      context,
                                    ),
                                  ]),
                      ),
                    ],
                  ),
                ),
              ))
            ],
          ),
        ));
  }
}
