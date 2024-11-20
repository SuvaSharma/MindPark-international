import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mindgames/child_profile_list_page.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/controllers/language_controller.dart';
import 'package:mindgames/language_widget.dart';
import 'package:mindgames/models/subscription_model.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/services/auth_service.dart';
import 'package:mindgames/utils/handle_payment.dart';
import 'package:mindgames/widgets/snackbar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindgames/parentlockpage.dart';
import 'package:url_launcher/url_launcher.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  final currentUser = AuthService.user;

  late Future<Map<String, dynamic>> signedInUser;
  final AudioCache _audioCache = AudioCache();
  late SharedPreferences _prefs;
  final player = AudioPlayer();

  late bool agreedToTerms = false;
  CloudStoreService cloudStoreService = CloudStoreService();
  SubscriptionModel? subscriptionData;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    getAgreementStatus();
    getSubscriptionData();

    signedInUser = getCurrentUser();
  }

  void getAgreementStatus() async {
    agreedToTerms = await cloudStoreService.getTermsStatus(currentUser!.uid);
  }

  Future<void> getSubscriptionData() async {
    subscriptionData =
        await cloudStoreService.getSubscriptionData(currentUser!.email);
    if (subscriptionData == null) {
      print('Start trial period');

      // Await the handleTrialAction to finish before fetching subscriptionData again
      await handleTrialAction();

      subscriptionData =
          await cloudStoreService.getSubscriptionData(currentUser!.email);
      print(subscriptionData);
    }
    ref.read(selectedSubscriptionDataProvider.notifier).state =
        subscriptionData;

    print(
        'this is the provider: ${ref.read(selectedSubscriptionDataProvider)}');
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    return await cloudStoreService.getCurrentUser(currentUser!.uid);
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> updateTermsStatus() async {
    final currentUser = AuthService.user?.uid;
    if (currentUser != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where("userId", isEqualTo: currentUser)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userDoc.id)
            .update({
          'agreedToTerms': true,
        });
        setState(() {
          agreedToTerms = true;
        });
      }
    }
  }

  Future<void> _showPinVerificationDialog(
      BuildContext context, Map<String, dynamic> signedInUser) async {
    final TextEditingController _pinController = TextEditingController();

    Future<bool> checkPIN() async {
      try {
        bool isValid = await cloudStoreService.verifyPIN(
            currentUser!.uid, _pinController.text);
        return isValid;
      } catch (e) {
        print(e);
        return false;
      }
    }

    if (signedInUser['PIN'] == null) {
      Get.to(() => ParentalLockSetupPage());
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        double dialogWidth = screenWidth * 0.8;
        if (screenWidth > 600) {
          dialogWidth = screenWidth * 0.5;
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
            side: const BorderSide(
              color: Color(0xFF309092),
              width: 2.0,
            ),
          ),
          backgroundColor: Colors.white,
          title: Text(
            'Enter PIN'.tr,
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Color(0xFF309092),
            ),
          ),
          content: Container(
            width: dialogWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  cursorColor: const Color(0xFF309092),
                  style: TextStyle(fontSize: screenWidth * 0.05),
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    counterStyle: TextStyle(
                        fontSize: screenWidth * 0.045,
                        color: const Color(0xFF309092)),
                    labelText: 'PIN'.tr,
                    labelStyle: TextStyle(
                      fontSize: screenWidth * 0.05,
                      color: const Color(0xFF309092),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Color(0xFF309092)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Color(0xFF309092)),
                    ),
                  ),
                  obscureText: true,
                  maxLength: 4,
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Get.to(() => ParentalLockSetupPage(isRecoveryFlow: true));
                  },
                  child: Text(
                    'Forgot PIN?'.tr,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      color: Color.fromARGB(199, 48, 144, 146),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF309092)),
                onPressed: () async {
                  if (await checkPIN()) {
                    Navigator.of(context).pop();
                    Get.to(() => const ChildProfileList(shownWhen: 'launch'));
                  } else {
                    showCustomSnackbar(context, 'Error'.tr, 'Incorrect PIN'.tr);
                  }
                },
                child: Text(
                  'Submit'.tr,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTermsAndConditionsDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        double dialogWidth = screenWidth * 0.8;
        if (screenWidth > 600) {
          dialogWidth = screenWidth * 0.5;
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
            side: BorderSide(
              color: Colors.black,
              width: 4.0,
            ),
          ),
          backgroundColor: Colors.white,
          title: Text(
            'Terms and Conditions'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize:
                  screenWidth * 0.06, // Adjust font size based on screen width
              fontWeight: FontWeight.bold,
              color: Color(0xFF309092),
            ),
          ),
          content: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02,
            ),
            width: dialogWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'ShantellSans',
                      fontSize: screenWidth * 0.04,
                    ),
                    children: [
                      TextSpan(
                        text:
                            'By clicking \"I Agree\", I affirm that I have read and accept to be bound by MindPark '
                                .tr,
                      ),
                      TextSpan(
                        text: 'Terms'.tr,
                        style: TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            const link =
                                "https://sites.google.com/view/mindpark-terms-and-conditions/home";
                            launchUrl(Uri.parse(link),
                                mode: LaunchMode.externalApplication);
                          },
                      ),
                      TextSpan(
                        text: ', and '.tr,
                      ),
                      TextSpan(
                        text: 'Privacy Policy'.tr,
                        style: TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            const link =
                                "https://sites.google.com/view/mindpark-privacy-policy/home";
                            launchUrl(Uri.parse(link),
                                mode: LaunchMode.externalApplication);
                          },
                      ),
                      TextSpan(
                        text: 'further terms and condition lines for nepali'
                            .tr
                            .tr,
                      ),
                      TextSpan(
                        text:
                            '. Further, I consent to the use of my information for the stated purpose.'
                                .tr,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Handle "I Do Not Agree" action
                Navigator.of(context).pop();
              },
              child: Text(
                'I Do Not Agree'.tr,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width *
                      0.045, // Adjust font size for button text
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.02),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                updateTermsStatus();
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                final bool parentalLockEnabled =
                    prefs.getBool('parental_lock_enabled') ?? true;
                if (parentalLockEnabled) {
                  signedInUser.then(
                      (user) => _showPinVerificationDialog(context, user));
                } else {
                  Get.to(() => const ChildProfileList(
                        shownWhen: 'launch',
                      ));
                }
              },
              child: Text(
                'I Agree'.tr,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width *
                      0.045, // Adjust font size for button text
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF309092),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return FutureBuilder<Map<String, dynamic>>(
      future: signedInUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: SizedBox(
                height: screenWidth * 0.09,
                width: screenWidth * 0.09,
                child: const CircularProgressIndicator(
                  color: Color(0xFFF88379),
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading user data'));
        } else {
          final user = snapshot.data!;
          return Scaffold(
            body: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/homepage2.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: GetBuilder<LocalizationController>(
                  builder: (localizationController) {
                    // Pre-translate texts
                    String selectLanguageText = 'select_language'.tr;
                    String youCanChangeLanguageText =
                        'you_can_change_language'.tr;
                    String playText = "Let's Start".tr;

                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05,
                          ),
                          Center(
                            child: Image.asset(
                              "assets/images/mindparklogo.png",
                              height: MediaQuery.of(context).size.height * 0.27,
                            ),
                          ),
                          Text(
                            'MindPark',
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.09,
                              color: Color(0xFF3CB4B6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            selectLanguageText,
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              color: Color(0xFFCD8278),
                            ),
                          ),
                          Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 1.08,
                                ),
                                itemCount: 2,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) => LanguageWidget(
                                  languageModel:
                                      localizationController.languages[index],
                                  localizationController:
                                      localizationController,
                                  index: index,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.01),
                          Text(
                            youCanChangeLanguageText,
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.042,
                              color: Color(0xFFCD8278),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              player.play(AssetSource('playbutton.mp3'));
                              final SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              final bool parentalLockEnabled =
                                  prefs.getBool('parental_lock_enabled') ??
                                      true;

                              if (agreedToTerms == false) {
                                _showTermsAndConditionsDialog(context);
                              } else {
                                if (parentalLockEnabled) {
                                  _showPinVerificationDialog(context, user);
                                } else {
                                  Get.to(() => const ChildProfileList(
                                      shownWhen: 'launch'));
                                }
                              }
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.38,
                              height: MediaQuery.of(context).size.width * 0.21,
                              color: Colors.transparent,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: Image.asset(
                                      'assets/images/Play.png',
                                      width: MediaQuery.of(context).size.width *
                                          0.38,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.205,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02),
                                      child: Text(
                                        playText,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.06,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
