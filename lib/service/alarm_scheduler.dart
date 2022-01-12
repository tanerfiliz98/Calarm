import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:calarm/service/alarm_file.dart';
import 'package:calarm/service/database.dart';
import 'package:path_provider/path_provider.dart';

class AlarmScheduler {
  Future<void> makeAlarm(int id, DateTime time) async {
    await AndroidAlarmManager.oneShotAt(time, id, alarmMake, alarmClock: true);
  }

  deleteAlarm(int id) async {
    await AndroidAlarmManager.cancel(id);
  }

  clearAlarms(String uid) async {
    var list = await Database.instance.getAlarmId(uid);
    for (int x in list) {
      AndroidAlarmManager.cancel(x);
    }
  }
}

Future<void> alarmMake(int id) async {
  print("alarm çalışıyor" + id.toString());
  final dir = await getApplicationDocumentsDirectory();
  AlarmFileStorage.toFile(File(dir.path + "/$id.alarm")).writeLAlarmFile();
}
