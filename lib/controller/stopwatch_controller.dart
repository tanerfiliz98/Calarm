import 'dart:async';

import 'package:get/get.dart';

class StopwatchController extends GetxController {
  int _timeMilli = 0;
  Stopwatch _stopwatch = Stopwatch();
  Rx<String> isPauseText = "Durdur".obs;
  Rx<bool> isStart = false.obs;
  Timer? _time;
  Rx<String> stopTime = (("0").padLeft(2, "0") +
          ":" +
          ("0").padLeft(2, "0") +
          ":" +
          ("0").padLeft(2, "0"))
      .obs;
  @override
  void onInit() {
    timerStartStop();
    // TODO: implement onInit
    super.onInit();
  }

  void timerStartStop() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _time = Timer.periodic(Duration(milliseconds: 30), (_) {
        _timeMilli = _stopwatch.elapsedMilliseconds;
        stopTime.value =
            (((_timeMilli ~/ 1000) ~/ 60).toString()).padLeft(2, "0") +
                ":" +
                (((_timeMilli ~/ 1000) % 60).toString()).padLeft(2, "0") +
                ":" +
                (((_timeMilli ~/ 10) % 100).toString()).padLeft(2, "0");
      });
      isPauseText.value = "Durdur";
    } else {
      isPauseText.value = "Devam";
      _time?.cancel();
      _stopwatch.stop();
    }
  }

  @override
  void onClose() {
    stopTime.value = (("0").padLeft(2, "0") +
        ":" +
        ("0").padLeft(2, "0") +
        ":" +
        ("0").padLeft(2, "0"));
    _time?.cancel();
    _stopwatch.stop();
    _stopwatch.reset();
    isStart.value = false;
    // TODO: implement onClose
    super.onClose();
  }
}
