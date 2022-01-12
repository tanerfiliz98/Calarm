import 'package:calarm/controller/water_reminder_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WaterRemainderScreen extends StatelessWidget {
  const WaterRemainderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(
            "İçilen Su Miktarı",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 20,
          ),
          GetX<WaterReminderController>(
            init: WaterReminderController(),
            builder: (_) => Text(_.waterDrinked.value.toString(),
                style: TextStyle(fontSize: 40)),
          ),
          SizedBox(
            height: 30,
          ),
          ElevatedButton(
              onPressed: () {
                Get.find<WaterReminderController>().waterDrink();
              },
              child: Text(
                "Su içtim",
                style: TextStyle(fontSize: 20),
              )),
          SizedBox(
            height: 40,
          ),
          GetX<WaterReminderController>(
            builder: (_) => CheckboxListTile(
              title: Text("Su Hatırlatıcı bildirmi"),
              value: _.isChecked.value,
              onChanged: (newValue) {
                _.checkedValue();
              },
              controlAffinity:
                  ListTileControlAffinity.leading, //  <-- leading Checkbox
            ),
          ),
        ],
      ),
    );
  }
}
