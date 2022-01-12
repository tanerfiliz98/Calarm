import 'package:calarm/controller/stopwatch_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StopwatchScreen extends StatelessWidget {
  const StopwatchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    StopwatchController controller;
    if (!Get.isRegistered<StopwatchController>()) {
      controller = StopwatchController();
    } else {
      controller = Get.find<StopwatchController>();
    }

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            return Text(
              controller.stopTime.value,
              style: TextStyle(fontSize: 40),
            );
          }),
          Obx(() {
            if (!controller.isStart.value) {
              return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Get.put(controller);
                          controller.isStart.value = true;
                        },
                        child: Text("Başla"))
                  ]);
            } else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        controller.timerStartStop();
                      },
                      child: Text(controller.isPauseText.value)),
                  SizedBox(
                    width: 40,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Get.delete<StopwatchController>();
                        controller = StopwatchController();
                      },
                      child: Text("Bitir"))
                ],
              );
            }
          })
        ],
      ),
    );
  }
}
