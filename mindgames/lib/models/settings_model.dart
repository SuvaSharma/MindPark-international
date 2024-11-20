class Settings {
  bool isSoundEnabled;
  bool isVibrationEnabled;

  Settings({this.isSoundEnabled = true, this.isVibrationEnabled = true});

  // Add methods to toggle sound and vibration
  void toggleSound() {
    isSoundEnabled = !isSoundEnabled;
  }

  void toggleVibration() {
    isVibrationEnabled = !isVibrationEnabled;
  }
}
