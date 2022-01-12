import 'dart:async';

import 'package:get/get.dart';
import 'package:pedometer/pedometer.dart';

class StepController extends GetxController {
  Stream<StepCount> _stepCountStream = Pedometer.stepCountStream;
  late StreamSubscription _subscription;
  int _firstStep = -1;
  Rx<int> stepCount = 0.obs;

  StepController(int step) {
    stepCount.value = step;
  }

  @override
  void onReady() {
    // TODO: implement onInit
    super.onReady();
    _subscription = _stepCountStream.listen(addStep);
    _subscription.onError(errorStep);
  }

  addStep(StepCount step) async {
    if (_firstStep < 0) _firstStep = step.steps;
    stepCount.value = stepCount.value - (step.steps - _firstStep);
    if (stepCount.value < 0) {
      Get.back(result: true);
    }
  }

  void errorStep(error) {
    print('onStepCountError: ' + error);
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    _subscription.cancel();
  }
}
