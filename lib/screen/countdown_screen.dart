import 'package:calarm/controller/countdown_controller.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CountdownScreen extends StatelessWidget {
  const CountdownScreen({Key? key}) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    CountdownController controller;
    if (!Get.isRegistered<CountdownController>()) {
      controller = CountdownController();
    } else {
      controller = Get.find<CountdownController>();
    }

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            return Expanded(
                child: DurationPicker(
                    duration: controller.duration.value,
                    baseUnit: BaseUnit.second,
                    onChange: (value) {
                      controller.duration.value = value;
                    }));
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
                        controller.countdownStartStop();
                      },
                      child: Text(controller.isPauseText.value)),
                  SizedBox(
                    width: 40,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Get.delete<CountdownController>();
                        controller = CountdownController();
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
