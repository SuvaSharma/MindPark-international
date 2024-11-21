import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/CPTdemopage.dart';
import 'package:mindgames/DSTdemopage.dart';
import 'package:mindgames/Domains.dart';
import 'package:mindgames/Level8demopage.dart';
import 'package:mindgames/Stroopdemopage.dart';
import 'package:mindgames/profile.dart';

class ExecutiveskillsPage extends StatefulWidget {
  const ExecutiveskillsPage({super.key});

  @override
  State<ExecutiveskillsPage> createState() => _ExecutiveskillsPageState();
}

class _ExecutiveskillsPageState extends State<ExecutiveskillsPage> {
  int index = 1;

  final screens = [
    const Profile(),
    const DomainPage(),
  ];
  final player = AudioPlayer();

  List<Map<String, dynamic>> levelTiles = [
    {
      "levelName": "Color Clash",
      "levelImage": "stroop.gif",
      "levelPage": const Stroopdemopage(),
    },
    {
      "levelName": "Digit Dazzle",
      "levelImage": "dst-3.gif",
      "levelPage": const DSTdemoPage(),
    },
    {
      "levelName": "Symbol Safari",
      "levelImage": "sdmt.png",
      "levelPage": Level8demo(), //(shownWhen: 'before-game'),
    },
    {
      "levelName": "Alert Alphas",
      "levelImage": "cpt.gif",
      "levelPage": const CPTdemoPage(),
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
                        'Executive Skills:'.tr,
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
                height: size.height * 0.05,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25)),
                ),
                child: Center(
                  child: Text(
                    levelName.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 51, 106, 134),
                      fontSize: MediaQuery.of(context).size.width * 0.048,
                      backgroundColor: Colors.white.withOpacity(
                          0.7), // Optional: Add background color for better readability
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
