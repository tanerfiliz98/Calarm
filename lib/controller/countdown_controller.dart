import 'dart:async';

import 'package:calarm/screen/root_screen.dart';
import 'package:calarm/service/alarm_player.dart';
import 'package:calarm/util/alarm_status.dart';
import 'package:get/get.dart';

class CountdownController extends GetxController {
  Stopwatch _stopwatch = Stopwatch();
  Rx<bool> isStart = false.obs;
  Rx<String> isPauseText = "Durdur".obs;
  Timer? _time;
  int _startTime = 0;
  Rx<Duration> duration = Duration(hours: 0, minutes: 0).obs;
  int remainingTime = 0;
  bool isTimesUp = false;
  @override
  void onInit() {
    _startTime = duration.value.inMilliseconds;
    countdownStartStop();
    // TODO: implement onInit
    super.onInit();
  }

  void countdownStartStop() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      isPauseText.value = "Durdur";
      _time = Timer.periodic(Duration(milliseconds: 100), (_) {
        remainingTime = _startTime - _stopwatch.elapsedMilliseconds;
        if (remainingTime > 0)
          duration.value = Duration(milliseconds: remainingTime);
        else {
          isTimesUp = true;
          Get.delete<CountdownController>();
        }
      });
    } else {
      _time?.cancel();
      _stopwatch.stop();
      isPauseText.value = "Devam";
    }
  }

  @override
  Future<void> onClose() async {
    if (isTimesUp) {
      if (AlarmStatus.instance.isAlarm.value == false) {
        AlarmPlayer.instance.play();
        if (Get.currentRoute != "") Get.offAll(() => Root());
        AlarmStatus.instance.alarmId.value = 0;
        AlarmStatus.instance.isAlarm.value = true;
      }
    } else {
      duration.value = Duration(milliseconds: _startTime);
      isStart.value = false;
    }

    _time?.cancel();
    _stopwatch.stop();
    _stopwatch.reset();

    // TODO: implement onClose
    super.onClose();
  }
}
