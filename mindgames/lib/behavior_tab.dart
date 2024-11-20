import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/Homepage.dart';
import 'package:mindgames/adhd_tracking_page.dart';
import 'package:mindgames/asd_tracking_page.dart';

class BehaviorTab extends StatelessWidget {
  const BehaviorTab({Key? key}) : super(key: key);

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
                  indicatorColor: Color(0xFF309092),
                  labelColor: Color(0xFF309092),
                  labelStyle: TextStyle(
                      fontSize: screenWidth * 0.04, fontFamily: 'ShantellSans'),
                  tabs: [
                    Tab(height: screenHeight * 0.07, text: 'ADHD'.tr),
                    Tab(height: screenHeight * 0.07, text: 'ASD'.tr),
                  ],
                ),
                const Expanded(
                  child: TabBarView(
                    children: [
                      ADHDTrackingPage(),
                      ASDTrackingPage(),
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
