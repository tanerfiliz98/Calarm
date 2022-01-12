import 'package:cloud_firestore/cloud_firestore.dart';

class AlarmModel {
  String? documentId;
  int? alarmId;
  String? alarmName;
  Timestamp? alarmTime;
  Timestamp? dateCreated;
  String? alarmType;
  int? walkNumber;
  bool? alarmStatus;
  String? computerId;
  int? alarmOffPin;

  AlarmModel(
      {this.documentId,
      this.alarmId,
      this.alarmName,
      this.dateCreated,
      this.alarmStatus,
      this.alarmType,
      this.walkNumber,
      this.alarmTime,
      this.computerId,
      this.alarmOffPin});

  AlarmModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    this.documentId = doc.id;
    this.alarmName = doc["alarmName"];
    this.dateCreated = doc["dateCreated"];
    this.alarmStatus = doc["alarmStatus"];
    this.alarmId = doc["alarmId"];
    this.alarmType = doc["alarmType"];
    this.walkNumber = doc["walkNumber"];
    this.alarmTime = doc["alarmTime"];
    this.computerId = doc["computerId"];
    this.alarmOffPin = doc["alarmOffPin"];
  }
}
