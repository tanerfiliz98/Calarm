import 'package:calarm/controller/alarm_list_controller.dart';
import 'package:calarm/model/alarm_model.dart';
import 'package:calarm/service/database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlarmCard extends StatelessWidget {
  final String? uid;
  final AlarmModel? alarm;
  AlarmCard({Key? key, this.alarm, this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                (Get.find<ALarmListController>()
                    .format
                    .format(alarm!.alarmTime!.toDate())),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(
                alarm!.alarmName!,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                alarm!.alarmType!,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Checkbox(
              value: alarm!.alarmStatus,
              onChanged: (newValue) async {
                await Database.instance
                    .updateAlarmStatus(newValue!, uid!, alarm!);
              },
            ),
          ],
        ),
      ),
    );
  }
}
