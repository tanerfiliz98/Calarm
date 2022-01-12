import 'dart:isolate';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:calarm/controller/auth_controller.dart';
import 'package:calarm/controller/user_controller.dart';
import 'package:calarm/screen/add_computer_close_screen.dart';
import 'package:calarm/screen/add_food_alarm_screen.dart';
import 'package:calarm/screen/alarm_list_screen.dart';
import 'package:calarm/screen/alarm_screen.dart';
import 'package:calarm/screen/clock_screen.dart';
import 'package:calarm/screen/countdown_screen.dart';
import 'package:calarm/screen/family_screen.dart';
import 'package:calarm/screen/stopwatch_screen.dart';
import 'package:calarm/screen/water_reminder_screen.dart';
import 'package:calarm/service/alarm_scheduler.dart';
import 'package:calarm/service/database.dart';
import 'package:calarm/util/alarm_status.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';

Future<void> startCallback() async {
  FlutterForegroundTask.setTaskHandler(ForegroundTaskHandler());
}

class ForegroundTaskHandler extends TaskHandler {
  String uid = "";
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    await Firebase.initializeApp();
    uid = FirebaseAuth.instance.currentUser!.uid;
    Database.instance.listenAlarms(uid);
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {}

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    Database.instance.listenClose();
    await AlarmScheduler().clearAlarms(uid);
    await FlutterForegroundTask.clearAllData();
  }

  @override
  Future<void> onButtonPressed(String id) async {}
}

class Root extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
        child: GetX<AuthController>(
      initState: (state) async {
        if (!(await FlutterForegroundTask.isRunningService)) {
          await FlutterForegroundTask.startService(
            notificationTitle: "Calarm çalışıyor",
            notificationText: "Uygulamaya dönmek için tıklayın",
            callback: startCallback,
          );
        }
        if (AlarmStatus.instance.conflict.length > 0) {
          Database.instance.clearConflict(
              UserController.instance.user.id!, AlarmStatus.instance.conflict);
        }
      },
      builder: (_) {
        if (AlarmStatus.instance.isAlarm.value) {
          return AlarmScreen();
        } else {
          return MainScreen();
        }
      },
    ));
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _selectedIndex = 0.obs;
    var menuName = [
      "Saat",
      "Alarmlar",
      "Kronometre",
      "Zamanlayıcı",
      "Su Takibi"
    ];
    return Scaffold(
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text(
                  "Hoşgeldin \n" + (UserController.instance.user.name ?? ""),
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  )),
            ),
            ListTile(
              title: const Text('Aile'),
              onTap: () {
                Get.to(() => FamilyScreen());
              },
            ),
            ListTile(
              title: const Text('Bilgisayar Kapatıcı Kur'),
              onTap: () {
                Get.bottomSheet(
                  AddComputerCloseAlarmScreen(),
                  isScrollControlled: true,
                  backgroundColor: ThemeData.dark().canvasColor,
                );
              },
            ),
            ListTile(
              title: const Text('Öğün Alarmı Kur'),
              onTap: () {
                Get.bottomSheet(
                  AddFoodAlarmScreen(),
                  isScrollControlled: true,
                  backgroundColor: ThemeData.dark().canvasColor,
                );
              },
            ),
            ListTile(
              title: Text('Çıkış Yap'),
              onTap: () async {
                Get.find<AuthController>().logOut();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Obx(() => Text(menuName[_selectedIndex.value])),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        child: Obx(() {
          if (_selectedIndex.value == 0) {
            return ClockScreen();
          } else if (_selectedIndex.value == 1) {
            return AlarmListScreen();
          } else if (_selectedIndex.value == 2) {
            return StopwatchScreen();
          } else if (_selectedIndex.value == 3) {
            return CountdownScreen();
          } else {
            return WaterRemainderScreen();
          }
        }),
      ),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.watch_later), label: menuName[0]),
            BottomNavigationBarItem(
                icon: Icon(Icons.alarm_add), label: menuName[1]),
            BottomNavigationBarItem(
                icon: Icon(Icons.timer), label: menuName[2]),
            BottomNavigationBarItem(
                icon: Icon(Icons.hourglass_empty), label: menuName[3]),
            BottomNavigationBarItem(icon: Icon(Icons.water), label: menuName[4])
          ],
          currentIndex: _selectedIndex.value,
          selectedItemColor: Colors.lightBlue,
          unselectedItemColor: Colors.grey,
          onTap: (value) => _selectedIndex.value = value,
        );
      }),
    );
  }
}
