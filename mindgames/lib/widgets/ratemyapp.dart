import 'package:flutter/material.dart';

class RateMyAppDialog extends StatelessWidget {
  const RateMyAppDialog({super.key});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enjoying our app?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Rate Us!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss the dialog
                  },
                  child: const Text(
                    'No, Thanks',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Open Google Play or App Store for rating
                    Navigator.of(context).pop();
                    // Add logic to open store link here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Rate Now'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss the dialog
                    // Add logic to remind later
                  },
                  child: const Text(
                    'Later',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showRateMyAppDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const RateMyAppDialog();
    },
  );
}
