import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/DSTIntroPage.dart';
import 'package:mindgames/CPTIntroPage.dart';
import 'package:mindgames/ERTInsPage.dart';
import 'package:mindgames/Homepage.dart';
import 'package:mindgames/TMTinfoscreen.dart';
import 'package:mindgames/Stroopinspage.dart';
import 'package:mindgames/level8infoscreen.dart';
import 'package:mindgames/performance_tab_bar.dart';
import 'package:mindgames/profile.dart';
import 'package:audioplayers/audioplayers.dart';

class LevelPage extends StatefulWidget {
  const LevelPage({super.key});

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  int index = 1;

  final screens = [
    const Profile(),
    const LevelPage(),
    const PerformanceTab(),
  ];
  final player = AudioPlayer();

  List<Map<String, dynamic>> levelTiles = [
    {
      "levelName": "Color Clash",
      "levelImage": "stroop.gif",
      "levelPage": const StroopinfoScreen(shownWhen: 'before-game'),
      "imgWidth": 120,
      "imgHeight": 120,
    },
    {
      "levelName": "Digit Dazzle",
      "levelImage": "dst-3.gif",
      "levelPage": const DSTIntroPage(shownWhen: 'before-game'),
      "imgWidth": 45,
      "imgHeight": 45,
    },
    {
      "levelName": "Alert Alphas",
      "levelImage": "cpt.gif",
      "levelPage": const CPTIntroPage(shownWhen: 'before-game'),
      "imgWidth": 170,
      "imgHeight": 170,
    },
    {
      "levelName": "Mood Magic",
      "levelImage": "ert.png",
      "levelPage": const ERTInfoScreen(shownWhen: 'before-game'),
      "imgWidth": 70,
      "imgHeight": 70,
    },
    {
      "levelName": "Symbol Safari",
      "levelImage": "sdmt.png",
      "levelPage": const Introduction(
          shownWhen: 'before-game'), //(shownWhen: 'before-game'),
      "imgWidth": 75,
      "imgHeight": 75,
    },
    {
      "levelName": "Track Titans",
      "levelImage": "TMT.gif",
      "levelPage": const TMTinfoscreen(shownWhen: 'before-game'),
      "imgWidth": 95,
      "imgHeight": 95,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Play background music when level screen is opened
    // playBackgroundMusic();
  }

  @override
  void dispose() {
    // // Stop background music when leaving level screen
    // stopBackgroundMusic();
    super.dispose();
  }

  // void playBackgroundMusic() async {
  //   await player.setSource(AssetSource('correct.mp3'));
  //   player.play(AssetSource('correct.mp3'));
  //   await player.setReleaseMode(ReleaseMode.loop);
  // }

  // void stopBackgroundMusic() {
  //   player.stop();
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate back to the homepage when the back button is pressed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
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
                        'Try These'.tr,
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
                            item['imgWidth'],
                            item['imgHeight'],
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

  GestureDetector buildLevelTile(String levelName, String levelImage,
      Widget levelPage, int imgWidth, int imgHeight) {
    return GestureDetector(
      onTap: () {
        // Navigate to the new page (Level 6)

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => levelPage),
        );
      },
      child: Container(
        width: 160,
        height: 130,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 190, 226, 226),
              Color.fromARGB(255, 255, 255, 255)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
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
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.025,
                  right: MediaQuery.of(context).size.width * 0.025),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(levelName.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 51, 106, 134),
                      fontSize: MediaQuery.of(context).size.width * 0.048,
                    )),
              ]),
            ),
            Center(
              child: Image.asset(
                'assets/images/$levelImage',
                width: MediaQuery.of(context).size.width *
                    0.0035 *
                    imgWidth, // Adjust the width as needed
                height: MediaQuery.of(context).size.height *
                    0.0035 *
                    imgHeight, // Adjust the height as needed
                // Adjust the color as needed
              ),
            ),
          ],
        ),
      ),
    );
  }
}
