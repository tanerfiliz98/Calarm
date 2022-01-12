import 'package:cloud_firestore/cloud_firestore.dart';

class FoodListModel {
  String? documentId;
  String? mealName;
  List<String>? foodList;

  FoodListModel(this.documentId, this.foodList, this.mealName);
  FoodListModel.toDocumentSnapshot(DocumentSnapshot doc) {
    this.documentId = doc.id;
    this.foodList = doc["foodList"]?.cast<String>();
    this.mealName = doc["alarmName"];
  }
}
