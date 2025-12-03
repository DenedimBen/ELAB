import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playClick() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/click.mp3'), volume: 0.5);
    } catch (e) {
      print("Ses hatası: $e");
    }
  }

  static Future<void> playBack() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/back.mp3'), volume: 0.4);
    } catch (e) {
      print("Ses hatası: $e");
    }
  }
}
