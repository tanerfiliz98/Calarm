import 'package:calarm/controller/auth_controller.dart';
import 'package:calarm/controller/step_controller.dart';
import 'package:calarm/controller/user_controller.dart';
import 'package:calarm/model/alarm_model.dart';
import 'package:calarm/model/food_list_model.dart';
import 'package:calarm/screen/camera_screen.dart';
import 'package:calarm/service/alarm_player.dart';
import 'package:calarm/service/database.dart';
import 'package:calarm/util/alarm_status.dart';
import 'package:calarm/widget/alarm_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AlarmScreen extends StatelessWidget {
  AlarmModel? alarm;
  RxString alarmNote = "".obs;
  RxList<String> _foods = <String>[].obs;
  _getAlarm() async {
    if (AlarmStatus.instance.alarmId.value != 0 && alarm == null) {
      alarm = await Database.instance.getAlarm(
          UserController.instance.user.id!, AlarmStatus.instance.alarmId.value);
      alarmNote.value = alarm!.alarmName!;
      AuthController.instance.update();
    } else if (alarm != null) {
      alarmNote.value = alarm!.alarmName!;
      AuthController.instance.update();
    }
  }

  _getFoods() async {
    FoodListModel foodListModel = await Database.instance
        .getFoodList(UserController.instance.user.id!, alarm!.documentId!);
    _foods.value = foodListModel.foodList!;
    _foods.refresh();
  }

  walkAlarmScreen() {
    return Container(
        child: Center(
      child: Column(
        children: [
          Text(
            "Gerekli Adım Sayısı",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          SizedBox(
            height: 20,
          ),
          GetX<StepController>(
            init: StepController(alarm!.walkNumber!),
            builder: (_) => Text(
              _.stepCount.value.toString(),
              style: TextStyle(fontSize: 45, fontWeight: FontWeight.w900),
            ),
          )
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    _getAlarm();
    final now = DateTime.now();
    final format = DateFormat('Hm');
    return AlarmContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(
            child: Container(
              width: 325,
              height: 325,
              decoration: ShapeDecoration(
                shape: CircleBorder(
                  side: BorderSide(
                    color: Colors.deepOrange,
                    style: BorderStyle.solid,
                    width: 5,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Icon(
                    Icons.alarm,
                    color: Colors.deepOrange,
                    size: 32,
                  ),
                  Text(
                    format.format(now),
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Obx(() {
                    if (AlarmStatus.instance.alarmId.value == 0) {
                      return Text(
                        "zamanlayıcı doldu",
                      );
                    } else {
                      return Text(alarmNote.value);
                    }
                  }),
                ],
              ),
            ),
          ),
          GetBuilder<AuthController>(builder: (_) {
            if (alarm?.alarmType == "öğün alarmı") {
              _getFoods();
              return Column(
                children: [
                  Container(
                    height: 100,
                    child: Obx(() => ListView.builder(
                          itemCount: _foods.value.length,
                          itemBuilder: (_, index) {
                            return Card(
                              margin: EdgeInsets.all(5),
                              child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(_foods.value[index])),
                            );
                          },
                        )),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: FlatButton(
                      child: Text("Alarmı Sustur"),
                      onPressed: () {
                        Database.instance.disableAlarm(
                            UserController.instance.user.id!, alarm!.alarmId!);
                      },
                    ),
                  )
                ],
              );
            } else if (alarm?.alarmType == "yüz tanıma") {
              return ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: FlatButton(
                  child: Text("Yüz Sustur"),
                  onPressed: () async {
                    var data = await Get.bottomSheet(
                      CameraScreen(),
                      isScrollControlled: true,
                      backgroundColor: ThemeData.dark().canvasColor,
                    );
                    if (data == true) {
                      Database.instance.disableAlarm(
                          UserController.instance.user.id!,
                          AlarmStatus.instance.alarmId.value!);
                    }
                  },
                ),
              );
            } else if (alarm?.alarmType == "adım atmalı") {
              return ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: FlatButton(
                  child: Text("Adim Sustur"),
                  onPressed: () async {
                    var data = await Get.bottomSheet(
                      walkAlarmScreen(),
                      backgroundColor: ThemeData.dark().canvasColor,
                    );
                    if (data == true) {
                      Database.instance.disableAlarm(
                          UserController.instance.user.id!,
                          AlarmStatus.instance.alarmId.value!);
                    }
                  },
                ),
              );
            } else {
              return ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: FlatButton(
                  child: Text("Alarmı Sustur"),
                  onPressed: () {
                    if (AlarmStatus.instance.alarmId.value != 0)
                      Database.instance.disableAlarm(
                          UserController.instance.user.id!, alarm!.alarmId!);
                    else {
                      AlarmStatus.instance.alarmId.value = -1;
                      AlarmStatus.instance.isAlarm.value = false;
                      AlarmPlayer.instance.stop();
                    }
                  },
                ),
              );
            }
          }),
        ],
      ),
    );
  }
}
