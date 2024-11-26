import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mindgames/Data/autismquestions.dart';
import 'package:mindgames/Dialogs/questionnaire_confirmation_dialog.dart';
import 'package:mindgames/widgets/austism_question_slider.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/questionnaire_response.dart';
import 'package:mindgames/services/auth_service.dart';
import 'package:mindgames/widgets/snackbar_widget.dart';
import 'package:mindgames/widgets/wrapper_widget.dart';

class Autism extends ConsumerStatefulWidget {
  const Autism({super.key});

  @override
  ConsumerState<Autism> createState() => _AutismState();
}

class _AutismState extends ConsumerState<Autism> {
  List<Map<String, dynamic>> a1Questions = [];
  List<Map<String, dynamic>> a2Questions = [];
  late final CloudStoreService cloudStoreService;
  final currentUser = AuthService.user?.uid;
  late final String selectedChildUserId;
  DateTime assessmentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    a1Questions = List.from(autismquestions
        .where((q) => q['category'] == 'Social Communication and Interaction')
        .map((q) =>
            {'question': (q['question'] as String), 'answer': q['answer']})
        .toList());

    a2Questions = List.from(autismquestions
        .where((q) =>
            q['category'] ==
            'Restricted, Repetitive Patterns of Behavior, Interests, or Activities')
        .map((q) =>
            {'question': (q['question'] as String), 'answer': q['answer']})
        .toList());

    cloudStoreService = CloudStoreService();
    final selectedChild = ref.read(selectedChildDataProvider);
    selectedChildUserId = selectedChild!.childId;
  }

  void saveQuestionnaireResponse() async {
    try {
      await cloudStoreService.addQuestionnaireResponse(
        QuestionnaireResponse(
          userId: currentUser!,
          childId: selectedChildUserId,
          category: 'ASD',
          assessmentDate: assessmentDate,
          response: [...a1Questions, ...a2Questions],
        ),
      );

      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainWrapper()),
        (route) => false,
      );
      showCustomSnackbar(
          context, 'Success'.tr, 'Questionnaire submitted successfully!'.tr);
    } catch (e) {
      if (!context.mounted) {
        showCustomSnackbar(context, 'Error'.tr, e.toString().tr);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/levelscreen.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: constraints.maxHeight * 0.02),
                      child: Text(
                        'ASD Questionnaire'.tr,
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.06,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    color: const Color.fromARGB(255, 107, 107, 107),
                    height: constraints.maxHeight * 0.02,
                    thickness: constraints.maxHeight * 0.003,
                    indent: constraints.maxWidth * 0.18,
                    endIndent: constraints.maxWidth * 0.18,
                  ),
                  SizedBox(height: constraints.maxHeight * 0.02),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth * 0.04),
                      children: [
                        _buildCategory(
                            "Social Communication and Interaction".tr,
                            a1Questions,
                            constraints),
                        SizedBox(height: constraints.maxHeight * 0.03),
                        _buildCategory(
                          "Restricted, Repetitive Patterns of Behavior, Interests, or Activities"
                              .tr,
                          a2Questions,
                          constraints,
                        ),
                        SizedBox(height: constraints.maxHeight * 0.02),
                        Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () {
                              showConfirmationDialog(context, () {
                                saveQuestionnaireResponse();
                              });
                            },
                            child: Container(
                              width: constraints.maxWidth * 0.25,
                              height: constraints.maxHeight * 0.06,
                              decoration: BoxDecoration(
                                color: const Color(0xFF309092),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Center(
                                child: Text(
                                  'Submit'.tr,
                                  style: TextStyle(
                                    fontSize: constraints.maxWidth * 0.045,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.02),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategory(String categoryName,
      List<Map<String, dynamic>> questions, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.04),
          child: Text(
            categoryName,
            style: TextStyle(
              fontSize: constraints.maxWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 51, 152, 154),
            ),
          ),
        ),
        SizedBox(height: constraints.maxHeight * 0.02),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            return AutismQuestionSlider(
              question: questions[index]['question'],
              answer: questions[index]['answer'],
              onChanged: (newValue) {
                setState(() {
                  questions[index]['answer'] = newValue;
                });
              },
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
