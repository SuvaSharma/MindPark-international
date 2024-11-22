import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:mindgames/controllers/settings_controller.dart';
import 'package:mindgames/language_screen.dart';
import 'package:mindgames/registration_page.dart';
import 'package:mindgames/splash_screen.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:mindgames/controllers/language_controller.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:mindgames/utils/app_constants.dart';
import 'package:mindgames/utils/app_routes.dart';
import 'package:mindgames/utils/messages.dart';
import 'package:mindgames/utils/dep.dart' as dep;
import 'change_notifiers/registration_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  Get.put(SettingsController());

  Map<String, Map<String, String>> languages = await dep.init();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details); // Log the error to the console
    if (details.stack != null) {
      print(details.stack); // Print the stack trace for better debugging
    }
  };
  runApp(ProviderScope(child: MyApp(languages: languages)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.languages});
  final Map<String, Map<String, String>> languages;

  @override
  Widget build(BuildContext context) {
    return DevicePreview(
      enabled: false,
      tools: const [
        ...DevicePreview.defaultTools,
      ],
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => RegistrationController()),
        ],
        child: GetBuilder<LocalizationController>(
          builder: (localizationController) {
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              locale: localizationController.locale,
              translations: Messages(languages: languages),
              fallbackLocale: Locale(
                AppConstants.languages[0].languageCode,
                AppConstants.languages[0].countryCode,
              ),
              initialRoute: RouteHelper.splash,
              theme: ThemeData(
                visualDensity: VisualDensity.adaptivePlatformDensity,
                fontFamily: 'ShantellSans',
              ),
              home: const SplashScreenWrapper(),
            );
          },
        ),
      ),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  _SplashScreenWrapperState createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      Get.off(() => LanguageScreen());
    } else {
      Get.off(() => const RegistrationPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
