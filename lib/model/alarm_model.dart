import 'package:cloud_firestore/cloud_firestore.dart';

class AlarmModel {
  String? documentId;
  int? alarmId;
  String? alarmName;
  Timestamp? alarmTime;
  Timestamp? alarmTimeTitle;
  String? alarmType;
  int? walkNumber;
  bool? alarmStatus;
  String? computerId;

  AlarmModel({
    this.documentId,
    this.alarmId,
    this.alarmName,
    this.alarmTimeTitle,
    this.alarmStatus,
    this.alarmType,
    this.walkNumber,
    this.alarmTime,
    this.computerId,
  });

  AlarmModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    this.documentId = doc.id;
    this.alarmName = doc["alarmName"];
    this.alarmTimeTitle = doc["alarmTimeTitle"];
    this.alarmStatus = doc["alarmStatus"];
    this.alarmId = doc["alarmId"];
    this.alarmType = doc["alarmType"];
    this.walkNumber = doc["walkNumber"];
    this.alarmTime = doc["alarmTime"];
    this.computerId = doc["computerId"];
  }
}
