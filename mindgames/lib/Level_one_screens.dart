import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/Home_Page.dart';
import 'package:mindgames/TMTinfoscreen.dart';
import 'package:mindgames/lego_game.dart';
import 'package:mindgames/number_counting_game.dart';
import 'package:mindgames/performance_tab_bar.dart';
import 'package:mindgames/picture_sorting_game.dart';
import 'package:mindgames/profile.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mindgames/simon_says_demo_page.dart';
import 'package:mindgames/voiceloon_page.dart';

class LevelOnePage extends StatefulWidget {
  LevelOnePage({super.key, Key? superkey});

  @override
  State<LevelOnePage> createState() => _LevelOnePageState();
}

class _LevelOnePageState extends State<LevelOnePage> {
  int index = 1;

  final screens = [
    const Profile(),
    LevelOnePage(),
    const PerformanceTab(),
  ];
  final player = AudioPlayer();

  List<Map<String, dynamic>> levelTiles = [
    {
      "levelName": "Lego Game",
      "levelImage": "stroop.gif",
      "levelPage": LegoGame(), //(shownWhen: 'before-game'),
      "imgWidth": 120,
      "imgHeight": 120,
    },
    {
      "levelName": "Number Count",
      "levelImage": "dst-3.gif",
      "levelPage": NumberCountingGame(),
      //(shownWhen: 'before-game'),
      "imgWidth": 45,
      "imgHeight": 45,
    },
    {
      "levelName": "Picture Sorting",
      "levelImage": "cpt.gif",
      "levelPage": PictureSortingGame,
      //(shownWhen: 'before-game'),
      "imgWidth": 170,
      "imgHeight": 170,
    },
    {
      "levelName": "Voiceloon ",
      "levelImage": "ert.png",
      "levelPage": VoiceloonPage(),
      "imgWidth": 70,
      "imgHeight": 70,
    },
    {
      "levelName": "Simon Says",
      "levelImage": "sdmt.png",
      "levelPage": SimonSaysDemoPage(),
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
          MaterialPageRoute(builder: (context) => const MainPage()),
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
                        'Try These:'.tr,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.06,
                            color: Color.fromARGB(255, 51, 106, 134)),
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
          gradient: LinearGradient(
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
                      color: Color.fromARGB(255, 51, 106, 134),
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
