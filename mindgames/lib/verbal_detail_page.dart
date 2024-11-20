import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/graph_data.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/utils/difficulty_enum.dart';
import 'package:mindgames/widgets/Container_widget.dart';
import 'package:mindgames/widgets/bar_graph_widget.dart';
import 'package:mindgames/widgets/gameprogressrow.dart';
import 'package:mindgames/widgets/wrapper_widget.dart';

class VerbalDetailPage extends ConsumerStatefulWidget {
  const VerbalDetailPage({super.key});

  @override
  _VerbalDetailPageState createState() => _VerbalDetailPageState();
}

class _VerbalDetailPageState extends ConsumerState<VerbalDetailPage> {
  late final selectedChild;
  List<GraphData> VerbaleasyGraphData = [];
  List<GraphData> VerbalmediumGraphData = [];
  List<GraphData> VerbalhardGraphData = [];
  bool isLoading = true;
  Map<String, Map<Difficulty, double>> VerbalprogressData = {};
  final List<bool> _selectedTimePeriod = <bool>[true, false];

  @override
  void initState() {
    super.initState();
    selectedChild = ref.read(selectedChildDataProvider);
    _fetchVerbalGraphData();
    fetchVerbalProgressData();
  }

  Future<void> _fetchVerbalGraphData() async {
    final selectedChild = ref.read(selectedChildDataProvider);

    try {
      final VerbaleasyData = await CloudStoreService()
          .getVerbalGraphData(selectedChild, Difficulty.easy);
      final VerbalmediumData = await CloudStoreService()
          .getVerbalGraphData(selectedChild, Difficulty.medium);
      final VerbalhardData = await CloudStoreService()
          .getVerbalGraphData(selectedChild, Difficulty.hard);

      setState(() {
        VerbaleasyGraphData = VerbaleasyData;
        VerbalmediumGraphData = VerbalmediumData;
        VerbalhardGraphData = VerbalhardData;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching graph data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchVerbalProgressData() async {
    final selectedChild = ref.read(selectedChildDataProvider);
    String? userId = selectedChild?.childId;

    try {
      Map<String, Map<Difficulty, double>> Verbaldata = {
        'Voiceloon': {
          Difficulty.easy: await CloudStoreService()
              .getVoiceloonDataWithDifficulty(userId, Difficulty.easy),
          Difficulty.medium: await CloudStoreService()
              .getVoiceloonDataWithDifficulty(userId, Difficulty.medium),
          Difficulty.hard: await CloudStoreService()
              .getVoiceloonDataWithDifficulty(userId, Difficulty.hard),
        },
      };

      setState(() {
        VerbalprogressData = Verbaldata;
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
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MainWrapper()));
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
                          'Verbal Skills Detail Page'.tr,
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
                          fillColor: Color(0xFF309092),
                          color: Color(0xFF309092),
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
                      SizedBox(height: 20),
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
                              graphData: VerbaleasyGraphData,
                              difficultyLabel: 'Easy Level'.tr,
                              aggregateByYear: showYear,
                            ),
                            BarGraphWidget(
                              graphData: VerbalmediumGraphData,
                              difficultyLabel: 'Medium Level'.tr,
                              aggregateByYear: showYear,
                            ),
                            BarGraphWidget(
                              graphData: VerbalhardGraphData,
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
                          'Verbal Skills Scores'.tr,
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
                            'Voiceloon'.tr,
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
                                      'Voiceloon'.tr,
                                      VerbalprogressData['Voiceloon'] ??
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
