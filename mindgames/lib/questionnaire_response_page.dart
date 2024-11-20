import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/utils/convert_to_nepali_numbers.dart';

class QuestionnaireResponsePage extends StatefulWidget {
  final String assessmentId;

  const QuestionnaireResponsePage({Key? key, required this.assessmentId})
      : super(key: key);

  @override
  _QuestionnaireResponsePageState createState() =>
      _QuestionnaireResponsePageState();
}

class _QuestionnaireResponsePageState extends State<QuestionnaireResponsePage> {
  CloudStoreService cloudStoreService = CloudStoreService();
  Map<String, dynamic>? responseData;
  bool isLoading = true;

  // Defined a map to convert numeric answers to strings (confirm it pehle)
  final Map<int, String> answerMapping = {
    0: 'Never',
    1: 'Sometimes',
    2: 'Often',
    3: 'Very Often',
  };

  Future<void> fetchQuestionnaireResponse() async {
    try {
      var response = await cloudStoreService
          .getQuestionnaireResponseById(widget.assessmentId);
      debugPrint('Fetched response: $response');
      setState(() {
        responseData = response;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching questionnaire response: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchQuestionnaireResponse();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/levelscreen.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: isLoading
              ? Center(
                  child: SizedBox(
                  height: screenWidth * 0.09,
                  width: screenWidth * 0.09,
                  child: CircularProgressIndicator(
                      backgroundColor: Colors.black.withOpacity(0.2),
                      color: const Color(0xFF309092)),
                ))
              : responseData == null
                  ? Center(child: Text('No data found'.tr))
                  : SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        child: Column(
                          children: [
                            Text(
                              'Responses'.tr,
                              style: TextStyle(
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 51, 152, 154),
                              ),
                            ),
                            Divider(
                              indent: 80,
                              endIndent: 80,
                              thickness: 3,
                              color: Colors.grey,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            ...List<Map<String, dynamic>>.from(
                                    responseData!['response'])
                                .map((entry) {
                              if (entry is Map<String, dynamic>) {
                                String questionIndex =
                                    entry['question'].split(". ")[0];
                                String questionKey =
                                    entry['question'].split(". ")[1];
                                double numericAnswer = entry['answer'] ?? -1.0;
                                String answerKey =
                                    answerMapping[numericAnswer.toInt()] ??
                                        'unknown_answer';

                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.01),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: screenWidth * 0.08,
                                            child: Text(
                                              convertToNepaliNumbers(
                                                  '$questionIndex.'),
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.045,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.05),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${entry["question"]}'.tr,
                                                  style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.045,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.0125),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: screenWidth * 0.08,
                                            child: Icon(
                                              Icons.arrow_forward_rounded,
                                              size: screenWidth * 0.045,
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.05),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  answerKey.tr,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        screenWidth * 0.045,
                                                  ),
                                                ),
                                                Divider(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                debugPrint('Invalid entry: $entry');
                                return Container();
                              }
                            }),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}
