import 'package:calarm/controller/user_controller.dart';
import 'package:calarm/screen/add_family_alarm_screen.dart';
import 'package:calarm/service/database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FamilyScreen extends StatelessWidget {
  RxString famId = UserController.instance.user.familyId!.obs;
  final TextEditingController _famNameTextController = TextEditingController();
  final TextEditingController _famIdTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Aile"),
      ),
      body: SingleChildScrollView(
          child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 40),
          child: Obx(() {
            if (famId.value == "") {
              return Column(
                children: [
                  Card(
                      margin: EdgeInsets.all(20),
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextFormField(
                            controller: _famNameTextController,
                            decoration: InputDecoration(hintText: "Aile Adı"),
                          ))),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_famNameTextController.text != "") {
                        await Database.instance.createNewFamily(
                            UserController.instance.user,
                            _famNameTextController.text);
                        famId.value = UserController.instance.user.familyId!;
                      } else {
                        Get.snackbar(
                          "Aile Kurulamıyor",
                          "Aile Adı boş bırakılmamalı",
                          backgroundColor: Colors.redAccent,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                    child: Text("Aile Kur"),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Card(
                      margin: EdgeInsets.all(20),
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextFormField(
                            controller: _famIdTextController,
                            decoration: InputDecoration(hintText: "Aile Id"),
                          ))),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_famIdTextController.text != "") {
                        await Database.instance.addFamilyMember(
                            UserController.instance.user,
                            _famIdTextController.text);
                        famId.value = UserController.instance.user.familyId!;
                      } else {
                        Get.snackbar(
                          "Aile Girilemiyor",
                          "Aile id boş bırakılmamalı",
                          backgroundColor: Colors.redAccent,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                    child: Text("Aileye Gir"),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  Text(
                    "Aile Id",
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SelectableText(
                    famId.value,
                    style: TextStyle(fontSize: 25),
                    toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.bottomSheet(
                        AddFamilyAlarmScreen(),
                        isScrollControlled: true,
                        backgroundColor: ThemeData.dark().canvasColor,
                      );
                    },
                    child: Text("Aile Alarm Kur"),
                  )
                ],
              );
            }
          }),
        ),
      )),
    );
  }
}
