import 'package:calarm/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FamilyModel {
  String? id;
  String? name;
  RxList<UserModel> members = <UserModel>[].obs;
  FamilyModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    this.id = doc.id;
    this.name = doc['name'];
    List<dynamic> maps = doc['members'];
    maps.forEach((element) {
      members.value.add(UserModel(id: element['uid'], name: element['name']));
    });
  }
}
