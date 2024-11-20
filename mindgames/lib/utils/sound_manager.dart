import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static bool isSoundEnabled = true; // Controls all sound globally
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playSound(String fileName) async {
    if (isSoundEnabled) {
      await _player.play(AssetSource(fileName));
    }
  }

  static Future<void> stopAllSounds() async {
    await _player.stop(); // Stops any sound currently playing
  }
}
