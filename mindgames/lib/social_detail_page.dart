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

class SocialDetailPage extends ConsumerStatefulWidget {
  const SocialDetailPage({super.key});

  @override
  _SocialDetailPageState createState() => _SocialDetailPageState();
}

class _SocialDetailPageState extends ConsumerState<SocialDetailPage> {
  Child? selectedChild;
  List<GraphData> SocialeasyGraphData = [];
  List<GraphData> SocialmediumGraphData = [];
  List<GraphData> SocialhardGraphData = [];
  bool isLoading = true;
  Map<String, Map<Difficulty, double>> SocialprogressData = {};
  final List<bool> _selectedTimePeriod = <bool>[true, false];

  @override
  void initState() {
    super.initState();
    selectedChild = ref.read(selectedChildDataProvider);
    _fetchSocialGraphData();
    fetchSocialProgressData();
  }

  Future<void> _fetchSocialGraphData() async {
    final selectedChild = ref.read(selectedChildDataProvider);

    try {
      final SocialeasyData = await CloudStoreService()
          .getSocialGraphData(selectedChild, Difficulty.easy);
      final SocialmediumData = await CloudStoreService()
          .getSocialGraphData(selectedChild, Difficulty.medium);
      final SocialhardData = await CloudStoreService()
          .getSocialGraphData(selectedChild, Difficulty.hard);

      setState(() {
        SocialeasyGraphData = SocialeasyData;
        SocialmediumGraphData = SocialmediumData;
        SocialhardGraphData = SocialhardData;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching graph data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchSocialProgressData() async {
    final selectedChild = ref.read(selectedChildDataProvider);
    String? userId = selectedChild?.childId;

    try {
      Map<String, Map<Difficulty, double>> Socialdata = {
        'Simon Says': {
          Difficulty.easy: await CloudStoreService()
              .getSimonSaysDataWithDifficulty(userId, Difficulty.easy),
          Difficulty.medium: await CloudStoreService()
              .getSimonSaysDataWithDifficulty(userId, Difficulty.medium),
          Difficulty.hard: await CloudStoreService()
              .getSimonSaysDataWithDifficulty(userId, Difficulty.hard),
        },
        'Mood Magic': {
          Difficulty.easy: await CloudStoreService()
              .getMoodMagicDataWithDifficulty(userId, Difficulty.easy),
          Difficulty.medium: await CloudStoreService()
              .getMoodMagicDataWithDifficulty(userId, Difficulty.medium),
          Difficulty.hard: await CloudStoreService()
              .getMoodMagicDataWithDifficulty(userId, Difficulty.hard),
        },
        'Jungle Jingles': {
          Difficulty.easy: await CloudStoreService()
              .getJungleJinglesDataWithDifficulty(userId, Difficulty.easy),
          Difficulty.medium: await CloudStoreService()
              .getJungleJinglesDataWithDifficulty(userId, Difficulty.medium),
          Difficulty.hard: await CloudStoreService()
              .getJungleJinglesDataWithDifficulty(userId, Difficulty.hard),
        },
        'Gaze Maze': {
          Difficulty.easy: await CloudStoreService()
              .getGazeMazeDataWithDifficulty(userId, Difficulty.easy),
          Difficulty.medium: await CloudStoreService()
              .getGazeMazeDataWithDifficulty(userId, Difficulty.medium),
          Difficulty.hard: await CloudStoreService()
              .getGazeMazeDataWithDifficulty(userId, Difficulty.hard),
        }
      };

      setState(() {
        SocialprogressData = Socialdata;
        isLoading = false;
      });
    } catch (e) {
      // Handle errors here
      print('Error fetching data: $e');
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
                          'Social Skills Detail Page'.tr,
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
                              graphData: SocialeasyGraphData,
                              difficultyLabel: 'Easy Level'.tr,
                              aggregateByYear: showYear,
                            ),
                            BarGraphWidget(
                              graphData: SocialmediumGraphData,
                              difficultyLabel: 'Medium Level'.tr,
                              aggregateByYear: showYear,
                            ),
                            BarGraphWidget(
                              graphData: SocialhardGraphData,
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
                          'Social Skills Scores'.tr,
                          style: TextStyle(
                              color: Color(0xFF309092),
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.05),
                        ),
                      ),
                      Divider(
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
                            'Mood Magic'.tr,
                            style: TextStyle(
                              color: Color(0xFF309092),
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
                                      'Mood Magic'.tr,
                                      SocialprogressData['Mood Magic'] ?? {},
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
                            'Simon Says'.tr,
                            style: TextStyle(
                              color: Color(0xFF309092),
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
                                      'Simon Says'.tr,
                                      SocialprogressData['Simon Says'] ??
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
                            'Gaze Maze'.tr,
                            style: TextStyle(
                              color: Color(0xFF309092),
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
                                      'Gaze Maze'.tr,
                                      SocialprogressData['Gaze Maze'] ?? {},
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
                            'Jungle Jingles'.tr,
                            style: TextStyle(
                              color: Color(0xFF309092),
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
                                      'Jungle Jingles'.tr,
                                      SocialprogressData['Jungle Jingles'] ??
                                          {},
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
