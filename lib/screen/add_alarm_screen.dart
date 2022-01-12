import 'package:calarm/controller/alarm_list_controller.dart';
import 'package:calarm/controller/user_controller.dart';
import 'package:calarm/model/alarm_model.dart';
import 'package:calarm/service/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddAlarmScreen extends StatelessWidget {
  AddAlarmScreen({Key? key}) : super(key: key);
  final TextEditingController _alarmTextController =
      TextEditingController(text: "Alarm");
  Rx<DateTime> alarmTime = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, DateTime.now().hour, DateTime.now().minute + 1)
      .obs;
  final types = [
    "basit",
    "yüz tanıma",
    "adım atmalı",
  ];

  RxString? _typeVal = "basit".obs;
  RxInt _walkNumberVal = 20.obs;
  final walkNumbers = [5, 10, 15, 20, 25, 30, 35];
  AlarmModel? alarm;
  @override
  Widget build(BuildContext context) {
    if (alarm == null) {
      alarm = AlarmModel();
    }
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                      child: Text("Alarmı ekle"),
                      onPressed: () async {
                        alarm?.walkNumber = 20;
                        if (_typeVal!.value == "adım atmalı") {
                          alarm?.walkNumber = _walkNumberVal.value;
                        }
                        if (alarmTime.value.isBefore(
                            DateTime.now().add(Duration(seconds: 5)))) {
                          alarmTime.value =
                              alarmTime.value.add(Duration(days: 1));
                        }
                        await Database.instance.addAlarmBase(
                          alarm!
                            ..alarmName = _alarmTextController.text
                            ..computerId = ""
                            ..alarmType = _typeVal!.value
                            ..dateCreated = Timestamp.now()
                            ..alarmTime = Timestamp.fromDate(alarmTime.value),
                          UserController.instance.user.id!,
                        );
                        if (Get.isSnackbarOpen == true) Get.back();
                        Get.back();
                        Get.snackbar(
                            "Alarm Eklendi",
                            alarmTime.value.toString() +
                                " da alarmınız çalacaktır");
                      }),
                )
              ],
            ),
            Obx(() {
              return GestureDetector(
                onTap: () {
                  Get.dialog(createInlinePicker(
                    value: TimeOfDay(
                        hour: TimeOfDay.now().hour,
                        minute: TimeOfDay.now().minute + 1),
                    onChange: (_) {},
                    is24HrFormat: true,
                    onChangeDateTime: (date) {
                      alarmTime.value = date;
                      Get.back();
                    },
                  ));
                },
                child: Text(
                  (Get.find<ALarmListController>()
                      .format
                      .format(alarmTime.value)),
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
            SizedBox(
              height: 20,
            ),
            Text("Alarm Notu"),
            Card(
                margin: EdgeInsets.all(20),
                child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: _alarmTextController,
                    ))),
            SizedBox(
              height: 40,
            ),
            Text("Alarm Türü"),
            Obx(() {
              if (_typeVal?.value == types[2]) {
                return Column(
                  children: [typeDropdown(), walkDropdown()],
                );
              } else {
                return typeDropdown();
              }
            }),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<String> menuTypeItem(String e) {
    return DropdownMenuItem(value: e, child: Text(e));
  }

  DropdownButton<String> typeDropdown() {
    return DropdownButton<String>(
      value: _typeVal?.value,
      items: types.map(menuTypeItem).toList(),
      onChanged: (value) {
        _typeVal?.value = value!;
      },
    );
  }

  DropdownMenuItem<int> menuWalkItem(int e) {
    return DropdownMenuItem(value: e, child: Text(e.toString()));
  }

  DropdownButton<int> walkDropdown() {
    return DropdownButton<int>(
      value: _walkNumberVal.value,
      items: walkNumbers.map(menuWalkItem).toList(),
      onChanged: (value) {
        _walkNumberVal.value = value!;
      },
    );
  }
}
