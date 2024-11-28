import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
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

class FinemotorDetailPage extends ConsumerStatefulWidget {
  const FinemotorDetailPage({super.key});

  @override
  ConsumerState<FinemotorDetailPage> createState() =>
      _FinemotorDetailPageState();
}

class _FinemotorDetailPageState extends ConsumerState<FinemotorDetailPage> {
  Child? selectedChild;
  List<GraphData> easyGraphData = [];
  List<GraphData> mediumGraphData = [];
  List<GraphData> hardGraphData = [];
  bool isLoading = true;
  Map<String, Map<Difficulty, double>> progressData = {};
  final List<bool> _selectedTimePeriod = <bool>[true, false];

  @override
  void initState() {
    super.initState();
    selectedChild = ref.read(selectedChildDataProvider);
    _fetchGraphData();
    fetchProgressData();
  }

  Future<void> _fetchGraphData() async {
    final selectedChild = ref.read(selectedChildDataProvider);

    try {
      final easyData = await CloudStoreService()
          .getFineMotorGraphData(selectedChild, Difficulty.easy);
      final mediumData = await CloudStoreService()
          .getFineMotorGraphData(selectedChild, Difficulty.medium);
      final hardData = await CloudStoreService()
          .getFineMotorGraphData(selectedChild, Difficulty.hard);

      log('this is the medium data: $mediumData');

      setState(() {
        easyGraphData = easyData;
        mediumGraphData = mediumData;
        hardGraphData = hardData;
        isLoading = false;
      });
    } catch (e) {
      log("Error fetching graph data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchProgressData() async {
    final selectedChild = ref.read(selectedChildDataProvider);
    String? userId = selectedChild?.childId;

    try {
      Map<String, Map<Difficulty, double>> data = {
        'TMT': {
          Difficulty.easy: await CloudStoreService()
              .getTMTDataWithDifficulty(userId, Difficulty.easy),
          Difficulty.medium: await CloudStoreService()
              .getTMTDataWithDifficulty(userId, Difficulty.medium),
          Difficulty.hard: await CloudStoreService()
              .getTMTDataWithDifficulty(userId, Difficulty.hard),
        },
        'Lego Game': {
          Difficulty.easy: await CloudStoreService()
              .getPixelPuzzleDataWithDifficulty(userId, Difficulty.easy),
          Difficulty.medium: await CloudStoreService()
              .getPixelPuzzleDataWithDifficulty(userId, Difficulty.medium),
          Difficulty.hard: await CloudStoreService()
              .getPixelPuzzleDataWithDifficulty(userId, Difficulty.hard),
        },
        'Puzzle Paradise': {
          Difficulty.easy: await CloudStoreService()
              .getPuzzleParadiseDataWithDifficulty(userId, Difficulty.easy),
          Difficulty.medium: await CloudStoreService()
              .getPuzzleParadiseDataWithDifficulty(userId, Difficulty.medium),
          Difficulty.hard: await CloudStoreService()
              .getPuzzleParadiseDataWithDifficulty(userId, Difficulty.hard),
        },
        'Picture Sorting Game': {
          Difficulty.easy: await CloudStoreService()
              .getPictureSortingGameDataWithDifficulty(userId, Difficulty.easy),
          Difficulty.medium: await CloudStoreService()
              .getPictureSortingGameDataWithDifficulty(
                  userId, Difficulty.medium),
          Difficulty.hard: await CloudStoreService()
              .getPictureSortingGameDataWithDifficulty(userId, Difficulty.hard),
        }
      };

      setState(() {
        progressData = data;
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
                        'Fine Motor Detail Page'.tr,
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
                            graphData: easyGraphData,
                            difficultyLabel: 'Easy Level'.tr,
                            aggregateByYear: showYear,
                          ),
                          BarGraphWidget(
                            graphData: mediumGraphData,
                            difficultyLabel: 'Medium Level'.tr,
                            aggregateByYear: showYear,
                          ),
                          BarGraphWidget(
                            graphData: hardGraphData,
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
                        'Fine Motor Scores'.tr,
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
                          'Pixel Puzzle'.tr,
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                  buildGameProgressRow(
                                    'Pixel Puzzle'.tr,
                                    progressData['Lego Game'] ?? {},
                                    context,
                                  ),
                                ]),
                    ),
                    SizedBox(
                      height: screenHeight * 0.03,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Track Titans'.tr,
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                  buildGameProgressRow(
                                    'Track Titans'.tr,
                                    progressData['TMT'] ??
                                        {}, // null error avoid garna empty map
                                    context,
                                  ),
                                ]),
                    ),
                    SizedBox(
                      height: screenHeight * 0.03,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Picture Playtime'.tr,
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                  buildGameProgressRow(
                                    'Picture Playtime'.tr,
                                    progressData['Picture Sorting Game'] ?? {},
                                    context,
                                  ),
                                ]),
                    ),
                    SizedBox(
                      height: screenHeight * 0.03,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Puzzle Paradise'.tr,
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                  buildGameProgressRow(
                                    'Puzzle Paradise'.tr,
                                    progressData['Puzzle Paradise'] ?? {},
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
      ),
    );
  }
}
