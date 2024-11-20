import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dialog_card.dart';
import 'register_button.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
  });
  final String title;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return DialogCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.040,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: screenHeight * 0.025),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              RegisterButton(
                onPressed: () => Navigator.pop(context, false),
                isOutlined: true,
                child: Text('No'.tr,
                    style: TextStyle(fontSize: screenWidth * 0.035)),
              ),
              SizedBox(width: screenWidth * 0.025),
              RegisterButton(
                child: Text('Yes'.tr,
                    style: TextStyle(fontSize: screenWidth * 0.035)),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
