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

class ASDTrackingPage extends ConsumerStatefulWidget {
  const ASDTrackingPage({super.key});

  @override
  ConsumerState<ASDTrackingPage> createState() => _ASDTrackingPageState();
}

class _ASDTrackingPageState extends ConsumerState<ASDTrackingPage> {
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
    dataList = await cloudStoreService.getASDResponse(
        currentUser!, selectedChildUserId);

    setState(() {
      isLoading = false;
    });
  }

  String getSeverityText(String type, double count) {
    if (type == 'socialCommunication') {
      if (count <= 5) {
        return 'Low'.tr;
      } else if (count <= 9) {
        return 'Mid'.tr;
      } else {
        return 'High'.tr;
      }
    } else {
      if (count <= 6) {
        return 'Low'.tr;
      } else if (count <= 12) {
        return 'Mid'.tr;
      } else {
        return 'High'.tr;
      }
    }
  }

  Color getSeverityColor(String type, double count) {
    if (type == 'socialCommunication') {
      if (count <= 5) {
        return Colors.green;
      } else if (count <= 9) {
        return Colors.orange;
      } else {
        return Colors.red;
      }
    } else {
      if (count <= 6) {
        return Colors.green;
      } else if (count <= 12) {
        return Colors.orange;
      } else {
        return Colors.red;
      }
    }
  }

  Accordion _nestedAccordion(List<Map<String, dynamic>>? data) {
    return Accordion(
      headerPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
      contentBorderWidth: 3,
      sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
      sectionClosingHapticFeedback: SectionHapticFeedback.light,
      children: dataList.map((item) {
        return _accordionSection(
            DateFormat.yMMMMd().format(item['assessmentDate'.tr]),
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
      headerBackgroundColor: const Color(0xFF309092),
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

    return Padding(
        padding: EdgeInsets.only(
            left: screenWidth * 0.02, right: screenWidth * 0.02),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Social Impairment'.tr,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.05)),
                Text(
                  getSeverityText('socialCommunication',
                      data['result']['socialCommunication']),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.05,
                    color: getSeverityColor('socialCommunication',
                        data['result']['socialCommunication']),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Repetitive Behavior'.tr,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.05)),
                Text(
                  getSeverityText('repetitiveBehavior',
                      data['result']['repetitiveBehavior']),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.05,
                    color: getSeverityColor('repetitiveBehavior',
                        data['result']['repetitiveBehavior']),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ASD Likelihood'.tr,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.05)),
                Text(
                  data['totalScore'] <= 10
                      ? 'Low'.tr
                      : data['totalScore'] <= 20
                          ? 'Mid'.tr
                          : 'High'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.05,
                    color: data['totalScore'] <= 10
                        ? Colors.green
                        : data['totalScore'] <= 20
                            ? Colors.orange
                            : Colors.red,
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
                          assessmentId: data['assessmentId'.tr]),
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
    final socialCommunicationTitle = 'Social Impairment'.tr;
    final repetitiveBehaviorTitle = "Repetitive Behavior".tr;
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
                                'Spotting ASD Signs: Social Communication vs Repetitive Behavior Trends'
                                    .tr,
                                style: TextStyle(fontSize: screenWidth * 0.05),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            BarGraph(
                              dataList: dataList,
                              parameterList: [
                                {
                                  'name': 'socialCommunication',
                                  'title': socialCommunicationTitle,
                                  'limit': 18.0,
                                },
                                {
                                  'name': 'repetitiveBehavior',
                                  'title': repetitiveBehaviorTitle,
                                  'limit': 24.0,
                                }
                              ],
                            ),
                            Divider(
                              color: const Color.fromARGB(255, 107, 107, 107),
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
