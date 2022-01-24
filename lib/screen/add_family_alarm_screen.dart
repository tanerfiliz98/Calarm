import 'package:calarm/controller/user_controller.dart';
import 'package:calarm/model/alarm_model.dart';
import 'package:calarm/model/computer_model.dart';
import 'package:calarm/model/family_model.dart';
import 'package:calarm/model/user_model.dart';
import 'package:calarm/service/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddFamilyAlarmScreen extends StatelessWidget {
  AddFamilyAlarmScreen({Key? key}) : super(key: key);
  Rx<DateTime> alarmTime = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, DateTime.now().hour, DateTime.now().minute + 1)
      .obs;
  final TextEditingController _alarmTextController =
      TextEditingController(text: "Alarm");
  RxList<ComputerModel> _computers = <ComputerModel>[].obs;
  FamilyModel? family;
  final types = ["basit", "yüz tanıma", "adım atmalı", "bilgisayar kapatıcı"];
  RxString _typeVal = "basit".obs;
  Rx<ComputerModel>? _compVal = ComputerModel().obs;
  Rx<UserModel>? _famVal = UserModel().obs;
  RxInt _walkNumberVal = 20.obs;
  final walkNumbers = [5, 10, 15, 20, 25, 30, 35];
  AlarmModel? alarm;
  @override
  Widget build(BuildContext context) {
    if (alarm == null) {
      alarm = AlarmModel();
    }
    getFam();
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
                        if (alarmTime.value.isBefore(
                            DateTime.now().add(Duration(seconds: 2)))) {
                          alarmTime.value =
                              alarmTime.value.add(Duration(days: 1));
                        }
                        if (_typeVal.value == "bilgisayar kapatıcı") {
                          if (_compVal!.value.id != "") {
                            await Database.instance.addAlarmBase(
                              alarm!
                                ..alarmName = _compVal!.value.name! +
                                    " bilgisayar kapatıcı alarmı"
                                ..alarmType = "bilgisayar kapatıcı"
                                ..walkNumber = 20
                                ..computerId = _compVal!.value.id
                                ..alarmTimeTitle =
                                    Timestamp.fromDate(alarmTime.value)
                                ..alarmTime =
                                    Timestamp.fromDate(alarmTime.value),
                              _famVal!.value.id!,
                            );
                            if (Get.isSnackbarOpen == true) Get.back();
                            Get.back();
                            Get.snackbar(
                                "Bilgisayar Kapatıcı Alarmı Eklendi",
                                alarmTime.value.toString() +
                                    "da" +
                                    _compVal!.value.name! +
                                    " bilgisayar için alarmınız çalacaktır");
                          } else {
                            Get.snackbar("Hatalı bilgisayar",
                                "Lütfen geçerli bir pc giriniz");
                          }
                        } else {
                          alarm?.walkNumber = 20;
                          if (_typeVal.value == types[2]) {
                            alarm?.walkNumber = _walkNumberVal.value;
                          }
                          await Database.instance.addAlarmBase(
                            alarm!
                              ..alarmName = _alarmTextController.text
                              ..computerId = ""
                              ..alarmType = _typeVal.value
                              ..alarmTimeTitle =
                                  Timestamp.fromDate(alarmTime.value)
                              ..alarmTime = Timestamp.fromDate(alarmTime.value),
                            _famVal!.value.id!,
                          );
                          if (Get.isSnackbarOpen == true) Get.back();
                          Get.back();
                          Get.snackbar(
                              "Alarm Eklendi",
                              alarmTime.value.toString() +
                                  " da alarmınız çalacaktır");
                        }
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
                  (DateFormat('Hm').format(alarmTime.value)),
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
            Obx(() {
              return Column(
                children: [
                  Text("Aile Üyeleri"),
                  Card(
                      margin: EdgeInsets.all(20),
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: famDropdown())),
                  SizedBox(
                    height: 20,
                  ),
                ],
              );
            }),
            Obx(() {
              return Column(
                children: [
                  Text("Alarm Tipi"),
                  Card(
                      margin: EdgeInsets.all(20),
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: typeDropdown())),
                ],
              );
            }),
            Obx(() {
              if (_typeVal.value != types[3])
                return Column(
                  children: [
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
                      height: 20,
                    )
                  ],
                );
              else
                return SizedBox(
                  height: 20,
                );
            }),
            Obx(() {
              if (_typeVal.value == types[3]) {
                return Column(
                  children: [
                    Text("Bilgisayarlar"),
                    Card(
                        margin: EdgeInsets.all(20),
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: compDropdown())),
                    SizedBox(
                      height: 40,
                    ),
                  ],
                );
              } else if (_typeVal.value == types[2]) {
                return Column(
                  children: [
                    Text("Adım Sayısı"),
                    Card(
                        margin: EdgeInsets.all(20),
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: walkDropdown())),
                    SizedBox(
                      height: 40,
                    ),
                  ],
                );
              } else {
                return SizedBox(
                  height: 40,
                );
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
      value: _typeVal.value,
      items: types.map(menuTypeItem).toList(),
      onChanged: (value) {
        _typeVal.value = value!;
        if (family!.members.value.length > 0 && _typeVal.value == types[3])
          getComputers();
      },
    );
  }

  DropdownMenuItem<ComputerModel> compMenuTypeItem(ComputerModel e) {
    return DropdownMenuItem(value: e, child: Text(e.name!));
  }

  DropdownButton<ComputerModel> compDropdown() {
    return DropdownButton<ComputerModel>(
      value: _compVal?.value,
      items: _computers.value.map(compMenuTypeItem).toList(),
      onChanged: (value) {
        _compVal?.value = value!;
      },
    );
  }

  DropdownMenuItem<UserModel> famMenuTypeItem(UserModel e) {
    return DropdownMenuItem(value: e, child: Text(e.name!));
  }

  DropdownButton<UserModel> famDropdown() {
    return DropdownButton<UserModel>(
      value: _famVal?.value,
      items: family?.members.value.map(famMenuTypeItem).toList(),
      onChanged: (value) {
        _famVal?.value = value!;
        if (family!.members.value.length > 0 && _typeVal.value == types[3])
          getComputers();
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

  getFam() async {
    family = await Database.instance
        .getFamily(UserController.instance.user.familyId!);
    if (family!.members.value.isEmpty) {
      Get.back();
    } else {
      _famVal!.value = family!.members.value[0];
    }
    family?.members.refresh();
  }

  getComputers() async {
    _computers.value =
        await Database.instance.getComputerList(_famVal!.value.id!);

    if (_computers.value.isEmpty) {
      _typeVal.value = types[0];
    } else
      _compVal!.value = _computers.value[0];

    _computers.refresh();
  }
}
