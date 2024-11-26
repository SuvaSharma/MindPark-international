import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/Parentlockpage.dart';
import 'package:mindgames/widgets/snackbar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecoveryQuestionsScreen extends StatefulWidget {
  const RecoveryQuestionsScreen({super.key});

  @override
  State<RecoveryQuestionsScreen> createState() =>
      _RecoveryQuestionsScreenState();
}

class _RecoveryQuestionsScreenState extends State<RecoveryQuestionsScreen> {
  final List<TextEditingController> _answerControllers =
      List.generate(3, (index) => TextEditingController());
  late SharedPreferences _prefs;
  final List<String> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      for (int i = 0; i < 3; i++) {
        _questions.add(_prefs.getString('security_question_$i') ?? '');
      }
    });
  }

  Future<void> _validateAnswers() async {
    bool areAnswersCorrect = true;

    for (int i = 0; i < _answerControllers.length; i++) {
      String savedAnswer = _prefs.getString('security_answer_$i') ?? '';
      if (_answerControllers[i].text != savedAnswer) {
        areAnswersCorrect = false;
        break;
      }
    }

    if (areAnswersCorrect) {
      Get.to(() => const ParentalLockSetupPage(isRecoveryFlow: true));
    } else {
      showCustomSnackbar(
          context, 'Error'.tr, 'Incorrect answers to security questions'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...List.generate(_questions.length, (index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _questions[index],
                        style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _answerControllers[index],
                        style: TextStyle(fontSize: screenWidth * 0.05),
                        decoration: InputDecoration(
                          labelText: 'Answer ${index + 1}',
                          labelStyle: TextStyle(fontSize: screenWidth * 0.05),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: screenHeight * 0.05),
              Center(
                child: ElevatedButton(
                  onPressed: _validateAnswers,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
