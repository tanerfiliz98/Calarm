import 'package:calarm/controller/user_controller.dart';
import 'package:calarm/model/alarm_model.dart';
import 'package:calarm/model/computer_model.dart';
import 'package:calarm/service/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddComputerCloseAlarmScreen extends StatelessWidget {
  AddComputerCloseAlarmScreen({Key? key}) : super(key: key);
  Rx<DateTime> alarmTime = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, DateTime.now().hour, DateTime.now().minute + 1)
      .obs;
  RxList<ComputerModel> _computers = <ComputerModel>[].obs;

  Rx<ComputerModel>? _typeVal = ComputerModel().obs;
  AlarmModel? alarm;
  @override
  Widget build(BuildContext context) {
    getComputers();
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
                        if (alarmTime.value.isBefore(
                            DateTime.now().add(Duration(seconds: 5)))) {
                          alarmTime.value =
                              alarmTime.value.add(Duration(days: 1));
                        }
                        if (_typeVal!.value.id != "") {
                          await Database.instance.addAlarmBase(
                            alarm!
                              ..alarmName = _typeVal!.value.name! +
                                  " bilgisayar kapatıcı alarmı"
                              ..alarmType = "bilgisayar kapatıcı"
                              ..walkNumber = 20
                              ..computerId = _typeVal!.value.id
                              ..alarmTimeTitle =
                                  Timestamp.fromDate(alarmTime.value)
                              ..alarmTime = Timestamp.fromDate(alarmTime.value),
                            UserController.instance.user.id!,
                          );
                          if (Get.isSnackbarOpen == true) Get.back();
                          Get.back();
                          Get.snackbar(
                              "Bilgisayar Kapatıcı Alarmı Eklendi",
                              alarmTime.value.toString() +
                                  "da" +
                                  _typeVal!.value.name! +
                                  " bilgisayarınız için alarmınız çalacaktır");
                        } else {
                          Get.snackbar("Hatalı bilgisayar",
                              "Lütfen geçerli bir pc giriniz");
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
                  Text("Bilgisayarlar"),
                  Card(
                      margin: EdgeInsets.all(20),
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: typeDropdown())),
                  SizedBox(
                    height: 40,
                  ),
                ],
              );
            }),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<ComputerModel> menuTypeItem(ComputerModel e) {
    return DropdownMenuItem(value: e, child: Text(e.name!));
  }

  DropdownButton<ComputerModel> typeDropdown() {
    return DropdownButton<ComputerModel>(
      value: _typeVal?.value,
      items: _computers.value.map(menuTypeItem).toList(),
      onChanged: (value) {
        _typeVal?.value = value!;
      },
    );
  }

  getComputers() async {
    _computers.value = await Database.instance
        .getComputerList(UserController.instance.user.id!);

    if (_computers.value.isEmpty) {
      Get.back();
      Get.snackbar("Bilgisayar Yok",
          "Bilgisayar alarmı kurmak için bir bilgisayardan giriş yapın");
    } else
      _typeVal!.value = _computers.value[0];

    _computers.refresh();
  }
}
