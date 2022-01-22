import 'dart:async';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:calarm/controller/binding/main_binding.dart';
import 'package:calarm/service/alarm_polling_worker.dart';
import 'package:calarm/service/app_listener.dart';
import 'package:calarm/service/camera_service.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

final AndroidFlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    AndroidFlutterLocalNotificationsPlugin();
Future<void> _initForegroundTask() async {
  await FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'notification_channel_id',
      channelName: 'Foreground Notification',
      channelDescription:
          'This notification appears when the foreground service is running.',
      channelImportance: NotificationChannelImportance.HIGH,
      priority: NotificationPriority.HIGH,
      playSound: false,
      iconData: const NotificationIconData(
        resType: ResourceType.mipmap,
        resPrefix: ResourcePrefix.ic,
        name: 'launcher',
      ),
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 60000,
      allowWifiLock: true,
      autoRunOnBoot: true,
    ),
  );
}

initLocalNot() {
  flutterLocalNotificationsPlugin
      .initialize(AndroidInitializationSettings("@mipmap/ic_launcher"));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  WidgetsBinding.instance!.addObserver(LifeCycleListener());

  await Firebase.initializeApp();
  await AndroidAlarmManager.initialize();
  initLocalNot();
  _initForegroundTask();
  List<CameraDescription> cameras = await availableCameras();
  CameraDescription cameraDescription = cameras.firstWhere(
    (CameraDescription camera) =>
        camera.lensDirection == CameraLensDirection.front,
  );
  CameraService().cameraDescription = cameraDescription;
  AlarmPollingWorker.instance.createPollingWorker();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return GetMaterialApp(
      initialRoute: "/",
      title: 'Flutter Demo',
      initialBinding: MainBinding(),
      theme: ThemeData.dark(),
      home: Container(child: Center(child: CircularProgressIndicator())),
    );
  }
}
