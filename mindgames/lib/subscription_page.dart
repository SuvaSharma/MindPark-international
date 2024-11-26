import 'package:flutter/material.dart';
import 'package:mindgames/widgets/snackbar_widget.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  void showSnackbar(String title, String message) {
    showCustomSnackbar(context, title, message);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
            screenWidth * 0.02,
          ),
          child: Column(
            children: [
              Text(
                'Choose a payment option',
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                ),
              ),
              Row(children: [
                ElevatedButton.icon(
                  label: const Text(''),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(
                      color: Colors.black87,
                      width: 1.0,
                      style: BorderStyle.solid,
                    ),
                  ),
                  onPressed: () {
                    // Esewa esewa = Esewa(showSnackbar: showSnackbar);
                    // esewa.pay();
                  },
                  icon: Image.asset(
                    'assets/images/esewa.png',
                    height: screenHeight * 0.04,
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
