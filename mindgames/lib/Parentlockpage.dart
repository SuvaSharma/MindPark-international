import 'package:flutter/material.dart';
import 'package:mindgames/child_profile_list_page.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/services/auth_service.dart';
import 'package:mindgames/swipe_button_view.dart';
import 'package:mindgames/widgets/snackbar_widget.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ParentalLockSetupPage extends StatefulWidget {
  final bool isRecoveryFlow;

  ParentalLockSetupPage({this.isRecoveryFlow = false});

  @override
  _ParentalLockSetupPageState createState() => _ParentalLockSetupPageState();
}

class _ParentalLockSetupPageState extends State<ParentalLockSetupPage> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isFinished = false;
  bool isReauthenticated = false;

  final currentUser = AuthService.user?.uid;
  User user = FirebaseAuth.instance.currentUser!;

  CloudStoreService cloudStoreService = CloudStoreService();

  Future<void> _validateAndSave() async {
    if (_pinController.text.length == 4 &&
        _pinController.text == _confirmPinController.text) {
      try {
        await cloudStoreService.addPIN(currentUser!, _pinController.text);
        showCustomSnackbar(context, 'Success'.tr, 'PIN set successfully'.tr);
        Get.offAll(() => const ChildProfileList(shownWhen: 'launch'));
      } catch (e) {
        showCustomSnackbar(context, 'Error'.tr, 'Error setting PIN'.tr);
      }
    } else {
      showCustomSnackbar(
          context,
          'Error'.tr,
          'PINs do not match, are not 4 digits, or security questions are not answered'
              .tr);
    }
  }

  Future<void> _reauthenticate() async {
    try {
      User user = FirebaseAuth.instance.currentUser!;
      if (user.providerData
          .any((element) => element.providerId == 'password')) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: _emailController.text,
          password: _passwordController.text,
        );

        await user.reauthenticateWithCredential(credential);
        setState(() {
          isReauthenticated = true;
        });
        showCustomSnackbar(
            context, 'Success'.tr, 'Reauthentication successful'.tr);
      } else if (user.providerData
          .any((element) => element.providerId == 'google.com')) {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          final AuthCredential credential = GoogleAuthProvider.credential(
            idToken: googleAuth.idToken,
            accessToken: googleAuth.accessToken,
          );

          await user.reauthenticateWithCredential(credential);
          setState(() {
            isReauthenticated = true;
          });
          showCustomSnackbar(
              context, 'Success'.tr, 'Reauthentication successful'.tr);
        } else {
          showCustomSnackbar(context, 'Error'.tr, 'Google sign-in failed'.tr);
        }
      }
    } catch (e) {
      showCustomSnackbar(context, 'Error'.tr, 'Reauthentication failed'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SafeArea(
      child: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
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
                  'Setup your Lock'.tr,
                  style: TextStyle(
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF309092)),
                ),
              ),
              if (widget.isRecoveryFlow && !isReauthenticated) ...[
                if ((user.providerData
                    .any((element) => element.providerId == 'password'))) ...[
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: TextField(
                      controller: TextEditingController(
                          text: user.email), // Preset value
                      enabled: false, // Disable editing
                      cursorColor: const Color(0xFF309092),

                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(fontSize: screenWidth * 0.05),
                      decoration: InputDecoration(
                        labelText: 'Enter Email'.tr,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(
                            fontSize: screenWidth * 0.05,
                            color: const Color(0xFF309092)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide:
                              const BorderSide(color: Color(0xFF309092)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide:
                              const BorderSide(color: Color(0xFF309092)),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: TextField(
                      cursorColor: const Color(0xFF309092),
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      style: TextStyle(fontSize: screenWidth * 0.05),
                      decoration: InputDecoration(
                        labelText: 'Enter Password'.tr,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(
                            fontSize: screenWidth * 0.05,
                            color: const Color(0xFF309092)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide:
                              const BorderSide(color: Color(0xFF309092)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide:
                              const BorderSide(color: Color(0xFF309092)),
                        ),
                      ),
                      obscureText: true,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF309092)),
                    onPressed: _reauthenticate,
                    child: Text(
                      'Reauthenticate'.tr,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ] else ...[
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _reauthenticate,
                          child: Image.asset(
                            'assets/images/google_logo.png',
                            height: screenWidth * 0.13,
                            width: screenWidth * 0.13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              ] else ...[
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: TextField(
                    cursorColor: const Color(0xFF309092),
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: screenWidth * 0.05),
                    decoration: InputDecoration(
                      labelText: 'Enter PIN'.tr,
                      fillColor: Colors.white,
                      counterStyle: TextStyle(fontSize: screenWidth * 0.045),
                      labelStyle: TextStyle(
                          fontSize: screenWidth * 0.05,
                          color: const Color(0xFF309092)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Color(0xFF309092)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Color(0xFF309092)),
                      ),
                    ),
                    obscureText: true,
                    maxLength: 4,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      bottom: screenWidth * 0.04,
                      left: screenWidth * 0.04,
                      right: screenWidth * 0.04),
                  child: TextField(
                    cursorColor: const Color(0xFF309092),
                    style: TextStyle(fontSize: screenWidth * 0.05),
                    controller: _confirmPinController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Confirm PIN'.tr,
                      counterStyle: TextStyle(fontSize: screenWidth * 0.045),
                      labelStyle: TextStyle(
                          fontSize: screenWidth * 0.05,
                          color: const Color(0xFF309092)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Color(0xFF309092)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Color(0xFF309092)),
                      ),
                    ),
                    obscureText: true,
                    maxLength: 4,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  child: Container(
                    height: screenHeight * 0.07,
                    child: SwipeableButtonView(
                      buttonText: 'Swipe to Save PIN'.tr,
                      buttontextstyle: TextStyle(
                          fontSize: screenWidth * 0.05, color: Colors.white),
                      buttonWidget: Container(
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.grey,
                          size: screenHeight * 0.04,
                        ),
                      ),
                      activeColor: Color(0xFF309092),
                      isFinished: isFinished,
                      onWaitingProcess: () {
                        setState(() {
                          isFinished = true;
                        });
                      },
                      onFinish: () {
                        _validateAndSave();
                        Future.delayed(Duration(seconds: 1), () {
                          setState(() {
                            isFinished = false;
                          });
                        });
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ));
  }
}
