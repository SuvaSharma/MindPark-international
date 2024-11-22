import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mindgames/Domains.dart';
import 'package:mindgames/behavior_tab.dart';
import 'package:mindgames/child.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/form_section.dart';
import 'package:mindgames/profile.dart';
import 'package:mindgames/performance_tab_bar.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/settings.dart';
import 'package:mindgames/widgets/star_display.dart';

class Homepage extends ConsumerStatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  ConsumerState<Homepage> createState() => _HomepageState();
}

class _HomepageState extends ConsumerState<Homepage> {
  CloudStoreService cloudStoreService = CloudStoreService();
  Child? selectedChild;
  bool isLoading = true;
  List<Map<String, dynamic>> gameResult = [
    {
      'domain': 'Attention',
      'tasks': [
        {
          'name': 'Symbol Safari',
          'data': [],
          'avg': 0,
        },
        {
          'name': 'Alert Alphas',
          'data': [],
          'avg': 0,
        },
        {
          'name': 'Track Titans',
          'data': [],
          'avg': 0,
        }
      ]
    },
    {
      'domain': 'Memory',
      'tasks': [
        {
          'name': 'Digit Dazzle',
          'data': [],
          'avg': 0,
        },
      ]
    },
    {
      'domain': 'Inhibitory Control',
      'tasks': [
        {
          'name': 'Alert Alphas',
          'data': [],
          'avg': 0,
        },
        {
          'name': 'Color Clash',
          'data': [],
          'avg': 0,
        }
      ]
    },
    {
      'domain': 'EQ',
      'tasks': [
        {
          'name': 'Mood Magic',
          'data': [],
          'avg': 0,
        }
      ]
    },
    {
      'domain': 'Speed',
      'tasks': [
        {
          'name': 'Symbol Safari',
          'data': [],
          'avg': 0,
        }
      ]
    },
  ];
  double calculateAverage(List<Map<String, dynamic>> data, String parameter) {
    double sum = 0;
    data.forEach((element) {
      sum += element[parameter];
    });

    return sum / data.length;
  }

  int _currentIndex = 0;
  late double performanceStrength = 0;
  bool allGamesPlayed = false;

