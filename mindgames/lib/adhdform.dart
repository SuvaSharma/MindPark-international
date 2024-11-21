import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mindgames/Data/adhdquestions.dart';
import 'package:mindgames/Dialogs/questionnaire_confirmation_dialog.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/questionnaire_response.dart';
import 'package:mindgames/services/auth_service.dart';
import 'package:mindgames/widgets/questions_slider.dart';
import 'package:mindgames/widgets/snackbar_widget.dart';
import 'package:mindgames/widgets/wrapper_widget.dart';

class ADHD extends ConsumerStatefulWidget {
  const ADHD({super.key});

  @override
  ConsumerState<ADHD> createState() => _ADHDState();
}

class _ADHDState extends ConsumerState<ADHD> {
  List<Map<String, dynamic>> inattentionQuestions = [];
  List<Map<String, dynamic>> hyperactiveQuestions = [];
  List<Map<String, dynamic>> impulsiveQuestions = [];
  late final CloudStoreService cloudStoreService;
  final currentUser = AuthService.user?.uid;
  late final String selectedChildUserId;
  DateTime assessmentDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    inattentionQuestions = List.from(adhdquestions
        .where((q) => q['category'] == 'Inattention Symptoms')
        .map((q) =>
            {'question': q['question'] as String, 'answer': q['answer']}));

    hyperactiveQuestions = List.from(adhdquestions
        .where((q) => q['category'] == 'Hyperactive Symptoms')
        .map((q) =>
            {'question': q['question'] as String, 'answer': q['answer']}));

    impulsiveQuestions = List.from(adhdquestions
        .where((q) => q['category'] == 'Impulsive Symptoms')
        .map((q) =>
            {'question': q['question'] as String, 'answer': q['answer']}));

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
          category: 'ADHD',
          assessmentDate: assessmentDate,
          response: [
            ...inattentionQuestions,
            ...hyperactiveQuestions,
            ...impulsiveQuestions
          ],
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
        return;
      }
      showCustomSnackbar(context, 'Error'.tr, '${e.toString()}'.tr);
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
                        'ADHD Questionnaire'.tr,
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
                        _buildCategory("Inattention Questions".tr,
                            inattentionQuestions, constraints),
                        SizedBox(height: constraints.maxHeight * 0.03),
                        _buildCategory(
                          "Hyperactive Questions".tr,
                          hyperactiveQuestions,
                          constraints,
                        ),
                        _buildCategory(
                          "Impulsive Questions".tr,
                          impulsiveQuestions,
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
            return QuestionSlider(
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
