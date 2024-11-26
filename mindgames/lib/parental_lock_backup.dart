import 'package:flutter/material.dart';
import 'package:mindgames/child_profile_list_page.dart';
import 'package:mindgames/swipe_button_view.dart';
import 'package:mindgames/widgets/snackbar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class ParentalLockSetupPage extends StatefulWidget {
  final bool isRecoveryFlow;

  const ParentalLockSetupPage({
    super.key,
    this.isRecoveryFlow = false,
  });

  @override
  State<ParentalLockSetupPage> createState() => _ParentalLockSetupPageState();
}

class _ParentalLockSetupPageState extends State<ParentalLockSetupPage> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final List<TextEditingController> _securityAnswerControllers =
      List.generate(3, (index) => TextEditingController());
  bool isFinished = false;

  final List<String> _securityQuestions = [
    'What is your favorite color?',
    'What was the name of the city/village that you were born?',
    'What is your favorite food?',
  ];

  Future<void> _validateAndSave() async {
    bool areAllQuestionsAnswered = _securityAnswerControllers
        .every((controller) => controller.text.isNotEmpty);

    if (_pinController.text.length == 4 &&
        _pinController.text == _confirmPinController.text &&
        (widget.isRecoveryFlow || areAllQuestionsAnswered)) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('parental_pin', _pinController.text);
      if (!widget.isRecoveryFlow) {
        for (int i = 0; i < _securityQuestions.length; i++) {
          await prefs.setString('security_question_$i', _securityQuestions[i]);
          await prefs.setString(
              'security_answer_$i', _securityAnswerControllers[i].text);
        }
      }
      if (!context.mounted) {
        return;
      }
      showCustomSnackbar(context, 'Success'.tr,
          'PIN and security questions set successfully'.tr);
      Get.offAll(() => const ChildProfileList(shownWhen: 'launch'));
    } else {
      showCustomSnackbar(
          context,
          'Error'.tr,
          'PINs do not match, are not 4 digits, or security questions are not answered'
              .tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/levelscreen.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'Setup your Lock',
                  style: TextStyle(
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF309092)),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: screenWidth * 0.05),
                  decoration: InputDecoration(
                    labelText: 'Enter PIN',
                    fillColor: Colors.white,
                    counterStyle: TextStyle(fontSize: screenWidth * 0.045),
                    labelStyle: TextStyle(fontSize: screenWidth * 0.05),
                  ),
                  obscureText: true,
                  maxLength: 4,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: TextField(
                  style: TextStyle(fontSize: screenWidth * 0.05),
                  controller: _confirmPinController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Confirm PIN',
                    counterStyle: TextStyle(fontSize: screenWidth * 0.045),
                    labelStyle: TextStyle(fontSize: screenWidth * 0.05),
                  ),
                  obscureText: true,
                  maxLength: 4,
                ),
              ),
              if (!widget.isRecoveryFlow) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Recovery Questions',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF309092)),
                  ),
                ),
                const Divider(
                  height: 5.0,
                  thickness: 2.0,
                  color: Color.fromARGB(255, 0, 0, 0),
                  indent: 70.0,
                  endIndent: 70.0,
                ),
                const SizedBox(
                  height: 20,
                ),
                ...List.generate(3, (index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenWidth * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _securityQuestions[index],
                          style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold),
                        ),
                        TextField(
                          controller: _securityAnswerControllers[index],
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
              ],
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: SizedBox(
                  height: screenHeight * 0.07,
                  child: SwipeableButtonView(
                    buttonText: 'Swipe to Save PIN',
                    buttontextstyle: TextStyle(
                        fontSize: screenWidth * 0.05, color: Colors.white),
                    buttonWidget: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey,
                      size: screenHeight * 0.04,
                    ),
                    activeColor: const Color(0xFF309092),
                    isFinished: isFinished,
                    onWaitingProcess: () {
                      // Simulate a delay for some process
                      Future.delayed(const Duration(seconds: 1), () {
                        setState(() {
                          isFinished = true;
                        });
                      });
                    },
                    onFinish: () {
                      _validateAndSave();
                      setState(() {
                        isFinished = false;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