  @override
  void initState() {
    super.initState();
    selectedChild = ref.read(selectedChildDataProvider);

    getData().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> getData() async {
    try {
      final attentionAverage =
          await cloudStoreService.getAttentionAverage(selectedChild!.childId);
      final spanAverage =
          await cloudStoreService.getMemoryAverage(selectedChild!.childId);
      final inhbitionAverage =
          await cloudStoreService.getInhibitionAverage(selectedChild!.childId);
      final eqAverage =
          await cloudStoreService.getEQAverage(selectedChild!.childId);

      final speedAverage =
          await cloudStoreService.getSpeedAverage(selectedChild!.childId);

      performanceStrength = (attentionAverage +
              spanAverage +
              inhbitionAverage +
              eqAverage +
              speedAverage) /
          5;

      //data to be used for accordion data

      // Attention
      final attentionSDMT = await cloudStoreService.getDataForTasks(
          selectedChild!.childId, 'SDMT', 'accuracy');

      final attentionCPT = await cloudStoreService.getDataForTasks(
          selectedChild!.childId, 'CPT', 'accuracy');

      final attentionTMT = await cloudStoreService.getDataForTasks(
          selectedChild!.childId, 'TMT', 'accuracy');

      gameResult[0]['tasks'][0]['data'] = attentionSDMT;
      gameResult[0]['tasks'][1]['data'] = attentionCPT;
      gameResult[0]['tasks'][2]['data'] = attentionTMT;

      gameResult[0]['tasks'][0]['avg'] =
          calculateAverage(attentionSDMT, 'accuracy');
      gameResult[0]['tasks'][1]['avg'] =
          calculateAverage(attentionCPT, 'accuracy');
      gameResult[0]['tasks'][2]['avg'] =
          calculateAverage(attentionTMT, 'accuracy');

      // Memory
      final memoryDST = await cloudStoreService.getDataForTasks(
          selectedChild!.childId, 'DST', 'span');
      gameResult[1]['tasks'][0]['data'] = memoryDST;
      gameResult[1]['tasks'][0]['avg'] = calculateAverage(memoryDST, 'span');

      // Inhibitory Control
      final inhibitionCPT = await cloudStoreService.getDataForTasks(
          selectedChild!.childId, 'CPT', 'inhibitoryControl');
      final inhibitionStroop = await cloudStoreService.getDataForTasks(
          selectedChild!.childId, 'Stroop', 'accuracy');

      gameResult[2]['tasks'][0]['data'] = inhibitionCPT;
      gameResult[2]['tasks'][1]['data'] = inhibitionStroop;

      gameResult[2]['tasks'][0]['avg'] =
          calculateAverage(inhibitionCPT, 'inhibitoryControl');
      gameResult[2]['tasks'][1]['avg'] =
          calculateAverage(inhibitionStroop, 'accuracy');

      // Emotional Quotient
      final eqERT = await cloudStoreService.getDataForTasks(
          selectedChild!.childId, 'ERT', 'accuracy');
      gameResult[3]['tasks'][0]['data'] = eqERT;
      gameResult[3]['tasks'][0]['avg'] = calculateAverage(eqERT, 'accuracy');

      // Speed
      final speedSDMT = await cloudStoreService.getDataForTasks(
          selectedChild!.childId, 'SDMT', 'score');
      gameResult[4]['tasks'][0]['data'] = speedSDMT;
      gameResult[4]['tasks'][0]['avg'] = calculateAverage(speedSDMT, 'score');

      allGamesPlayed = attentionSDMT.isNotEmpty &&
          attentionCPT.isNotEmpty &&
          attentionTMT.isNotEmpty &&
          memoryDST.isNotEmpty &&
          inhibitionStroop.isNotEmpty &&
          inhibitionCPT.isNotEmpty &&
          eqERT.isNotEmpty &&
          speedSDMT.isNotEmpty;
    } catch (e) {
      // Handle any errors that might occur during data fetch
      print('Error fetching data: $e');
    }
  }

  final List<Map<String, dynamic>> carouselItems = [
    {
      'imagePath': 'assets/images/ob1.png',
      'name': 'Behavioral Assessment'.tr,
      'navigateTo': FormPage(),
    },
    {
      'imagePath': 'assets/images/ob3.png',
      'name': 'Cognitive Training'.tr,
      'navigateTo': DomainPage(),
    },
  ];
  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    return Scaffold(
        body: SafeArea(
      top: true, // Apply safe area only to the top
      bottom: false, // Do not apply safe area to the bottom
      child: SingleChildScrollView(
        child: Column(children: [
          Stack(
            children: [
              Material(
                elevation: 15,
                child: Container(
                  height: screenHeight * 0.16, // 20% of screen height
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFF6D28D),
                        Color(0xFFF59C84),
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
                          onTap: () {
                            // Fuchhe! game khelnu chaina settings jana parni eslai
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Settingspage()),
                            );
                          },
                          child: Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: screenWidth * 0.1, // 10% of screen width
                          ),
                        ),
                        SizedBox(
                            width: screenWidth * 0.02), // 2% of screen width
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        // thupukka game khel kina profile jana paryo talai
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Profile()),
                        );
                      },
                      child: CircleAvatar(
                        child: Text(selectedChild!.name.substring(0, 1),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.05,
                            )),
                        radius: screenWidth * 0.05, // 5% of screen width
                        backgroundColor: Colors.white,
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
                    "Welcome, ".tr + selectedChild!.name + "!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.06, // 6% of screen width
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.03), // 3% of screen height
          CarouselSlider.builder(
            itemCount: carouselItems.length,
            itemBuilder: (context, index, realIndex) {
              final item = carouselItems[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => item['navigateTo']),
                  );
                },
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    image: DecorationImage(
                      image: AssetImage(carouselItems[index]['imagePath']),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: screenHeight * 0.07, // 5% of screen height
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(25),
                            bottomRight: Radius.circular(25),
                          ),
                        ),
                        child: Text(
                          carouselItems[index]['name'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.06, // 4% of screen width
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: screenHeight * 0.4, // 40% of screen height
              enlargeCenterPage: true,
              autoPlay: true,
              aspectRatio: 16 / 9,
              autoPlayCurve: Curves.fastOutSlowIn,
              enableInfiniteScroll: true,
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              viewportFraction: 0.8,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
          SizedBox(height: screenHeight * 0.01), // 1% of screen height

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Performance'.tr,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05, // 6% of screen width
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('See all'.tr),
              ],
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PerformanceTab(),
                            ),
                          );
                        },
                        child: Container(
                          height: screenHeight * 0.22,
                          width: screenWidth * 0.45,
                          decoration: BoxDecoration(
                            gradient: !allGamesPlayed
                                ? LinearGradient(
                                    colors: [
                                      Color(0xFFF6D28D),
                                      Color(0xFFF59C84),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  )
                                : performanceStrength >= 75
                                    ? LinearGradient(
                                        colors: [
                                          Color(0xFFB7FFF0),
                                          Color(0xFF37B197),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : performanceStrength >= 50
                                        ? LinearGradient(
                                            colors: [
                                              Color(0xFFFFF3C8),
                                              Color(0xFFEFBB00),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : LinearGradient(
                                            colors: [
                                              Color(0xFFFFDFD5),
                                              Color(0xFFCA1700),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Stack(
                            children: [
                              Visibility(
                                visible: !allGamesPlayed && isLoading,
                                child: Center(
                                  child:
                                      CircularProgressIndicator(), // Loading indicator
                                ),
                              ),
                              Visibility(
                                visible: !allGamesPlayed &&
                                    !isLoading, // Show "No data available" when not all games are played and loading is false
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'No data \n available'.tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: allGamesPlayed && !isLoading,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: StarDisplay(
                                    numberOfStars: performanceStrength >= 75
                                        ? 3
                                        : performanceStrength >= 50
                                            ? 2
                                            : 1,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: screenHeight * 0.01,
                                  ),
                                  child: Text(
                                    'Cognitive Performance'.tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: screenWidth * 0.05, // 5% of screen width
                  ),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BehaviorTab(),
                            ),
                          );
                        },
                        child: Container(
                          height: screenHeight * 0.22,
                          width: screenWidth * 0.45,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFF6D28D),
                                Color(0xFFF59C84),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment
                                .center, // Center the content vertically
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: screenHeight *
                                          0.02), // Reduced padding
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Icon(
                                      Icons.bar_chart_rounded,
                                      size: screenWidth * 0.19,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom:
                                        screenHeight * 0.01), // Reduced padding
                                child: Text(
                                  'Behavioral Performance'.tr,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: screenWidth * 0.05, // 5% of screen width
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    ));
  }
}
