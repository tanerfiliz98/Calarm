import 'package:calarm/controller/user_controller.dart';
import 'package:calarm/model/alarm_model.dart';
import 'package:calarm/model/food_list_model.dart';
import 'package:calarm/service/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddFoodAlarmScreen extends StatelessWidget {
  AddFoodAlarmScreen({Key? key}) : super(key: key);
  final TextEditingController _foodTextController = TextEditingController();
  Rx<DateTime> alarmTime = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, DateTime.now().hour, DateTime.now().minute + 1)
      .obs;
  RxList<String> _foods = <String>[].obs;
  final types = [
    "Sabah",
    "Öğle",
    "Akşam",
  ];
  RxString? _typeVal = "Sabah".obs;
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
                        if (alarmTime.value.isBefore(
                            DateTime.now().add(Duration(seconds: 5)))) {
                          alarmTime.value =
                              alarmTime.value.add(Duration(days: 1));
                        }
                        if (_foods.value.isNotEmpty) {
                          String retval = await Database.instance.addAlarmBase(
                            alarm!
                              ..alarmName = _typeVal!.value + " öğün alarmı"
                              ..alarmType = "öğün alarmı"
                              ..walkNumber = 20
                              ..computerId = ""
                              ..alarmTimeTitle =
                                  Timestamp.fromDate(alarmTime.value)
                              ..alarmTime = Timestamp.fromDate(alarmTime.value),
                            UserController.instance.user.id!,
                          );

                          await Database.instance.addMeal(
                              FoodListModel(
                                  retval, _foods.value, _typeVal!.value),
                              UserController.instance.user);
                          if (Get.isSnackbarOpen == true) Get.back();
                          Get.back();
                          Get.snackbar(
                              "Öğün Alarmı Eklendi",
                              alarmTime.value.toString() +
                                  " da alarmınız çalacaktır");
                        } else {
                          Get.snackbar("Hatalı yiyecek listesi",
                              "Lütfen öğünde yiyeceğiniz yiyecekleri giriniz");
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
                  Text("Öğün türü"),
                  Card(
                      margin: EdgeInsets.all(20),
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: typeDropdown())),
                  SizedBox(
                    height: 40,
                  ),
                  Text("Yiyecek ekle"),
                  Card(
                    margin: EdgeInsets.all(20),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _foodTextController,
                            ),
                          ),
                          FlatButton(
                              onPressed: () {
                                _foods.value.add(_foodTextController.text);
                                _foods.refresh();
                              },
                              child: Text("öğün ekle"))
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 100,
                    child: ListView.builder(
                      itemCount: _foods.value.length,
                      itemBuilder: (_, index) {
                        return Card(
                          margin: EdgeInsets.all(5),
                          child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(_foods.value[index])),
                        );
                      },
                    ),
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
}
