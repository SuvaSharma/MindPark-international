import 'package:get/get.dart';
import 'package:mindgames/models/settings_model.dart';

class SettingsController extends GetxController {
  // Observable settings
  var settings = Settings().obs;

  // Method to toggle sound
  void toggleSound() {
    settings.update((settings) {
      settings?.toggleSound();
    });
  }

  // Method to toggle vibration
  void toggleVibration() {
    settings.update((settings) {
      settings?.toggleVibration();
    });
  }
}
