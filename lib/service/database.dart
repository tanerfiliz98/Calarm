import 'dart:async';

import 'package:calarm/model/alarm_model.dart';
import 'package:calarm/model/computer_model.dart';
import 'package:calarm/model/family_model.dart';
import 'package:calarm/model/food_list_model.dart';
import 'package:calarm/model/user_model.dart';
import 'package:calarm/service/alarm_scheduler.dart';
import 'package:calarm/util/alarm_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'alarm_player.dart';

class Database {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Database._privateConstructor();
  static final Database instance = Database._privateConstructor();

  Future<bool> createNewUser(UserModel user) async {
    try {
      await _firestore.collection("users").doc(user.id).set({
        "name": user.name,
        "email": user.email,
        "familyId": "",
        "lastAlarmId": 1
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<UserModel> getUser(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection("users").doc(uid).get();
      return UserModel.fromDocumentSnapshot(doc);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<String> addAlarmBase(AlarmModel alarm, String uid) async {
    try {
      UserModel user = await getUser(uid);
      String retVal = "";
      await _firestore.collection("users").doc(uid).collection("alarms").add({
        'dateCreated': alarm.dateCreated,
        'alarmName': alarm.alarmName,
        'alarmId': user.lastAlarmId,
        'alarmType': alarm.alarmType,
        'walkNumber': alarm.walkNumber,
        'alarmStatus': true,
        'alarmTime': alarm.alarmTime,
        'computerId': alarm.computerId,
        'alarmOffPin': alarm.alarmOffPin
      }).then((value) => retVal = value.id);
      user.lastAlarmId = user.lastAlarmId! + 1;
      _firestore
          .collection("users")
          .doc(user.id)
          .update({"lastAlarmId": user.lastAlarmId});
      return retVal;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> addMeal(FoodListModel meal, UserModel user) async {
    try {
      await _firestore
          .collection("users")
          .doc(user.id)
          .collection("meals")
          .doc(meal.documentId)
          .set({
        'foodList': meal.foodList,
        'alarmName': meal.mealName,
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> updateAlarmStatus(
      bool newValue, String uid, AlarmModel alarm) async {
    try {
      if (alarm.alarmTime!.compareTo(Timestamp.now()) < 0) {
        alarm.alarmTime = Timestamp.fromDate(
            alarm.alarmTime!.toDate().add(Duration(days: 1)));
      }
      _firestore
          .collection("users")
          .doc(uid)
          .collection("alarms")
          .doc(alarm.documentId)
          .update({"alarmStatus": newValue, "alarmTime": alarm.alarmTime});
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<List<int>> getAlarmId(String uid) async {
    try {
      List<int> alarms = [];
      await _firestore
          .collection("users")
          .doc(uid)
          .collection("alarms")
          .where("alarmStatus", isEqualTo: true)
          .get()
          .then((value) => value.docs.forEach((element) {
                alarms.add(element["alarmId"]);
              }));
      return alarms;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  disableAlarm(String uid, int alarmId) {
    try {
      _firestore
          .collection("users")
          .doc(uid)
          .collection("alarms")
          .where("alarmId", isEqualTo: alarmId)
          .get()
          .then((value) => value.docs.forEach((element) {
                element.reference.update({"alarmStatus": false});
              }));
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<Stream<List<AlarmModel>>> alarmStream(String uid) async {
    return _firestore
        .collection("users")
        .doc(uid)
        .collection("alarms")
        .orderBy("alarmId", descending: true)
        .snapshots()
        .map((QuerySnapshot query) {
      List<AlarmModel> retVal = [];
      query.docs.forEach((element) {
        retVal.add(AlarmModel.fromDocumentSnapshot(element));
      });
      return retVal;
    });
  }

  Future<AlarmModel?> getAlarm(String uid, int? alarmId) async {
    try {
      AlarmModel? model;
      await _firestore
          .collection("users")
          .doc(uid)
          .collection("alarms")
          .where("alarmId", isEqualTo: alarmId)
          .limit(1)
          .get()
          .then((value) => value.docs.forEach((element) {
                model = AlarmModel.fromDocumentSnapshot(element);
              }));
      return model;
    } catch (e) {
      rethrow;
    }
  }

  StreamSubscription? alarmSub;
  void listenAlarms(String uid) {
    alarmSub = _firestore
        .collection("users")
        .doc(uid)
        .collection("alarms")
        .orderBy("dateCreated", descending: true)
        .snapshots()
        .listen((QuerySnapshot query) {
      query.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          if (change.doc["alarmStatus"] == true &&
              change.doc["alarmType"] != "bilgisayar kapatıcı") {
            AlarmScheduler().makeAlarm(
                change.doc["alarmId"], change.doc["alarmTime"].toDate());
          }
        } else if (change.type == DocumentChangeType.modified) {
          if (change.doc["alarmStatus"] == true &&
              change.doc["alarmType"] != "bilgisayar kapatıcı") {
            AlarmScheduler().makeAlarm(
                change.doc["alarmId"], change.doc["alarmTime"].toDate());
          } else if (change.doc["alarmStatus"] == false &&
              change.doc["alarmType"] != "bilgisayar kapatıcı") {
            AlarmScheduler().deleteAlarm(change.doc["alarmId"]);
          }
        }
      });
    });
  }

  void listenClose() {
    alarmSub?.cancel();
  }

  StreamSubscription? sub;
  listenAlarm(int alarmId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    sub = _firestore
        .collection("users")
        .doc(userId)
        .collection("alarms")
        .where("alarmId", isEqualTo: alarmId)
        .limit(1)
        .snapshots()
        .listen((event) {
      event.docChanges.forEach((element) {
        if (element.doc["alarmStatus"] == false) {
          AlarmStatus.instance.isAlarm.value = false;
          AlarmStatus.instance.alarmId.value = -1;
        }
      });
    });
  }

  alarmlistenerStop() async {
    await sub?.cancel();
    AlarmPlayer.instance.stop();
  }

  Future<FoodListModel> getFoodList(String uid, String alarmId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection("users")
          .doc(uid)
          .collection("meals")
          .doc(alarmId)
          .get();
      return FoodListModel.toDocumentSnapshot(doc);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ComputerModel>> getComputerList(String uid) async {
    try {
      List<ComputerModel> model = <ComputerModel>[];
      await _firestore
          .collection("users")
          .doc(uid)
          .collection("computers")
          .get()
          .then((value) => value.docs.forEach((element) {
                model.add(ComputerModel.fromDocumentSnapshot(element));
              }));

      return model;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createNewFamily(UserModel user, String familyName) async {
    try {
      List<Map<String, dynamic>> members = [];
      members.add({
        'name': user.name,
        'uid': user.id,
      });
      await _firestore
          .collection("family")
          .add({"name": familyName, "members": members}).then((value) async {
        await _firestore.collection("users").doc(user.id).update(
            {"familyId": value.id}).then((x) => user.familyId = value.id);
      });
      return true;
    } catch (e) {
      Get.snackbar("About Family", "Family message",
          backgroundColor: Colors.redAccent,
          snackPosition: SnackPosition.BOTTOM,
          titleText: Text(
            "Family create failed",
            style: TextStyle(color: Colors.white),
          ),
          messageText:
              Text(e.toString(), style: TextStyle(color: Colors.white)));
      return false;
    }
  }

  Future<bool> addFamilyMember(UserModel user, String fid) async {
    try {
      Map<String, dynamic> member = {
        'name': user.name,
        'uid': user.id,
      };
      await _firestore.collection("family").doc(fid).update({
        "members": FieldValue.arrayUnion([member])
      }).then((value) async => await _firestore
          .collection("users")
          .doc(user.id)
          .update({"familyId": fid}).then((x) => user.familyId = fid));

      return true;
    } catch (e) {
      Get.snackbar("About Family", "Family message",
          backgroundColor: Colors.redAccent,
          snackPosition: SnackPosition.BOTTOM,
          titleText: Text(
            "Family Not found failed",
            style: TextStyle(color: Colors.white),
          ),
          messageText:
              Text(e.toString(), style: TextStyle(color: Colors.white)));
      return false;
    }
  }

  Future<FamilyModel> getFamily(String fid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection("family").doc(fid).get();
      return FamilyModel.fromDocumentSnapshot(doc);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> clearConflict(String uid, List<int> conflict) async {
    for (int i = conflict.length; i > 10 && conflict.length > 10; i = i - 10) {
      await _firestore
          .collection("users")
          .doc(uid)
          .collection("alarms")
          .where("alarmId", whereIn: conflict.sublist(0, 10))
          .get()
          .then((value) => value.docs.forEach((element) {
                updateAlarmStatus(
                    false, uid, AlarmModel.fromDocumentSnapshot(element));
              }));
      conflict.removeRange(0, 10);
    }
    await _firestore
        .collection("users")
        .doc(uid)
        .collection("alarms")
        .where("alarmId", whereIn: conflict)
        .get()
        .then((value) => value.docs.forEach((element) {
              updateAlarmStatus(
                  false, uid, AlarmModel.fromDocumentSnapshot(element));
            }));
    conflict.clear();
  }
}
