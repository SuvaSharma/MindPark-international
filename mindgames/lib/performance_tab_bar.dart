import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/Homepage.dart';
import 'package:mindgames/cognitive_test_page.dart'; // Assuming CognitiveTestScreen is defined here
import 'package:mindgames/tracking_page.dart';

class PerformanceTab extends StatelessWidget {
  const PerformanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        // Navigate back to the homepage when the back button is pressed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
        );
        return false; // Prevents the default back button action
      },
      child: DefaultTabController(
        length: 2,
        child: SafeArea(
          child: Scaffold(
            body: Column(
              children: [
                TabBar(
                  indicatorColor: const Color(0xFF309092),
                  labelColor: const Color(0xFF309092),
                  labelStyle: TextStyle(
                      fontSize: screenWidth * 0.04, fontFamily: 'ShantellSans'),
                  tabs: [
                    Tab(
                        height: screenHeight * 0.07,
                        text: 'Performance Data'.tr),
                    Tab(height: screenHeight * 0.07, text: 'Level Data'.tr),
                  ],
                ),
                const Expanded(
                  child: TabBarView(
                    children: [
                      const TrackingPage(),
                      CognitiveTestScreen(), // Assuming this is the correct import
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
