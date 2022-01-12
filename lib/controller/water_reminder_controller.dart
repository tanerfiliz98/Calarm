import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../main.dart';

class WaterReminderController extends GetxController {
  RxBool isChecked = false.obs;
  RxInt waterDrinked = 0.obs;
  DateTime _dateTime = DateTime.now();
  WaterReminderController() {
    checkControl();
  }
  Future<void> checkControl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isChecked.value = (prefs.getBool('waterRemindercheck') ?? false);
    int date = _dateTime.day + _dateTime.month + _dateTime.year;
    if (date != (prefs.getInt('waterReminderDate') ?? 0)) {
      await prefs.setInt('waterReminderDate', date);
      await prefs.setInt('waterDrink', 0);
    }

    waterDrinked.value = (prefs.getInt('waterDrink') ?? 0);
  }

  Future<void> checkedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isChecked.value = !(prefs.getBool('waterRemindercheck') ?? false);
    await prefs.setBool('waterRemindercheck', isChecked.value);
    if (isChecked.value == true) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.high,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        ticker: "ticker",
        timeoutAfter: 30 * 60 * 1000,
      );
      tz.initializeTimeZones();
      final String currentTimeZone =
          await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));

      tz.TZDateTime _getTzTime(int hour, int min) {
        final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
        return tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, min);
      }

      String title = "Su Hatırlatıcısı";
      String body = "Suyunuzu içmeyi unutmayınız";
      for (var i = 0; i < 12; i++) {
        await flutterLocalNotificationsPlugin.zonedSchedule(i, title, body,
            _getTzTime(10 + i, 00), androidPlatformChannelSpecifics,
            androidAllowWhileIdle: true,
            matchDateTimeComponents: DateTimeComponents.time);
      }
    } else {
      await flutterLocalNotificationsPlugin.cancelAll();
    }
  }

  Future<void> waterDrink() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    waterDrinked.value = waterDrinked.value + 250;
    await prefs.setInt('waterDrink', waterDrinked.value);
  }
}
