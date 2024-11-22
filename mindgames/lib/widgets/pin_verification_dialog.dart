import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/parentlockpage.dart';
import 'package:mindgames/profile.dart';
import 'package:mindgames/services/auth_service.dart';
import 'package:mindgames/widgets/snackbar_widget.dart';

Future<void> showProfilePinVerificationDialog(
    BuildContext context, Map<String, dynamic> signedInUser) async {
  final currentUser = AuthService.user;
  CloudStoreService cloudStoreService = CloudStoreService();
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
                  Get.to(() => const Profile());
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
