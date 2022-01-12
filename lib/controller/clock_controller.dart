import 'dart:async';

import 'package:get/get.dart';

class ClockController extends GetxController {
  var _timer;
  var time = DateTime.now();
  @override
  void onInit() {
    super.onInit();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      time = DateTime.now();
      update();
    });
  }

  @override
  void onClose() {
    _timer.cancel();
    super.onClose();
  }
}
