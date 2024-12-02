import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mindgames/AnimatedButton.dart';
import 'package:mindgames/Cognitive_detail_page.dart';
import 'package:mindgames/Domains.dart';
import 'package:mindgames/Math_detail_page.dart';
import 'package:mindgames/adhd_tracking_page.dart';
import 'package:mindgames/adhdform.dart';
import 'package:mindgames/asd_tracking_page.dart';
import 'package:mindgames/autismform.dart';
import 'package:mindgames/child.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/finemotor_detail_page.dart';
import 'package:mindgames/form_section.dart';
import 'package:mindgames/profile.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/services/auth_service.dart';
import 'package:mindgames/settings.dart';
import 'package:mindgames/social_detail_page.dart';
import 'package:mindgames/utils/difficulty_enum.dart';
import 'package:mindgames/verbal_detail_page.dart';
import 'package:mindgames/widgets/Container_widget.dart';
import 'package:mindgames/widgets/carousel_slider.dart';
import 'package:mindgames/widgets/circular_progress_indicator.dart';
import 'package:mindgames/widgets/pin_verification_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  CloudStoreService cloudStoreService = CloudStoreService();

  late Future<Map<String, dynamic>> signedInUser;
  final currentUser = AuthService.user;
  Child? selectedChild;
  bool isLoading = true;
  Map<String, dynamic>? adhdStatus;
  Map<String, dynamic>? asdStatus;
  double easyData = 0;
  double mediumData = 0;
  double hardData = 0;

  double SocialeasyData = 0;
  double SocialmediumData = 0;
  double SocialhardData = 0;

  double VerbaleasyData = 0;
  double VerbalmediumData = 0;
  double VerbalhardData = 0;

  double MatheasyData = 0;
  double MathmediumData = 0;
  double MathhardData = 0;

  double CognitiveeasyData = 0;
  double CognitivemediumData = 0;
  double CognitivehardData = 0;

  double SpeedData = 0;
  double AttentionData = 0;
  double MemoryData = 0;
  double InibitionData = 0;

  double calculateAverage(List<Map<String, dynamic>> data, String parameter) {
    double sum = 0;

    for (final element in data) {
      sum += element[parameter];
    }

    return sum / data.length;
  }

  int _currentIndex = 0;

  List<Map<String, dynamic>> get carouselItems {
    return [
      {
        'imagePath': 'assets/images/BehavioralAssessment.jpeg',
        'name': 'Behavioral Assessment'.tr,
        'navigateTo': const FormPage(),
      },
      {
        'imagePath': 'assets/images/cognitivetraining.jpeg',
        'name': 'Cognitive Training'.tr,
        'navigateTo': const DomainPage(),
      },
    ];
  }

  late double performanceStrength = 0;
  bool allGamesPlayed = false;
  int selectedIndex = 1;

  @override
  void initState() {
    super.initState();

    selectedChild = ref.read(selectedChildDataProvider);
    fetchADHDStatus();
    fetchASDStatus();
    fetchFineMotorData();
    fetchSocialData();
    fetchVerbalData();
    fetchMathData();
    fetchCognitiveData();
    fetchExecutiveData();
    signedInUser = getCurrentUser();
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    return await cloudStoreService.getCurrentUser(currentUser!.uid);
  }

  Future<void> fetchADHDStatus() async {
    try {
      setState(() {
        isLoading = true;
      });

      adhdStatus =
          await cloudStoreService.getADHDStatus(selectedChild!.childId);
    } catch (e) {
      adhdStatus = null;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchASDStatus() async {
    try {
      setState(() {
        isLoading = true;
      });
      asdStatus = await cloudStoreService.getASDStatus(selectedChild!.childId);
    } catch (e) {
      setState(() {
        asdStatus = null;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

// Fine Motor Skills
  Future<void> fetchFineMotorData() async {
    String? userId = selectedChild!.childId;
    setState(() {
      isLoading = true;
    });

    easyData = await CloudStoreService()
        .getFineMotorDataWithDifficulty(userId, Difficulty.easy);
    mediumData = await CloudStoreService()
        .getFineMotorDataWithDifficulty(userId, Difficulty.medium);
    hardData = await CloudStoreService()
        .getFineMotorDataWithDifficulty(userId, Difficulty.hard);

    setState(() {
      isLoading = false;
    });
  }

// Social Skills
  Future<void> fetchSocialData() async {
    String? userId = selectedChild!.childId;
    setState(() {
      isLoading = true;
    });

    SocialeasyData = await CloudStoreService()
        .getSocialDataWithDifficulty(userId, Difficulty.easy);
    SocialmediumData = await CloudStoreService()
        .getSocialDataWithDifficulty(userId, Difficulty.medium);
    SocialhardData = await CloudStoreService()
        .getSocialDataWithDifficulty(userId, Difficulty.hard);
    setState(() {
      isLoading = false;
    });
  }

  //Verbal Skills
  Future<void> fetchVerbalData() async {
    String? userId = selectedChild!.childId;
    setState(() {
      isLoading = true;
    });
    VerbaleasyData = await CloudStoreService()
        .getVerbalDataWithDifficulty(userId, Difficulty.easy);
    VerbalmediumData = await CloudStoreService()
        .getVerbalDataWithDifficulty(userId, Difficulty.medium);
    VerbalhardData = await CloudStoreService()
        .getVerbalDataWithDifficulty(userId, Difficulty.hard);

    setState(() {
      isLoading = false;
    });
  }

  //Math Skills
  Future<void> fetchMathData() async {
    String? userId = selectedChild!.childId;
    setState(() {
      isLoading = true;
    });
    MatheasyData = await CloudStoreService()
        .getMathDataWithDifficulty(userId, Difficulty.easy);
    MathmediumData = await CloudStoreService()
        .getMathDataWithDifficulty(userId, Difficulty.medium);
    MathhardData = await CloudStoreService()
        .getMathDataWithDifficulty(userId, Difficulty.hard);

    setState(() {
      isLoading = false;
    });
  }

  //Cognitive Skills
  Future<void> fetchCognitiveData() async {
    String? userId = selectedChild!.childId;
    setState(() {
      isLoading = true;
    });
    CognitiveeasyData = await CloudStoreService()
        .getCognitiveDataWithDifficulty(userId, Difficulty.easy);
    CognitivemediumData = await CloudStoreService()
        .getCognitiveDataWithDifficulty(userId, Difficulty.medium);
    CognitivehardData = await CloudStoreService()
        .getCognitiveDataWithDifficulty(userId, Difficulty.hard);

    setState(() {
      isLoading = false;
    });
  }

  //Executive Skills
  Future<void> fetchExecutiveData() async {
    String? userId = selectedChild!.childId;
    setState(() {
      isLoading = true;
    });
    SpeedData = await CloudStoreService().getSpeedAverage(userId);
    AttentionData = await CloudStoreService().getAttentionAverage(userId);
    MemoryData = await CloudStoreService().getMemoryAverage(userId);
    InibitionData = await CloudStoreService().getInhibitionAverage(userId);
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Stack(
              children: [
                Material(
                  elevation: 15,
                  child: Container(
                    height: screenHeight * 0.16,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF37B197),
                          Color(0xFF309092),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Settingspage(),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: screenWidth * 0.1,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Profile(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: screenWidth * 0.05, // 5% of screen width
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            color: const Color(0xFF309092),
                            size: screenWidth * 0.09,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "${"Welcome, ".tr}${selectedChild!.name}!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            CarouselSlide(
              carouselItems: carouselItems, // Always fetch the latest items
              screenHeight: screenHeight,
              screenWidth: screenWidth,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
              currentIndex: _currentIndex,

              signedInUser: signedInUser,
            ),
            SizedBox(height: screenHeight * 0.03),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Behavioral Performance'.tr,
                  style: TextStyle(
                      color: const Color(0xFF309092),
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(
              thickness: 2,
              indent: 15,
              endIndent: 25,
              color: Colors.black45,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 15),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Autism'.tr,
                  style: TextStyle(
                    color: const Color(0xFF309092),
                    fontSize: screenWidth * 0.06,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ContainerWidget(
                screenWidth: screenWidth,
                showIcon: true,
                child: asdStatus == null
                    ? Center(
                        child: SizedBox(
                        height: screenWidth * 0.09,
                        width: screenWidth * 0.09,
                        child: CircularProgressIndicator(
                            backgroundColor: Colors.black.withOpacity(0.1),
                            color: const Color(0xFF309092)),
                      ))
                    : asdStatus!.isEmpty
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Please fill the questionnaire!',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenWidth * 0.05,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01), // Spacing
                              AnimatedButton(
                                width: screenWidth * 0.6,
                                height: screenHeight * 0.06,
                                color: const Color(0xFF309092),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Autism()),
                                  );
                                  setState(() {});
                                },
                                child: Text(
                                  'Go to Questionnaire',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        : GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ASDTrackingPage()));
                            },
                            child: Align(
                              alignment: Alignment.center,
                              child: Column(
                                // mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'As of {date}'.tr.replaceFirst(
                                          '{date}',
                                          DateFormat.yMMMMd().format(
                                              asdStatus!['assessmentDate']),
                                        ),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenWidth * 0.047,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.015,
                                  ),
                                  Text("Your child's Autism is likely".tr,
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: screenWidth * 0.047,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    height: screenHeight * 0.015,
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const ASDTrackingPage()));
                                      },
                                      child: AnimatedButton(
                                        width: screenWidth * 0.45,
                                        height: screenHeight * 0.06,
                                        color:
                                            asdStatus!['likelihood'] == 'HIGH'
                                                ? Colors.red
                                                : asdStatus!['likelihood'] ==
                                                        'MODERATE'
                                                    ? Colors.orange
                                                    : Colors.green,
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const ASDTrackingPage()));
                                        }, // Empty function as placeholder
                                        child: Text(
                                          '${asdStatus!['likelihood']}'.tr,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screenWidth * 0.05,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
              ),
            ),
            SizedBox(
              height: screenHeight * 0.03,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'ADHD'.tr,
                  style: TextStyle(
                    color: const Color(0xFF309092),
                    fontSize: screenWidth * 0.06,
                  ),
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: ContainerWidget(
                  screenWidth: screenWidth,
                  showIcon: true,
                  child: adhdStatus == null
                      ? Center(
                          child: SizedBox(
                          height: screenWidth * 0.09,
                          width: screenWidth * 0.09,
                          child: CircularProgressIndicator(
                              backgroundColor: Colors.black.withOpacity(0.1),
                              color: const Color(0xFF309092)),
                        ))
                      : adhdStatus!.isEmpty
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Please fill the questionnaire!',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: screenWidth * 0.05,
                                  ),
                                ),
                                SizedBox(
                                  height: screenHeight * 0.02,
                                ), // Spacing
                                AnimatedButton(
                                  width: screenWidth * 0.6,
                                  height: screenHeight * 0.06,
                                  color: const Color(0xFF309092),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const ADHD()),
                                    );
                                  },
                                  child: Text(
                                    'Go to Questionnaire',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenWidth * 0.05,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            )
                          : GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ADHDTrackingPage()));
                              },
                              child: Align(
                                alignment: Alignment.center,
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'As of {date}'.tr.replaceFirst(
                                              '{date}',
                                              DateFormat.yMMMMd().format(
                                                  adhdStatus![
                                                      'assessmentDate']),
                                            ),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: screenWidth * 0.047,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: screenHeight * 0.015,
                                      ),
                                      Text("Your child's ADHD is likely".tr,
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: screenWidth * 0.047,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(
                                        height: screenHeight * 0.015,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ADHDTrackingPage()));
                                          },
                                          child: AnimatedButton(
                                            width: screenWidth * 0.45,
                                            height: screenHeight * 0.06,
                                            color: adhdStatus!['likelihood'] ==
                                                    'HIGH'
                                                ? Colors.red
                                                : Colors.green,
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const ADHDTrackingPage()));
                                            },
                                            child: Text(
                                              '${adhdStatus!['likelihood']}'.tr,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: screenWidth * 0.05,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                )),
            SizedBox(
              height: screenHeight * 0.05,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  'Key Skills Scores'.tr,
                  style: TextStyle(
                      color: const Color(0xFF309092),
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(
              thickness: 2,
              indent: 15,
              endIndent: 25,
              color: Colors.black45,
            ),
            SizedBox(
              height: screenHeight * 0.03,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Fine Motor'.tr,
                  style: TextStyle(
                    color: const Color(0xFF309092),
                    fontSize: screenWidth * 0.06,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FinemotorDetailPage(),
                    ),
                  );
                },
                child: ContainerWidget(
                  screenWidth: screenWidth,
                  showIcon: true,
                  child: isLoading
                      ? Center(
                          child: SizedBox(
                          height: screenWidth * 0.09,
                          width: screenWidth * 0.09,
                          child: CircularProgressIndicator(
                              backgroundColor: Colors.black.withOpacity(0.1),
                              color: const Color(0xFF309092)),
                        ))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildProgressIndicator(
                              context,
                              'Easy'.tr,
                              easyData,
                              Colors.black.withOpacity(0.1),
                              screenWidth,
                            ),
                            SizedBox(
                              width: screenWidth * 0.07,
                            ),
                            buildProgressIndicator(
                                context,
                                'Medium'.tr,
                                mediumData,
                                Colors.black.withOpacity(0.1),
                                screenWidth),
                            SizedBox(
                              width: screenWidth * 0.07,
                            ),
                            buildProgressIndicator(
                              context,
                              'Hard'.tr,
                              hardData,
                              Colors.black.withOpacity(0.1),
                              screenWidth,
                            ),
                          ],
                        ),
                ),
              ),
            ),
            SizedBox(
              height: screenHeight * 0.03,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Social'.tr,
                  style: TextStyle(
                    color: const Color(0xFF309092),
                    fontSize: screenWidth * 0.06,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SocialDetailPage()));
                },
                child: ContainerWidget(
                  screenWidth: screenWidth,
                  showIcon: true,
                  child: isLoading
                      ? Center(
                          child: SizedBox(
                          height: screenWidth * 0.09,
                          width: screenWidth * 0.09,
                          child: CircularProgressIndicator(
                              backgroundColor: Colors.black.withOpacity(0.1),
                              color: const Color(0xFF309092)),
                        ))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildProgressIndicator(
                                context,
                                'Easy'.tr,
                                SocialeasyData,
                                Colors.black.withOpacity(0.1),
                                screenWidth),
                            SizedBox(
                              width: screenWidth * 0.07,
                            ),
                            buildProgressIndicator(
                                context,
                                'Medium'.tr,
                                SocialmediumData,
                                Colors.black.withOpacity(0.1),
                                screenWidth),
                            SizedBox(
                              width: screenWidth * 0.07,
                            ),
                            buildProgressIndicator(
                                context,
                                'Hard'.tr,
                                SocialhardData,
                                Colors.black.withOpacity(0.1),
                                screenWidth),
                          ],
                        ),
                ),
              ),
            ),
            SizedBox(
              height: screenHeight * 0.03,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Verbal'.tr,
                  style: TextStyle(
                    color: const Color(0xFF309092),
                    fontSize: screenWidth * 0.06,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const VerbalDetailPage()));
                },
                child: ContainerWidget(
                  screenWidth: screenWidth,
                  showIcon: true,
                  child: isLoading
                      ? Center(
                          child: SizedBox(
                          height: screenWidth * 0.09,
                          width: screenWidth * 0.09,
                          child: CircularProgressIndicator(
                              backgroundColor: Colors.black.withOpacity(0.1),
                              color: const Color(0xFF309092)),
                        ))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildProgressIndicator(
                                context,
                                'Easy'.tr,
                                VerbaleasyData,
                                Colors.black.withOpacity(0.1),
                                screenWidth),
                            SizedBox(
                              width: screenWidth * 0.07,
                            ),
                            buildProgressIndicator(
                                context,
                                'Medium'.tr,
                                VerbalmediumData,
                                Colors.black.withOpacity(0.1),
                                screenWidth),
                            SizedBox(
                              width: screenWidth * 0.07,
                            ),
                            buildProgressIndicator(
                                context,
                                'Hard'.tr,
                                VerbalhardData,
                                Colors.black.withOpacity(0.1),
                                screenWidth),
                          ],
                        ),
                ),
              ),
            ),
            SizedBox(
              height: screenHeight * 0.03,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Math'.tr,
                  style: TextStyle(
                    color: const Color(0xFF309092),
                    fontSize: screenWidth * 0.06,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MathDetailPage()));
                },
                child: ContainerWidget(
                  screenWidth: screenWidth,
                  showIcon: true,
                  child: isLoading
                      ? Center(
                          child: SizedBox(
                          height: screenWidth * 0.09,
                          width: screenWidth * 0.09,
                          child: CircularProgressIndicator(
                              backgroundColor: Colors.black.withOpacity(0.1),
                              color: const Color(0xFF309092)),
                        ))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildProgressIndicator(
                                context,
                                'Easy'.tr,
                                MatheasyData,
                                Colors.black.withOpacity(0.1),
                                screenWidth),
                            SizedBox(
                              width: screenWidth * 0.07,
                            ),
                            buildProgressIndicator(
                                context,
                                'Medium'.tr,
                                MathmediumData,
                                Colors.black.withOpacity(0.1),
                                screenWidth),
                            SizedBox(
                              width: screenWidth * 0.07,
                            ),
                            buildProgressIndicator(
                                context,
                                'Hard'.tr,
                                MathhardData,
                                Colors.black.withOpacity(0.1),
                                screenWidth),
                          ],
                        ),
                ),
              ),
            ),
            SizedBox(
              height: screenHeight * 0.03,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Cognitive'.tr,
                  style: TextStyle(
                    color: const Color(0xFF309092),
                    fontSize: screenWidth * 0.06,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CognitiveDetailPage()));
                },
                child: ContainerWidget(
                  screenWidth: screenWidth,
                  showIcon: true,
                  child: isLoading
                      ? Center(
                          child: SizedBox(
                          height: screenWidth * 0.09,
                          width: screenWidth * 0.09,
                          child: CircularProgressIndicator(
                              backgroundColor: Colors.black.withOpacity(0.1),
                              color: const Color(0xFF309092)),
                        ))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildProgressIndicator(
                                context,
                                'Easy'.tr,
                                CognitiveeasyData,
                                Colors.black.withOpacity(0.1),
                                screenWidth),
                            SizedBox(
                              width: screenWidth * 0.07,
                            ),
                            buildProgressIndicator(
                                context,
                                'Medium'.tr,
                                CognitivemediumData,
                                Colors.black.withOpacity(0.1),
                                screenWidth),
                            SizedBox(
                              width: screenWidth * 0.07,
                            ),
                            buildProgressIndicator(
                                context,
                                'Hard'.tr,
                                CognitivehardData,
                                Colors.black.withOpacity(0.1),
                                screenWidth),
                          ],
                        ),
                ),
              ),
            ),
            SizedBox(
              height: screenHeight * 0.03,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Executive'.tr,
                  style: TextStyle(
                      color: const Color(0xFF309092),
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ContainerWidget(
                screenWidth: screenWidth,
                showIcon: false,
                child: isLoading
                    ? Center(
                        child: SizedBox(
                        height: screenWidth * 0.09,
                        width: screenWidth * 0.09,
                        child: SizedBox(
                          height: screenWidth * 0.09,
                          width: screenWidth * 0.09,
                          child: CircularProgressIndicator(
                              backgroundColor: Colors.black.withOpacity(0.1),
                              color: const Color(0xFF309092)),
                        ),
                      ))
                    : Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildProgressIndicator(
                                  context,
                                  'Speed'.tr,
                                  SpeedData,
                                  Colors.black.withOpacity(0.1),
                                  screenWidth),
                              SizedBox(
                                width: screenWidth * 0.07,
                              ),
                              buildProgressIndicator(
                                  context,
                                  'Attention'.tr,
                                  AttentionData,
                                  Colors.black.withOpacity(0.1),
                                  screenWidth),
                            ],
                          ),
                          SizedBox(
                            height: screenHeight * 0.03,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildProgressIndicator(
                                    context,
                                    'Memory'.tr,
                                    MemoryData,
                                    Colors.black.withOpacity(0.1),
                                    screenWidth),
                                SizedBox(
                                  width: screenWidth * 0.07,
                                ),
                                buildProgressIndicator(
                                    context,
                                    'Inhibition'.tr,
                                    InibitionData,
                                    Colors.black.withOpacity(0.1),
                                    screenWidth),
                              ]),
                        ],
                      ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
