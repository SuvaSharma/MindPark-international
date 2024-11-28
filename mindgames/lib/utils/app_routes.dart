import 'package:get/get_navigation/get_navigation.dart';
import 'package:mindgames/language_screen.dart';
import 'package:mindgames/registration_page.dart';
import 'package:mindgames/splash_screen.dart';

class RouteHelper {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String language = '/language';
  static const String register = '/register';

  static String getSplashRoute() => splash;
  static String getInitialRoute() => initial;
  static String getRegistrationRoute() => register;
  static String getLanguageRoute() => language;

  static List<GetPage> routes = [
    GetPage(
        name: splash,
        page: () {
          return const SplashScreen();
        }),
    GetPage(
        name: register,
        page: () {
          return const RegistrationPage();
        }),
    GetPage(
        name: language,
        page: () {
          return const LanguageScreen();
        }),
  ];
}
