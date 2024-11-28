import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/level8infoscreen.dart';

class CurrentScreen extends StatelessWidget {
  final List<Map<String, dynamic>> levelTiles;

  const CurrentScreen({
    super.key,
    required this.levelTiles,
  });

  Widget buildLevelTile(BuildContext context, String levelName,
      String levelImage, Widget levelPage, double imgWidth, double imgHeight) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => levelPage),
        );
      },
      child: Column(
        children: [
          Image.asset(levelImage, width: imgWidth, height: imgHeight),
          Text(levelName),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/levelscreen.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.05,
            bottom: MediaQuery.of(context).size.height * 0.05,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const Introduction(shownWhen: 'before-game'),
                    ),
                  );
                },
                child: Text(
                  'Try These:'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                    color: const Color.fromARGB(255, 51, 106, 134),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.17),
          child: GridView.count(
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: MediaQuery.of(context).size.width * 0.04,
            mainAxisSpacing: MediaQuery.of(context).size.width * 0.04,
            crossAxisCount: 2,
            children: levelTiles.map((item) {
              return buildLevelTile(
                context,
                item['levelName'].toString(),
                item['levelImage'].toString(),
                item['levelPage'],
                item['imgWidth'],
                item['imgHeight'],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
