import 'package:flutter/material.dart';

import 'dialog_card.dart';
import 'register_button.dart';

class MessageDialog extends StatelessWidget {
  const MessageDialog({
    super.key,
    required this.message,
  });
  final String message;

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
            message,
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: screenHeight * 0.025),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              RegisterButton(
                child:
                    Text('OK', style: TextStyle(fontSize: screenWidth * 0.04)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
