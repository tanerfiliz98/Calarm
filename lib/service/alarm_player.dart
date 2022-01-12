import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock/wakelock.dart';

class AlarmPlayer {
  AlarmPlayer._privateConstructor();
  static final AlarmPlayer instance = AlarmPlayer._privateConstructor();
  final _player = AudioPlayer();
  Future<void> play() async {
    try {
      await _player.setAsset("assets/music/alarm.mp3");
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(1);
      _player.play();
    } catch (e) {
      print(e);
    }
  }

  void stop() {
    _player.stop();
    Wakelock.disable();
  }
}
