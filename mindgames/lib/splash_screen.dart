// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:async';

// import 'package:mindgames/onboardingscreen.dart';
// import 'package:mindgames/utils/app_routes.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   late Animation<double> animation;
//   late AnimationController _controller;
//   GlobalKey<ScaffoldState> _globalKey = GlobalKey();
//   SharedPreferences? _prefs; // Declare a SharedPreferences instance

//   @override
//   void initState() {
//     super.initState();
//     _controller =
//         AnimationController(vsync: this, duration: Duration(seconds: 2))
//           ..forward();
//     animation = Tween<double>(
//       begin: 0.5, // Start from a smaller scale (center)
//       end: 1.0, // Expand to normal scale
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

//     // Get SharedPreferences instance
//     SharedPreferences.getInstance().then((prefs) {
//       _prefs = prefs;

//       // Check if onboarding has been shown before
//       bool onboardingShown = _prefs!.getBool('onboarding_shown') ?? false;

//       // Navigate based on whether onboarding has been shown
//       if (!onboardingShown) {
//         Timer(const Duration(seconds: 3), () {
//           Get.off(() => OnboardingScreen());
//         });
//       } else {
//         // Navigate to your main app flow if onboarding has been shown
//         Timer(const Duration(seconds: 3), () {
//           // Example: Get.offNamed(RouteHelper.getRegistrationRoute());
//           // Replace with your main app navigation logic
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _globalKey,
//       body: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/images/homepage2.png'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Center(
//           // Center the ScaleTransition widget
//           child: ScaleTransition(
//             scale: animation,
//             child: SizedBox(
//               height: MediaQuery.of(context).size.height * 0.2,
//               child: Center(
//                 child: Image.asset(
//                   "assets/images/mindparklogo.png",
//                   width: 200,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'package:mindgames/onboardingscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController _controller;
  GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..forward();
    animation = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      bool onboardingShown = _prefs!.getBool('onboarding_shown') ?? false;

      if (!onboardingShown) {
        Timer(const Duration(seconds: 3), () {
          Get.off(() => const OnboardingScreen());
        });
      } else {
        Timer(const Duration(seconds: 3), () {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/homepage2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: animation,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Center(
                child: Image.asset(
                  "assets/images/mindparklogo.png",
                  width: 200,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
