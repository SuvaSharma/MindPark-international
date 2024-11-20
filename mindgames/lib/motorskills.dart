import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/Domains.dart';
import 'package:mindgames/TMTpage.dart';
import 'package:mindgames/logigamedemo.dart';
import 'package:mindgames/picturesortinggame_demo.dart';
import 'package:mindgames/profile.dart';
import 'package:mindgames/puzzle_paradise_demo_page.dart';
import 'package:mindgames/puzzle_paradise_page.dart';
import 'package:mindgames/tmt_demo_page.dart';

class MotorskillsPage extends StatefulWidget {
  const MotorskillsPage({super.key});

  @override
  State<MotorskillsPage> createState() => _MotorskillsPageState();
}

class _MotorskillsPageState extends State<MotorskillsPage> {
  int index = 1;

  final screens = [
    const Profile(),
    const DomainPage(),
  ];
  final AudioCache _audioCache = AudioCache();
  final player = AudioPlayer();

  List<Map<String, dynamic>> levelTiles = [
    {
      "levelName": "Pixel Puzzle",
      "levelImage": "pixel_puzzle.jpeg",
      "levelPage": const LogiGameDemoPage(),
    },
    {
      "levelName": "Track Titans",
      "levelImage": "TMT.jpeg",
      "levelPage": const TMTDemoPage(),
    },
    {
      "levelName": "Picture Playtime",
      "levelImage": "picturesortinggame.jpeg",
      "levelPage": const PictureSortingDemoPage(),
    },
    {
      "levelName": "Puzzle Paradise",
      "levelImage": "puzzle_paradise.jpg",
      "levelPage": const PuzzleDemoWidget(),
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate back to the homepage when the back button is pressed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DomainPage()),
        );
        return false; // Prevents the default back button action
      },
      child: OrientationBuilder(
        builder: (context, orientation) {
          return Scaffold(
            extendBody: true,
            body: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/levelscreen.png'),
                        fit: BoxFit.cover),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.05,
                      bottom: MediaQuery.of(context).size.height * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Fine Motor Skills:'.tr,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.06,
                            color: const Color.fromARGB(255, 51, 106, 134)),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.width * 0.17),
                  child: GridView.count(
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: MediaQuery.of(context).size.width * 0.04,
                    mainAxisSpacing: MediaQuery.of(context).size.width * 0.04,
                    crossAxisCount: 2,
                    children: levelTiles
                        .map(
                          (item) => buildLevelTile(
                            item['levelName'].toString(),
                            item['levelImage'].toString(),
                            item['levelPage'],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  GestureDetector buildLevelTile(
      String levelName, String levelImage, Widget levelPage) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        // Navigate to the new page (Level 6)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => levelPage),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: const Color.fromARGB(255, 51, 106, 134),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(
                  24), // Match the container's border radius
              child: Center(
                child: Image.asset(
                  'assets/images/$levelImage',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25)),
                ),
                height: size.height * 0.05,
                width: double.infinity,
                child: Center(
                  child: Text(
                    levelName.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 51, 106, 134),
                      fontSize: MediaQuery.of(context).size.width * 0.048,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
