import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mindgames/child_profile_list_page.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/feedback_page.dart';
import 'package:mindgames/profile_page.dart';
import 'package:mindgames/core/dialogs.dart';
import 'package:mindgames/rate_my_app_page.dart';
import 'package:mindgames/registration_page.dart';
import 'package:mindgames/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ChartData {
  ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}

class Profile extends ConsumerStatefulWidget {
  const Profile({super.key});

  @override
  ConsumerState<Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  CloudStoreService cloudStoreService = CloudStoreService();
  late String currentDate;
  final userId = AuthService.user?.uid;
  late Map<String, dynamic> currentUser;
  bool isLoading = true;

  void setCurrentDate() {
    currentDate = DateFormat.yMMMMd().format(DateTime.now());
  }

  Future<void> getCurrentUser() async {
    currentUser = await cloudStoreService.getCurrentUser(userId);
  }

  @override
  void initState() {
    super.initState();
    setCurrentDate();
    getCurrentUser().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: SafeArea(
            bottom: false,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF37B197),
                    Color(0xFF309092),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.topLeft,
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            isLoading
                                ? Center(
                                    child: CircularProgressIndicator(
                                        backgroundColor:
                                            Colors.black.withOpacity(0.2),
                                        color: const Color(0xFF309092)))
                                : Text(
                                    '${'Hello, '.tr + currentUser['name']!.split(' ')[0]}!',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.07,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                            Text(
                              currentDate,
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: screenHeight * 1.07,
                    width: screenWidth,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Divider(
                          color: const Color.fromARGB(255, 107, 107, 107),
                          height: screenHeight * 0.030,
                          thickness: screenHeight * 0.003,
                          indent: screenWidth * 0.47,
                          endIndent: screenWidth * 0.47,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: screenWidth * 0.010,
                              left: screenWidth * 0.030,
                              right: screenWidth * 0.030),
                          child: Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(15),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfilePage()),
                                );
                              },
                              child: Container(
                                height: screenHeight / 8.7,
                                width: screenWidth,
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'User Profile'.tr,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.055,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'View and update your profile'.tr,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.037,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(Icons.more_horiz,
                                          size: screenWidth * 0.055),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: screenWidth * 0.050,
                              left: screenWidth * 0.030,
                              right: screenWidth * 0.030),
                          child: Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(15),
                            child: GestureDetector(
                              onTap: () {
                                const link =
                                    "https://sites.google.com/view/mindpark-privacy-policy/home";
                                launchUrl(Uri.parse(link),
                                    mode: LaunchMode.externalApplication);
                              },
                              child: Container(
                                height: screenHeight / 8.7,
                                width: screenWidth,
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Privacy Policy'.tr,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.055,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Read our Privacy Policy'.tr,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.037,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(Icons.more_horiz,
                                          size: screenWidth * 0.055),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: screenWidth * 0.050,
                              left: screenWidth * 0.030,
                              right: screenWidth * 0.030),
                          child: Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(15),
                            child: GestureDetector(
                              onTap: () {
                                const link =
                                    "https://sites.google.com/view/mindpark-terms-and-conditions/home";
                                launchUrl(Uri.parse(link),
                                    mode: LaunchMode.externalApplication);
                              },
                              child: Container(
                                height: screenHeight / 8.7,
                                width: screenWidth,
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Terms and Conditions'.tr,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.055,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Read our Terms and Conditions'.tr,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.037,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(Icons.more_horiz,
                                          size: screenWidth * 0.055),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: screenWidth * 0.050,
                              left: screenWidth * 0.030,
                              right: screenWidth * 0.030),
                          child: Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(15),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ChildProfileList(
                                            shownWhen: 'profile'),
                                  ),
                                );
                              },
                              child: Container(
                                height: screenHeight / 8.7,
                                width: screenWidth,
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Switch Profile'.tr,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.055,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Switch or add new profiles'.tr,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.037,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(Icons.more_horiz,
                                          size: screenWidth * 0.055),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: screenWidth * 0.050,
                              left: screenWidth * 0.030,
                              right: screenWidth * 0.030),
                          child: Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(15),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FeedbackPage(),
                                  ),
                                );
                              },
                              child: Container(
                                height: screenHeight / 8.7,
                                width: screenWidth,
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Feedback'.tr,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.055,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Help to make our app better'.tr,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.037,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(Icons.more_horiz,
                                          size: screenWidth * 0.055),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: screenWidth * 0.050,
                              left: screenWidth * 0.030,
                              right: screenWidth * 0.030),
                          child: Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(15),
                            child: GestureDetector(
                              onTap: () async {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RateMyAppPage()),
                                );
                              },
                              child: Container(
                                height: screenHeight / 8.7,
                                width: screenWidth,
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Rate our app'.tr,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.055,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Like our app? Rate Us!'.tr,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.037,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(Icons.more_horiz,
                                          size: screenWidth * 0.055),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: screenWidth * 0.045,
                              left: screenWidth * 0.030,
                              right: screenWidth * 0.030),
                          child: Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(15),
                            child: GestureDetector(
                              onTap: () async {
                                final bool shouldLogout =
                                    await showConfirmationDialog(
                                          context: context,
                                          title:
                                              'Do you want to sign out of the app?'
                                                  .tr,
                                        ) ??
                                        false;
                                if (shouldLogout) {
                                  await AuthService.logout();
                                  if (!mounted) return;
                                  Get.offAll(() => const RegistrationPage());
                                }
                              },
                              child: Container(
                                height: screenHeight / 9,
                                width: screenWidth,
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Logout'.tr,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.055,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Icon(Icons.logout,
                                              size: screenWidth * 0.045),
                                        ],
                                      ),
                                      Icon(Icons.more_horiz,
                                          size: screenWidth * 0.055),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
