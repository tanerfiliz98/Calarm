import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock/wakelock.dart';

class AlarmPlayer {
  AlarmPlayer._privateConstructor();
  static final AlarmPlayer instance = AlarmPlayer._privateConstructor();
  final _player = AudioPlayer();
  Timer? time;
  Future<void> play() async {
    try {
      await _player.setAsset("assets/music/alarm.mp3");
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(1);
      _player.play();
      time = Timer.periodic(Duration(seconds: 1), (_) {
        Vibration.vibrate();
      });
    } catch (e) {
      if (time != null) time?.cancel();
      Timer(Duration(seconds: 1), play);
    }
  }

  void stop() {
    _player.stop();
    time?.cancel();
    Vibration.cancel();
    Wakelock.disable();
  }
}
