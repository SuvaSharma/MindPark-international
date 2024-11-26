import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mindgames/Data/frendship_text.dart';

class FriendshipPage extends StatefulWidget {
  const FriendshipPage({super.key});

  @override
  State<FriendshipPage> createState() => _FriendshipPageState();
}

class _FriendshipPageState extends State<FriendshipPage> {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  'Friendships And Socialising',
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF309092),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Image.asset('assets/images/socialskills.jpeg'),
              const SizedBox(height: 50),
              buildContainerWithIcon(
                  icon: Iconsax.tick_circle,
                  iconColor: Colors.green,
                  texts: FriendshipsTexts.sublist(0, 5),
                  label: "Do's",
                  labelColor: const Color(0xFF309092),
                  containerColor: const Color(0xFFEFF9FF)),
              const SizedBox(height: 30),
              const Divider(thickness: 1, color: Colors.black38),
              const SizedBox(height: 30),
              buildContainerWithIcon(
                  icon: Iconsax.close_circle,
                  iconColor: Colors.red,
                  texts: FriendshipsTexts.sublist(5),
                  label: "Don'ts",
                  labelColor: Colors.red,
                  containerColor: const Color.fromARGB(255, 242, 255, 243)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContainerWithIcon({
    required IconData icon,
    required Color iconColor,
    required List<String> texts,
    required String label,
    required Color labelColor,
    required Color containerColor,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: containerColor, // Use containerColor for background
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0.5,
                  blurRadius: 5,
                  offset: const Offset(0.5, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: texts
                  .map((text) => Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(icon, color: iconColor, size: 24),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                text,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
        Positioned(
          top: -20,
          left: 10,
          child: Container(
            width: 85,
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: labelColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
