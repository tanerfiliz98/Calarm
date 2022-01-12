import 'dart:async';

import 'package:calarm/service/alarm_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AlarmStatus {
  static final AlarmStatus instance = AlarmStatus._privateConstructor();
  AlarmStatus._privateConstructor();

  List<int> conflict = [];
  Rx<bool> isAlarm = false.obs;

  Rx<int?> alarmId = (-1).obs;
}
