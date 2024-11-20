import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mindgames/Data/communication_text.dart';

class CommunicationPage extends StatefulWidget {
  const CommunicationPage({super.key});

  @override
  State<CommunicationPage> createState() => _CommunicationPageState();
}

class _CommunicationPageState extends State<CommunicationPage> {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Text(
                    'How To Help Your Child Communicate',
                    style: TextStyle(
                      fontSize: screenWidth * 0.06, // Scalable font size
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF309092),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Image.asset(
                  'assets/images/communication.jpeg',
                  height: screenHeight * 0.3, // Scalable image height
                  width: screenWidth, // Full-width image
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              buildContainerWithIcon(
                icon: Iconsax.tick_circle,
                iconColor: Colors.green,
                texts: communicationTexts.sublist(0, 8),
                label: "Do's",
                labelColor: const Color(0xFF309092),
                containerColor: const Color(0xFFEFF9FF),
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),
              SizedBox(height: screenHeight * 0.03),
              const Divider(thickness: 1, color: Colors.black38),
              SizedBox(height: screenHeight * 0.03),
              buildContainerWithIcon(
                icon: Iconsax.close_circle,
                iconColor: Colors.red,
                texts: communicationTexts.sublist(8),
                label: "Don'ts",
                labelColor: Colors.red,
                containerColor: const Color.fromARGB(255, 242, 255, 243),
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),
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
    required double screenWidth,
    required double screenHeight,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          elevation: 10,
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.04), // Scalable padding
            decoration: BoxDecoration(
              color: containerColor,
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
                  .map(
                    (text) => Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            child: Icon(icon,
                                color: iconColor, size: screenHeight * 0.03),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              text,
                              style: TextStyle(
                                fontSize: screenHeight * 0.025,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        Positioned(
          top: -screenHeight * 0.03,
          left: screenWidth * 0.05,
          child: Container(
            width: screenWidth * 0.25,
            height: screenHeight * 0.05,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02,
              vertical: screenHeight * 0.005,
            ),
            decoration: BoxDecoration(
              color: labelColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: screenHeight * 0.025, // Scalable label size
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
