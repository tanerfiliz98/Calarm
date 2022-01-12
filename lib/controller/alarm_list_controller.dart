import 'package:calarm/controller/user_controller.dart';
import 'package:calarm/model/alarm_model.dart';
import 'package:calarm/service/database.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ALarmListController extends GetxController {
  Rx<List<AlarmModel>> _alarmList = Rx<List<AlarmModel>>([]);
  List<AlarmModel> get alarms => _alarmList.value;
  var format = DateFormat('Hm');
  @override
  Future<void> onReady() async {
    super.onReady();
    String uid = UserController.instance.user.id!;
    _alarmList.bindStream(await Database.instance.alarmStream(uid));
  }
}
