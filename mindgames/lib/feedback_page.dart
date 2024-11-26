import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindgames/core/validator.dart';
import 'package:mindgames/models/user_feedback.dart';
import 'package:mindgames/profile.dart';
import 'package:mindgames/widgets/register_button.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  List<String> attachments = [];
  late final TextEditingController textController;
  late final TextEditingController attachmentController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    textController = TextEditingController();
    attachmentController = TextEditingController();
    super.initState();
  }

  void _openImagePicker() async {
    final picker = ImagePicker();
    final pick = await picker.pickImage(source: ImageSource.gallery);
    if (pick != null) {
      setState(() {
        attachments.add(pick.path);
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      attachments.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Profile(),
          ),
        );
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Image.asset(
              'assets/images/homepage2.png',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(screenWidth * 0.1),
                  ),
                  child: Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Feedback'.tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.08,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFF88379),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.05),
                              TextFormField(
                                cursorColor: const Color(0xFFF88379),
                                maxLines: 5,
                                controller: textController,
                                autofocus: true,
                                style: TextStyle(fontSize: screenWidth * 0.04),
                                decoration: InputDecoration(
                                    alignLabelWithHint: true,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    hintText: 'Enter your feedback'.tr,
                                    hintStyle:
                                        TextStyle(fontSize: screenWidth * 0.04),
                                    labelText: 'Feedback'.tr,
                                    errorStyle:
                                        TextStyle(fontSize: screenWidth * 0.04),
                                    labelStyle: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        color: const Color(0xFFF88379)),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.02,
                                      vertical: screenHeight * 0.02,
                                    ),
                                    isDense: true,
                                    filled: true,
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFF88379)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFF88379)),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide:
                                          const BorderSide(color: Colors.red),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide:
                                          const BorderSide(color: Colors.red),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    )),
                                textCapitalization:
                                    TextCapitalization.sentences,
                                textInputAction: TextInputAction.next,
                                validator: Validator.feedbackValidator,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              if (attachments.isNotEmpty) ...[
                                Text(
                                  'Attachments'.tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.06,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFF88379),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                              ],
                              Wrap(
                                spacing: screenWidth * 0.01,
                                runSpacing: screenWidth * 0.01,
                                children:
                                    attachments.asMap().entries.map((entry) {
                                  return Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        child: SizedBox(
                                          width: screenWidth * 0.15,
                                          height: screenWidth * 0.15,
                                          child: Image.file(
                                            File(entry.value),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: screenWidth * 0.01,
                                        right: screenWidth * 0.01,
                                        child: GestureDetector(
                                          onTap: () =>
                                              _removeAttachment(entry.key),
                                          child: CircleAvatar(
                                            backgroundColor: Colors.black87,
                                            radius: screenWidth * 0.025,
                                            child: Icon(
                                              Icons.cancel,
                                              size: screenWidth * 0.05,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              SizedBox(
                                width: screenWidth * 0.6,
                                height: screenWidth * 0.15,
                                child: ElevatedButton.icon(
                                  onPressed: _openImagePicker,
                                  icon: Icon(Icons.attach_file,
                                      size: screenWidth * 0.08),
                                  label: Text('Attach files'.tr),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.red[50],
                                    textStyle: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        fontFamily: 'ShantellSans'),
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              SizedBox(
                                height: screenHeight * 0.07,
                                width: screenWidth * 0.7,
                                child: RegisterButton(
                                  color: const Color(0xFFF88379),
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      try {
                                        final feedback = UserFeedback(
                                            text: textController.text);
                                        log('$feedback');

                                        final Email email = Email(
                                          body: feedback.text,
                                          subject: 'User Feedback',
                                          recipients: [
                                            'mindpark.nepal@gmail.com'
                                          ],
                                          attachmentPaths: attachments,
                                          isHTML: false,
                                        );

                                        await FlutterEmailSender.send(email);
                                        if (!context.mounted) {
                                          return;
                                        }
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const Profile(),
                                          ),
                                        );
                                      } catch (e) {}
                                    }
                                  },
                                  child: Text('Submit'.tr,
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.06)),
                                ),
                              ),
                            ]),
                      )),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
