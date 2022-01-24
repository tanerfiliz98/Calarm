import 'package:calarm/controller/user_controller.dart';
import 'package:calarm/model/user_model.dart';
import 'package:calarm/screen/login_signup_screen.dart';
import 'package:calarm/screen/root_screen.dart';
import 'package:calarm/service/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find<AuthController>();

  late UserController _userController;
  FirebaseAuth auth = FirebaseAuth.instance;
  late Rx<User?> _user;
  RxBool isDark = true.obs;
  AuthController() {
    _userController = UserController.instance;
    _user = Rx<User?>(auth.currentUser);
  }
  @override
  onReady() {
    super.onReady();
    _getTheme();
    _user.bindStream(auth.userChanges());
    ever(_user, _initialScreen);
  }

  _getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isDark.value = (prefs.getBool('darkTheme') ?? true);
    if (isDark.value) {
      Get.changeTheme(ThemeData.dark());
    } else {
      Get.changeTheme(ThemeData.light());
    }
  }

  _initialScreen(User? user) async {
    if (user != null) {
      _userController.user = await Database.instance.getUser(user.uid);
      Get.offAll(() => Root());
    } else {
      Get.offAll(() => LoginScreen());
    }
  }

  void registerUser(String email, String password, String name) async {
    try {
      await auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        UserModel _user =
            UserModel(id: value.user!.uid, name: name, email: email);
        if (await Database.instance.createNewUser(_user)) {
          _userController.user = _user;
        }
      });
    } catch (e) {
      Get.snackbar("About User", "User message",
          backgroundColor: Colors.redAccent,
          snackPosition: SnackPosition.BOTTOM,
          titleText: Text(
            "Account creation failed",
            style: TextStyle(color: Colors.white),
          ),
          messageText:
              Text(e.toString(), style: TextStyle(color: Colors.white)));
    }
  }

  void loginUser(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Get.snackbar("About Login", "Login message",
          backgroundColor: Colors.redAccent,
          snackPosition: SnackPosition.BOTTOM,
          titleText: Text(
            "Login failed",
            style: TextStyle(color: Colors.white),
          ),
          messageText:
              Text(e.toString(), style: TextStyle(color: Colors.white)));
    }
  }

  void logOut() async {
    _userController.clear();
    await flutterLocalNotificationsPlugin.cancelAll();
    FlutterForegroundTask.stopService();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('waterReminderDate') != null)
      await prefs.remove('waterReminderDate');
    if (prefs.getInt('waterDrink') != null) await prefs.remove('waterDrink');
    if (prefs.getBool('waterRemindercheck') != null)
      await prefs.remove('waterRemindercheck');
    await auth.signOut();
  }

  updateState() {
    update();
  }
}
