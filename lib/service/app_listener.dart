import 'package:calarm/service/alarm_polling_worker.dart';
import 'package:flutter/material.dart';

class LifeCycleListener extends WidgetsBindingObserver {
  LifeCycleListener();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        createAlarmPollingIsolate();
        break;
      default:
        print("guncel lifecycle state: " + state.toString());
    }
  }

  void createAlarmPollingIsolate() {
    AlarmPollingWorker.instance.createPollingWorker();
  }
}
