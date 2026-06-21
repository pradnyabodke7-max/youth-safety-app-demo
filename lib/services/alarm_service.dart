// lib/services/alarm_service.dart

import 'package:audioplayers/audioplayers.dart';

class AlarmService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isPlaying = false;

  // Play alarm sound on loop
  static Future<void> playAlarm() async {
    try {
      if (!_isPlaying) {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
        _isPlaying = true;
      }
    } catch (e) {
      print('Error playing alarm: $e');
    }
  }

  // Stop alarm sound
  static Future<void> stopAlarm() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
    } catch (e) {
      print('Error stopping alarm: $e');
    }
  }

  // Check if alarm is playing
  static bool get isPlaying => _isPlaying;
}