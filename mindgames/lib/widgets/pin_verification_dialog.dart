import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/parentlockpage.dart';
import 'package:mindgames/services/auth_service.dart';
import 'package:mindgames/widgets/snackbar_widget.dart';

Future<void> showPinVerificationDialog(BuildContext context,
    Map<String, dynamic> signedInUser, Widget destinationPage) async {
  final currentUser = AuthService.user;
  CloudStoreService cloudStoreService = CloudStoreService();
  final TextEditingController pinController = TextEditingController();

  // Check the entered PIN
  Future<bool> checkPIN() async {
    try {
      bool isValid = await cloudStoreService.verifyPIN(
          currentUser!.uid, pinController.text);
      return isValid;
    } catch (e) {
      log('$e');
      return false;
    }
  }

  showDialog(
    context: context,
    builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
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
            color: const Color(0xFF309092),
          ),
        ),
        content: SizedBox(
          width: dialogWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                cursorColor: const Color(0xFF309092),
                style: TextStyle(fontSize: screenWidth * 0.05),
                controller: pinController,
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
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to recovery page if PIN is forgotten
                  Get.to(
                      () => const ParentalLockSetupPage(isRecoveryFlow: true));
                },
                child: Text(
                  'Forgot PIN?'.tr,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: const Color.fromARGB(199, 48, 144, 146),
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
                if (!context.mounted) {
                  return;
                }
                if (await checkPIN()) {
                  Navigator.of(context).pop();
                  // Navigate to the dynamic destination page after successful PIN verification
                  Get.to(() => destinationPage);
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
