import 'package:cloud_firestore/cloud_firestore.dart';

class ComputerModel {
  String? id;
  String? name;

  ComputerModel({this.id, this.name});

  ComputerModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    id = doc.id;
    name = doc['name'];
  }
}
