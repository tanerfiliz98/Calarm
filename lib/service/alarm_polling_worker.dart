import 'dart:async';

import 'package:calarm/screen/root_screen.dart';
import 'package:calarm/service/alarm_player.dart';
import 'package:calarm/service/database.dart';
import 'package:calarm/util/alarm_status.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:wakelock/wakelock.dart';

class AlarmPollingWorker {
  AlarmPollingWorker._privateConstructor();
  static final AlarmPollingWorker instance =
      AlarmPollingWorker._privateConstructor();
  Timer? _timer;
  bool running = false;

  void createPollingWorker() {
    if (running) {
      print("Alarm dosyası arama hala devam ediyor");
      return;
    }
    running = true;
    poller(60).then((alarmId) {
      running = false;
      if (alarmId != null &&
          (AlarmStatus.instance.isAlarm.value == false ||
              AlarmStatus.instance.alarmId.value == 0)) {
        AlarmStatus.instance.isAlarm.value = true;
        AlarmStatus.instance.alarmId.value = int.parse(alarmId);
        Database.instance.listenAlarm(int.parse(alarmId));
        AlarmPlayer.instance.play();
        Wakelock.enable();
        _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
          if (AlarmStatus.instance.isAlarm.value == false) {
            timer.cancel();
            Database.instance.alarmlistenerStop();
            AlarmPlayer.instance.stop();
          } else {
            if (timer.tick > 590) {
              AlarmStatus.instance.isAlarm.value = false;
              Database.instance.alarmlistenerStop();
              AlarmPlayer.instance.stop();
              Database.instance.updateAlarmTime(int.parse(alarmId));
              timer.cancel();
            }
          }
        });
        cleanUpAlarmFiles();
        if (Get.currentRoute != "") Get.offAll(() => Root());
      } else if (AlarmStatus.instance.isAlarm.value == true &&
          alarmId != null) {
        AlarmStatus.instance.conflict.add(int.parse(alarmId));
        cleanUpAlarmFiles();
      }
    });
  }

  Future<String?> poller(int iterations) async {
    for (int i = 0; i < iterations; i++) {
      final foundFiles = await findFiles();
      if (foundFiles.length > 0) {
        for (var x in foundFiles) {
          AlarmStatus.instance.conflict.add(int.parse(x));
        }
        AlarmStatus.instance.conflict.removeAt(0);

        return foundFiles[0];
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }

    return null;
  }

  Future<List<String>> findFiles() async {
    final extension = ".alarm";
    final dir = await getApplicationDocumentsDirectory();
    return dir
        .list()
        .map((entry) => entry.path)
        .where((path) => path.endsWith(extension))
        .map((path) => basename(path))
        .map((path) => path.substring(0, path.length - extension.length))
        .toList();
  }

  void cleanUpAlarmFiles() async {
    print("alarm dosyaları temizleniyor");
    final dir = await getApplicationDocumentsDirectory();
    dir
        .list()
        .where((entry) => entry.path.endsWith(".alarm"))
        .forEach((entry) => entry.delete());
  }
}
