import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showParentsConfirmationDialog(
    BuildContext context, VoidCallback onConfirmed) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: const BorderSide(color: Colors.black, width: 3),
            ),
            content: SizedBox(
              width: constraints.maxWidth * 0.8,
              height: constraints.maxHeight * 0.2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "Did your child complete the task?".tr,
                      style: TextStyle(
                        fontSize: constraints.maxWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text(
                          "No".tr,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: constraints.maxWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      SizedBox(width: constraints.maxWidth * 0.02),
                      TextButton(
                        child: Text(
                          "Yes".tr,
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: constraints.maxWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          onConfirmed();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth * 0.05,
                vertical: constraints.maxHeight * 0.01),
          );
        },
      );
    },
  );
}
