import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showCustomSnackbar(BuildContext context, String title, String message) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  Get.snackbar(
    '',
    '',
    backgroundColor: title == 'Success'.tr
        ? Color(0xff40C2AB).withOpacity(0.8)
        : Colors.red.withOpacity(0.8),
    colorText: Colors.white,
    snackPosition: SnackPosition.TOP,
    margin: EdgeInsets.all(screenWidth * 0.05),
    borderRadius: screenWidth * 0.02,
    icon: Icon(
      title == 'Success'.tr ? Icons.check_box : Icons.warning,
      color: Colors.white,
      size: screenWidth * 0.08,
    ),
    duration: Duration(seconds: 1),
    snackStyle: SnackStyle.FLOATING,
    padding: EdgeInsets.symmetric(
      horizontal: screenWidth * 0.05,
      vertical: screenHeight * 0.015,
    ),
    titleText: Text(
      title.tr,
      style: TextStyle(
        fontSize: screenWidth * 0.05,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    messageText: Text(
      message.tr,
      style: TextStyle(
        fontSize: screenWidth * 0.045,
        color: Colors.white,
      ),
    ),
  );
}
