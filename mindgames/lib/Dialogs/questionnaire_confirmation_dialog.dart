import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showConfirmationDialog(BuildContext context, VoidCallback onConfirmed) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final double dialogWidth = constraints.maxWidth * 0.9;
          final double dialogHeight = constraints.maxHeight * 0.3;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: const BorderSide(color: Colors.black, width: 3),
            ),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: dialogWidth,
                  maxHeight: dialogHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "Do you want to submit the above responses?".tr,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: dialogHeight * 0.05),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: Text(
                            "No".tr,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: dialogWidth * 0.02),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                            onConfirmed(); // Call the submission function
                          },
                          child: Text(
                            "Yes".tr,
                            style: TextStyle(
                              color: Colors.green,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: dialogWidth * 0.05,
              vertical: dialogHeight * 0.02,
            ),
          );
        },
      );
    },
  );
}
