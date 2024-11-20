// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class PauseMenu extends StatefulWidget {
//   final Function onResume;
//   final Function onQuit;
//   final Widget quitDestinationPage;

//   PauseMenu({
//     required this.onResume,
//     required this.onQuit,
//     required this.quitDestinationPage,
//   });

//   @override
//   State<PauseMenu> createState() => _PauseMenuState();
// }

// class _PauseMenuState extends State<PauseMenu> {
//   bool isSoundOn = true;

//   Widget _buildOptionRow(
//       IconData icon, String text, BuildContext context, Function onPressed) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;

//     return Container(
//       margin: EdgeInsets.symmetric(
//         vertical: screenHeight * 0.01,
//       ),
//       decoration: BoxDecoration(
//         color: Color(0xFF309092),
//         borderRadius: BorderRadius.circular(screenWidth * 0.05),
//       ),
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Color(0xFF309092),
//           padding: EdgeInsets.symmetric(
//             vertical: screenHeight * 0.02,
//             horizontal: screenWidth * 0.05,
//           ),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(screenWidth * 0.05),
//           ),
//         ),
//         onPressed: () => onPressed(),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: <Widget>[
//             Flexible(
//               child: FittedBox(
//                 fit: BoxFit.scaleDown,
//                 child: Text(
//                   text,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: screenWidth * 0.05,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//             Icon(
//               icon,
//               color: Colors.white,
//               size: screenWidth * 0.05,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _toggleSound() {
//     setState(() {
//       isSoundOn = !isSoundOn;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(
//         borderRadius:
//             BorderRadius.circular(MediaQuery.of(context).size.width * 0.1),
//         side: BorderSide(
//           color: Colors.black,
//           width: MediaQuery.of(context).size.width * 0.01,
//         ),
//       ),
//       content: Padding(
//         padding: EdgeInsets.symmetric(
//           horizontal: MediaQuery.of(context).size.width * 0.1,
//           vertical: MediaQuery.of(context).size.height * 0.02,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Pause Menu'.tr,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Color(0xFF309092),
//                 fontSize: MediaQuery.of(context).size.width * 0.07,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: MediaQuery.of(context).size.height * 0.02),
//             _buildOptionRow(
//                 Icons.play_arrow, 'Resume'.tr, context, widget.onResume),
//             _buildOptionRow(
//               isSoundOn ? Icons.volume_up : Icons.volume_off_rounded,
//               'Sound'.tr,
//               context,
//               _toggleSound,
//             ),
//             _buildOptionRow(Icons.info, 'Instructions'.tr, context, () {
//               // Navigate to instructions page
//             }),
//             _buildOptionRow(Icons.exit_to_app, 'Quit'.tr, context, () {
//               widget.onQuit();
//               Navigator.pop(context, true);
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => widget.quitDestinationPage),
//                 (route) => false,
//               );
//             }),
//             SizedBox(height: MediaQuery.of(context).size.height * 0.01),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/utils/sound_manager.dart';
import 'package:mindgames/AnimatedButton.dart';

class PauseMenu extends StatefulWidget {
  final Function onResume;
  final Function onQuit;
  final Widget quitDestinationPage;

  PauseMenu({
    required this.onResume,
    required this.onQuit,
    required this.quitDestinationPage,
  });

  @override
  State<PauseMenu> createState() => _PauseMenuState();
}

class _PauseMenuState extends State<PauseMenu> {
  late bool isSoundOn;

  @override
  void initState() {
    super.initState();
    // Initialize isSoundOn to reflect the global SoundManager state
    isSoundOn = SoundManager.isSoundEnabled;
  }

  Widget _buildOptionRow(
      IconData icon, String text, BuildContext context, Function onPressed) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double baseSize = screenWidth > screenHeight ? screenHeight : screenWidth;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: baseSize * 0.01,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
      ),
      child: AnimatedButton(
        color: const Color(0xFF309092),
        width: baseSize * 0.44,
        height: baseSize * 0.12,
        onPressed: () => onPressed(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: baseSize * 0.02,
            horizontal: baseSize * 0.05,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: baseSize * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Icon(
                icon,
                color: Colors.white,
                size: baseSize * 0.05,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleSound() {
    setState(() {
      // Toggle the local sound state
      isSoundOn = !isSoundOn;

      // Update the global SoundManager
      SoundManager.isSoundEnabled = isSoundOn;

      // Stop all sounds if sound is turned off
      if (!isSoundOn) {
        SoundManager.stopAllSounds();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.width * 0.1),
        side: BorderSide(
          color: Colors.black,
          width: MediaQuery.of(context).size.width * 0.01,
        ),
      ),
      content: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.1,
          vertical: MediaQuery.of(context).size.height * 0.02,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pause Menu'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF309092),
                fontSize: MediaQuery.of(context).size.width * 0.07,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            _buildOptionRow(
                Icons.play_arrow, 'Resume'.tr, context, widget.onResume),
            _buildOptionRow(
              isSoundOn ? Icons.volume_up : Icons.volume_off_rounded,
              'Sound'.tr,
              context,
              _toggleSound,
            ),
            _buildOptionRow(Icons.info, 'Help'.tr, context, () {
              // Navigate to instructions page
            }),
            _buildOptionRow(Icons.exit_to_app, 'Quit'.tr, context, () {
              widget.onQuit();
              Navigator.pop(context, true);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => widget.quitDestinationPage),
                (route) => false,
              );
            }),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          ],
        ),
      ),
    );
  }
}
