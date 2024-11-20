import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mindgames/bar_graph.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/questionnaire_response_page.dart';
import 'package:mindgames/services/auth_service.dart';
import 'package:mindgames/utils/difficulty_enum.dart';

class ADHDTrackingPage extends ConsumerStatefulWidget {
  const ADHDTrackingPage({super.key});

  @override
  ConsumerState<ADHDTrackingPage> createState() => _ADHDTrackingPageState();
}

class _ADHDTrackingPageState extends ConsumerState<ADHDTrackingPage> {
  CloudStoreService cloudStoreService = CloudStoreService();
  final currentUser = AuthService.user?.uid;
  late final String selectedChildUserId;

  bool isLoading = true;
  List<Map<String, dynamic>> dataList = [];

  @override
  void initState() {
    super.initState();
    final selectedChild = ref.read(selectedChildDataProvider);
    selectedChildUserId = selectedChild!.childId;
    getData();
  }

  void getData() async {
    dataList = await cloudStoreService.getADHDResponse(
        currentUser!, selectedChildUserId);
    double successRate = await cloudStoreService.getFineMotorDataWithDifficulty(
        selectedChildUserId, Difficulty.medium);
    print(successRate);
    setState(() {
      isLoading = false;
    });
  }

  Accordion _nestedAccordion(List<Map<String, dynamic>>? data) {
    return Accordion(
      headerPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
      contentBorderWidth: 3,
      sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
      sectionClosingHapticFeedback: SectionHapticFeedback.light,
      children: dataList.map((item) {
        return _accordionSection(
            DateFormat.yMMMMd().format(item['assessmentDate']),
            item,
            Colors.blue);
      }).toList(),
    );
  }

  AccordionSection _accordionSection(
      String sessionId, Map<String, dynamic> item, Color color) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return AccordionSection(
      isOpen: true,
      rightIcon: Icon(
        Icons.arrow_drop_down,
        color: Colors.white,
        size: screenWidth * 0.06,
      ),
      headerBackgroundColor: Color(0xFF309092),
      headerBackgroundColorOpened: const Color(0xFFF88379),
      headerPadding: EdgeInsets.only(
        top: screenHeight * 0.01,
        bottom: screenHeight * 0.01,
        left: screenHeight * 0.01,
      ),
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

  Widget _taskContent(Map<String, dynamic> data) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
        padding: EdgeInsets.only(
            left: screenWidth * 0.02, right: screenWidth * 0.02),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Inattentive'.tr,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.05)),
                Text(
                  data['result']['inattentiveness'] >= 6
                      ? 'adhd_yes'.tr
                      : 'adhd_no'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.05,
                    color: data['result']['inattentiveness'] >= 6
                        ? Colors.red
                        : Colors.green,
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Hyperactivity'.tr,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.05)),
                Text(
                  data['result']['hyperactivity'] >= 6
                      ? 'adhd_yes'.tr
                      : 'adhd_no'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.05,
                    color: data['result']['hyperactivity'] >= 6
                        ? Colors.red
                        : Colors.green,
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ADHD Likelihood'.tr,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.05)),
                Text(
                  data['result']['hyperactivity'.tr] >= 6 ||
                          data['result']['inattentiveness'.tr] >= 6
                      ? 'High'.tr
                      : 'Low'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.05,
                    color: data['result']['hyperactivity'] >= 6 ||
                            data['result']['inattentiveness'] >= 6
                        ? Colors.red
                        : Colors.green,
                  ),
                )
              ],
            ),
            TextButton(
                onPressed: () async {
                  // print(data['assessmentId']);
                  // print(
                  //     'this is the response ${await cloudStoreService.getQuestionnaireResponseById(data['assessmentId'])}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuestionnaireResponsePage(
                          assessmentId: data['assessmentId']),
                    ),
                  );
                },
                child: Container(
                    height: screenWidth * 0.15,
                    width: screenWidth * 0.4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF88379),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Text(
                        'View Response'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ))),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final String hyperactivityTitle = 'Hyperactivity'.tr;
    final String inattentivenessTitle = 'Inattentiveness'.tr;
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/levelscreen.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: isLoading
              ? Center(
                  child: SizedBox(
                  height: screenWidth * 0.09,
                  width: screenWidth * 0.09,
                  child: CircularProgressIndicator(
                      backgroundColor: Colors.black.withOpacity(0.2),
                      color: const Color(0xFF309092)),
                ))
              : SingleChildScrollView(
                  child: dataList.isEmpty
                      ? Padding(
                          padding: EdgeInsets.all(screenHeight * 0.03),
                          child: Center(
                            child: Text('No data available currently!'.tr,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: screenWidth * 0.05)),
                          ),
                        )
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Spotting ADHD Signs: Hyperactivity vs. Inattention Trends'
                                    .tr,
                                style: TextStyle(fontSize: screenWidth * 0.05),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            BarGraph(dataList: dataList, parameterList: [
                              {
                                'name': 'hyperactivity',
                                'title': hyperactivityTitle,
                                'limit': 9.0,
                              },
                              {
                                'name': 'inattentiveness',
                                'title': inattentivenessTitle,
                                'limit': 9.0,
                              }
                            ]),
                            Divider(
                              color: Color.fromARGB(255, 107, 107, 107),
                              height: screenHeight * 0.02,
                              thickness: screenHeight * 0.003,
                              indent: screenWidth * 0.22,
                              endIndent: screenWidth * 0.22,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Questionnaire Response'.tr,
                                style: TextStyle(fontSize: screenWidth * 0.05),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: screenWidth * 0.03,
                                  right: screenWidth * 0.03),
                              child: _nestedAccordion(dataList),
                            )
                          ],
                        ),
                ),
        ),
      ),
    );
  }
}
