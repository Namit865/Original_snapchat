import 'dart:async';
import 'package:chat_app/Helper/auth_helper.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Home Screens/Screens/homescreen.dart';
import '../../Login Screens/login_screen.dart';

class splashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Timer(const Duration(milliseconds: 300), () {
      Get.to(const LoginScreen());
    });
    checkloggedinStatus();
  }

  Future<void> checkloggedinStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('email');
    final String? password = prefs.getString('password');

    if (email != null && password != null) {
      final result = await AuthHelper.authHelper
          .loginUserWithEmailAndPassword(email: email, password: password);
      if (result == null) {
        Get.offAll(() => const HomeScreen());
      } else {
        Get.offAll(() => const LoginScreen());
      }
    } else {
      Get.offAll(() => const LoginScreen());
    }
  }
}
