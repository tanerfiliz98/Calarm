import 'package:calarm/controller/alarm_list_controller.dart';
import 'package:calarm/controller/user_controller.dart';
import 'package:calarm/screen/add_alarm_screen.dart';
import 'package:calarm/widget/alarm_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlarmListScreen extends StatelessWidget {
  const AlarmListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GetX<ALarmListController>(
          init: ALarmListController(),
          builder: (ALarmListController aControl) {
            return Expanded(
              child: ListView.builder(
                itemCount: aControl.alarms.length,
                itemBuilder: (_, index) {
                  return AlarmCard(
                    uid: UserController.instance.user.id,
                    alarm: aControl.alarms[index],
                  );
                },
              ),
            );
          },
        ),
        SizedBox(
          height: 20,
        ),
        ElevatedButton(
          onPressed: () {
            Get.bottomSheet(
              AddAlarmScreen(),
              isScrollControlled: true,
              backgroundColor: ThemeData.dark().canvasColor,
            );
          },
          child: Text("Alarm Kur"),
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(24),
          ),
        ),
      ],
    );
  }
}
